package backend;


import haxe.Json;
import openfl.Assets;
import states.PlayState;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;

typedef Stage = {
    var BF_POS:Array<Int>;
    var GF_POS:Array<Int>;
    var DAD_POS:Array<Int>;

    var CAM_POS_BF:Array<Int>;
    var CAM_POS_GF:Array<Int>;
    var CAM_POS_DAD:Array<Int>;

    var BG:Array<StageBGImg>;

    var FG:Array<StageBGImg>;

    var CamZoom:Float;
}

typedef StageBGImg = {
    var img:String;
    var pos:Array<Int>;
    var scale:Array<Int>;
    var scrol:Array<Int>;
    var flipX:Bool;
    var flipY:Bool;
}

class Stagebg extends FlxSprite {

    public var bf_pos:Array<Int>        = null;
    public var gf_pos:Array<Int>        = null;
    public var dad_pos:Array<Int>       = null;
    public var camZoom:Float            = 0;
    public var bf_cam_pos:Array<Int>    = null;
    public var gf_cam_pos:Array<Int>    = null;
    public var dad_cam_pos:Array<Int>   = null;

    public var spriteGroup:FlxGroup     = null; 

    public var bg:StageBGImg            = null;

    public var stages:Stage             = null;

    public function new(stage:String = 'stage') {
        super();
        var path = 'assets/stage/' + stage + '.json';
        if (!(AssetLoader.exists(path)))
            path = 'assets/stage/stage.json';
        var stageJson = AssetLoader.getText(path).trim();
        var stages:Stage = Json.parse(stageJson);

        spriteGroup = new FlxGroup();
        
        bf_pos = stages.BF_POS;
        gf_pos = stages.GF_POS;
        dad_pos = stages.DAD_POS;
        bf_cam_pos = stages.CAM_POS_BF;
        gf_cam_pos = stages.CAM_POS_GF;
        dad_cam_pos = stages.CAM_POS_DAD;
        camZoom = stages.CamZoom;
        trace(bf_pos);
        trace(dad_pos);
        trace(gf_pos);

        if(stages.BG.length > 0)
        for (i in 0 ... stages.BG.length)
        {
            bg = stages.BG[i];
            trace(bg.img);
            var bitmap = Img.load('stages/' + bg.img);
            var spr = new FlxSprite().loadGraphic(bitmap);
            spr.x = bg.pos[0]; 
            spr.y = bg.pos[1];
            // var spr = new FlxSprite (bg.pos[0], bg.pos[1], 'assets/images/stages/' + bg.img + '.png');
            spr.scrollFactor.set(bg.scrol[0], bg.scrol[1]);
            spr.scale.y = bg.scale[1];
            spr.scale.x = bg.scale[0];
            if (bg.flipX)
                spr.flipX = bg.flipX;
            if (bg.flipY)
                spr.flipY = bg.flipY;
            spriteGroup.add(spr);
        }

    }

    
}