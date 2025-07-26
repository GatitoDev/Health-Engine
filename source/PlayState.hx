package;

import data.Sprite;
import flixel.group.FlxSpriteGroup;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.sound.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;

#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;
	public static var songName:FlxText;

	public static var rep:Replay;
	public static var loadRep:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var halloweenLevel:Bool = false;

	var songLength:Float = 0;

	private var vocals:FlxSound;

	var stage:StageBuilder;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	private var SplashNote:NoteSplash;
	var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
	var noteSplashOp:Bool;

	public var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	public static var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;


	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	public var uiGroup:FlxSpriteGroup;
	
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	public static var offsetTesting:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var fc:Bool = true;

	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;
	var funneEffect:FlxSprite;
	var inCutscene:Bool = false;
	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;
	
	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;
	
	// Per song additive offset
	public static var songOffset:Float = 0;
	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Float> = [];

	private var executeModchart = false;

	// API stuff
	
	public function addObject(object:FlxBasic) { add(object); }
	public function removeObject(object:FlxBasic) { remove(object); }


	override public function create()
	{
		instance = this;
		//if (FlxG.save.data.fpsCap > 290) (cast (Lib.current.getChildAt(0), Main)).setFPSCap(800);
		if (FlxG.sound.music != null) FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		repPresses = 0;
		repReleases = 0;

		#if windows executeModchart = FileSystem.exists(Paths.lua(PlayState.SONG.song.toLowerCase()  + "/modchart")); #end
		#if !cpp executeModchart = false; #end
		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(PlayState.SONG.song.toLowerCase() + "/modchart"));

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		FlxG.cameras.setDefaultDrawTarget(camera, true);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null) SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + Conductor.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: ' + Conductor.timeScale + '\nBotPlay : ' + FlxG.save.data.botplay);

		//dialogue shit
		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
			case 'bopeebo':
				dialogue = [
					'HEY!',
					"You think you can just sing\nwith my daughter like that?",
					"If you want to date her...",
					"You're going to have to go \nthrough ME first!"
				];
			case 'fresh':
				dialogue = ["Not too shabby boy.", ""];
			case 'dad battle':
				dialogue = [
					"gah you think you're hot stuff?",
					"If you can beat me here...",
					"Only then I will even CONSIDER letting you\ndate my daughter!"
				];
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		add(stage = new StageBuilder());
		var gfVersion:String = 'gf';
		add(gf = new Character(stage.gfPosition[0], stage.gfPosition[1], gfVersion));
		gf.scrollFactor.set(0.95, 0.95);
		add(boyfriend = new Boyfriend(stage.bfPosition[0], stage.bfPosition[1], SONG.player1));
		add(dad = new Character(stage.dadPosition[0], stage.dadPosition[1], SONG.player2));

		switch (SONG.gfVersion) {
			case 'gf-car': gfVersion = 'gf-car';
			case 'gf-christmas': gfVersion = 'gf-christmas';
			case 'gf-pixel': gfVersion = 'gf-pixel';
			case 'gf': gfVersion = 'gf';
			default: gfVersion = 'gf';
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode) {
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky": dad.y += 200;
			case "monster": dad.y += 100;
			case 'monster-christmas': dad.y += 130;
			case 'dad': camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas': dad.x -= 500;
		}

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses',repPresses);
			FlxG.watch.addQuick('rep releases',repReleases);
			
			FlxG.save.data.botplay = true;
			FlxG.save.data.scrollSpeed = rep.replay.noteSpeed;
			FlxG.save.data.downscroll = rep.replay.isDownscroll;
			// FlxG.watch.addQuick('Queued',inputsQueued);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		add(uiGroup = new FlxSpriteGroup());

		Conductor.songPosition = -5000;
		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		if (FlxG.save.data.downscroll) strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);
		playerStrums = new FlxTypedGroup<FlxSprite>();

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var sploosh:NoteSplash = new NoteSplash(100, 100, 0);
		sploosh.alpha = 0.6;
		grpNoteSplashes.add(sploosh);
		noteSplashOp = true;
		add(grpNoteSplashes);
		grpNoteSplashes.cameras = [camHUD];

		generateSong(SONG.song);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		if (prevCamFollow != null) {
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / KadeEngineData.getFPSCap()));
		FlxG.camera.zoom = stage.defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;
		FlxG.camera.snapToTarget();

		if (FlxG.save.data.songPosition) {
			songPosBG = new FlxSprite(0, FlxG.save.data.downscroll ? FlxG.height * 0.9 + 45 : 10).loadGraphic(Paths.image('healthBar'));
			songPosBG.screenCenter(X).scrollFactor.set();
			add(songPosBG);
				
			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
	
			songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
			if (FlxG.save.data.downscroll) songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);
		}

		function createTextLabel(text:String, x:Float, y:Float):FlxText {
			var label = new FlxText(x, y, 0, text, 20);
			label.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			label.scrollFactor.set();
			return label;
		}

		healthBarBG = new FlxSprite(0, FlxG.save.data.downscroll ? 50 : FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X).scrollFactor.set();
		uiGroup.add(healthBarBG);
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2).createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.scrollFactor.set();
		uiGroup.add(healthBar);
		iconP1 = new HealthIcon(SONG.player1, true);
		iconP2 = new HealthIcon(SONG.player2, false);
		for (icon in [iconP1, iconP2]) {
			icon.y = healthBar.y - (icon.height / 2);
			uiGroup.add(icon);
		}

		scoreTxt = new FlxText(0, healthBarBG.y + 30, FlxG.width, "", 22).setFormat(Paths.font("vcr.ttf"), 22, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.screenCenter(X).scrollFactor.set();
		uiGroup.add(scoreTxt);
		replayTxt = createTextLabel("REPLAY", healthBarBG.x + healthBarBG.width/2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100));
		if (loadRep) add(replayTxt);
		botPlayState = createTextLabel("BOTPLAY", healthBarBG.x + healthBarBG.width/2 - 75, healthBarBG.y + (FlxG.save.data.downscroll ? 100 : -100));
		if (FlxG.save.data.botplay && !loadRep) add(botPlayState);

		uiGroup.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		doof.cameras = [camHUD];
		if (FlxG.save.data.songPosition) {
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}
		if (loadRep) replayTxt.cameras = [camHUD];
		startingSong = true;
		
		if (isStoryMode) {
			switch (curSong.toLowerCase()) {
				default: startCountdown();
			}
		} else {
			switch (curSong.toLowerCase()) {
				default: startCountdown();
			}
		}
		if (!loadRep) rep = new Replay("na");
		super.create();
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0) tmr.reset(0.3);
			else {
				if (dialogueBox != null) {
					inCutscene = true;
					add(dialogueBox);
				} else startCountdown();
				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;

	var luaWiggles:Array<WiggleEffect> = [];

	#if windows
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		inCutscene = false;

		generateStaticArrows(0);
		generateStaticArrows(1);


		#if windows
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start',[PlayState.SONG.song]);
		}
		#end

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			dad.dance();
			gf.dance();
			boyfriend.playAnim('idle');

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;


	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
		{
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		}

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songName);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (FlxG.save.data.downscroll)
				songPosBG.y = FlxG.height * 0.9 + 45; 
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength - 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			var songName = new FlxText(songPosBG.x + (songPosBG.width / 2) - 20,songPosBG.y,0,SONG.song, 16);
			if (FlxG.save.data.downscroll)
				songName.y -= 3;
			songName.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
			songName.scrollFactor.set();
			add(songName);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songName.cameras = [camHUD];
		}
	}

	private function generateSong(dataPath:String):Void {
		Conductor.changeBPM(SONG.bpm);
		curSong = SONG.song;
		
		vocals = new FlxSound();
		if (SONG.needsVoices) vocals.loadEmbedded(Paths.voices(PlayState.SONG.song));
		FlxG.sound.list.add(vocals);
		
		notes = new FlxTypedGroup<Note>();
		add(notes);
		
		var noteData:Array<SwagSection> = SONG.notes;
		for (section in noteData) {
			var mustHit = section.mustHitSection;
			
			for (songNote in section.sectionNotes) {
				var strumTime:Float = songNote[0] + FlxG.save.data.offset;
				if (strumTime < 0) strumTime = 0;
				
				var noteData:Int = Std.int(songNote[1] % 4);
				var isPlayerNote:Bool = mustHit ? songNote[1] < 4 : songNote[1] > 3;
				var lastNote = unspawnNotes.length > 0 ? unspawnNotes[unspawnNotes.length - 1] : null;
				
				var note:Note = new Note(strumTime, noteData, lastNote);
				note.sustainLength = songNote[2];
				note.scrollFactor.set(0, 0);
				note.mustPress = isPlayerNote;
				note.x += isPlayerNote ? FlxG.width / 2 : 0;
				unspawnNotes.push(note);
				
				var susLength:Int = Math.floor(note.sustainLength / Conductor.stepCrochet);
				for (susNote in 0...susLength) {
					lastNote = unspawnNotes[unspawnNotes.length - 1];
					var sustain:Note = new Note(strumTime + (Conductor.stepCrochet * (susNote + 1)), noteData, lastNote, true);
					sustain.scrollFactor.set();
					sustain.mustPress = isPlayerNote;
					sustain.x += isPlayerNote ? FlxG.width / 2 : 0;
					unspawnNotes.push(sustain);
				}
			}
		}
		unspawnNotes.sort(sortByShit);
		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int { return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime); }

	private function generateStaticArrows(player:Int):Void {
		final directions:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
		final prefixes:Array<String> = ['left', 'down', 'up', 'right'];
		final colors:Array<String> = ['green', 'red', 'blue', 'purple'];
		final colorFrames:Array<Int> = [6, 7, 5, 4];
		final arrowColors:Array<String> = ['arrowUP', 'arrowRIGHT', 'arrowDOWN', 'arrowLEFT'];

		for (i in 0...4) {
			final xPos:Float = Note.swagWidth * i + 50 + (FlxG.width / 2 * player);
			final isPixel:Bool = SONG.noteStyle == 'pixel';
			final anims = [
				{name: 'static', prefix: isPixel ? null : 'arrow${directions[i]}', frames: isPixel ? [i] : null, frameRate: 0, loop: false},
				{name: 'pressed', prefix: isPixel ? null : '${prefixes[i]} press', frames: isPixel ? [i + 4, i + 8] : null, frameRate: isPixel ? 12 : 24, loop: false},
				{name: 'confirm', prefix: isPixel ? null : '${prefixes[i]} confirm', frames: isPixel ? [i + 12, i + 16] : null,frameRate: isPixel ? (i == 2 ? 12 : 24) : 24, loop: false}
			];
			final babyArrow:Sprite = Sprite.create(isPixel ? 'weeb/pixelUI/arrows-pixels' : 'NOTE_assets', xPos, strumLine.y,
			 1, 1, { scale: isPixel ? daPixelZoom : 0.7, antialiasing: !isPixel}, { atlas: !isPixel, animations: anims, defaultAnim: 'static'});
			for (j in 0...4) isPixel ? babyArrow.animation.add(colors[j], [colorFrames[j]]) : babyArrow.animation.addByPrefix(colors[j], arrowColors[j]);

			if (!isStoryMode) {
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;
			(player == 1 ? playerStrums : strumLineNotes).add(babyArrow);
			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void { FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut}); }

	override function openSubState(SubState:FlxSubState) {
		if (paused) {
			if (FlxG.sound.music != null) {
				FlxG.sound.music.pause();
				vocals.pause();
			}
			if (!startTimer.finished) startTimer.active = false;
		}
		super.openSubState(SubState);
	}

	override function closeSubState() {
		if (paused) {
			if (FlxG.sound.music != null && !startingSong) resyncVocals();
			if (!startTimer.finished) startTimer.active = true;
			paused = false;
		}
		super.closeSubState();
	}
	

	function resyncVocals():Void {
		vocals.pause();
		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	override public function update(elapsed:Float)
	{
		if(!inCutscene && !paused) FlxG.camera.followLerp = 0.04 * stage.cameraSpeed;
		else FlxG.camera.followLerp = 0;
		#if !debug perfectMode = false; #end

		if (FlxG.save.data.botplay && FlxG.keys.justPressed.ONE) camHUD.visible = !camHUD.visible;

		#if windows
		if (executeModchart && luaModchart != null && songStarted) {
			luaModchart.setVar('songPos',Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom',FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (i in luaWiggles) {
				trace('wiggle le gaming');
				i.update(elapsed);
			}
			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle','float');

			if (luaModchart.getVar("showOnlyStrums",'bool')) uiGroup.visible = false;
			else uiGroup.visible = true;

			var p1 = luaModchart.getVar("strumLine1Visible",'bool');
			var p2 = luaModchart.getVar("strumLine2Visible",'bool');

			for (i in 0...4) {
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length) playerStrums.members[i].visible = p2;
			}
		}
		#end

		var balls:Int = notesHitArray.length-1;
		while (balls >= 0) {
			var cock:Date = notesHitArray[balls];
			if (cock != null && cock.getTime() + 1000 < Date.now().getTime()) notesHitArray.remove(cock);
			else balls = 0;
			balls--;
		}
		nps = notesHitArray.length;
		if (nps > maxNPS) maxNPS = nps;

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore,songScoreDef,nps,maxNPS,accuracy);
		if (FlxG.keys.justPressed.ENTER && startedCountdown && canPause) {
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN) {

			FlxG.switchState(() -> new ChartingState());
			#if windows if (luaModchart != null) {
				luaModchart.die();
				luaModchart = null;
			} #end
		}

		updateIcons(elapsed, healthBar, health);

		if (FlxG.keys.justPressed.EIGHT) {
			FlxG.switchState(() -> new AnimationDebug(SONG.player2));
			#if windows if (luaModchart != null) {
				luaModchart.die();
				luaModchart = null;
			} #end
		}

		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0) startSong();
			}
		} else {
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = Conductor.songPosition;
			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;
				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null) {
			#if windows if (luaModchart != null) luaModchart.setVar("mustHit",PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection); #end
			updateCamFollow();
		}

		if (camZooming) {
			FlxG.camera.zoom = FlxMath.lerp(stage.defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (health <= 0) {
			boyfriend.stunned = true;
			persistentUpdate = false;
			persistentDraw = false;
			paused = true;
			vocals.stop();
			FlxG.sound.music.stop();
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (unspawnNotes[0] != null) {
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500) {
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic) {
			notes.forEachAlive(function(daNote:Note) {
				daNote.active = daNote.visible = !daNote.tooLate;
				
				if (!daNote.modifiedByLua) {
					var scrollSpeed:Float = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? SONG.speed : FlxG.save.data.scrollSpeed, 2);
					var noteProgress:Float = 0.45 * (Conductor.songPosition - daNote.strumTime) * scrollSpeed;
					
					var strum:FlxSprite = daNote.mustPress ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))] 
					 : strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))];
					
					daNote.y = FlxG.save.data.downscroll ? strum.y + noteProgress : strum.y - noteProgress;
					
					if (daNote.isSustainNote) {
						var clipRect:FlxRect = null;
						var shouldClip:Bool = FlxG.save.data.botplay || (!daNote.mustPress || daNote.wasGoodHit || 
						 (daNote.prevNote != null && daNote.prevNote.wasGoodHit && !daNote.canBeHit));
						
						if (FlxG.save.data.downscroll) {
							daNote.y += daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null ? 
							 daNote.prevNote.height : daNote.height / 2;
							
							if (shouldClip && daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2)) {
								clipRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								clipRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
								clipRect.y = daNote.frameHeight - clipRect.height;
							}
						} else {
							daNote.y -= daNote.height / 2;
							if (shouldClip && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2)) {
								clipRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								clipRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
								clipRect.height -= clipRect.y;
								if (daNote.mustPress) songScore += Std.int(250.0 * elapsed);
							}
						}
						
						if (clipRect != null) daNote.clipRect = clipRect;
					}
				}
				
				if (!daNote.mustPress && daNote.wasGoodHit) {
					camZooming = SONG.song != 'Tutorial';
					
					var altAnim:String = (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) ? '-alt' : '';
					
					switch (Math.abs(daNote.noteData)) {
						case 0: dad.playAnim('singLEFT' + altAnim, true);
						case 1: dad.playAnim('singDOWN' + altAnim, true);
						case 2: dad.playAnim('singUP' + altAnim, true);
						case 3: dad.playAnim('singRIGHT' + altAnim, true);
					}
					
					var strum:FlxSprite = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))];
					strum.animation.play('confirm', true);
					strum.centerOffsets();
					strum.offset.x -= 13;
					strum.offset.y -= 13;
					
					new FlxTimer().start(0.1, function(tmr:FlxTimer) {
						strum.animation.play('static');
						strum.centerOffsets();
					});
					
					#if windows if (luaModchart != null) luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]); #end
					
					dad.holdTimer = 0;
					if (SONG.needsVoices) vocals.volume = 1;
					
					notes.remove(daNote, true);
					daNote.destroy();
				}
				
				var targetStrum:FlxSprite = daNote.mustPress ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))] 
				 : strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))];
				
				if (!daNote.modifiedByLua) {
					daNote.visible = targetStrum.visible;
					daNote.x = targetStrum.x;
					if (!daNote.isSustainNote) daNote.angle = targetStrum.angle;
					daNote.alpha = targetStrum.alpha;
				}
				
				if (daNote.isSustainNote) daNote.x += daNote.width / 2 + 17;
				
				if (daNote.mustPress && daNote.tooLate) {
					if (daNote.isSustainNote && daNote.wasGoodHit) {
						notes.remove(daNote, true);
						daNote.destroy();
					} else {
						health -= 0.075;
						vocals.volume = 0;
						if (theFunne) noteMiss(daNote.noteData, daNote);
					}
					
					notes.remove(daNote, true);
					daNote.destroy();
				}
			});
		}
		if (!inCutscene) keyShit();
		#if debug if (FlxG.keys.justPressed.ONE) endSong(); #end
	}

	function endSong():Void {
		if (!loadRep) rep.SaveReplay(saveNotes);
		else {
			FlxG.save.data.botplay = false;
			FlxG.save.data.scrollSpeed = 1;
			FlxG.save.data.downscroll = false;
		}

		//if (FlxG.save.data.fpsCap > 290) (cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if windows if (luaModchart != null) {
			luaModchart.die();
			luaModchart = null;
		} #end

		canPause = false;
		FlxG.sound.music.volume = vocals.volume = 0;
		
		if (SONG.validScore) #if !switch Highscore.saveScore(SONG.song, Math.round(songScore), storyDifficulty); #end

		if (offsetTesting) {
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			FlxG.save.data.offset = offsetTest;
			return;
		}

		if (isStoryMode) {
			campaignScore += Math.round(songScore);
			storyPlaylist.shift();

			if (storyPlaylist.length == 0) {
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
				
				#if windows if (luaModchart != null) {
					luaModchart.die();
					luaModchart = null;
				} #end

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;
				
				if (SONG.validScore) Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				
				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
				FlxG.switchState(() -> new StoryMenuState());
			} else {
				var difficulty:String = switch(storyDifficulty) {
					case 0: '-easy';
					case 2: '-hard';
					case _: '';
				}

				trace('LOADING NEXT SONG: ${PlayState.storyPlaylist[0].toLowerCase()}$difficulty');

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;
				prevCamFollow = camFollow;

				PlayState.SONG = Song.loadFromJson('${PlayState.storyPlaylist[0].toLowerCase()}$difficulty', PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();
				LoadingState.loadAndSwitchState(new PlayState());
			}
		} else {
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(() -> new FreeplayState());
		}
	}

	function updateIcons(elapsed:Float, healthBar:FlxBar, health:Float) {
		inline function updateIcon(icon:FlxSprite, scaleMult:Float) {
			icon.scale.set(scaleMult, scaleMult);
			icon.updateHitbox();
		}
		
		var lerpFactor:Float = Math.exp(-elapsed * 9);
		updateIcon(iconP1, FlxMath.lerp(1, iconP1.scale.x, lerpFactor));
		updateIcon(iconP2, FlxMath.lerp(1, iconP2.scale.x, lerpFactor));

		var healthPercent:Float = FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01;
		var baseX:Float = healthBar.x + (healthBar.width * healthPercent);
		iconP1.x = baseX - 26;
		iconP2.x = baseX - (iconP2.width - 26);

		health = Math.min(health, 2);
		iconP1.animation.curAnim.curFrame = (healthBar.percent < 20) ? 1 : 0;
		iconP2.animation.curAnim.curFrame = (healthBar.percent > 80) ? 1 : 0;
	}
	
	function updateCamFollow():Void {
		var section:SwagSection = PlayState.SONG.notes[Std.int(curStep / 16)];
		var target:Character = section.mustHitSection ? boyfriend : dad;
		var offsetIndex:Int = section.mustHitSection ? 0 : 1;
		var stageOffsets:Array<Float> = stage.cameraOffsets[offsetIndex];
		var baseOffset:FlxPoint = new FlxPoint(section.mustHitSection ? -100 : 150, -100);
		baseOffset.x += stageOffsets[0];
		baseOffset.y += stageOffsets[1];
		var event:String = section.mustHitSection ? 'playerOneTurn' : 'playerTwoTurn';
		
		if (camFollow.x != target.getMidpoint().x + baseOffset.x) {
			var modOffsetX:Int = 0, modOffsetY:Int = 0;
			#if windows  if (luaModchart != null) {
				modOffsetX = luaModchart.getVar("followXOffset", "float");
				modOffsetY = luaModchart.getVar("followYOffset", "float");
				luaModchart.executeState(event, []);
			}  #end
			camFollow.setPosition(
				target.getMidpoint().x + baseOffset.x + modOffsetX,
				target.getMidpoint().y + baseOffset.y + modOffsetY
			);
		}
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	private function popUpScore(daNote:Note):Void {
		var noteDiff:Float = Math.abs(Conductor.songPosition - daNote.strumTime);
		var wife:Float = EtternaFunctions.wife3(noteDiff, Conductor.timeScale);
		vocals.volume = 1;

		var coolText:FlxText = new FlxText(0, 0, 0, Std.string(combo), 32);
		coolText.screenCenter().x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;
		var daRating:String = daNote.rating;

		if (FlxG.save.data.accuracyMod == 1) totalNotesHit += wife;

		switch (daRating) {
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				health -= 0.2;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.25;
			
			case 'bad':
				score = 0;
				health -= 0.06;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.50;
			
			case 'good':
				score = 200;
				ss = false;
				goods++;
				if (health < 2) health += 0.04;
				if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 0.75;
			
			case 'sick':
				if (health < 2) health += 0.1;
				if (FlxG.save.data.accuracyMod == 0) totalNotesHit += 1;
				sicks++;
				if (noteSplashOp) {
					var recycledNote:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
					recycledNote.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
					grpNoteSplashes.add(recycledNote);
				}
		}

		if (daRating != 'shit' || daRating != 'bad') {
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			var pixelShitPart1:String = curStage.startsWith('school') ? 'weeb/pixelUI/' : '';
			var pixelShitPart2:String = curStage.startsWith('school') ? '-pixel' : '';

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.y -= 50;
			rating.x = FlxG.save.data.changedHit ? FlxG.save.data.changedHitX : coolText.x - 125;
			rating.y = FlxG.save.data.changedHit ? FlxG.save.data.changedHitY : rating.y;
				
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
				
			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;
			comboSpr.velocity.x += FlxG.random.int(1, 10);
				
			if (!FlxG.save.data.botplay) add(rating);

			var scale:Float = curStage.startsWith('school') ? daPixelZoom * 0.7 : 0.7;
			rating.setGraphicSize(Std.int(rating.width * scale));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * scale));
			rating.antialiasing = comboSpr.antialiasing = !curStage.startsWith('school');
				
			comboSpr.updateHitbox();
			rating.updateHitbox();
			comboSpr.cameras = rating.cameras = [camHUD];

			var stringArray:Array<String> = Std.string(combo).split("");
			for (i in 0...stringArray.length) {
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num${stringArray[i]}' + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * i);
				numScore.x -= ((Std.string(combo).length - 1) * 22);
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];
					
				if (!curStage.startsWith('school')) {
					numScore.antialiasing = true;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				} else numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				numScore.updateHitbox();
					
				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);
				
				if (combo >= 10 || combo == 0) add(numScore);
				
				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: tween -> numScore.destroy(),
					startDelay: Conductor.crochet * 0.002
				});
			}
			FlxTween.tween(rating, {alpha: 0}, 0.2, {startDelay: Conductor.crochet * 0.001});
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: tween -> {
					coolText.destroy();
					comboSpr.destroy();
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});
			curSection++;
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;	

	private function keyShit():Void {
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];

		if (FlxG.save.data.botplay) {
			holdArray = [false, false, false, false];
			pressArray = releaseArray = holdArray;
		}

		if (holdArray.contains(true) && generatedMusic) {
			notes.forEachAlive(daNote -> {
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData]) goodNoteHit(daNote);
			});
		}

		if (pressArray.contains(true) && generatedMusic) {
			boyfriend.holdTimer = 0;
			var possibleNotes:Array<Note> = [];
			var directionList:Array<Int> = [];
			var dumbNotes:Array<Note> = [];

			notes.forEachAlive(daNote -> {
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
					if (directionList.contains(daNote.noteData)) {
						for (coolNote in possibleNotes) {
							if (coolNote.noteData == daNote.noteData) {
								if (Math.abs(daNote.strumTime - coolNote.strumTime) < 10) {
									dumbNotes.push(daNote);
									break;
								} else if (daNote.strumTime < coolNote.strumTime) {
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
					} else {
						possibleNotes.push(daNote);
						directionList.push(daNote.noteData);
					}
				}
			});

			for (note in dumbNotes) {
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}

			possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			var dontCheck = false;
			for (i in 0...pressArray.length) {
				if (pressArray[i] && !directionList.contains(i)) {
					dontCheck = true;
					break;
				}
			}

			if (perfectMode) goodNoteHit(possibleNotes[0]);
			else if (possibleNotes.length > 0 && !dontCheck) {
				if (!FlxG.save.data.ghost) for (i in 0...pressArray.length) if (pressArray[i] && !directionList.contains(i)) noteMiss(i, null);
				for (coolNote in possibleNotes) {
					if (pressArray[coolNote.noteData]) {
						if (mashViolations != 0) mashViolations--;
						goodNoteHit(coolNote);
					}
				}
			} 
			else if (!FlxG.save.data.ghost) for (i in 0...pressArray.length) if (pressArray[i]) noteMiss(i, null);
			if (dontCheck && possibleNotes.length > 0 && FlxG.save.data.ghost && !FlxG.save.data.botplay) {
				if (mashViolations > 4) noteMiss(0, null); else mashViolations++;
			}
		}

		notes.forEachAlive(daNote -> {
			var downscroll = FlxG.save.data.downscroll;
			if ((downscroll && daNote.y > strumLine.y) || (!downscroll && daNote.y < strumLine.y)) {
				if (FlxG.save.data.botplay && (daNote.canBeHit || daNote.tooLate) && daNote.mustPress) {
					if (loadRep && rep.replay.songNotes.contains(HelperFunctions.truncateFloat(daNote.strumTime, 2))) {
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
					} else if (!loadRep) {
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
					}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || FlxG.save.data.botplay)) {
			if (boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
				boyfriend.playAnim('idle');
		}

		playerStrums.forEach(spr -> {
			if (pressArray[spr.ID] && spr.animation.curAnim.name != 'confirm') spr.animation.play('pressed');
			if (!holdArray[spr.ID]) spr.animation.play('static');
			spr.centerOffsets();
			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school')) {
				spr.offset.x -= 13;
				spr.offset.y -= 13;
				spr.alpha = 1;
			}
		});
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void {
		if (boyfriend.stunned) return;
		
		health -= 0.04;
		if (combo > 5 && gf.animOffsets.exists('sad')) gf.playAnim('sad');
		
		combo = 0;
		misses++;
		songScore -= 10;
		
		if (FlxG.save.data.accuracyMod == 1) totalNotesHit -= 1;
		
		FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
		boyfriend.playAnim(['singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'][direction], true);

		#if windows
		if (luaModchart != null) luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
		#end

		updateAccuracy();
	}

	function updateAccuracy() {
		totalPlayed += 1;
		accuracy = Math.max(0,totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}


	function getKeyPresses(note:Note):Int {
		var possibleNotes:Array<Note> = [];
		notes.forEachAlive(function(daNote:Note) {
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate) {
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1) return possibleNotes.length + 1;
		return possibleNotes.length;
	}
	
	var mashing:Int = 0;
	var mashViolations:Int = 0;
	function noteCheck(controlArray:Array<Bool>, note:Note):Void {
		note.rating = Ratings.CalculateRating(Math.abs(note.strumTime - Conductor.songPosition));
		if (controlArray[note.noteData]) goodNoteHit(note, mashing > getKeyPresses(note));
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void {
		if (mashing != 0) mashing = 0;
		
		note.rating = Ratings.CalculateRating(Math.abs(note.strumTime - Conductor.songPosition));

		if (!note.isSustainNote) notesHitArray.unshift(Date.now());
		
		if (!resetMashViolation && mashViolations >= 1) mashViolations--;
		if (mashViolations < 0) mashViolations = 0;

		if (!note.wasGoodHit) {
			if (!note.isSustainNote) {
				popUpScore(note);
				combo++;
			} else totalNotesHit++;

			boyfriend.playAnim(['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'][note.noteData], true);

			#if windows
			if (luaModchart != null) luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep && note.mustPress) saveNotes.push(HelperFunctions.truncateFloat(note.strumTime, 2));
			
			playerStrums.forEach(spr -> if (Math.abs(note.noteData) == spr.ID) spr.animation.play('confirm', true));
			
			note.wasGoodHit = true;
			vocals.volume = 1;
			
			note.kill();
			notes.remove(note, true);
			note.destroy();
			
			updateAccuracy();
		}
	}

	override function stepHit() {
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - Conductor.songPosition) > 20) resyncVocals();
		#if windows if (executeModchart && luaModchart != null) {
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		songLength = FlxG.sound.music.length; #end
	}

	override function beatHit() {
		super.beatHit();
		if (generatedMusic) notes.sort(FlxSort.byY, FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
		#if windows if (executeModchart && luaModchart != null) {
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		} #end

		var section:SwagSection = SONG.notes[Math.floor(curStep / 16)];
		if (section != null) {
			if (section.changeBPM) {
				Conductor.changeBPM(section.bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			if (section.mustHitSection) dad.dance();
		}

		wiggleShit.update(Conductor.crochet);

		if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0) {
			FlxG.camera.zoom += 0.015;
			camHUD.zoom += 0.03;
		}

		for (icon in [iconP1, iconP2]) {
			icon.scale.set(1.2, 1.2);
			icon.updateHitbox();
		}

		if (curBeat % gfSpeed == 0) gf.dance();
		if (!boyfriend.animation.curAnim.name.startsWith("sing")) boyfriend.playAnim('idle');
		if (!dad.animation.curAnim.name.startsWith("sing")) dad.dance();

		if (curSong == 'Bopeebo' && curBeat % 8 == 7) boyfriend.playAnim('hey', true);
		if (curSong == 'Tutorial' && dad.curCharacter == 'gf' && curBeat % 16 == 15 && curBeat > 16 && curBeat < 48) {
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}
	}
}
