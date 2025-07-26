package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxSpriteGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.display.FlxGridOverlay;

class AnimationDebug extends FlxState
{
	var char:Character;
	var textAnim:FlxText;
	var infoPanel:InfoPanel;
	var dumbTexts:FlxTypedGroup<FlxText>;
	var animList:Array<String> = [];
	var curAnim:Int = 0;
	var camFollow:FlxObject;
	
	final panelConfig:{width:Int, padding:Int, headerHeight:Int, textHeight:Int, textSpacing:Int, contentIndent:Int, 
	 alpha:Float, headerAlpha:Float} = {width: 300, padding: 10, headerHeight: 30, textHeight: 20, textSpacing: 5, 
	 contentIndent: 10, alpha: 0.7, headerAlpha: 0.9}
	
	var panelGroup:FlxTypedSpriteGroup<FlxSprite>;
	var selectionBox:FlxSprite;
	var camHUD:FlxCamera;

	public function new(daAnim:String = 'spooky')
	{
		super();
		FlxG.sound.music.stop();
		FlxG.mouse.visible = true;

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.add(camHUD, false);

		var gridBG:FlxSprite = FlxGridOverlay.create(10, 10);
		gridBG.scrollFactor.set(0.5, 0.5);
		add(gridBG);

		char = daAnim == 'bf' ? new Boyfriend(0, 0) : new Character(0, 0, daAnim);
		char.screenCenter();
		char.debugMode = true;
		char.flipX = false;
		add(char);

		initPanel();
		createSelectionBox();
		
		dumbTexts = new FlxTypedGroup<FlxText>();
		add(dumbTexts);

		add(infoPanel = new InfoPanel());
		infoPanel.cameras = [camHUD];

		genBoyOffsets();

		camFollow = new FlxObject(0, 0, 2, 2);
		camFollow.screenCenter();
		add(camFollow);
		FlxG.camera.follow(camFollow);

		panelGroup.cameras = dumbTexts.cameras = [camHUD];
	}

	function initPanel():Void {
		if (panelGroup != null && members.contains(panelGroup)) remove(panelGroup);
		panelGroup = new FlxTypedSpriteGroup<FlxSprite>();
		
		var panelBG:FlxSprite = new FlxSprite(panelConfig.padding, panelConfig.padding)
		 .makeGraphic(panelConfig.width, 100, FlxColor.BLACK);
		panelBG.alpha = panelConfig.alpha;
		panelBG.scrollFactor.set();
		panelGroup.add(panelBG);
		
		var headerBG:FlxSprite = new FlxSprite(panelBG.x, panelBG.y)
	     .makeGraphic(panelConfig.width, panelConfig.headerHeight, FlxColor.fromRGB(40, 40, 40));
		headerBG.alpha = panelConfig.headerAlpha;
		headerBG.scrollFactor.set();
		panelGroup.add(headerBG);
		
		var headerText:FlxText = new FlxText(headerBG.x + panelConfig.padding,  headerBG.y + (panelConfig.headerHeight - 20) / 2, 
		 panelConfig.width - (panelConfig.padding * 2), "ANIMATION OFFSETS", 20);
		headerText.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, LEFT);
		headerText.scrollFactor.set();
		panelGroup.add(headerText);
		
		add(panelGroup);
	}

	function createSelectionBox():Void {
		selectionBox = new FlxSprite(panelConfig.padding, 0)
		 .makeGraphic(panelConfig.width, panelConfig.textHeight + panelConfig.textSpacing, FlxColor.GRAY);
		selectionBox.alpha = 0.3;
		selectionBox.scrollFactor.set();
		selectionBox.visible = false;
		panelGroup.add(selectionBox);
	}

	function genBoyOffsets(pushList:Bool = true):Void {
		dumbTexts.clear();
		if (pushList) animList = [];
		
		final startY:Int = panelConfig.padding + panelConfig.headerHeight + panelConfig.textSpacing;
		final contentWidth:Int = panelConfig.width - (panelConfig.padding * 2) - panelConfig.contentIndent;
		
		for (anim => offsets in char.animOffsets) {
			var text:FlxText = new FlxText(
				panelConfig.padding + panelConfig.contentIndent,
				startY + (dumbTexts.length * (panelConfig.textHeight + panelConfig.textSpacing)),
				contentWidth, '$anim: (${offsets[0]}, ${offsets[1]})', panelConfig.textHeight
			);
			text.offset.y += 3;
			text.setFormat(Paths.font('vcr.ttf'), panelConfig.textHeight, FlxColor.WHITE, LEFT);
			text.scrollFactor.set();
			dumbTexts.add(text);
			
			if (pushList) animList.push(anim);
		}
		
		final panelHeight:Int = panelConfig.headerHeight + (dumbTexts.length * (panelConfig.textHeight + panelConfig.textSpacing));
		if (panelGroup.members[0] != null) panelGroup.members[0].makeGraphic(panelConfig.width, Std.int(panelHeight), FlxColor.BLACK);
		
		updateSelectionBox();
	}

	function updateSelectionBox():Void {
		if (dumbTexts.members[curAnim] != null) {
			selectionBox.y = dumbTexts.members[curAnim].y - (panelConfig.textSpacing/2) - 2;
			selectionBox.visible = true;
		} else selectionBox.visible = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		infoPanel.updateText(char.animation.curAnim.name);

		if (FlxG.keys.justPressed.E) FlxG.camera.zoom += 0.25;
		else if (FlxG.keys.justPressed.Q) FlxG.camera.zoom -= 0.25;

		camFollow.velocity.set(FlxG.keys.pressed.J ? -90 : (FlxG.keys.pressed.L ? 90 : 0),
		 FlxG.keys.pressed.I ? -90 : (FlxG.keys.pressed.K ? 90 : 0));

		if (FlxG.keys.justPressed.W || (infoPanel.leftButton != null && FlxG.mouse.justPressed && 
		 FlxG.mouse.overlaps(infoPanel.leftButton))) changeAnim(-1);
		else if (FlxG.keys.justPressed.S || (infoPanel.rightButton != null && FlxG.mouse.justPressed && 
		 FlxG.mouse.overlaps(infoPanel.rightButton))) changeAnim(1);

		var multiplier:Int = FlxG.keys.pressed.SHIFT ? 10 : 1;
		var offsetChanged:Bool = false;
		var offsets = char.animOffsets.get(animList[curAnim]);
		
		if (offsets != null) {
			if (FlxG.keys.justPressed.UP) { offsets[1] += multiplier; offsetChanged = true; }
			else if (FlxG.keys.justPressed.DOWN) { offsets[1] -= multiplier; offsetChanged = true; }
			else if (FlxG.keys.justPressed.LEFT) { offsets[0] += multiplier; offsetChanged = true; }
			else if (FlxG.keys.justPressed.RIGHT) { offsets[0] -= multiplier; offsetChanged = true; }
		}

		if (FlxG.keys.justPressed.SPACE || FlxG.keys.justPressed.W || FlxG.keys.justPressed.S || offsetChanged) {
			char.playAnim(animList[curAnim]);
			genBoyOffsets(false);
		}
	}

	function changeAnim(change:Int):Void {
		curAnim = (curAnim + change + animList.length) % animList.length;
		updateSelectionBox();
		char.playAnim(animList[curAnim]);
		genBoyOffsets(false);
	}
}

class InfoPanel extends FlxTypedGroup<FlxBasic> {
    public var textAnim:FlxText;
    public var bg:FlxSprite;
    public var leftButton:FlxSprite;
    public var rightButton:FlxSprite;
    
    final cfg = {
        width: 400, height: 40, padding: 10,
        textSize: 24, bgAlpha: 0.6,
        bgColor: FlxColor.BLACK, textColor: FlxColor.WHITE,
        buttonWidth: 40, buttonHeight: 40
    };
    
    public function new() {
        super();
        
        bg = new FlxSprite().makeGraphic(cfg.width, cfg.height, cfg.bgColor);
        bg.setPosition(FlxG.width/2 - cfg.width/2, FlxG.height/2 + 250 - cfg.height/2);
        bg.alpha = cfg.bgAlpha;
        add(bg);
        
        leftButton = new FlxSprite(bg.x - cfg.buttonWidth - 5, bg.y + (cfg.height - cfg.buttonHeight)/2)
         .makeGraphic(cfg.buttonWidth, cfg.buttonHeight, cfg.bgColor);
        leftButton.alpha = cfg.bgAlpha;
        add(leftButton);
        
        rightButton = new FlxSprite(bg.x + bg.width + 5, bg.y + (cfg.height - cfg.buttonHeight)/2)
         .makeGraphic(cfg.buttonWidth, cfg.buttonHeight, cfg.bgColor);
        rightButton.alpha = cfg.bgAlpha;
        add(rightButton);
        
        add(new FlxText(leftButton.x, leftButton.y + (cfg.buttonHeight - cfg.textSize)/2, 
         cfg.buttonWidth, "<", cfg.textSize).setFormat(Paths.font('vcr.ttf'), cfg.textSize, cfg.textColor, CENTER));
        add(new FlxText(rightButton.x, rightButton.y + (cfg.buttonHeight - cfg.textSize)/2, 
         cfg.buttonWidth, ">", cfg.textSize).setFormat(Paths.font('vcr.ttf'), cfg.textSize, cfg.textColor, CENTER));
        
        final textY:Float = FlxG.height/2 + 250 - cfg.textSize/2;
        final textX:Float = FlxG.width/2 - cfg.width/2 + cfg.padding;
        
        add(textAnim = new FlxText(textX, textY, cfg.width - cfg.padding*2, "", cfg.textSize)
         .setFormat(Paths.font('vcr.ttf'), cfg.textSize, cfg.textColor, CENTER));
    }
    
    public inline function updateText(t:String) textAnim.text = t;
    public inline function toggle(b:Bool) visible = b;
}