package;

import Song.SwagSong;

import flixel.FlxG;
import flixel.sound.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;

class NoteTest extends FlxTypedGroup<FlxBasic> {
    private var SONG:SwagSong;
    private var vocals:FlxSound;

    private var songTime:Float = 0;
    private var previousFrameTime:Int = 0;

    private var paused:Bool = false;
    private var songStarted:Bool = false;
	public var startingSong:Bool = false;
    private var generatedMusic:Bool = false;
    private var startedCountdown:Bool = true;

    public var noteGroup:FlxTypedGroup<FlxBasic>;

    private var strumLine:FlxSprite;
    private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];
    private var playerStrums:FlxTypedGroup<FlxSprite> = null;
    private var strumLineNotes:FlxTypedGroup<FlxSprite> = null;

    public function new(song:SwagSong) {
        super();

        this.SONG = song;

        add(noteGroup = new FlxTypedGroup<FlxBasic>());
        noteGroup.add(strumLineNotes = new FlxTypedGroup<FlxSprite>());
        noteGroup.add(playerStrums = new FlxTypedGroup<FlxSprite>());

        Conductor.songPosition = -5000;

        strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10, 0xFF000000);
        strumLine.scrollFactor.set();
        if (FlxG.save.data != null && FlxG.save.data.downscroll) strumLine.y = FlxG.height - 165;
    }

    public function generateSong():Void {
        Conductor.changeBPM(SONG.bpm);
        
        vocals = new FlxSound();
        if (SONG.needsVoices) vocals.loadEmbedded(Paths.voices(SONG.song));
        FlxG.sound.list.add(vocals);
    }

    public function startCountdown():Void {
        if (StrumLine == null) return;
        StrumLine.makeStatic(0, strumLine, strumLineNotes, playerStrums, SONG, false);
        StrumLine.makeStatic(1, strumLine, strumLineNotes, playerStrums, SONG, false);

        startedCountdown = true;
		Conductor.songPosition = -Conductor.crochet * 5;
    }

    public function startSong():Void {
        startingSong = false;
        songStarted = true;
        previousFrameTime = FlxG.game.ticks;

        FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
        FlxG.sound.music.onComplete = () -> trace("Song ended!");

        if (vocals != null) vocals.play();
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);
		if (startingSong) {
			if (startedCountdown) {
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0) startSong();
			}
		} else {
			Conductor.songPosition += FlxG.elapsed * 1000;
			if (!paused) {
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;
				if (Conductor.lastSongPos != Conductor.songPosition) {
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
				}
			}
		}
    }

    public function resyncVocals():Void {
        if (FlxG.sound.music != null && Math.abs(FlxG.sound.music.time - Conductor.songPosition) > 20) {
            if (vocals != null && FlxG.sound.music.playing) {
                vocals.pause();
                Conductor.songPosition = FlxG.sound.music.time;
                vocals.time = Conductor.songPosition;
                vocals.play();
            }
        }
    }

    function stopMusic():Void {
        if (vocals != null && vocals.playing) vocals.stop();
        if (FlxG.sound.music != null && FlxG.sound.music.playing) FlxG.sound.music.stop();
    }

    function pauseMusic():Void {
        if (!paused) {
            paused = true;
            if (FlxG.sound.music != null) FlxG.sound.music.pause();
            if (vocals != null && vocals.playing) vocals.pause();
        }
    }

    function resumeMusic():Void {
        if (paused) {
            paused = false;
            if (FlxG.sound.music != null) FlxG.sound.music.resume();
            if (vocals != null && !vocals.playing) vocals.resume();
        }
    }
}