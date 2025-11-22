package;

import lime.app.Promise;
import lime.app.Future;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxSprite;
import flixel.util.FlxTimer;

import openfl.utils.Assets;
import lime.utils.Assets as LimeAssets;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;

import haxe.io.Path;

class LoadingState extends MusicBeatState
{
	inline static var MIN_TIME = 1.0;
	
	var target:FlxState;
	var stopMusic:Bool;
	var callbacks:MultiCallback;
	
	var logo:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft = false;
	
	public function new(target:FlxState, stopMusic:Bool)
	{
		super();
		this.target = target;
		this.stopMusic = stopMusic;
	}
	
	override function create()
	{
		super.create();
		initGraphics();
		startLoadingProcess();
	}
	
	function initGraphics()
	{
		// Logo setup
		logo = new FlxSprite(-150, -100);
		logo.frames = Paths.getSparrowAtlas('logoBumpin');
		logo.antialiasing = true;
		logo.animation.addByPrefix('bump', 'logo bumpin', 24);
		logo.animation.play('bump');
		logo.updateHitbox();

		// GF Dance setup
		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		
		add(gfDance);
		add(logo);
	}
	
	function startLoadingProcess()
	{
		initSongsManifest().onComplete(function(lib)
		{
			initializeCallbacks();
			loadRequiredAssets();
			startTransitionTimer();
		});
	}
	
	function initializeCallbacks()
	{
		callbacks = new MultiCallback(onLoadComplete);
	}
	
	function loadRequiredAssets()
	{
		var introComplete = callbacks.add("introComplete");
		
		// Load audio assets
		loadSongAssets();
		
		// Load library assets
		loadLibraryAssets();
		
		// Set timer for minimum loading time
		new FlxTimer().start(MIN_TIME, function(_) introComplete());
	}
	
	function loadSongAssets()
	{
		checkLoadSong(getSongPath());
		if (PlayState.SONG.needsVoices)
			checkLoadSong(getVocalPath());
	}
	
	function loadLibraryAssets()
	{
		checkLibrary("shared");
		
		var weekLibrary = (PlayState.storyWeek > 0) ? "week" + PlayState.storyWeek : "tutorial";
		checkLibrary(weekLibrary);
	}
	
	function startTransitionTimer()
	{
		var fadeTime = 0.5;
		FlxG.camera.fade(FlxG.camera.bgColor, fadeTime, true);
	}
	
	function checkLoadSong(path:String)
	{
		if (!Assets.cache.hasSound(path))
		{
			var callback = callbacks.add("song:" + path);
			Assets.loadSound(path).onComplete(function(_) callback());
		}
	}
	
	function checkLibrary(library:String)
	{
		if (Assets.getLibrary(library) == null)
		{
			@:privateAccess
			if (!LimeAssets.libraryPaths.exists(library))
			{
				trace('Missing library: $library');
				return;
			}
			
			var callback = callbacks.add("library:" + library);
			Assets.loadLibrary(library).onComplete(function(_) callback());
		}
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		updateAnimations();
	}
	
	function updateAnimations()
	{
		logo.animation.play('bump', true);
		
		danceLeft = !danceLeft;
		gfDance.animation.play(danceLeft ? 'danceRight' : 'danceLeft');
	}
	
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		
		#if debug
		if (FlxG.keys.justPressed.SPACE)
		{
			var fired = callbacks.getFired();
			var unfired = callbacks.getUnfired();
			trace('fired: ${fired.length} unfired: ${unfired.length}');
		}
		#end
	}
	
	function onLoadComplete()
	{
		cleanupAudio();
		switchToTargetState();
	}
	
	function cleanupAudio()
	{
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
	}
	
	function switchToTargetState()
	{
		FlxG.switchState(() -> target);
	}
	
	static function getSongPath():String
	{
		return Paths.inst(PlayState.SONG.song);
	}
	
	static function getVocalPath():String
	{
		return Paths.voices(PlayState.SONG.song);
	}
	
	inline static public function loadAndSwitchState(target:FlxState, stopMusic = false)
	{
		FlxG.switchState(() -> getNextState(target, stopMusic));
	}
	
	static function getNextState(target:FlxState, stopMusic = false):FlxState
	{
		Paths.setCurrentLevel("week" + PlayState.storyWeek);
		
		#if NO_PRELOAD_ALL
		if (!areRequiredAssetsLoaded())
			return new LoadingState(target, stopMusic);
		#end
		
		if (stopMusic && FlxG.sound.music != null)
			FlxG.sound.music.stop();
		
		return target;
	}
	
	#if NO_PRELOAD_ALL
	static function areRequiredAssetsLoaded():Bool
	{
		return isSoundLoaded(getSongPath())
			&& (!PlayState.SONG.needsVoices || isSoundLoaded(getVocalPath()))
			&& isLibraryLoaded("shared");
	}
	
	static function isSoundLoaded(path:String):Bool
	{
		return Assets.cache.hasSound(path);
	}
	
	static function isLibraryLoaded(library:String):Bool
	{
		return Assets.getLibrary(library) != null;
	}
	#end
	
	override function destroy()
	{
		super.destroy();
		callbacks = null;
	}
	
	static function initSongsManifest():Future<AssetLibrary>
	{
		var id = "songs";
		var promise = new Promise<AssetLibrary>();

		var library = LimeAssets.getLibrary(id);
		if (library != null)
			return Future.withValue(library);

		return loadSongsManifest(id);
	}
	
	static function loadSongsManifest(id:String):Future<AssetLibrary>
	{
		var promise = new Promise<AssetLibrary>();
		var pathInfo = getLibraryPathInfo(id);

		AssetManifest.loadFromFile(pathInfo.path, pathInfo.rootPath).onComplete(function(manifest)
		{
			if (manifest == null)
			{
				promise.error('Cannot parse asset manifest for library "$id"');
				return;
			}

			var library = AssetLibrary.fromManifest(manifest);
			if (library == null)
			{
				promise.error('Cannot open library "$id"');
			}
			else
			{
				registerLibrary(id, library);
				promise.completeWith(Future.withValue(library));
			}
		}).onError(function(_)
		{
			promise.error('There is no asset library with an ID of "$id"');
		});

		return promise.future;
	}
	
	static function getLibraryPathInfo(id:String):{path:String, rootPath:String}
	{
		@:privateAccess
		var libraryPaths = LimeAssets.libraryPaths;
		
		if (libraryPaths.exists(id))
		{
			var path = libraryPaths[id];
			return {path: path, rootPath: Path.directory(path)};
		}
		else
		{
			var path = id;
			var rootPath = StringTools.endsWith(path, ".bundle") ? path : Path.directory(path);
			if (StringTools.endsWith(path, ".bundle"))
				path += "/library.json";
				
			@:privateAccess
			path = LimeAssets.__cacheBreak(path);
			
			return {path: path, rootPath: rootPath};
		}
	}
	
	static function registerLibrary(id:String, library:AssetLibrary)
	{
		@:privateAccess
		LimeAssets.libraries.set(id, library);
		library.onChange.add(LimeAssets.onChange.dispatch);
	}
}

class MultiCallback
{
	public var callback:Void->Void;
	public var logId:String;
	public var length(default, null) = 0;
	public var numRemaining(default, null) = 0;
	
	var unfired = new Map<String, Void->Void>();
	var fired:Array<String> = [];
	
	public function new(callback:Void->Void, logId:String = null)
	{
		this.callback = callback;
		this.logId = logId;
	}
	
	public function add(id = "untitled"):Void->Void
	{
		var callbackId = '$length:$id';
		length++;
		numRemaining++;
		
		var func:Void->Void = function()
		{
			if (unfired.exists(callbackId))
			{
				unfired.remove(callbackId);
				fired.push(callbackId);
				numRemaining--;
				
				log('fired $callbackId, $numRemaining remaining');
				
				if (numRemaining == 0)
				{
					log('all callbacks fired');
					callback();
				}
			}
			else
			{
				log('already fired $callbackId');
			}
		}
		
		unfired[callbackId] = func;
		return func;
	}
	
	inline function log(msg:String):Void
	{
		if (logId != null)
			trace('$logId: $msg');
	}
	
	public function getFired():Array<String>
	{
		return fired.copy();
	}
	
	public function getUnfired():Array<String>
	{
		return [for (id in unfired.keys()) id];
	}
}