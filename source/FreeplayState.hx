package;

import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class FreeplayState extends MusicBeatState
{
	var songs:Array<SongMetadata> = [];
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;
	var grpSongs:FlxTypedGroup<Alphabet>;
	var iconArray:Array<HealthIcon> = [];
	
	var scoreBG:FlxSprite;
	var scoreText:FlxText;
	var diffText:FlxText;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	override function create() {
		add(new FlxSprite().loadGraphic(Paths.image('menuBGBlue')));

		loadSongList();
		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;
			iconArray.push(icon);
			add(icon);
		}

		scoreBG = new FlxSprite(0, FlxG.height - 66).makeGraphic(1, 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		scoreText = new FlxText(0, FlxG.height - 61, FlxG.width, "", 32);
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		scoreText.wordWrap = false;
		add(scoreText);

		diffText = new FlxText(0, FlxG.height - 25, FlxG.width, "", 24);
		diffText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER);
		diffText.wordWrap = false;
		add(diffText);

		changeSelection();
		changeDiff();

		super.create();
	}

	function loadSongList():Void {
		var initSonglist:Array<String> = CoolUtil.coolTextFile(Paths.txt('freeplaySonglist'));
		for (i in 0...initSonglist.length) {
			var data:Array<String> = initSonglist[i].split(':');
			songs.push(new SongMetadata(data[0], Std.parseInt(data[2]), data[1]));
		}
	}

	override function update(elapsed:Float) {
		super.update(elapsed);
		FlxG.sound.music.volume < 0.7 ? FlxG.sound.music.volume += 0.5 * FlxG.elapsed : null;
		
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));
		if (Math.abs(lerpScore - intendedScore) <= 10) lerpScore = intendedScore;
		
		scoreText.text = "HIGHSCORE:" + lerpScore;
		updateScoreUI();
		input();
	}

	function updateScoreUI():Void {
		var bgWidth:Int = Std.int(Math.max(scoreText.textField.textWidth, diffText.textField.textWidth) + 40);
		var bgX:Float = (FlxG.width - bgWidth) / 2;
		
		scoreBG.setGraphicSize(bgWidth, 66);
		scoreBG.updateHitbox();
		scoreBG.x = bgX;
		
		scoreText.x = bgX;
		scoreText.fieldWidth = bgWidth;
		
		diffText.x = bgX;
		diffText.fieldWidth = bgWidth;
	}

	function input():Void {
		if (controls.UP_P) changeSelection(-1);
		else if (controls.DOWN_P) changeSelection(1);
		if (controls.LEFT_P) changeDiff(-1);
		else if (controls.RIGHT_P) changeDiff(1);

		if (controls.BACK) FlxG.switchState(new MainMenuState());
		else if (controls.ACCEPT) startSong();
	}

	function startSong():Void {
		var poop:String = Highscore.formatSong(songs[curSelected].songName.toLowerCase(), curDifficulty);
		PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName.toLowerCase());
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = curDifficulty;
		PlayState.storyWeek = songs[curSelected].week;
		LoadingState.loadAndSwitchState(new PlayState());
	}

	function changeDiff(change:Int = 0):Void {
		curDifficulty = (curDifficulty + change) % 3;
		if (curDifficulty < 0) curDifficulty = 2;
		#if !switch intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty); #end
		var diff:Array<String> = ["EASY", "NORMAL", "HARD"];
		diffText.text = '< ${diff[curDifficulty]} >';
	}

	function changeSelection(change:Int = 0):Void {
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected = FlxMath.wrap(curSelected + change, 0, songs.length - 1);

		#if !switch intendedScore = Highscore.getScore(songs[curSelected].songName, curDifficulty); #end
		FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);

		for (i in 0...iconArray.length) iconArray[i].alpha = i == curSelected ? 1 : 0.6;
		for (i in 0...grpSongs.members.length) {
			var item:Alphabet = grpSongs.members[i];
			item.targetY = i - curSelected;
			item.alpha = item.targetY == 0 ? 1 : 0.6;
		}
	}
}

class SongMetadata {
	public var songName:String;
	public var week:Int;
	public var songCharacter:String;

	public function new(song:String, week:Int, songCharacter:String) {
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
}