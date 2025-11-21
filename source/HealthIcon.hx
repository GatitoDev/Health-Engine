package;
import flixel.ui.FlxBar;
import flixel.math.FlxMath;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite {
    public var sprTracker:FlxSprite;
    public var isPlayer:Bool = false;

    public function new(char:String = 'bf', isPlayer:Bool = false) {
        super();
        this.isPlayer = isPlayer;
        loadGraphic(Paths.image('iconGrid'), true, 150, 150);
        
        animation.add('bf', [0, 1], 0, false, isPlayer);
        animation.add('face', [10, 11], 0, false, isPlayer);
        animation.add('dad', [12, 13], 0, false, isPlayer);
        animation.add('bf-old', [14, 15], 0, false, isPlayer);
        animation.add('gf', [16], 0, false, isPlayer);
        animation.play(char);
        scrollFactor.set();
    }

	public function onStepHit(curStep:Int):Void {
        if (curStep % 2 != 0) return;
        setGraphicSize(Std.int(width*1.2), Std.int(height*1.2));
        updateHitbox();
    }

    public function updateIcons(elapsed:Float, healthBar:FlxBar) {
        inline function updateIcon(icon:FlxSprite, scaleMult:Float) {
			icon.setGraphicSize(Std.int(icon.frameWidth * scaleMult));
   			icon.updateHitbox();
		}
		updateIcon(this, FlxMath.lerp(1, scale.x, Math.exp(-elapsed * 9)));
		var baseX:Float = healthBar.x + (healthBar.width * (1 - healthBar.percent * 0.01));
        x = isPlayer ? baseX - 26 : baseX - (width - 26);
        animation.curAnim.curFrame = isPlayer ? (healthBar.percent < 20 ? 1 : 0) : (healthBar.percent > 80 ? 1 : 0);
	}

    override function update(elapsed:Float) {
        super.update(elapsed);
        if (sprTracker != null) setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
    }
}