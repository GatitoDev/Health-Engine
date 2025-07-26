package data;

import flixel.math.FlxPoint;
import flixel.graphics.frames.FlxTileFrames;
import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class Sprite extends FlxSprite {
    public var animOffsets:Map<String, Array<Float>> = new Map();
    
    public function new(x:Float = 0, y:Float = 0) {
        super(x, y);
    }

    override public function loadGraphic(Graphic:FlxGraphicAsset, Animated:Bool = false,
     Width:Int = 0, Height:Int = 0, Unique:Bool = false,?Key:String):Sprite {
        var graph:FlxGraphic = FlxG.bitmap.add(Graphic, Unique, Key);
        if (graph == null) return this;
        Width = (Width == 0) ? (Animated ? graph.height : graph.width) : (Width > graph.width ? graph.width : Width);
        Height = (Height == 0) ? (Animated ? Width : graph.height) : (Height > graph.height ? graph.height : Height);
        frames = Animated ? FlxTileFrames.fromGraphic(graph, FlxPoint.get(Width, Height)): graph.imageFrame;
        return this;
    }
    public static function create(?image:String, x:Float = 0, y:Float = 0, scrollX:Float = 1.0, scrollY:Float = 1.0, 
     ?options:SpriteOptions, ?animOptions:AnimOptions):Sprite {
        final sprite = new Sprite(x, y);
        
        if (image != null) {
            animOptions != null && animOptions.atlas ? sprite.frames = Paths.getSparrowAtlas(image) 
             : sprite.loadGraphic(Paths.image(image), animOptions != null);
        }
        
        if (animOptions != null && animOptions.animations != null) {
            for (anim in animOptions.animations) {
                animOptions.atlas ? sprite.animation.addByPrefix(anim.name, anim.prefix, anim.frameRate, anim.loop)
                 : sprite.animation.add(anim.name, anim.frames, anim.frameRate, anim.loop);
            }
            final defaultAnim = animOptions.defaultAnim ?? animOptions.animations[0]?.name;
            if (defaultAnim != null) sprite.animation.play(defaultAnim);
        }
        
        if (options?.background == true) {
            sprite.active = false;
            scrollX = scrollY = 0.9;
        }
        return configure(sprite, scrollX, scrollY, options);
    }

    public function addOffset(name:String, x:Float = 0, y:Float = 0) {animOffsets.set(name, [x, y]);}
    public function playAnim(name:String, force:Bool = false, reversed:Bool = false, frame:Int = 0):Void {
        animation.play(name, force, reversed, frame);
        var offset = animOffsets.exists(name) ? animOffsets.get(name) : [0.0, 0.0];
        this.offset.set(offset[0], offset[1]);
    }

    public static function dance(sprite:Sprite, forceplay:Bool = false):Void 
    {if (sprite.animation?.curAnim != null) sprite.playAnim(sprite.animation.curAnim.name, forceplay);}

    override public function destroy() {
        if (frames != null) frames = null;
        animOffsets.clear();
        super.destroy();
    }

    private static function configure(sprite:Sprite, scrollX:Float, scrollY:Float, ?options:SpriteOptions):Sprite {
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
    ?background:Bool
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