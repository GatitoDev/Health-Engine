package;

import flixel.FlxGame;
import openfl.Lib;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
    public static final game = {
        width: 1280, // WINDOW width
        height: 720, // WINDOW height
        initialState: TitleState, // initial game state
        framerate: 60, // default framerate
        skipSplash: true, // if the default flixel splash screen should be skipped
        startFullscreen: false // if the game should start at fullscreen mode
    };

    public static function main():Void { Lib.current.addChild(new Main()); }

    public function new() {
        super();
        if (stage != null) init();
        else addEventListener(Event.ADDED_TO_STAGE, init);
    }

    private function init(?E:Event):Void {
        if (hasEventListener(Event.ADDED_TO_STAGE)) removeEventListener(Event.ADDED_TO_STAGE, init);
        setupGame();
    }

    private function setupGame():Void {
        #if !debug game.initialState = TitleState; #end
        addChild(new FlxGame(game.width, game.height, game.initialState, game.framerate, game.framerate, game.skipSplash, game.startFullscreen));
        
        // Inicializar FPS counter
        KadeEngineData.initFPS(this);
    }
}