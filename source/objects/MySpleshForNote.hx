package objects;

import flixel.animation.FlxAnimation;
import data.Splashs;
import haxe.Json;

class MySpleshForNote extends FlxSprite
{
    public var animOffsets:Map<String, Array<Dynamic>>  = null;

    public var noteData:Int                             = 0;

    public var imgpng:FlxGraphic                        = null;
    public var imgxml:String                            = null;
    public var name:String                              = null;

    public var isPlayer:Int                             = 0;
    public var tex:FlxAtlasFrames                       = null;

    public var animList:Array<String>                   = [];

    public function new(x:Float, y:Float, data:Int, p:Int, img:String = 'splashVanilla') {
        super(x,y);
        this.noteData = data;
        this.isPlayer = p;
        this.ID = noteData;
        name = img;
       

        reloadSplesh();
        scrollFactor.set();
        playAnim('pressed');
    }

    public function reloadSplesh()
    {

        var pathJson:String = 'assets/images/Splashes/' + name + '.json';
        var spalshJson = AssetLoader.getText(pathJson).trim();
        var splash:DataSpleshs = Json.parse(spalshJson);

        imgpng = Img.load('Splashes/'+ splash.textyra );
        imgxml = AssetLoader.getText('assets/images/Splashes/' + splash.textyra + '.xml');

        animOffsets = new Map<String, Array<Dynamic>>(); 

        scale.x = splash.size;
        scale.y = splash.size;

        tex = FlxAtlasFrames.fromSparrow(imgpng,imgxml);
		frames = tex;

        antialiasing = ClientSetings.data.antialiasing;

        animation.addByPrefix('green', splash.up[0].anim[1]);
		animation.addByPrefix('blue', splash.down[0].anim[1]);
		animation.addByPrefix('purple', splash.left[0].anim[1]);
		animation.addByPrefix('red', splash.right[0].anim[1]);

        switch (Math.abs(noteData) % 4)
        {
            case 0:
                x += Note.swagWidth * 0 ;
                for(anim in splash.left)
                    addAnim(anim);
            case 1:
                x += Note.swagWidth * 1 ;
                for(anim in splash.down)
                    addAnim(anim);
            case 2:
                x += Note.swagWidth * 2 ;
                for(anim in splash.up)
                    addAnim(anim);
            case 3:
                x += Note.swagWidth * 3 ;
                for(anim in splash.right)
                    addAnim(anim);
        }

        updateHitbox();

        trace(animOffsets);

        alpha = ClientSetings.data.splashAlpha;
    }

    function addAnim(anim:AnimSplash)
    {
        trace(anim.anim[1]);
        animation.addByPrefix(anim.anim[0] , anim.anim[1], anim.fps, false);
        AnimUtilis.addOffset(animOffsets, anim.anim[0], anim.offset[0], anim.offset[1]);
        animList.push(anim.anim[0]);
    }


    public function playerPosition()
    {
		if (!ClientSetings.data.middleScroll)
			x += ((FlxG.width / 2) * isPlayer);
		else
			if (isPlayer == 1)
				x += ((FlxG.width / 2) * isPlayer - Note.swagWidth * 2 - 50);
			else
				if (noteData < 2)
					x += ((FlxG.width / 2) * isPlayer);
				else
					x += ((FlxG.width / 2) * 1 + 50);

    }	

    public function playAnim(anim:String, ?force:Bool = false) {
        if(!hasAnimation(anim)) return;
        // trace('play anim');
        visible = true;
		animation.play(anim, force);
        
        var daOffset = animOffsets.get(animation.curAnim.name);
        if (animOffsets.exists(animation.curAnim.name))
        {
            offset.set(daOffset[0], daOffset[1]);
        }
	}

    public function hasAnimation(animationName:String):Bool
    {
        // Проверяем, существует ли анимация с указанным именем
        var anim:FlxAnimation = animation.getByName(animationName);
        return anim != null;
    }

    override function update(elapsed:Float) {
		if (animation.curAnim.finished && visible)
            visible = false;
		super.update(elapsed);
	}
}