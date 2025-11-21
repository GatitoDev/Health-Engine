package data;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxTileFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;

class BaseSprite extends FlxSprite {
    public var animOffsets:Map<String, Array<Float>> = [];
    
    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
        animOffsets = new Map();
    }

    private static var _pointCache:FlxPoint = FlxPoint.get();
    
    override public function loadGraphic(graphic:FlxGraphicAsset, animated:Bool = false, width:Int = 0, height:Int = 0, unique:Bool = false, ?key:String):FlxSprite {
        var graph:FlxGraphic = FlxG.bitmap.add(graphic, unique, key);
        if (graph == null) return this;
        
        final frameWidth:Float = width == 0 ? (animated ? graph.height : graph.width) : Math.min(width, graph.width);
        final frameHeight:Float = height == 0 ? (animated ? frameWidth : graph.height) : Math.min(height, graph.height);
        
        _pointCache.set(frameWidth, frameHeight);
        frames = animated ? FlxTileFrames.fromGraphic(graph, _pointCache) : graph.imageFrame;
        return this;
    }

    public inline function addOffset(name:String, x:Float = 0, y:Float = 0):Void animOffsets.set(name, [x, y]);
    public inline function getOffset(name:String):Array<Float> return animOffsets.exists(name) ? animOffsets.get(name) : [0.0, 0.0];

    public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
        animation.play(name, force, reversed, frame);
        final offset = getOffset(name);
        this.offset.set(offset[0], offset[1]);
    }

    override public function destroy() {
        if (animOffsets != null) animOffsets.clear();
        frames = null;
        super.destroy();
    }
}