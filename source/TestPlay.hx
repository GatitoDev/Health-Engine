package;

import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import stages.Stage;

using StringTools;

class TestPlay extends MusicBeatState
{
    public var stage:Stage;
    
    public var gf:Character;
    public var bf:Character;
    public var dad:Character;

    public var camHUD:FlxCamera;
	private var camGame:FlxCamera;
    private var camFollow:FlxObject;

    public static var SONG:SwagSong;
    
	private var noteField:NoteTest;

    public static var daPixelZoom(default, null):Int = 6;

    override public function create():Void {
        super.create();

        camGame = new FlxCamera();
        camHUD = new FlxCamera();
        camHUD.bgColor.alpha = 0;

        FlxG.cameras.reset(camGame);
        FlxG.cameras.add(camHUD, false);

        FlxG.cameras.setDefaultDrawTarget(camGame, true);

        persistentUpdate = persistentDraw = true;

        if (FlxG.sound.music != null) FlxG.sound.music.stop();
        if (SONG == null) SONG = Song.loadFromJson('bopeebo', 'bopeebo');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

        add(stage = new Stage());

        add(gf = new Character(400, 130, 'gf'));
        gf.scrollFactor.set(0.95, 0.95);
        
        add(dad = new Character(100, 100, 'dad'));
        add(bf = new Character(770, 450, 'bf', true));

        remove(stage.foreground); 
        add(stage.foreground);

        noteField = new NoteTest(SONG);
        add(noteField);
        noteField.noteGroup.cameras = [camHUD];

        noteField.generateSong();

        add(camFollow = new FlxObject(gf.getGraphicMidpoint().x, gf.getGraphicMidpoint().y, 1, 1));

        FlxG.camera.follow(camFollow, LOCKON, 0.04);
        FlxG.camera.zoom = 0.9;
        FlxG.camera.snapToTarget();

        FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

        noteField.startingSong = true;
        noteField.startCountdown();
    }

    override function update(elapsed:Float):Void {
        super.update(elapsed);

        camGame.zoom = FlxMath.lerp(0.9, camGame.zoom, 0.95);
        camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
    }

    public function playSingAnim(noteData:Int, ?altAnim:String = ""):Void {
        var altAnim:String = (SONG.notes[Math.floor(curStep / 16)] != null && SONG.notes[Math.floor(curStep / 16)].altAnim) ? '-alt' : '';
        var anims:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
        var data:Int = Std.int(Math.abs(noteData));
        if (data < anims.length) dad.playAnim('${anims[data]}${altAnim}', true);
    }

    function focus(type:Int):Void {
        var characters:Array<Character> = [dad, bf, gf];
        var x:Array<Float> = [150, -100, 0];
        var y:Array<Float> = [-100, -100, 0];

        var char:Character = characters[type];
        
        if (char != null) {
            var mid:FlxPoint = char.getMidpoint();
            camFollow.setPosition(mid.x + x[type], mid.y + y[type]);
            mid.put();
        }
    }

    override function beatHit():Void {
        super.beatHit(); 
        noteField.beatHit();

        if (camGame.zoom < 1.35 && curBeat % 4 == 0) {
            camGame.zoom += 0.015;
            camHUD.zoom += 0.03;
        }

        if (curBeat % 6 == 0) focus(0);
        else if (curBeat % 4 == 0) focus(1);
        else if (curBeat % 2 == 0) focus(2);

        if (gf != null && gf.animation.curAnim != null) {
            if (!gf.animation.curAnim.name.startsWith("sing"))
                if (curBeat % 2 == 0) gf.dance();
        }

        if (dad != null && dad.animation.curAnim != null) {
            if (!dad.animation.curAnim.name.startsWith("sing"))
                dad.dance();
        }

        if (bf != null && bf.animation.curAnim != null) {
            if (!bf.animation.curAnim.name.startsWith("sing"))
                bf.dance();

            if (curBeat % 8 == 7) bf.playAnim('hey', true);
        }
    }

    override function stepHit():Void {
        super.stepHit();
        noteField.resyncVocals();
    }
}