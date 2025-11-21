package data;

import flixel.util.FlxColor;

class SpriteHelper {
    public static function make(?image:String, x:Float = 0, y:Float = 0, scrollX:Float = 1.0, 
     scrollY:Float = 1.0, ?scale:Float, ?color:FlxColor, ?alpha:Float, antialiasing:Bool = true):BaseSprite {
        final sprite = new BaseSprite(x, y);
        
        // Cargar gráfico
        if (image != null) {
            sprite.loadGraphic(Paths.image(image));
        }
        
        sprite.active = false;
        return setup(sprite, scrollX, scrollY, scale, color, alpha, antialiasing);
    }

    public static function makeAnimated(image:String, x:Float = 0, y:Float = 0, scrollX:Float = 1.0, 
     scrollY:Float = 1.0, animations:Array<Array<Dynamic>>, ?defaultAnim:String, 
     ?scale:Float, ?color:FlxColor, ?alpha:Float, antialiasing:Bool = true):BaseSprite {
        final sprite = new BaseSprite(x, y);
        
        // Cargar gráfico con soporte para animaciones
        sprite.frames = Paths.getSparrowAtlas(image);
        
        // Configurar animaciones
        if (animations != null && animations.length > 0) {
            setupAnimations(sprite, animations, defaultAnim);
        }
        
        sprite.active = false;
        return setup(sprite, scrollX, scrollY, scale, color, alpha, antialiasing);
    }

    public static function play(sprite:BaseSprite, force:Bool = false):Void {
        if (sprite.animation?.curAnim != null) {
            sprite.playAnim(sprite.animation.curAnim.name, force);
        }
    }

    static function setupAnimations(sprite:BaseSprite, anims:Array<Array<Dynamic>>, ?defaultAnim:String):Void {
        for (anim in anims) {
            // Formato: [name, prefix, ?frameRate, ?loop]
            // Si no se especifica frameRate, usa 24
            // Si no se especifica loop, usa false
            var name:String = anim[0];
            var prefix:String = anim[1];
            var frameRate:Int = anim.length > 2 && anim[2] != null ? anim[2] : 24;
            var loop:Bool = anim.length > 3 && anim[3] != null ? anim[3] : false;
            
            sprite.animation.addByPrefix(name, prefix, frameRate, loop);
        }
        
        // Si no se especifica defaultAnim, usar el nombre de la primera animación
        final firstAnim = defaultAnim ?? anims[0][0];
        if (firstAnim != null) {
            sprite.animation.play(firstAnim);
        }
    }

    static function setup(sprite:BaseSprite, scrollX:Float, scrollY:Float, ?scale:Float, 
     ?color:FlxColor, ?alpha:Float, antialiasing:Bool):BaseSprite {
        sprite.scrollFactor.set(scrollX, scrollY);
        sprite.antialiasing = antialiasing;
        
        if (scale != null) {
            sprite.setGraphicSize(Std.int(sprite.width * scale));
            sprite.updateHitbox();
        }
        if (color != null) sprite.color = color;
        if (alpha != null) sprite.alpha = alpha;
        
        return sprite;
    }
}