package;

import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import flixel.graphics.frames.FlxAtlasFrames;

class Paths
{
	@:isVar static public var SOUND_EXT(get, never):String;
	@:noCompletion static function get_SOUND_EXT():String return #if web "mp3" #else "ogg" #end;
	
	static var currentLevel:String;
	@:keep static public function setCurrentLevel(name:String):Void currentLevel = name.toLowerCase();
	
	@:noCompletion static function getPath(file:String, type:AssetType, library:Null<String>):String {
		if (library != null) return getLibraryPath(file, library);
		if (currentLevel != null) {
			var levelPath:String = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type)) return levelPath;
		}
		return getPreloadPath(file);
	}

	@:keep static public function getLibraryPath(file:String, library = "preload"):String
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);

	@:noCompletion @:noUsing inline static function getLibraryPathForce(file:String, library:String):String return '$library:assets/$library/$file';

	@:keep inline static public function getPreloadPath(file:String):String return 'assets/$file';

	@:keep inline static public function file(file:String, type:AssetType = TEXT, ?library:String):String return getPath(file, type, library);

	@:keep inline static public function lua(key:String, ?library:String):String return getPath('data/$key.lua', TEXT, library);

	@:keep inline static public function luaImage(key:String, ?library:String):String return getPath('data/$key.png', IMAGE, library);

	@:keep inline static public function txt(key:String, ?library:String):String return getPath('data/$key.txt', TEXT, library);

	@:keep inline static public function xml(key:String, ?library:String):String return getPath('data/$key.xml', TEXT, library);

	@:keep inline static public function json(key:String, ?library:String):String return getPath('data/$key.json', TEXT, library);
	
	@:keep static public function sound(key:String, ?library:String):String return getPath('sounds/$key.$SOUND_EXT', SOUND, library);

	@:keep inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String):String return sound(key + FlxG.random.int(min, max), library);

	@:keep inline static public function music(key:String, ?library:String):String return getPath('music/$key.$SOUND_EXT', MUSIC, library);

	@:keep inline static public function voices(song:String, ?library:String):String return getPath('songs/${song.toLowerCase()}/Voices.$SOUND_EXT', SOUND, library);

	@:keep inline static public function inst(song:String, ?library:String):String return getPath('songs/${song.toLowerCase()}/Inst.$SOUND_EXT', SOUND, library);
	
	@:keep inline static public function image(key:String, ?library:String):String return getPath('images/$key.png', IMAGE, library);

	@:keep inline static public function font(key:String):String return 'assets/fonts/$key';
	
	@:keep inline static public function getSparrowAtlas(key:String, ?library:String):FlxAtlasFrames 
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));

	@:keep inline static public function getPackerAtlas(key:String, ?library:String):FlxAtlasFrames
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
}