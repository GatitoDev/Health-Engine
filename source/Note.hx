package;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class Note extends FlxSprite {
    public static var swagWidth:Float = 160 * 0.7;
    private static var COLORS:Array<String> = ['purple', 'blue', 'green', 'red'];

    public var strumTime:Float = 0;
    public var mustPress:Bool = false;
    public var noteData:Int = 0;
    public var canBeHit:Bool = false;
    public var tooLate:Bool = false;
    public var wasGoodHit:Bool = false;
    public var prevNote:Note;
    public var modifiedByLua:Bool = false;
    public var sustainLength:Float = 0;
    public var isSustainNote:Bool = false;
    public var noteScore:Float = 1;
    public var rating:String = "shit";

    public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false) {
        super();

        this.prevNote = (prevNote == null) ? this : prevNote;
        this.strumTime = (strumTime < 0) ? 0 : strumTime;
        this.noteData = noteData;
        this.isSustainNote = sustainNote;

        x += 50 + (swagWidth * noteData);
        y -= 2000;

        var isPixel:Bool = TestPlay.SONG.noteStyle == 'pixel';

        if (isPixel) setupPixelNote();
        else setupNormalNote();

        updateHitbox();
        animation.play('${COLORS[noteData]}Scroll');

        if (FlxG.save.data.downscroll && sustainNote) flipY = true;
        if (isSustainNote && prevNote != null) sustainLogic(isPixel);
    }

    private function setupPixelNote() {
        loadGraphic(Paths.image('weeb/pixelUI/' + (isSustainNote ? 'arrowEnds' : 'arrows-pixels')), true, isSustainNote ? 7 : 17, isSustainNote ? 6 : 17);
        
        for (i in 0...COLORS.length) {
            var color:String = COLORS[i].toLowerCase();
            animation.add('${color}Scroll', [isSustainNote ? i : (i == 1 ? 5 : i == 2 ? 6 : i == 3 ? 7 : 4)]);
            
            if (isSustainNote) {
                animation.add('${color}hold', [i % 2 == 0 ? 0 : 1]);
                animation.add('${color}holdend', [i + 4]);
            }
        }
        setGraphicSize(Std.int(width * TestPlay.daPixelZoom));
    }

    private function setupNormalNote() {
        frames = Paths.getSparrowAtlas('NOTE_assets');
        
        for (name in COLORS) {
            var color:String = name.toLowerCase();
            animation.addByPrefix('${color}Scroll', '${color}0');
            animation.addByPrefix('${color}holdend', '${color} hold end');
            animation.addByPrefix('${color}hold', '${color} hold piece');
        }
        
        setGraphicSize(Std.int(width * 0.7));
        antialiasing = true;
    }

    private function sustainLogic(isPixel:Bool):Void {
        noteScore *= 0.2;
        alpha = 0.6;
        x += width / 2;
        
        animation.play('${COLORS[noteData].toLowerCase()}holdend');
        updateHitbox();
        
        x -= width / 2;
        if (isPixel) x += 30;

        if (prevNote.isSustainNote) {
            prevNote.animation.play('${COLORS[prevNote.noteData].toLowerCase()}hold');
            
            var scrollSpeed:Float = (FlxG.save.data.scrollSpeed != 1) ? FlxG.save.data.scrollSpeed : TestPlay.SONG.speed;
            prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * scrollSpeed;
            prevNote.updateHitbox();
            
            if (antialiasing) prevNote.scale.y *= 1.0 + (1.0 / prevNote.frameHeight);
        }

        if (FlxG.save.data.downscroll) {
            y -= height;
            flipY = true;
        } else y += height / 2;
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (mustPress) {
            canBeHit = (strumTime > Conductor.songPosition - Conductor.safeZoneOffset * 1.5) 
             && (strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.5);
            
            tooLate = !wasGoodHit && (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale);
        } else {
            canBeHit = false;
            wasGoodHit = strumTime <= Conductor.songPosition;
        }

        if (tooLate && alpha > 0.3) 
            alpha = 0.3;
    }
}