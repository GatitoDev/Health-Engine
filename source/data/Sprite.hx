package data;

import flixel.graphics.FlxGraphic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.graphics.frames.FlxTileFrames;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Sprite extends FlxSprite {
    public var animOffsets:Map<String, Array<Float>> = [];
    
    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
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

    public static function create(?image:String, x:Float = 0, y:Float = 0, scrollX:Float = 1.0, 
     scrollY:Float = 1.0, ?options:SpriteOptions, ?animOptions:AnimOptions):Sprite {
        final sprite = new Sprite(x, y);
        
        if (image != null) {
            animOptions?.atlas ? sprite.frames = Paths.getSparrowAtlas(image)
                : sprite.loadGraphic(Paths.image(image), animOptions != null);
        }
        
        if (animOptions?.animations != null) {
            for (anim in animOptions.animations) {
                animOptions.atlas ? sprite.animation.addByPrefix(anim.name, anim.prefix, anim.frameRate, anim.loop)
                    : sprite.animation.add(anim.name, anim.frames, anim.frameRate, anim.loop);
            }
            final defaultAnim = animOptions.defaultAnim ?? animOptions.animations[0]?.name;
            if (defaultAnim != null) sprite.animation.play(defaultAnim);
        }
        
        sprite.active = false;
        return configure(sprite, scrollX, scrollY, options);
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0) {
        animOffsets.set(name, [x, y]);
    }

    public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
        animation.play(name, force, reversed, frame);
        final offset = animOffsets.exists(name) ? animOffsets.get(name) : [0.0, 0.0];
        this.offset.set(offset[0], offset[1]);
    }

    public static function dance(sprite:Sprite, forceplay:Bool = false):Void {
        if (sprite.animation?.curAnim != null) 
            sprite.playAnim(sprite.animation.curAnim.name, forceplay);
    }

    override public function destroy() {
        frames = null;
        animOffsets.clear();
        super.destroy();
    }

    static function configure(sprite:Sprite, scrollX:Float, scrollY:Float, ?options:SpriteOptions):Sprite {
        sprite.scrollFactor.set(scrollX, scrollY);
        sprite.antialiasing = options?.antialiasing ?? true;
        
        if (options != null) {
            if (options.scale != null) {
                sprite.setGraphicSize(Std.int(sprite.width * options.scale));
                sprite.updateHitbox();
            }
            if (options.color != null) sprite.color = options.color;
            if (options.alpha != null) sprite.alpha = options.alpha;
        }
        return sprite;
    }
}

typedef SpriteOptions = {
    ?scale:Float, 
    ?antialiasing:Bool,
    ?color:FlxColor,
    ?alpha:Float,
}

typedef AnimOptions = {
    ?atlas:Bool,
    ?animations:Array<AnimData>,
    ?defaultAnim:String
}

typedef AnimData = {
    name:String,
    ?prefix:String,
    ?frames:Array<Int>,
    frameRate:Int,
    loop:Bool
}