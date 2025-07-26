package;

import flixel.*;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxGroup.FlxTypedGroup;

import openfl.Lib;
#if windows import llua.Lua; #end

class PauseSubState extends MusicBeatSubstate {
    var grpMenuShit:FlxTypedGroup<Alphabet>;
    var menuItems:Array<String> = ['Resume', 'Restart Song', 'Exit to menu'];
    var curSelected:Int = 0;
    var pauseMusic:FlxSound;
    
    public function new(x:Float, y:Float) {
        super();
        
        pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
        pauseMusic.volume = 0;
        pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
        FlxG.sound.list.add(pauseMusic);

        var bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bg.alpha = bg.scrollFactor.set().x = 0;
        add(bg);

        function createText(y:Float, text:String):FlxText {
            var txt = new FlxText(20, y, 0, text, 32);
            txt.scrollFactor.set();
            txt.setFormat(Paths.font("vcr.ttf"), 32);
            txt.updateHitbox();
            txt.x = FlxG.width - (txt.width + 20);
            txt.alpha = 0;
            add(txt);
            return txt;
        }

        var levelInfo:FlxText = createText(15, PlayState.SONG.song);
        var levelDifficulty:FlxText = createText(15 + 32, CoolUtil.difficultyString());

        FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
        FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
        FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

        grpMenuShit = new FlxTypedGroup<Alphabet>();
        add(grpMenuShit);

        for (i in 0...menuItems.length) {
            var songText = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
            songText.isMenuItem = true;
            songText.targetY = i;
            grpMenuShit.add(songText);
        }

        changeSelection();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    override function update(elapsed:Float) {
        if (pauseMusic.volume < 0.5) pauseMusic.volume += 0.01 * elapsed;
        super.update(elapsed);

        if (controls.UP_P) changeSelection(-1);
        else if (controls.DOWN_P) changeSelection(1);

        if (controls.ACCEPT) switch (menuItems[curSelected]) {
            case "Resume": 
				FlxG.sound.play(Paths.sound('cancelMenu'));
				close();
            case "Restart Song": 
				FlxG.sound.play(Paths.sound('confirmMenu'));
				FlxG.switchState(() -> new PlayState());
            case "Exit to menu":
				FlxG.sound.play(Paths.sound('cancelMenu'));
                if (PlayState.loadRep) {
                    FlxG.save.data.botplay = false;
                    FlxG.save.data.scrollSpeed = 1;
                    FlxG.save.data.downscroll = false;
                }
                PlayState.loadRep = false;
                #if windows if (PlayState.luaModchart != null) {
                    PlayState.luaModchart.die();
                    PlayState.luaModchart = null;
                } #end
                if (FlxG.save.data.fpsCap > 290) KadeEngineData.setFPSCap(290);
                FlxG.switchState(() -> new MainMenuState());
        }
    }

    override function destroy() {
        pauseMusic.destroy();
        super.destroy();
    }

    function changeSelection(change:Int = 0):Void {
		FlxG.sound.play(Paths.sound('scrollMenu'));
        curSelected = (curSelected + change + menuItems.length) % menuItems.length;
        for (i in 0...grpMenuShit.members.length) {
            var item = grpMenuShit.members[i];
            item.targetY = i - curSelected;
            item.alpha = item.targetY == 0 ? 1 : 0.6;
        }
    }
}