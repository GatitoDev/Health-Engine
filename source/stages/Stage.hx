package stages;

import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup;

class Stage extends FlxTypedGroup<FlxBasic> 
{
    private var PATH:String = 'stages/stage/';
    
    public var background:FlxTypedGroup<FlxSprite>;
    public var foreground:FlxTypedGroup<FlxSprite>;

    public function new() {
        super();

        add(background = new FlxTypedGroup<FlxSprite>());
        add(foreground = new FlxTypedGroup<FlxSprite>());

        drawStage();
    }

    private function drawStage():Void {
        var stageback:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('${PATH}stageback'));
        stageback.scrollFactor.set(0.9, 0.9);
        stageback.antialiasing = true;
        background.add(stageback);

        var stagefront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('${PATH}stagefront'));
        stagefront.setGraphicSize(Std.int(stagefront.width * 1.1));
        stagefront.scrollFactor.set(0.9, 0.9);
        stagefront.antialiasing = true;
        stagefront.updateHitbox();
        background.add(stagefront);

        var stageLightL:FlxSprite = new FlxSprite(-125, -100).loadGraphic(Paths.image('${PATH}stage_light'));
        stageLightL.setGraphicSize(Std.int(stageLightL.width * 1.1));
        stageLightL.scrollFactor.set(1, 1);
        stageLightL.antialiasing = true;
        stageLightL.updateHitbox();
        foreground.add(stageLightL);

        var stageLightR:FlxSprite = new FlxSprite(1225, -100).loadGraphic(Paths.image('${PATH}stage_light'));
        stageLightR.setGraphicSize(Std.int(stageLightR.width * 1.1));
        stageLightR.scrollFactor.set(1, 1);
        stageLightR.antialiasing = true;
        stageLightR.flipX = true;
        stageLightR.updateHitbox();
        foreground.add(stageLightR);

        var stagecurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('${PATH}stagecurtains'));
        stagecurtains.setGraphicSize(Std.int(stagecurtains.width * 0.9));
        stagecurtains.scrollFactor.set(1.3, 1.3);
        stagecurtains.antialiasing = true;
        stagecurtains.updateHitbox();
        foreground.add(stagecurtains);
    }
}