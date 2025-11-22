package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.Assets;

#if cpp import sys.thread.Thread; #end
using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var titleText:FlxSprite;
	var bg:FlxSprite;
	
	var danceLeft:Bool = false;
	var transitioning:Bool = false;
	var skippedIntro:Bool = false;
	var curWacky:Array<String> = [];

	override public function create():Void
	{

		PlayerSettings.init();
		curWacky = FlxG.random.getObject(getIntroTextShit());
		
		super.create();

		// Initialize save data
		FlxG.save.bind('funkin', 'ninjamuffin99');
		KadeEngineData.initSave();
		Highscore.load();

		// Week unlock progression
		if (FlxG.save.data.weekUnlocked != null && StoryMenuState.weekUnlocked.length < 4) {
			StoryMenuState.weekUnlocked.insert(0, true);
			if (!StoryMenuState.weekUnlocked[0]) StoryMenuState.weekUnlocked[0] = true;
		}

		#if FREEPLAY FlxG.switchState(new FreeplayState());
		#elseif CHARTING FlxG.switchState(new ChartingState());
		#else new FlxTimer().start(1, function(_) startIntro()); #end
	}

	function startIntro() {
		if (!initialized) setupInitialState();
		
		Conductor.changeBPM(102);
		persistentUpdate = true;

		add(bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK));

		logoBl = new FlxSprite(-150, -100);
		logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.updateHitbox();

		gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		gfDance.antialiasing = true;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		credGroup = new FlxGroup();
		textGroup = new FlxGroup();
		add(credGroup);
		
		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;
		ngSpr.visible = false;
		add(ngSpr);

		FlxG.mouse.visible = false;

		if (initialized) skipIntro();
		else initialized = true;
	}

	function setupInitialState() {
		var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		diamond.persist = true;
		diamond.destroyOnNoUse = false;

		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, 
		 new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
		 new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, 
		 new FlxPoint(0, 1), {asset: diamond, width: 32, height: 32},
		 new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
		FlxG.sound.music.fadeIn(4, 0, 0.7);
	}

	function getIntroTextShit():Array<Array<String>>
	{ return Assets.getText(Paths.txt('introText')).split('\n').map(i -> i.split('--')); }

	override function update(elapsed:Float) {
		if (FlxG.sound.music != null) Conductor.songPosition = FlxG.sound.music.time;
		if (FlxG.keys.justPressed.F) FlxG.fullscreen = !FlxG.fullscreen;
		var pressedEnter:Bool = checkForEnterPress();
		if (pressedEnter && !transitioning && skippedIntro) startTransitionToMenu();
		else if (pressedEnter && !skippedIntro && initialized) skipIntro();
		super.update(elapsed);
	}

	function checkForEnterPress():Bool {
		var pressed = FlxG.keys.justPressed.ENTER;
		#if mobile for (touch in FlxG.touches.list) if (touch.justPressed) pressed = true; #end
		var gamepad = FlxG.gamepads.lastActive;
		if (gamepad != null && (gamepad.justPressed.START #if switch || gamepad.justPressed.B #end)) pressed = true;
		return pressed;
	}

	function startTransitionToMenu() {
		if (FlxG.save.data.flashing) titleText.animation.play('press');

		FlxG.camera.flash(FlxColor.WHITE, 1);
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		transitioning = true;

		new FlxTimer().start(2, function(_) checkVersionAndProceed());
	}

	function checkVersionAndProceed() {
		var http = new haxe.Http("https://raw.githubusercontent.com/KadeDev/Kade-Engine/patchnotes/version.downloadMe");
		var returnedData:Array<String> = [];
		
		http.onData = function(data:String) {
			returnedData[0] = data.substring(0, data.indexOf(';'));
			returnedData[1] = data.substring(data.indexOf('-'), data.length);
			
			if (!MainMenuState.kadeEngineVer.contains(returnedData[0].trim()) && 
				!OutdatedSubState.leftState && MainMenuState.nightly == "") {
				OutdatedSubState.needVer = returnedData[0];
				OutdatedSubState.currChanges = returnedData[1];
				FlxG.switchState(() -> new OutdatedSubState());
			}
			else FlxG.switchState(() -> new MainMenuState());
		}
		
		http.onError = function(error) {
			trace('error: $error');
			FlxG.switchState(() -> new MainMenuState());
		}
		
		http.request();
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		gfDance.animation.play(danceLeft ? 'danceRight' : 'danceLeft');
		danceLeft = !danceLeft;

		switch (curBeat)
		{
			case 1: createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
			case 3: addMoreText('present');
			case 4: deleteCoolText();
			case 5: createCoolText(['In Partnership', 'with']);
			case 7: addMoreText('Newgrounds'); ngSpr.visible = true;
			case 8: deleteCoolText(); ngSpr.visible = false;
			case 9: createCoolText([curWacky[0]]);
			case 11: addMoreText(curWacky[1]);
			case 12: deleteCoolText();
			case 13: addMoreText('Friday');
			case 14: addMoreText('Night');
			case 15: addMoreText('Funkin');
			case 16: skipIntro();
		}
	}

	function createCoolText(textArray:Array<String>) {
		for (i in 0...textArray.length) {
			var text:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			text.screenCenter(X);
			text.y += (i * 60) + 200;
			credGroup.add(text);
			textGroup.add(text);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText() {
		while (textGroup.members.length > 0) {
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	function skipIntro():Void {
		if (!skippedIntro) {
			remove(ngSpr);
			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);
			skippedIntro = true;
		}
	}
}