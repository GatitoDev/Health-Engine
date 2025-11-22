package;

import flixel.FlxG;
import Song.SwagSong;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;

class StrumLine
{
    public static function makeStatic(player:Int, line:FlxSprite, notes:FlxTypedGroup<FlxSprite>, playerStrums:FlxTypedGroup<FlxSprite>, song:SwagSong, storyMode:Bool):Void {
        for (i in 0...4) {
            final x:Float = Note.swagWidth * i + 50 + (FlxG.width / 2 * player);
            final pixel:Bool = song.noteStyle == 'pixel';
            final arrow:FlxSprite = makeArrow(pixel, x, line.y, i);

            if (!storyMode) {
                arrow.y -= 10;
                arrow.alpha = 0;
                FlxTween.tween(arrow, {y: arrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
            }

            arrow.ID = i;
            if (player == 1) playerStrums.add(arrow);
            notes.add(arrow);
        }
    }

    private static function makeArrow(pixel:Bool, x:Float, y:Float, dir:Int):FlxSprite
    {
        var arrow:FlxSprite = new FlxSprite(x, y);
        final dirs:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
        final prefs:Array<String> = ['left', 'down', 'up', 'right'];
        final cols:Array<String> = ['purple', 'blue', 'green', 'red'];
        final arrColors:Array<String> = ['arrowLEFT', 'arrowDOWN', 'arrowUP', 'arrowRIGHT'];
        
        if (pixel) {
            arrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
            arrow.antialiasing = false;
            arrow.setGraphicSize(Std.int(arrow.width * PlayState.daPixelZoom));
            arrow.animation.add('static', [dir]);
            arrow.animation.add('pressed', [dir + 4, dir + 8], 12, false);
            arrow.animation.add('confirm', [dir + 12, dir + 16], dir == 2 ? 12 : 24, false);
            for (j in 0...4) arrow.animation.add(cols[j], [getPixelFrame(j)]);
        } else {
            arrow.frames = Paths.getSparrowAtlas('NOTE_assets');
            arrow.antialiasing = true;
            arrow.setGraphicSize(Std.int(arrow.width * 0.7));
            arrow.animation.addByPrefix('static', 'arrow${dirs[dir]}');
            arrow.animation.addByPrefix('pressed', '${prefs[dir]} press', 24, false);
            arrow.animation.addByPrefix('confirm', '${prefs[dir]} confirm', 24, false);
            for (j in 0...4) arrow.animation.addByPrefix(cols[j], arrColors[j]);
        }

        arrow.animation.play('static');
        arrow.updateHitbox();
        arrow.scrollFactor.set();

        return arrow;
    }

    private static function getPixelFrame(colIdx:Int):Int {
        return switch (colIdx) {
            case 0: 4;
            case 1: 5;
            case 2: 6;
            case 3: 7;
            case _: 0;
        }
    }
}