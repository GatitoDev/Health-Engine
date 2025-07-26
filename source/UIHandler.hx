package;

import data.Text;
import data.Sprite;

import flixel.ui.FlxBar;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

class UIHandler extends FlxTypedGroup<FlxBasic> {
    private var healthBarBG:Sprite;
	private var healthBar:FlxBar;
    private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
    private var scoreText:Text;

    override function new() {
        super();
    }
}