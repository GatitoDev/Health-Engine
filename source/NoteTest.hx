package;

import Section.SwagSection;
import Song.SwagSong;

import flixel.FlxG;
import flixel.math.FlxRect;
import flixel.util.FlxSort;
import flixel.sound.FlxSound;
import flixel.group.FlxGroup.FlxTypedGroup;

using StringTools;

class NoteTest extends FlxTypedGroup<FlxBasic> {
    private var SONG:SwagSong;
    private var vocals:FlxSound;

    private var songTime:Float = 0;
    private var previousFrameTime:Int = 0;

    private var paused:Bool = false;
    private var songStarted:Bool = false;
	public var startingSong:Bool = false;
    private var generatedMusic:Bool = false;
    private var startedCountdown:Bool = false;

    public var noteGroup:FlxTypedGroup<FlxBasic>;

    private var reusableRect:FlxRect;

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

        reusableRect = new FlxRect();
    }

    public function generateSong():Void {
        Conductor.changeBPM(SONG.bpm);

        vocals = new FlxSound();
        if (SONG.needsVoices) vocals.loadEmbedded(Paths.voices(SONG.song));
        FlxG.sound.list.add(vocals);

        notes = new FlxTypedGroup<Note>();
        noteGroup.add(notes);

        var songOffset:Float = (FlxG.save.data != null && FlxG.save.data.offset != null) 
            ? FlxG.save.data.offset : 0.0;

        var sections:Array<SwagSection> = SONG.notes;
        for (section in sections) {
            if (section == null || section.sectionNotes == null) continue;

            var mustHit:Bool = section.mustHitSection;

            for (songNote in section.sectionNotes) {
                if (songNote == null || songNote.length < 2) continue;

                var strumTime:Float = songNote[0] + songOffset;
                if (strumTime < 0) strumTime = 0;

                var column:Int = Std.int(songNote[1] % 4);
                var isPlayerNote:Bool = mustHit ? (songNote[1] < 4) : (songNote[1] > 3);

                var lastNote:Note = unspawnNotes.length > 0 ? unspawnNotes[unspawnNotes.length - 1] : null;

                var note:Note = new Note(strumTime, column, lastNote);
                note.sustainLength = (songNote.length > 2 && songNote[2] != null) ? songNote[2] : 0.0;
                note.scrollFactor.set(0, 0);
                note.mustPress = isPlayerNote;
                note.x += isPlayerNote ? FlxG.width / 2 : 0;
                unspawnNotes.push(note);

                if (note.sustainLength > 0 && Conductor.stepCrochet > 0) {
                    var susLength:Int = Math.floor(note.sustainLength / Conductor.stepCrochet);
                    for (susNote in 0...susLength) {
                        var susLast:Note = unspawnNotes[unspawnNotes.length - 1];
                        var sustain:Note = new Note(
                            strumTime + (Conductor.stepCrochet * (susNote + 1)), column, susLast, true
                        );
                        sustain.scrollFactor.set(0, 0);
                        sustain.mustPress = isPlayerNote;
                        sustain.x += isPlayerNote ? FlxG.width / 2 : 0;
                        unspawnNotes.push(sustain);
                    }
                }
            }
        }

        unspawnNotes.sort(sorting);
        generatedMusic = true;
    }

    private function sorting(a:Note, b:Note):Int
        return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);

    public function startCountdown():Void {
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

        if (unspawnNotes[0] != null) {
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500) {
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);
				unspawnNotes.shift();
			}
		}

        if (generatedMusic && notes.length > 0) {
            var saveScroll:Float = FlxG.save.data.scrollSpeed;
            var scrollSpeed:Float = (saveScroll == 1 ? SONG.speed : saveScroll);
            var isDownscroll:Bool = FlxG.save.data.downscroll;
            var centerStrumDiff:Float = Note.swagWidth / 2;

            notes.forEachAlive(function(daNote:Note) {
                daNote.active = daNote.visible = !daNote.tooLate;

                var targetGroup:FlxTypedGroup<FlxSprite> = daNote.mustPress ? playerStrums : strumLineNotes;
                var strum:FlxSprite = targetGroup.members[daNote.noteData];
                
                daNote.x = strum.x;
                daNote.alpha = strum.alpha;
                daNote.visible = strum.visible && daNote.visible;
                if (!daNote.isSustainNote) daNote.angle = strum.angle;

                var noteProgress:Float = 0.45 * (Conductor.songPosition - daNote.strumTime) * scrollSpeed;
                daNote.y = strum.y + (isDownscroll ? noteProgress : -noteProgress);

                if (daNote.isSustainNote) {
                    daNote.alpha = 0.6;
                    daNote.x += daNote.width / 2 + 17;

                    var shouldClip:Bool = FlxG.save.data.botplay || (!daNote.mustPress || daNote.wasGoodHit || 
                     (daNote.prevNote != null && daNote.prevNote.wasGoodHit && !daNote.canBeHit));

                    if (shouldClip) {
                        if (isDownscroll) {
                            if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
                                daNote.y += daNote.prevNote.height;
                            else daNote.y += daNote.height / 2;

                            if (daNote.y + daNote.height >= strum.y + centerStrumDiff) {
                                reusableRect.set(0, 0, daNote.frameWidth, daNote.frameHeight);
                                reusableRect.height = (strum.y + centerStrumDiff - daNote.y) / daNote.scale.y;
                                reusableRect.y = daNote.frameHeight - reusableRect.height;
                                daNote.clipRect = reusableRect;
                            }
                        } else {
                            daNote.y -= daNote.height / 2;
                            if (daNote.y <= strum.y + centerStrumDiff) {
                                reusableRect.set(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
                                reusableRect.y = (strum.y + centerStrumDiff - daNote.y) / daNote.scale.y;
                                reusableRect.height -= reusableRect.y;
                                daNote.clipRect = reusableRect;
                            }
                        }
                    }
                }

                if (!daNote.mustPress && daNote.wasGoodHit) {
                    strum.animation.play('confirm', true);
                    strum.centerOffsets();
                    strum.offset.set(strum.offset.x - 13, strum.offset.y - 13);
                    
                    new FlxTimer().start(0.1, function(tmr:FlxTimer) {
                        strum.animation.play('static');
                        strum.centerOffsets();
                    });

                    if (SONG.needsVoices) vocals.volume = 1;

                    killNote(daNote);
                }

                if (daNote.mustPress && daNote.tooLate) {
                    if (!daNote.isSustainNote || !daNote.wasGoodHit) vocals.volume = 0;
                    killNote(daNote);
                }
            });
        }
    }

    function killNote(daNote:Note):Void {
        notes.remove(daNote, true);
        daNote.destroy();
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

    public function beatHit():Void {
        if (generatedMusic && notes.length > 1) {
			notes.sort(FlxSort.byY, FlxG.save.data.downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
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
