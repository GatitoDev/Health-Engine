package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import Song.SwagSong;

class StrumLine
{
    private static var DIRECTIONS:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
    private static var PREFIXES:Array<String> = ['left', 'down', 'up', 'right'];
    private static var COLORS:Array<String> = ['purple', 'blue', 'green', 'red'];

    public static function makeStatic(player:Int, line:FlxSprite, notes:FlxTypedGroup<FlxSprite>, strums:FlxTypedGroup<FlxSprite>, song:SwagSong, story:Bool):Void {
        final isPixel:Bool = (song.noteStyle == 'pixel');

        for (i in 0...4) {
            var arrow:FlxSprite = draw(isPixel, (Note.swagWidth * i) + (FlxG.width / 2 * player) + (2 * 42), line.y, i);

            if (!story) {
                arrow.y -= 10;
                arrow.alpha = 0;
                FlxTween.tween(arrow, {y: arrow.y + 10, alpha: 1}, 1, {
                    ease: FlxEase.circOut, 
                    startDelay: 0.5 + (0.2 * i)
                });
            }

            arrow.ID = i;
            notes.add(arrow);
            
            if (player == 1) strums.add(arrow);
        }
    }

    private static function draw(isPixel:Bool, x:Float, y:Float, id:Int):FlxSprite {
        var arrow:FlxSprite = new FlxSprite(x, y);
        arrow.scrollFactor.set();

        if (isPixel)  {
            arrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
            arrow.antialiasing = false;
            arrow.setGraphicSize(Std.int(arrow.width * TestPlay.daPixelZoom));
            
            arrow.animation.add('static', [id]);
            arrow.animation.add('pressed', [id + 4, id + 8], 12, false);
            arrow.animation.add('confirm', [id + 12, id + 16], (id == 2 ? 12 : 24), false);
            
            arrow.animation.add(COLORS[id], [id + 4]); 
        } else {
            arrow.frames = Paths.getSparrowAtlas('NOTE_assets');
            arrow.antialiasing = true;
            arrow.setGraphicSize(Std.int(arrow.width * 0.7));

            arrow.animation.addByPrefix('static', 'arrow${DIRECTIONS[id]}');
            arrow.animation.addByPrefix('pressed', '${PREFIXES[id]} press', 24, false);
            arrow.animation.addByPrefix('confirm', '${PREFIXES[id]} confirm', 24, false);
            
            arrow.animation.addByPrefix(COLORS[id], 'arrow${DIRECTIONS[id]}');
        }

        arrow.updateHitbox();
        arrow.animation.play('static');

        return arrow;
    }
}