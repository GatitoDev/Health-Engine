import flixel.math.FlxMath;
import openfl.Lib;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.display.Sprite;

class KadeEngineData
{
    private static var fpsCounter:FPS;
    private static var parent:Sprite;
    
    public static function initSave()
    {
        if (FlxG.save.data.newInput == null) FlxG.save.data.newInput = true;
        if (FlxG.save.data.downscroll == null) FlxG.save.data.downscroll = false;
        if (FlxG.save.data.dfjk == null) FlxG.save.data.dfjk = false;
        if (FlxG.save.data.accuracyDisplay == null) FlxG.save.data.accuracyDisplay = true;
        if (FlxG.save.data.offset == null) FlxG.save.data.offset = 0;
        if (FlxG.save.data.songPosition == null) FlxG.save.data.songPosition = false;
        
        if (FlxG.save.data.changedHit == null) {
            FlxG.save.data.changedHitX = -1;
            FlxG.save.data.changedHitY = -1;
            FlxG.save.data.changedHit = false;
        }
        
        if (FlxG.save.data.scrollSpeed == null) FlxG.save.data.scrollSpeed = 1;
        if (FlxG.save.data.npsDisplay == null) FlxG.save.data.npsDisplay = false;
        if (FlxG.save.data.frames == null) FlxG.save.data.frames = 10;
        if (FlxG.save.data.accuracyMod == null) FlxG.save.data.accuracyMod = 1;
        if (FlxG.save.data.ghost == null) FlxG.save.data.ghost = true;
        if (FlxG.save.data.distractions == null) FlxG.save.data.distractions = true;
        if (FlxG.save.data.flashing == null) FlxG.save.data.flashing = true;
        if (FlxG.save.data.botplay == null) FlxG.save.data.botplay = false;

        if (FlxG.save.data.fps == null) FlxG.save.data.fps = false;
        if (FlxG.save.data.fpsCap == null) FlxG.save.data.fpsCap = 60;
        FlxG.save.data.fpsCap = FlxMath.bound(FlxG.save.data.fpsCap, 60, 200);
        setFPSCap(FlxG.save.data.fpsCap);

        Conductor.recalculateTimings();
    }

    public static function saveSettings():Void
    {
        FlxG.save.flush();
    }

    public static function initFPS(parent:Sprite):Void
    {
        #if !mobile
        KadeEngineData.parent = parent;
        fpsCounter = new FPS(10, 3, 0xFFFFFF);
        parent.addChild(fpsCounter);
        toggleFPS(FlxG.save.data.fps);
        #end
    }

    public static function toggleFPS(fpsEnabled:Bool):Void
    {
        FlxG.save.data.fps = fpsEnabled;
        if (fpsCounter != null) {
            fpsCounter.visible = fpsEnabled;
        }
        saveSettings();
    }

    public static function setFPSCap(cap:Float):Void
    {
        FlxG.save.data.fpsCap = FlxMath.bound(cap, 60, 200);
        Lib.current.stage.frameRate = FlxG.save.data.fpsCap;
        saveSettings();
    }

    public static function getFPSCap():Float
    {
        return FlxG.save.data.fpsCap;
    }

    public static function getFPS():Float
    {
        return fpsCounter != null ? fpsCounter.currentFPS : 0;
    }
}