package states;

import backend.SwitshState;
import flixel.FlxState;
import flixel.FlxObject;

class LogoState extends FlxState
{
    private var head:FlxSprite          = null;
    private var text1:FlxSprite         = null;
    private var text2:FlxSprite         = null;

    private var _camFollow:FlxObject    = null;

    private var _camOther:FlxCamera     = null;

    override public function create():Void
	{
        super.create();
        ClientSetings.loadPrefs();

        // На Android data.json не существует изначально — создаём заготовку
        // до перехода в меню, иначе Free Play падает на чтении файла
        DataFile.ensure();
        // persistentUpdate = true;
		// persistentDraw = true;

        _camOther = new FlxCamera();
        _camOther.bgColor = FlxColor.BLACK;
        FlxG.cameras.reset(_camOther);
        _camOther.zoom = 1;

        if(!ClientSetings.data.skipLogoEngine)
        {
            _camFollow = new FlxObject(0, 0);

            _camFollow.setPosition(FlxG.width/2, FlxG.height/2);
            add(_camFollow);

            FlxG.camera.follow(_camFollow, LOCKON, 0.04);

            var cadrs = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38];
            head = new FlxSprite(-0,-550);
            var headTex= FlxAtlasFrames.fromSparrow('assets/images/LogoEngine/Logo_head.png', 'assets/images/LogoEngine/Logo_head.xml');
            head.frames = headTex;
            head.animation.addByIndices('LogoBoop', 'head_finel_anim0', cadrs, "", 24, false);
            // head.animation.addByPrefix('LogoBoop', 'head_finel_anim0');
            head.animation.play('LogoBoop');
            head.antialiasing = ClientSetings.data.antialiasing;

            add(head);

            text1 = new FlxSprite(620,-450);
            var text1Tex= FlxAtlasFrames.fromSparrow('assets/images/LogoEngine/Logo_Furr.png', 'assets/images/LogoEngine/Logo_Furr.xml');
            text1.frames = text1Tex;
            text1.animation.addByIndices('LogoBoop', 'text_tween20', cadrs, "", 24, false);
            // text1.animation.addByPrefix('LogoBoop', 'text_tween20');
            text1.animation.play('LogoBoop');
            text1.antialiasing = ClientSetings.data.antialiasing;

            add(text1);

            text2 = new FlxSprite(530,200);
            var text2Tex= FlxAtlasFrames.fromSparrow('assets/images/LogoEngine/Logo_engine.png', 'assets/images/LogoEngine/Logo_engine.xml');
            text2.frames = text2Tex;
            text2.animation.addByIndices('LogoBoop', 'Text_tween10', cadrs, "", 24, false);
            // text2.animation.addByPrefix('LogoBoop', 'Text_tween10');
            text2.animation.play('LogoBoop');
            text2.antialiasing = ClientSetings.data.antialiasing;

            add(text2);
        }
        else
        {
            FlxG.switchState(new TitleState());
        }
        
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);
        if(!ClientSetings.data.skipLogoEngine)
            if (head.animation.curAnim.finished)
            {
                movetCam();
                if (_camOther.zoom >= 0.5)
                    _camOther.zoom -= 0.015;
                SwitshState.switchState(new TitleState());
            }

    }

    function movetCam()
    {
        _camFollow.setPosition(FlxG.width/2, -1000);	
    }
}