package;

import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import haxe.Json;
import sys.io.File;
import sys.FileSystem;
import PlayState;
import data.Sprite;

class StageBuilder extends FlxSpriteGroup {
    public var curStage:String = 'stage';
    public var cameraSpeed:Float = 1;
    public var defaultCamZoom:Float = 1.05;
    public var bfPosition:Array<Float> = [770, 450];
    public var gfPosition:Array<Float> = [400, 130];
    public var dadPosition:Array<Float> = [100, 100];

    public var cameraOffsets:Array<Array<Float>> = [[0, 0], [0, 0]];

    private var stagePath:String;
    
    public function new() {
        super();
        initStage();
        buildStage();
    }
    
    public function initStage():Void {
        curStage = PlayState.SONG.stage != null ? PlayState.SONG.stage.toLowerCase() : 'stage';
        stagePath = 'stages/$curStage/';
        loadStageData();
    }

    function loadStageData():Void {
        var path:String = Paths.getPreloadPath('images/stages/$curStage/data.json');
        
        if (!FileSystem.exists(path)) {
            trace('Stage data not found for ${curStage}, using default values');
            return;
        }
        
        try {
            var rawJson:String = File.getContent(path);
            var data:Dynamic = Json.parse(rawJson);
            
            if (data.camera != null) {
                if (data.camera.zoom != null) defaultCamZoom = data.camera.zoom;
                if (data.camera.speed != null) cameraSpeed = data.camera.speed;
                if (data.camera.offset != null) {
                    if (data.camera.offset.bf != null) cameraOffsets[0] = data.camera.offset.bf;
                    if (data.camera.offset.dad != null) cameraOffsets[1] = data.camera.offset.dad;
                }
            }
            
            if (data.character != null) {
                if (data.character.bf != null) bfPosition = data.character.bf;
                if (data.character.gf != null) gfPosition = data.character.gf;
                if (data.character.dad != null) dadPosition = data.character.dad;
            }
            
        } catch (e:Dynamic) {
            trace('Error loading stage data: $e');
        }
    }

    public function buildStage():Void {
        switch(curStage) {
            case 'stage': buildDefaultStage();
            default: buildDefaultStage();
        }
    }

    public function buildDefaultStage():Void {
        add(Sprite.create('${stagePath}stageback', -600, -200, 0.9, 0.9));
        add(Sprite.create('${stagePath}stagefront', -650, 600, 0.9, 0.9, { scale: 1.1, background: true}));
        add(Sprite.create('${stagePath}stagecurtains', -500, -300, 1.3, 1.3, { scale: 0.9, background: true }));
    }
}