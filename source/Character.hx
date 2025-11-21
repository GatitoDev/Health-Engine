package;

import flixel.animation.FlxAnimation;
import flixel.graphics.frames.FlxFramesCollection;
import data.BaseSprite;

using StringTools;

class Character extends BaseSprite
{
	public var debugMode:Bool = false;
	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var holdTimer:Float = 0;
	private var danced:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);
		curCharacter = character;
		this.isPlayer = isPlayer;
		antialiasing = true;

		var anims:Array<Array<Dynamic>> = [];
		var defaultAnim:String = 'idle';

		switch (curCharacter)
		{
			case 'gf':
				anims = [['cheer', 'GF Cheer'], ['singLEFT', 'GF left note'], ['singRIGHT', 'GF Right Note'],
					['singUP', 'GF Up Note'], ['singDOWN', 'GF Down Note'], ['scared', 'GF FEAR', 24, true]];
				
				frames = Paths.getSparrowAtlas('characters/GF_assets');
				for (a in anims) animation.addByPrefix(a[0], a[1], a[2] ?? 24, a[3] ?? false);
				
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24, true);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);

				addOffset('cheer'); addOffset('sad', -2, -2); addOffset('danceLeft', 0, -9); addOffset('danceRight', 0, -9);
				addOffset("singUP", 0, 4); addOffset("singRIGHT", 0, -20); addOffset("singLEFT", 0, -19); addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8); addOffset('hairFall', 0, -9); addOffset('scared', -2, -17);
				defaultAnim = 'danceRight';

			case 'dad':
				anims = [['idle', 'Dad idle dance', 24, true], ['singUP', 'Dad Sing Note UP'],
					['singRIGHT', 'Dad Sing Note RIGHT'], ['singDOWN', 'Dad Sing Note DOWN'], ['singLEFT', 'Dad Sing Note LEFT']];
				
				loadAnims('DADDY_DEAREST', anims);
				addOffset('idle'); addOffset("singDOWN", -4, -30); addOffset("singRIGHT", -7, 12);
				addOffset("singUP", -8, 52); addOffset("singLEFT", -2, 29);

			case 'bf':
				anims = [['idle', 'BF idle dance'], ['singUP', 'BF NOTE UP0'], ['singLEFT', 'BF NOTE LEFT0'],
					['singRIGHT', 'BF NOTE RIGHT0'], ['singDOWN', 'BF NOTE DOWN0'], ['singUPmiss', 'BF NOTE UP MISS'],
					['singLEFTmiss', 'BF NOTE LEFT MISS'], ['singRIGHTmiss', 'BF NOTE RIGHT MISS'],
					['singDOWNmiss', 'BF NOTE DOWN MISS'], ['hey', 'BF HEY'], ['firstDeath', "BF dies"],
					['deathLoop', "BF Dead Loop", 24, true], ['deathConfirm', "BF Dead confirm"], ['scared', 'BF idle shaking', 24, true]];
				
				loadAnims('BOYFRIEND', anims);
				addOffset('idle', -5); addOffset("singUP", -29, 27); addOffset("singRIGHT", -38, -7); addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50); addOffset("singUPmiss", -29, 27); addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24); addOffset("singDOWNmiss", -11, -19); addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11); addOffset('deathLoop', 37, 5); addOffset('deathConfirm', 37, 69); addOffset('scared', -4);
				flipX = true;
		}
		playAnim(defaultAnim);

		if (isPlayer) {
			flipX = !flipX;
			if (!curCharacter.startsWith('bf')) {
				swapAnimationFrames('singLEFT', 'singRIGHT');
				if (animation.getByName('singRIGHTmiss') != null) swapAnimationFrames('singLEFTmiss', 'singRIGHTmiss');
			}
		}
		dance();
	}

	private static var frameCache:Map<String, FlxFramesCollection> = new Map();
	function loadAnims(path:String, anims:Array<Array<Dynamic>>):Void {
		var cacheKey:String = 'characters/${path}';
		if (!frameCache.exists(cacheKey)) frameCache.set(cacheKey, Paths.getSparrowAtlas(cacheKey));
		frames = frameCache.get(cacheKey);
		for (a in anims) animation.addByPrefix(a[0], a[1], a[2] ?? 24, a[3] ?? false);
	}

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
		if (!curCharacter.startsWith('bf')) {
			if (curAnim.name.startsWith('sing')) {
				holdTimer += elapsed;
				if (holdTimer >= Conductor.stepCrochet * (curCharacter == 'dad' ? 0.0061 : 0.004)) {
					dance();
					holdTimer = 0;
				}
			}
		}
		if (curCharacter == 'gf' && curAnim.name == 'hairFall' && curAnim.finished) playAnim('danceRight');
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
			default: if (curAnim.name != 'idle') playAnim('idle');
		}
	}
}