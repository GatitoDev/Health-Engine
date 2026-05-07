package;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.display.StageScaleMode;

class Main extends Sprite
{
    public static final game = {
        width: 1280,
        height: 720,
        initialState: TestPlay,
        framerate: 60,
        skipSplash: true,
        startFullscreen: false
    };

    public static function main():Void { Lib.current.addChild(new Main()); }

    public function new() {
        super();
        if (stage != null) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(?E:Event):Void {
        if (hasEventListener(Event.ADDED_TO_STAGE)) removeEventListener(Event.ADDED_TO_STAGE, init);
        
        Lib.current.stage.align = "tl";
        Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
        
        setupGame();
        
        stage.addEventListener(Event.ACTIVATE, onActivate);
    }

    private function setupGame():Void {
        #if !debug game.initialState = TestPlay; #end
        
        addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
        
        FlxG.fixedTimestep = false;
        FlxG.game.focusLostFramerate = 60;
        KadeEngineData.initFPS(this);
    }

    private function onActivate(_:Event):Void {
        KadeEngineData.restoreFPSCap();
        #if desktop if (Lib.current.stage.frameRate != KadeEngineData.fpsCap) Lib.current.stage.frameRate = KadeEngineData.fpsCap; #end
    }
}