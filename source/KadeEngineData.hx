import flixel.math.FlxMath;
import openfl.Lib;
import flixel.FlxG;
import openfl.display.FPS;
import openfl.display.Sprite;

class KadeEngineData
{
    private static var fpsCounter:FPS;
    private static var parent:Sprite;

    public static var newInput:Bool = true;
    public static var downscroll:Bool = false; 
    public static var dfjk:Bool = false;
    public static var botplay:Bool = false;
    public static var accuracyDisplay:Bool = true;
    public static var songPosition:Bool = false;
    public static var ghost:Bool = true;
    public static var distractions:Bool = true;
    public static var flashing:Bool = true;
    public static var changedHit:Bool = false;
    public static var changedHitX:Float = -1;
    public static var changedHitY:Float = -1;
    public static var scrollSpeed:Float = 1;
    public static var offset:Float = 0;
    public static var accuracyMod:Float = 1;
    public static var fps:Bool = false;
    public static var fpsCap:Float = 60;
    public static var frames:Int = 10;
    
    public static function initSave()
    {
        newInput = (FlxG.save.data.newInput != null) ? FlxG.save.data.newInput : true;
        downscroll = (FlxG.save.data.downscroll != null) ? FlxG.save.data.downscroll : false;
        dfjk = (FlxG.save.data.dfjk != null) ? FlxG.save.data.dfjk : false;
        botplay = (FlxG.save.data.botplay != null) ? FlxG.save.data.botplay : false;
        accuracyDisplay = (FlxG.save.data.accuracyDisplay != null) ? FlxG.save.data.accuracyDisplay : true;
        songPosition = (FlxG.save.data.songPosition != null) ? FlxG.save.data.songPosition : false;
        ghost = (FlxG.save.data.ghost != null) ? FlxG.save.data.ghost : true;
        distractions = (FlxG.save.data.distractions != null) ? FlxG.save.data.distractions : true;
        flashing = (FlxG.save.data.flashing != null) ? FlxG.save.data.flashing : true;
        changedHit = (FlxG.save.data.changedHit != null) ? FlxG.save.data.changedHit : false;
        changedHitX = (FlxG.save.data.changedHitX != null) ? FlxG.save.data.changedHitX : -1;
        changedHitY = (FlxG.save.data.changedHitY != null) ? FlxG.save.data.changedHitY : -1;
        scrollSpeed = (FlxG.save.data.scrollSpeed != null) ? FlxG.save.data.scrollSpeed : 1;
        offset = (FlxG.save.data.offset != null) ? FlxG.save.data.offset : 0;
        accuracyMod = (FlxG.save.data.accuracyMod != null) ? FlxG.save.data.accuracyMod : 1;
        fps = (FlxG.save.data.fps != null) ? FlxG.save.data.fps : false;
        fpsCap = (FlxG.save.data.fpsCap != null) ? FlxMath.bound(FlxG.save.data.fpsCap, 60, 200) : 60;
        frames = (FlxG.save.data.frames != null) ? FlxG.save.data.frames : 10;

        setFPSCap(fpsCap);
        Conductor.recalculateTimings();
    }

    public static function saveSettings():Void
    {
        FlxG.save.data.newInput = newInput;
        FlxG.save.data.downscroll = downscroll;
        FlxG.save.data.dfjk = dfjk;
        FlxG.save.data.botplay = botplay;
        FlxG.save.data.accuracyDisplay = accuracyDisplay;
        FlxG.save.data.songPosition = songPosition;
        FlxG.save.data.ghost = ghost;
        FlxG.save.data.distractions = distractions;
        FlxG.save.data.flashing = flashing;
        FlxG.save.data.changedHit = changedHit;
        FlxG.save.data.changedHitX = changedHitX;
        FlxG.save.data.changedHitY = changedHitY;
        FlxG.save.data.scrollSpeed = scrollSpeed;
        FlxG.save.data.offset = offset;
        FlxG.save.data.accuracyMod = accuracyMod;
        FlxG.save.data.fps = fps;
        FlxG.save.data.fpsCap = fpsCap;
        FlxG.save.data.frames = frames;

        FlxG.save.flush();
    }

    public static function initFPS(parent:Sprite):Void {
        #if !mobile
        KadeEngineData.parent = parent;
        fpsCounter = new FPS(10, 3, 0xFFFFFF);
        parent.addChild(fpsCounter);
        toggleFPS(fps);
        #end
    }

    public static function toggleFPS(fpsEnabled:Bool):Void {
        fps = fpsEnabled;
        if (fpsCounter != null) fpsCounter.visible = fpsEnabled;
        saveSettings();
    }

    public static function setFPSCap(cap:Float):Void {
        fpsCap = FlxMath.bound(cap, 60, 200);
        Lib.current.stage.frameRate = fpsCap;
        saveSettings();
    }

    public static function getFPSCap():Float { return fpsCap; }
    public static function getFPS():Float { return fpsCounter != null ? fpsCounter.currentFPS : 0; }
}