package;

import haxe.Json;
import openfl.Assets;
import data.BaseSprite;
import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxFramesCollection;

using StringTools;

typedef CharacterData = {
	var tex:String;
	var init:String;
	var ?flipX:Bool;
	var anims:Dynamic;
}

class Character extends BaseSprite
{
	public var debugMode:Bool = false;
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var holdTimer:Float = 0;
	private var danced:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false):Void {
		super(x, y);
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = true;

		loadCharacterFromJSON(curCharacter);

		if (isPlayer) {
			flipX = !flipX;
			if (!curCharacter.startsWith('bf')) {
				swapAnimationFrames('singLEFT', 'singRIGHT');
				if (animation.getByName('singRIGHTmiss') != null) swapAnimationFrames('singLEFTmiss', 'singRIGHTmiss');
			}
		}
		dance();
	}

	private function loadCharacterFromJSON(character:String):Void {
		var path:String = Paths.getPreloadPath('images/characters/$character.json');
		
		if (!Assets.exists(path)) {
			trace('Character JSON not found: $path');
			return;
		}

		var jsonContent:String = Assets.getText(path);
		var charData:CharacterData = Json.parse(jsonContent);

		var cacheKey:String = 'characters/${charData.tex}';
		if (!frameCache.exists(cacheKey)) frameCache.set(cacheKey, Paths.getSparrowAtlas(cacheKey));
		frames = frameCache.get(cacheKey);

		if (charData.flipX != null) flipX = charData.flipX;

		var animFields:Array<String> = Reflect.fields(charData.anims);
		for (animName in animFields) {
			var animData:Array<Dynamic> = Reflect.field(charData.anims, animName);
			var prefix:String = animData[0];
			var offsetX:Float = animData[1];
			var offsetY:Float = animData[2];
			
			if (animData.length > 3 && Std.isOfType(animData[3], Array)) {
				var frames:Array<Int> = cast animData[3];
				var fps:Int = (animData.length > 4) ? animData[4] : 24;
				var looped:Bool = (animData.length > 5) ? animData[5] : false;
				animation.addByIndices(animName, prefix, frames, "", fps, looped);
			} else {
				var fps:Int = (animData.length > 3) ? animData[3] : 24;
				var looped:Bool = (animData.length > 4) ? animData[4] : false;
				animation.addByPrefix(animName, prefix, fps, looped);
			}
			
			addOffset(animName, offsetX, offsetY);
		}
		playAnim(charData.init);
	}

	private static var frameCache:Map<String, FlxFramesCollection> = new Map();

	private function swapAnimationFrames(anim1:String, anim2:String):Void {
		var temp:Array<Int> = animation.getByName(anim1).frames;
		animation.getByName(anim1).frames = animation.getByName(anim2).frames;
		animation.getByName(anim2).frames = temp;
	}

	override function update(elapsed:Float):Void {
		var curAnim:FlxAnimation = animation.curAnim;
		if (curAnim == null) {
			super.update(elapsed);
			return;
		}
		if (curAnim.name.startsWith('sing')) {
			if (animation.curAnim.finished) {
				dance();
				holdTimer = 0;
			} else holdTimer += elapsed;
		}
		if (curCharacter == 'gf' && curAnim.name == 'hairFall' && curAnim.finished) 
			playAnim('danceRight');
		super.update(elapsed);
	}

	public function dance():Void {
		if (debugMode) return;
		var curAnim:FlxAnimation = animation.curAnim;
		if (curAnim == null) return;
		switch (curCharacter) {
			case 'gf':
				if (curAnim.name.indexOf("hair") == -1) {
					danced = !danced;
					playAnim(danced ? 'danceRight' : 'danceLeft');
				}
			default: playAnim('idle', true);
		}
	}
}