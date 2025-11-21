package;

import Section.SwagSection;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Int;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = 'gf';
	public var noteStyle:String = 'normal';
	public var stage:String = 'stage';

	public function new(song:String, notes:Array<SwagSection>, bpm:Int) {
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{
		var rawJson = Assets.getText(Paths.json('${folder.toLowerCase()}/${jsonInput.toLowerCase()}')).trim();
		var lastValidBraceIndex:Int = rawJson.lastIndexOf('}');
		if (lastValidBraceIndex != -1) rawJson = rawJson.substr(0, lastValidBraceIndex + 1);
		else trace('ERROR: Very corrupted JSON for the song: $jsonInput');
		return parseJSONshit(rawJson);
	}

	public static function parseJSONshit(rawJson:String):SwagSong {
		var swagShit:SwagSong = cast Json.parse(rawJson).song;
		swagShit.validScore = true;
		return swagShit;
	}
}
