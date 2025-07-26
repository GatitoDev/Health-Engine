package;

import flixel.FlxG;
import data.Sprite;

class NoteSplash extends Sprite {
    static final COLORS:Array<String> = ["purple", "blue", "green", "red"];
    static final ANIM_TYPES:Array<String> = ["note impact 1 ", "note impact 2 "];

    public function new(x:Float = 0, y:Float = 0, ?note:Int = 0) {
        super(x, y);
        setupAnimations();
        setupNoteSplash(x, y, note);
    }

    function setupAnimations():Void {
        frames = Paths.getSparrowAtlas('noteSplashes');
        for (i => color in COLORS) for (j => anim in ANIM_TYPES) animation.addByPrefix('note$i-$j', anim + color, 24, false);
    }

    public function setupNoteSplash(x:Float, y:Float, ?note:Int = 0):Void {
        setPosition(x, y);
        alpha = 0.6;
        animation.play('note$note-${FlxG.random.int(0, ANIM_TYPES.length - 1)}', true);
        animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
        updateHitbox();
        offset.set(width * 0.3, height * 0.3);
    }

    override public function update(elapsed:Float):Void {
        if (animation.curAnim != null && animation.curAnim.finished) kill();
        super.update(elapsed);
    }
}