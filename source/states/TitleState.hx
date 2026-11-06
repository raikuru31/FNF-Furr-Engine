package states;


import objects.ABot;
import objects.Visualizer;
import backend.RandomSongForDemo;
import charectors.CharectorsOther;
import flixel.util.FlxColor;
import states.ResultState;
import backend.Song;
import backend.EventJson;
import states.LevelSelect;
import backend.mobile.TouchButton;

class TitleState extends MusicBeatState
{
    public var rSong:RandomSongForDemo  = new RandomSongForDemo();

    public var gf:CharectorsOther       = null;

    public var logo:FlxSprite           = null;
    public var danceGF:Bool             = false;
    public var song:FlxSound            = null;

    public var camGame:FlxCamera        = null;
    public var camHUD:FlxCamera         = null;

    public var bg:FlxSprite             = null;

    public var whileColor:FlxSprite     = null;

    public var titleEnter:FlxSprite     = null;
    var pressEnter:Bool                 = false;

    var visualizer:Visualizer           = null;

    public static var verEngine:String = "0.1.5.02-08";
    public static var verGame:String = "0.2.8";

    override public function create():Void 
    {
        _skipCFT = true;

        super.create();

        persistentUpdate = true;
		persistentDraw = true;

        #if mobile
        addTitleButtons();
        #end

        // Conductor.songPosition = 0;
        camGame = new FlxCamera();
		camGame.bgColor = FlxColor.BLACK;
		FlxG.cameras.reset(camGame);
		// camGame.zoom = 0.72;
        
		camHUD = new FlxCamera();
        camHUD.bgColor = FlxColor.TRANSPARENT; 
        camHUD.width = FlxG.width;
        camHUD.height = FlxG.height;
        camHUD.x = 0;
        camHUD.y = 0;
        FlxG.cameras.add(camHUD);
    
        whileColor = new FlxSprite();
        whileColor.makeGraphic(FlxG.width, FlxG.height,FlxColor.fromString('#FFFFFF'));
		whileColor.cameras = [camHUD];
		whileColor.alpha = 1;
        add(whileColor);

        //Код предназначеный чтоб делать окно прозрачным 
        // var bg_alhpa:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(24 , 24, 24));
        // if (camGame.zoom < 1)
        //     bg_alhpa.scale.scale(1 / camGame.zoom);
        // bg_alhpa.scrollFactor.set();
        // bg_alhpa.cameras = [camGame];
        // add(bg_alhpa);
        // FlxTransWindow.getWindowsTransparent();

        // song = FlxG.sound.load('assets/music/freakyMenu.ogg', 1, false);

        if (ClientSetings.data.visualizerVisible)
		{
            visualizer = new Visualizer(0, 400, 120);
            visualizer.cameras = [camGame];
            add(visualizer);
        }
        gf = new CharectorsOther(500, 50, 'gf', 'TitleState');
        gf.updateHitbox();
        add(gf);
        gf.cameras = [camGame];


        logo = new FlxSprite(-100,-100);
        var logoTex= FlxAtlasFrames.fromSparrow('assets/images/TitleState/logoBumpin.png', 'assets/images/TitleState/logoBumpin.xml');
        logo.frames = logoTex;
        logo.animation.addByPrefix('LogoBoop', 'logo bumpin0');
        logo.animation.play('LogoBoop');
        add(logo);
        logo.cameras = [camGame];
        logo.antialiasing = true;

        titleEnter = new FlxSprite(50,FlxG.height - 150);
        var titleEnterTex= FlxAtlasFrames.fromSparrow('assets/images/TitleState/titleEnter.png', 'assets/images/TitleState/titleEnter.xml');
        titleEnter.frames = titleEnterTex;
        titleEnter.animation.addByPrefix('idle', 'ENTER IDLE0');
        titleEnter.animation.addByPrefix('freeze', 'ENTER FREEZE0');
        titleEnter.animation.addByPrefix('pressed', 'ENTER PRESSED0');
        titleEnter.animation.play('idle');
        add(titleEnter);
        titleEnter.cameras = [camGame];


        if (FlxG.sound.music == null)
        {
            FlxG.sound.playMusic('assets/music/freakyMenu.ogg', 1);
            // song.play();
        }

        if (ClientSetings.data.visualizerVisible)
            visualizer.snd = FlxG.sound.music;

        // var ABot = new ABot(400, 200);
        // ABot.cameras = [camGame];
        // ABot.set_pos();
        // add(ABot);

        // ABot.snd = FlxG.sound.music;


        if (controls.justPressed('BACK'))
        {
            SwitshState.switchState(new Watafak());
        }

        if (FlxG.sound.music != null) 
            Conductor.songPosition = FlxG.sound.music.time;

        FlxG.sound.music.onComplete = SongEnd;

        Conductor.changeBPM(102);

        gf.playAnim('danceRight');


    }


    #if mobile
    /**
     * Мобильные кнопки титульного экрана:
     *  - большая невидимая зона -> ACCEPT (вход в главное меню);
     *  - маленькая кнопка "test" в углу -> BACK (как раньше по клавише).
     */
    function addTitleButtons():Void
    {
        var big:TouchButton = new TouchButton(0, 0, 'ACCEPT', Std.int(FlxG.width), Std.int(FlxG.height - 170), 0.0);
        big.cameras = [camHUD];
        add(big);

        var bx:Float = FlxG.width - 180;
        var by:Float = FlxG.height - 150;

        var test:TouchButton = new TouchButton(bx, by, 'BACK', 160, 100, 0.45);
        test.cameras = [camHUD];
        add(test);

        var label:FlxText = new FlxText(bx, by + 32, 160, 'test', 32);
        label.setFormat(null, 32, FlxColor.WHITE, CENTER);
        label.scrollFactor.set(0, 0);
        label.cameras = [camHUD];
        add(label);
    }
    #end

    var animEnter:Bool                  = false;
    override public function update(elapsed:Float) 
    {
        super.update(elapsed);

        if (whileColor.alpha > 0)
            whileColor.alpha -=0.01;
        if (controls.justPressed('ACCEPT') && !pressEnter)
        {
            pressEnter = true;
			whileColor.alpha = 1;
            if (!animEnter)
                titleEnter.animation.play('pressed');
            else
                titleEnter.animation.play('freeze');
            var mySound:FlxSound = FlxG.sound.play("assets/sounds/confirmMenu.ogg", 0.4);
            mySound.onComplete = function() 
                    SwitshState.switchState(new MeinMenu());
        }
        if (FlxG.sound.music != null)
        {    // Conductor.songPosition = song.time;
            Conductor.songPosition = FlxG.sound.music.time;
        }
        // if (controls.justPressed('BACK'))
        //     {MusicBeatState.switchState(new Watafak());
        //         FlxG.sound.playMusic('assets/music/freakyMenu.ogg', 0);}
    } 

    override function beatHit() 
    {
        super.beatHit();
            if (gf.animation.curAnim.finished || gf.animation.name == 'danceLeft' || gf.animation.name == 'danceRight')	
            {
                if (!danceGF)
                {gf.playAnim('danceLeft'); danceGF = true;logo.animation.play('static');}
                else
                {gf.playAnim('danceRight'); danceGF = false;logo.animation.play('static');}
                // trace('Dance');
            }
    }

    function SongEnd() 
	{
        FlxG.sound.playMusic('assets/music/freakyMenu.ogg', 0);
        PlayState.SONG = Song.loadFromJson(rSong.randSong,rSong.randSong);
        PlayState.EVENT = EventJson.loadFromJson(rSong.randSong);
        PlayState.songName = rSong.randSong;
        PlayState.demo = true;
        SwitshState.switchState(new PlayState()); // Переход в игру
	}
}