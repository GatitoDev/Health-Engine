package;

import Song.SwagSong;
import Section.SwagSection;
import flixel.util.FlxSort;
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.util.FlxTimer;

using StringTools;

class NoteField extends FlxTypedGroup<FlxBasic> {
    public var onNoteHit:Note->Void;
    public var onNoteMiss:Int->Note->Void;
    public var onSustainHit:Note->Void;

    public var strumLineNotes:FlxTypedGroup<FlxSprite>;
    public var playerStrums:FlxTypedGroup<FlxSprite>;
    public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;
    public var notes:FlxTypedGroup<Note>;

    private var unspawnNotes:Array<Note> = [];
    private var strumLine:FlxSprite;
    private var vocals:FlxSound;
    private var camHUD:FlxCamera;
    private var controls:Controls;
    private var song:SwagSong;
    public var curStage:String = '';
    private var mashViolations:Int = 0;
    private var noteSplashEnabled:Bool = true;
    private var reusableRect:FlxRect;
    
    private var lastNoteTime:Float = 0;

    public function new(song:SwagSong, camHUD:FlxCamera, controls:Controls) {
        super();
        
        if (song == null || camHUD == null || controls == null) {
            throw "NoteField requires non-null parameters: song, camHUD, and controls";
        }
        
        this.song = song;
        this.camHUD = camHUD;
        this.controls = controls;
        this.reusableRect = new FlxRect();

        _initGroups();
        _initStrumLine();
        _generateSong();
    }

    private function _initGroups():Void {
        strumLineNotes = new FlxTypedGroup<FlxSprite>();
        playerStrums = new FlxTypedGroup<FlxSprite>();
        notes = new FlxTypedGroup<Note>();
        grpNoteSplashes = new FlxTypedGroup<NoteSplash>();

        // Pre-spawn one note splash
        var sploosh:NoteSplash = new NoteSplash(100, 100, 0);
        sploosh.alpha = 0.6;
        grpNoteSplashes.add(sploosh);

        add(strumLineNotes);
        add(playerStrums);
        add(notes);
        add(grpNoteSplashes);

        strumLineNotes.cameras = [camHUD];
        playerStrums.cameras = [camHUD];
        notes.cameras = [camHUD];
        grpNoteSplashes.cameras = [camHUD];
    }

    private function _initStrumLine():Void {
        strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10, 0xFF000000);
        strumLine.scrollFactor.set();
        
        if (FlxG.save.data != null && FlxG.save.data.downscroll) {
            strumLine.y = FlxG.height - 165;
        }
    }

    public function makeStrumLines(isStoryMode:Bool = false):Void {
        if (StrumLine == null) return;
        
        StrumLine.makeStatic(0, strumLine, strumLineNotes, playerStrums, song, isStoryMode);
        StrumLine.makeStatic(1, strumLine, strumLineNotes, playerStrums, song, isStoryMode);
    }

    private function _generateSong():Void {
        if (Conductor == null || song == null) return;
        
        Conductor.changeBPM(song.bpm);
        
        vocals = new FlxSound();
        if (song.needsVoices) {
            vocals.loadEmbedded(Paths.voices(song.song));
        }
        
        if (FlxG.sound.list != null) {
            FlxG.sound.list.add(vocals);
        }

        var noteData:Array<SwagSection> = song.notes;
        if (noteData == null) return;

        for (section in noteData) {
            if (section == null) continue;
            
            var mustHit:Bool = section.mustHitSection;
            var sectionNotes:Array<Dynamic> = section.sectionNotes;
            
            if (sectionNotes == null) continue;

            for (songNote in sectionNotes) {
                if (songNote == null) continue;
                
                var strumTime:Float = songNote[0];
                
                // Apply offset
                if (FlxG.save.data != null && FlxG.save.data.offset != null) {
                    strumTime += FlxG.save.data.offset;
                }
                
                if (strumTime < 0) strumTime = 0;

                var noteDir:Int = Std.int(songNote[1] % 4);
                var isPlayer:Bool = mustHit ? songNote[1] < 4 : songNote[1] > 3;
                var lastNote:Note = unspawnNotes.length > 0 ? unspawnNotes[unspawnNotes.length - 1] : null;

                var note:Note = new Note(strumTime, noteDir, lastNote);
                note.sustainLength = songNote[2];
                note.scrollFactor.set(0, 0);
                note.mustPress = isPlayer;
                if (isPlayer) note.x += FlxG.width / 2;
                
                unspawnNotes.push(note);

                // Generate sustain notes
                if (note.sustainLength > 0 && Conductor.stepCrochet > 0) {
                    var susLength:Int = Math.floor(note.sustainLength / Conductor.stepCrochet);
                    
                    for (i in 0...susLength) {
                        lastNote = unspawnNotes[unspawnNotes.length - 1];
                        var sustain:Note = new Note(strumTime + (Conductor.stepCrochet * (i + 1)), noteDir, lastNote, true);
                        sustain.scrollFactor.set();
                        sustain.mustPress = isPlayer;
                        if (isPlayer) sustain.x += FlxG.width / 2;
                        
                        unspawnNotes.push(sustain);
                    }
                }
            }
        }
        
        unspawnNotes.sort(_sortByTime);
    }

    private function _sortByTime(a:Note, b:Note):Int {
        return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        
        // Spawn notes as they approach
        while (unspawnNotes.length > 0) {
            var nextNote:Note = unspawnNotes[0];
            if (nextNote != null && Conductor.songPosition + 3500 >= nextNote.strumTime) {
                notes.add(nextNote);
                unspawnNotes.shift();
            } else {
                break;
            }
        }
        
        _updateNotes(elapsed);
        _keyShit();
    }

    private function _updateNotes(elapsed:Float):Void {
        if (notes.length == 0 || strumLineNotes.length == 0 || playerStrums.length == 0) return;
        
        var scrollSpeed:Float = 1.0;
        if (FlxG.save.data != null) {
            scrollSpeed = FlxMath.roundDecimal(FlxG.save.data.scrollSpeed == 1 ? song.speed : FlxG.save.data.scrollSpeed, 2);
        }
        
        var isDown:Bool = FlxG.save.data != null && FlxG.save.data.downscroll;

        notes.forEachAlive(function(daNote:Note) {
            if (daNote == null) return;
            
            daNote.active = daNote.visible = !daNote.tooLate;
            
            var noteProgress:Float = 0.45 * (Conductor.songPosition - daNote.strumTime) * scrollSpeed;
            var strum:FlxSprite = daNote.mustPress ? 
                playerStrums.members[Math.floor(Math.abs(daNote.noteData))] : 
                strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))];

            if (strum == null) return;
            
            daNote.y = isDown ? strum.y + noteProgress : strum.y - noteProgress;

            // Handle sustain note rendering
            if (daNote.isSustainNote) {
                _updateSustainNote(daNote, isDown, scrollSpeed);
            }

            // Handle opponent notes
            if (!daNote.mustPress && daNote.wasGoodHit) {
                _handleOpponentNoteHit(daNote);
                return;
            }

            // Update note position and appearance
            var targetStrum:FlxSprite = daNote.mustPress ? 
                playerStrums.members[Math.floor(Math.abs(daNote.noteData))] : 
                strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))];
            
            if (targetStrum == null) return;

            daNote.visible = targetStrum.visible;
            daNote.x = targetStrum.x;
            
            if (!daNote.isSustainNote) {
                daNote.angle = targetStrum.angle;
            }
            
            daNote.alpha = targetStrum.alpha;
            
            if (daNote.isSustainNote) {
                daNote.x += daNote.width / 2 + 17;
            }

            // Handle missed notes
            if (daNote.mustPress && daNote.tooLate) {
                if (!(daNote.isSustainNote && daNote.wasGoodHit)) {
                    if (vocals != null) vocals.volume = 0;
                    if (onNoteMiss != null) onNoteMiss(daNote.noteData, daNote);
                }
                notes.remove(daNote, true);
                daNote.destroy();
            }
        });
    }

    private function _updateSustainNote(daNote:Note, isDown:Bool, scrollSpeed:Float):Void {
        if (daNote == null) return;
        
        var shouldClip:Bool = (FlxG.save.data != null && FlxG.save.data.botplay) || 
                              (!daNote.mustPress || daNote.wasGoodHit || 
                              (daNote.prevNote != null && daNote.prevNote.wasGoodHit && !daNote.canBeHit));

        if (isDown) {
            var animName:String = daNote.animation != null && daNote.animation.curAnim != null ? daNote.animation.curAnim.name : '';
            daNote.y += (animName.endsWith('end') && daNote.prevNote != null) ? daNote.prevNote.height : daNote.height / 2;
            
            if (shouldClip) {
                var strumY:Float = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))] != null ? 
                    strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y : 0;
                    
                if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= strumY + Note.swagWidth / 2) {
                    reusableRect.set(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
                    reusableRect.height = (strumY + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
                    reusableRect.y = daNote.frameHeight - reusableRect.height;
                    daNote.clipRect = reusableRect;
                }
            }
        } else {
            daNote.y -= daNote.height / 2;
            
            if (shouldClip) {
                var strumY:Float = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))] != null ? 
                    strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y : 0;
                    
                if (daNote.y + daNote.offset.y * daNote.scale.y <= strumY + Note.swagWidth / 2) {
                    reusableRect.set(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
                    reusableRect.y = (strumY + Note.swagWidth / 2 - daNote.y) / daNote.scale.y;
                    reusableRect.height -= reusableRect.y;
                    daNote.clipRect = reusableRect;
                }
            }
        }
    }

    private function _handleOpponentNoteHit(daNote:Note):Void {
        if (daNote == null) return;
        
        var oppStrum:FlxSprite = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))];
        if (oppStrum != null) {
            oppStrum.animation.play('confirm', true);
            oppStrum.centerOffsets();
            oppStrum.offset.x -= 13;
            oppStrum.offset.y -= 13;

            new FlxTimer().start(0.1, function(_) {
                if (oppStrum != null) {
                    oppStrum.animation.play('static');
                    oppStrum.centerOffsets();
                }
            });
        }
        
        if (song.needsVoices && vocals != null) {
            vocals.volume = 1;
        }
        
        notes.remove(daNote, true);
        daNote.destroy();
    }

    private function _keyShit():Void {
        if (controls == null) return;
        
        var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
        var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];

        var isBotplay:Bool = FlxG.save.data != null && FlxG.save.data.botplay;
        
        if (isBotplay) {
            holdArray = pressArray = [false, false, false, false];
        }

        // Handle held sustain notes
        if (holdArray[0] || holdArray[1] || holdArray[2] || holdArray[3]) {
            notes.forEachAlive(function(daNote:Note) {
                if (daNote != null && daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData]) {
                    _goodNoteHit(daNote);
                }
            });
        }

        // Handle pressed notes
        if (pressArray[0] || pressArray[1] || pressArray[2] || pressArray[3]) {
            _handleKeyPress(pressArray, isBotplay);
        }

        // Handle botplay
        if (isBotplay) {
            _handleBotplay();
        }

        // Update strum animations
        _updateStrumAnimations(holdArray, pressArray);
    }

    private function _handleKeyPress(pressArray:Array<Bool>, isBotplay:Bool):Void {
        var possibleNotes:Array<Note> = [];
        var directionMap:Map<Int, Bool> = new Map();
        var dumbNotes:Array<Note> = [];
        
        notes.forEachAlive(function(daNote:Note) {
            if (daNote == null) return;
            
            if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit) {
                if (directionMap.exists(daNote.noteData)) {
                    for (coolNote in possibleNotes) {
                        if (coolNote != null && coolNote.noteData == daNote.noteData) {
                            if (Math.abs(daNote.strumTime - coolNote.strumTime) < 10) {
                                dumbNotes.push(daNote);
                            } else if (daNote.strumTime < coolNote.strumTime) {
                                possibleNotes.remove(coolNote);
                                possibleNotes.push(daNote);
                            }
                            break;
                        }
                    }
                } else {
                    possibleNotes.push(daNote);
                    directionMap.set(daNote.noteData, true);
                }
            }
        });

        // Clean up duplicate notes
        for (note in dumbNotes) {
            if (note != null) {
                note.kill();
                notes.remove(note, true);
                note.destroy();
            }
        }

        // Sort by strum time
        if (possibleNotes.length > 1) {
            possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
        }

        // Check if player is mashing
        var dontCheck:Bool = false;
        for (i in 0...4) {
            if (pressArray[i] && !directionMap.exists(i)) {
                dontCheck = true;
                break;
            }
        }

        // Hit notes or miss
        if (possibleNotes.length > 0 && !dontCheck) {
            var ghostMode:Bool = FlxG.save.data != null && FlxG.save.data.ghost;
            
            if (!ghostMode) {
                for (i in 0...4) {
                    if (pressArray[i] && !directionMap.exists(i)) {
                        if (onNoteMiss != null) onNoteMiss(i, null);
                    }
                }
            }
            
            for (coolNote in possibleNotes) {
                if (coolNote != null && pressArray[coolNote.noteData]) {
                    if (mashViolations != 0) mashViolations--;
                    _goodNoteHit(coolNote);
                }
            }
        } else if (!isBotplay && !(FlxG.save.data != null && FlxG.save.data.ghost)) {
            for (i in 0...4) {
                if (pressArray[i]) {
                    if (onNoteMiss != null) onNoteMiss(i, null);
                }
            }
        }

        // Mash violation check
        if (dontCheck && possibleNotes.length > 0 && FlxG.save.data != null && FlxG.save.data.ghost && !isBotplay) {
            if (mashViolations > 4) {
                if (onNoteMiss != null) onNoteMiss(0, null);
            } else {
                mashViolations++;
            }
        }
    }

    private function _handleBotplay():Void {
        var down:Bool = FlxG.save.data != null && FlxG.save.data.downscroll;
        
        notes.forEachAlive(function(daNote:Note) {
            if (daNote == null) return;
            
            if ((down && daNote.y > strumLine.y) || (!down && daNote.y < strumLine.y)) {
                if ((daNote.canBeHit || daNote.tooLate) && daNote.mustPress) {
                    _goodNoteHit(daNote);
                }
            }
        });
    }

    private function _updateStrumAnimations(holdArray:Array<Bool>, pressArray:Array<Bool>):Void {
        playerStrums.forEach(function(spr:FlxSprite) {
            if (spr == null) return;
            
            var animName:String = spr.animation != null && spr.animation.curAnim != null ? spr.animation.curAnim.name : '';
            
            if (pressArray[spr.ID] && animName != 'confirm') {
                spr.animation.play('pressed');
            }
            
            if (!holdArray[spr.ID]) {
                spr.animation.play('static');
            }
            
            spr.centerOffsets();
            
            if (animName == 'confirm' && !curStage.startsWith('school')) {
                spr.offset.x -= 13;
                spr.offset.y -= 13;
            }
        });
    }

    private function _goodNoteHit(note:Note):Void {
        if (note == null || note.wasGoodHit) return;
        
        note.rating = Ratings.CalculateRating(Math.abs(note.strumTime - Conductor.songPosition));

        if (note.isSustainNote) {
            if (onSustainHit != null) onSustainHit(note);
        } else {
            if (onNoteHit != null) onNoteHit(note);
        }

        playerStrums.forEach(function(spr:FlxSprite) {
            if (spr != null && Math.abs(note.noteData) == spr.ID) {
                spr.animation.play('confirm', true);
            }
        });

        if (noteSplashEnabled && note.rating == 'sick' && !note.isSustainNote) {
            var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
            if (splash != null) {
                splash.setupNoteSplash(note.x, note.y, note.noteData);
                grpNoteSplashes.add(splash);
            }
        }

        note.wasGoodHit = true;
        if (vocals != null) vocals.volume = 1;
        
        note.kill();
        notes.remove(note, true);
        note.destroy();
    }

    public function getVocals():FlxSound {
        return vocals;
    }

    public function resyncVocals():Void {
        if (vocals == null || FlxG.sound.music == null) return;
        
        vocals.pause();
        Conductor.songPosition = FlxG.sound.music.time;
        vocals.time = Conductor.songPosition;
        vocals.play();
    }

    public function sortNotes():Void {
        if (notes != null && notes.length > 1) {
            var downscroll:Bool = FlxG.save.data != null && FlxG.save.data.downscroll;
            notes.sort(FlxSort.byY, downscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING);
        }
    }

    public function setNoteSplash(enabled:Bool):Void {
        noteSplashEnabled = enabled;
    }

    override public function destroy():Void {
        reusableRect = null;
        unspawnNotes = null;
        super.destroy();
    }
}