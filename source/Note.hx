package;

import PlayState;
import flixel.FlxG;
import data.Sprite;

using StringTools;

class Note extends Sprite {
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
	public static var swagWidth:Float = 160 * 0.7;
	public var rating:String = "shit";

	private static var COLORS:Array<String> = ['purple', 'blue', 'green', 'red'];

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false) {
		super();
		this.prevNote = prevNote == null ? this : prevNote;
		this.strumTime = strumTime < 0 ? 0 : strumTime;
		this.noteData = noteData;
		this.isSustainNote = sustainNote;
		x += 50 + swagWidth * noteData;
		y -= 2000;

		var isPixel = PlayState.SONG.noteStyle == 'pixel';

		if (isPixel) {
			loadGraphic(Paths.image('weeb/pixelUI/' + (isSustainNote ? 'arrowEnds' : 'arrows-pixels'), 'week6'), true, isSustainNote ? 7 : 17, isSustainNote ? 6 : 17);
			for (i in 0...COLORS.length) {
				var c = COLORS[i].toLowerCase();
				animation.add(c + 'Scroll', [isSustainNote ? i : (i == 1 ? 5 : i == 2 ? 6 : i == 3 ? 7 : 4)]);
				if (isSustainNote) {
					animation.add(c + 'hold', [i % 2 == 0 ? 0 : 1]);
					animation.add(c + 'holdend', [i + 4]);
				}
			}
			setGraphicSize(Std.int(width * PlayState.daPixelZoom));
		} else {
			frames = Paths.getSparrowAtlas('NOTE_assets');
			for (c in COLORS) {
				var cl = c.toLowerCase();
				animation.addByPrefix(cl + 'Scroll', cl + '0');
				animation.addByPrefix(cl + 'holdend', cl + ' hold end');
				animation.addByPrefix(cl + 'hold', cl + ' hold piece');
			}
			setGraphicSize(Std.int(width * 0.7));
			antialiasing = true;
		}
		updateHitbox();
		animation.play(COLORS[noteData] + 'Scroll');

		if (FlxG.save.data.downscroll && sustainNote) flipY = true;

		if (isSustainNote && prevNote != null) {
			noteScore *= 0.2;
			alpha = 0.6;
			x += width / 2;
			animation.play([for (c in COLORS) c.toLowerCase() + 'holdend'][noteData]);
			updateHitbox();
			x -= width / 2;
			if (PlayState.curStage.startsWith('school')) x += 30;

			if (prevNote.isSustainNote) {
				prevNote.animation.play([for (c in COLORS) c.toLowerCase() + 'hold'][prevNote.noteData]);
				var scrollSpeed = (FlxG.save.data.scrollSpeed != 1) ? FlxG.save.data.scrollSpeed : PlayState.SONG.speed;
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.5 * scrollSpeed;
				prevNote.updateHitbox();
			}

			if (FlxG.save.data.downscroll) {
				y -= height;
				flipY = true;
			} else y += height / 2;
		}
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
		if (tooLate && alpha > 0.3) alpha = 0.3;
	}
}