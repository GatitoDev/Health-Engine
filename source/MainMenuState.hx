package;

import Controls.KeyboardScheme;
import flixel.effects.FlxFlicker;

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	var menuItems:FlxTypedGroup<FlxSprite>;
	var optionShit:Array<String> = ['story mode', 'freeplay', #if !switch 'donate', 'options' #end];

	public static var nightly:String = "";
	
	public static var kadeEngineVer:String = "1.4.2";
	public static var gameVer:String = "0.2.7.1";
	
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var selectedSomethin:Bool = false;

	override function create() {
		if (!FlxG.sound.music.playing) FlxG.sound.playMusic(Paths.music('freakyMenu'));
		
		persistentUpdate = persistentDraw = true;

		add(camFollow = new FlxObject(0, 0, 1, 1));
		FlxG.camera.follow(camFollow, null, 1);
		
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.scrollFactor.set(0, 0.15);
		bg.antialiasing = true;
		bg.screenCenter();
		add(bg);
		
		magenta = new FlxSprite(bg.x).loadGraphic(Paths.image('menuBGMagenta'));
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.scrollFactor.set(0, 0.15);
		magenta.antialiasing = true;
		magenta.visible = false;
		magenta.screenCenter();
		add(magenta);

		add(menuItems = new FlxTypedGroup<FlxSprite>());
		
		for (i in 0...optionShit.length) {
			var menuItem:FlxSprite = new FlxSprite(0, 60 + (i * 160));
			menuItem.frames = Paths.getSparrowAtlas('FNF_main_menu_assets');
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			menuItems.add(menuItem);
		}
		
		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		
		controls.setKeyboardScheme(FlxG.save.data.dfjk ? KeyboardScheme.Solo : KeyboardScheme.Duo(true), true);
		
		changeItem();
		super.create();
	}

	override function update(elapsed:Float) {
		if (FlxG.sound.music.volume < 0.8) FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
			
		if (!selectedSomethin) handleInput();
		
		super.update(elapsed);
		menuItems.forEach(spr -> spr.screenCenter(X));
	}
	
	function handleInput() {
		if (controls.UP_P || controls.DOWN_P) {
			FlxG.sound.play(Paths.sound('scrollMenu'));
			changeItem(controls.UP_P ? -1 : 1);
		}
		
		if (controls.BACK) FlxG.switchState(new TitleState());
		
		if (controls.ACCEPT) {
			if (optionShit[curSelected] == 'donate') FlxG.openURL('https://www.kickstarter.com/projects/funkin/friday-night-funkin-the-full-ass-game');
			else {
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				
				if (FlxG.save.data.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);
				
				menuItems.forEach(spr -> {
					if (curSelected != spr.ID) FlxTween.tween(spr, {alpha: 0}, 1.3, { ease: FlxEase.quadOut, onComplete: twn -> spr.kill() });
					else {
						if (FlxG.save.data.flashing) FlxFlicker.flicker(spr, 1, 0.06, false, false, flick -> goToState());
						else new FlxTimer().start(1, tmr -> goToState());
					}
				});
			}
		}
	}
	
	function goToState() {
		switch (optionShit[curSelected]) {
			case 'story mode': FlxG.switchState(new StoryMenuState());
			case 'freeplay': FlxG.switchState(new FreeplayState());
			case 'options': FlxG.switchState(new OptionsScreen());
		}
	}

	function changeItem(huh:Int = 0) {
		curSelected += huh;
		
		if (curSelected >= menuItems.length) curSelected = 0;
		if (curSelected < 0) curSelected = menuItems.length - 1;
		
		menuItems.forEach(spr -> {
			spr.animation.play(spr.ID == curSelected ? 'selected' : 'idle');
			if (spr.ID == curSelected) camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			spr.updateHitbox();
		});
	}
}