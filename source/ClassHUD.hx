package;

import flixel.FlxG;
import data.Text;
import data.Sprite;

import flixel.ui.FlxBar;
import flixel.FlxBasic;
import flixel.group.FlxGroup.FlxTypedGroup;

class ClassHUD extends FlxTypedGroup<FlxBasic> {
    private static var healthBarBG:Sprite;
	private var healthBar:FlxBar;
    private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
    private var scoreText:Text;
    private var botPlayState:Text;

    override function new() {
        super();
        healthBarBG = Sprite.create('healthBarBG', 0, KadeEngineData.downscroll ? 50 : FlxG.height * 0.9);
		add(healthBarBG.screenCenter(X));
		add(healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8),
         Std.int(healthBarBG.height - 8), this, 'health', 0, 2).createFilledBar(0xFFFF0000, 0xFF66FF33));
		add(iconP1 = new HealthIcon(PlayState.SONG.player1, true));
		add(iconP2 = new HealthIcon(PlayState.SONG.player2, false));
        add(scoreText = new Text(0, healthBarBG.y + 30, FlxG.width, "", 22).center());

        botPlayState = new Text(healthBarBG.x + (healthBarBG.width / 2) - 75, healthBarBG.y + (KadeEngineData.downscroll ? 100 : -100), "BOTPLAY");
		if (KadeEngineData.downscroll) add(botPlayState);
    }

    override public function update(elapsed:Float):Void {
        super.update(elapsed);
        iconP1.updateIcons(elapsed, healthBar);
		iconP2.updateIcons(elapsed, healthBar);
        scoreText.text = Ratings.CalculateRanking(PlayState.songScore, PlayState.songScoreDef, PlayState.accuracy);
    }
}