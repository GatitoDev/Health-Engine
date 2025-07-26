package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import data.Sprite;

class OptionsScreen extends MusicBeatState
{
    final PANEL_WIDTH:Int = 600;
    final PANEL_HEIGHT:Int = 400;
    final PADDING:Int = 20;
    final HEADER_HEIGHT:Int = 30;
    final BUTTON_HEIGHT:Int = 40;
    final NAV_BUTTON_WIDTH:Int = 50;
    
    var panelGroup:FlxSpriteGroup;
    var contentPanel:FlxSprite;
    var navButtons:Array<FlxSprite>;
    var buttonLabels:Array<FlxText>;
    var currentOptionText:FlxText;
    var currentSelected:Int = 0;
    var options:Array<String> = ["Gameplay", "Appearance", "Misc", "Audio"];
    
    override function create() {
        super.create();
        FlxG.mouse.visible = true;
        var bg:FlxSprite = Sprite.create('menuDesat', {scale: 1.1, color: FlxColor.GRAY, background: true});
        add(bg.screenCenter());
        initPanel();
    }
    
    function initPanel():Void
    {
        panelGroup = new FlxSpriteGroup();
        final panelX:Float = (FlxG.width - PANEL_WIDTH) / 2;
        final panelY:Float = (FlxG.height - PANEL_HEIGHT) / 2;
        
        panelGroup.add(createPanelBG(panelX, panelY));
        panelGroup.add(createHeaderBG(panelX, panelY));
        panelGroup.add(createHeaderText(panelX, panelY));
        
        createNavigationSection(panelX, panelY + HEADER_HEIGHT);
        
        contentPanel = new FlxSprite(panelX + PADDING, panelY + HEADER_HEIGHT + BUTTON_HEIGHT + PADDING * 2)
         .makeGraphic(PANEL_WIDTH - PADDING * 2, PANEL_HEIGHT - HEADER_HEIGHT - BUTTON_HEIGHT - PADDING * 3, FlxColor.BLACK);
        contentPanel.alpha = 0.6;
        panelGroup.add(contentPanel);
        
        add(panelGroup);
    }
    
    function createPanelBG(x:Float, y:Float):FlxSprite {
        var bg:FlxSprite = new FlxSprite(x, y).makeGraphic(PANEL_WIDTH, PANEL_HEIGHT, FlxColor.BLACK);
        bg.alpha = 0.7;
        return bg;
    }
    
    function createHeaderBG(x:Float, y:Float):FlxSprite {
        var header:FlxSprite = new FlxSprite(x, y).makeGraphic(PANEL_WIDTH, HEADER_HEIGHT, FlxColor.fromRGB(40, 40, 40));
        header.alpha = 0.9;
        return header;
    }
    
    function createHeaderText(x:Float, y:Float):FlxText {
        var text:FlxText = new FlxText(x, y + (HEADER_HEIGHT - 20) / 2, PANEL_WIDTH, "OPTIONS", 24);
        text.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
        return text;
    }
    
    function createNavigationSection(x:Float, y:Float):Void {
        navButtons = [];
        buttonLabels = [];
        
        // Calculate positions
        var navY = y + PADDING;
        var leftButtonX = x + PADDING;
        var rightButtonX = x + PANEL_WIDTH - PADDING - NAV_BUTTON_WIDTH;
        var optionTextWidth = PANEL_WIDTH - (NAV_BUTTON_WIDTH + PADDING) * 2 - PADDING * 2;
        var optionTextX = x + (PANEL_WIDTH - optionTextWidth) / 2;
        
        // Create left button "<"
        var leftButton:FlxSprite = new FlxSprite(leftButtonX, navY).makeGraphic(NAV_BUTTON_WIDTH, BUTTON_HEIGHT, FlxColor.fromRGB(60, 60, 60));
        leftButton.alpha = 0.8;
        var leftLabel:FlxText = new FlxText(leftButtonX, navY + (BUTTON_HEIGHT - 20) / 2, NAV_BUTTON_WIDTH, "<", 20);
        leftLabel.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, CENTER);
        
        // Create right button ">"
        var rightButton:FlxSprite = new FlxSprite(rightButtonX, navY).makeGraphic(NAV_BUTTON_WIDTH, BUTTON_HEIGHT, FlxColor.fromRGB(60, 60, 60));
        rightButton.alpha = 0.8;
        var rightLabel:FlxText = new FlxText(rightButtonX, navY + (BUTTON_HEIGHT - 20) / 2, NAV_BUTTON_WIDTH, ">", 20);
        rightLabel.setFormat(Paths.font('vcr.ttf'), 20, FlxColor.WHITE, CENTER);
        
        // Create current option display (centered between buttons)
        currentOptionText = new FlxText(optionTextX, navY + (BUTTON_HEIGHT - 24) / 2, optionTextWidth, options[currentSelected], 24);
        currentOptionText.setFormat(Paths.font('vcr.ttf'), 24, FlxColor.WHITE, CENTER);
        
        // Store references
        navButtons.push(leftButton);
        navButtons.push(rightButton);
        buttonLabels.push(leftLabel);
        buttonLabels.push(rightLabel);
        
        // Add to group
        panelGroup.add(leftButton);
        panelGroup.add(rightButton);
        panelGroup.add(leftLabel);
        panelGroup.add(rightLabel);
        panelGroup.add(currentOptionText);
    }
    
    function updateButtonSelection(newSelection:Int):Void {
        // Update current option
        currentSelected = newSelection;
        currentOptionText.text = options[currentSelected];
        
        // Here you would also update the content panel with the selected option's content
        updateContentPanel();
    }
    
    function updateContentPanel():Void {
        // Clear previous content (you would implement this based on your needs)
        // Add content specific to the selected option
        // Example: contentPanel.add(new FlxText(...));
    }
    
    function navigate(direction:Int):Void {
        var newSelection = currentSelected + direction;
        
        // Wrap around if out of bounds
        if (newSelection < 0) newSelection = options.length - 1;
        if (newSelection >= options.length) newSelection = 0;
        
        updateButtonSelection(newSelection);
    }
    
    override function update(elapsed:Float):Void {
        super.update(elapsed);
        
        // Handle mouse hover and clicks for navigation buttons
        for (i in 0...navButtons.length) {
            if (FlxG.mouse.overlaps(navButtons[i])) {
                navButtons[i].color = FlxColor.WHITE;
                
                if (FlxG.mouse.justPressed) {
                    navigate(i == 0 ? -1 : 1); // Left button decreases index, right increases
                }
            } else {
                navButtons[i].color = FlxColor.fromRGB(60, 60, 60);
            }
        }
        
        // Keyboard controls for accessibility
        if (FlxG.keys.justPressed.LEFT) navigate(-1);
        if (FlxG.keys.justPressed.RIGHT) navigate(1);
    }
}