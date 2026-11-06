package states;

import haxe.Json;
import data.DataSave;
import backend.Song;
import backend.EventJson;

import charectors.CharectorsOther;

class LevelSelect extends MusicBeatState
{
    public var rSong:RandomSongForDemo                      = new RandomSongForDemo();
    public var arraySong:Array<String>                      = [];
    var menuItems:Array<FlxText>                            = [];

    public static var select:Int                            = 0;

    var lerpSelected:Float                                  = 0;
    var lerpSelectedOptions:Float                           = 0;

    var bg:FlxSprite                                        = null;
    var bfDJ:CharectorsOther                                = null;

    var debugTxt:FlxText                                    = null;

    var camGame:FlxCamera                                   = null;
    var camOther:FlxCamera                                  = null;
    var camHUD:FlxCamera                                    = null;

    var blackBG:FlxSprite                                   = null;

    var optionsOpen:Bool                                    = false;

    var menuItemsOptions:Array<FlxText>                     = [];
    var selectOptions:Int                                   = 0;

    var textScore:FlxText                                   = null;

    private static var _FullData:DataSave                   = null;

    var dataSong:Array<Dynamic>                             = [1000, 1000, 956, 44, 0, 0, 0, 600000, 95.67, "FC", "E"];

    var blocControl:Bool                                    = false;

    var scoreSprGroup:FlxTypedGroup<FlxSprite>              = new FlxTypedGroup<FlxSprite>();
    var scoreSprArray:Array<FlxSprite>                      = [];
    
    private var _scoreUp:Int                                = 0;
    override public function create():Void
    {	
        _skipCFT = true;

        var data = DataFile.read().trim();
        _FullData = Json.parse(data);

        var path = "assets/data";
        var folders = AssetLoader.listDirs(path);

        arraySong = folders;
        try 
        {
            reloadScore();
        }
        catch (e:Dynamic) {
            Error.onError(e);
        }
        

        arraySong.push('random song');

        super.create();

        Conductor.changeBPM(102);

        camGame = new FlxCamera();
		camGame.bgColor = FlxColor.BLACK;
		FlxG.cameras.reset(camGame);
		// camGame.zoom = 0.72;
        
		camOther = new FlxCamera();
        camOther.bgColor = FlxColor.TRANSPARENT; 
        camOther.width = FlxG.width;
        camOther.height = FlxG.height;
        camOther.x = 0;
        camOther.y = 0;
        FlxG.cameras.add(camOther);

        camHUD = new FlxCamera();
        camHUD.bgColor = FlxColor.TRANSPARENT; 
        camHUD.width = FlxG.width;
        camHUD.height = FlxG.height;
        camHUD.x = 0;
        camHUD.y = 0;
        FlxG.cameras.add(camHUD);
        
        lerpSelected = select;
        lerpSelectedOptions = selectOptions;

        bg = new FlxSprite();
        bg.loadGraphic(Img.load('menuBG')); // Загружаем изображение
        bg.setGraphicSize(FlxG.width, FlxG.height); // Растягиваем на весь экран
        bg.updateHitbox();
        bg.scrollFactor.set(0, 0); // Фон не должен двигаться при движении камеры
        add(bg);
        bg.cameras = [camGame];

        blackBG = new FlxSprite(0,0);
		blackBG.makeGraphic (1280,850,FlxColor.fromString('#FFD863'));
        blackBG.angle = 100;
        blackBG.x -= 300;
        blackBG.alpha = 1;
		blackBG.cameras = [camGame];
		blackBG.scrollFactor.set();
        add(blackBG);

        bfDJ = new CharectorsOther(800, -50, 'bf', 'FreePlay');
        bfDJ.updateHitbox();
        bfDJ.cameras = [camGame];
        add(bfDJ);

        var bgScore = new FlxSprite(0,0);
		    bgScore.makeGraphic (400,150,FlxColor.fromString('#000000'));

            bgScore.x = 1280 - bgScore.width;
            bgScore.alpha = 0.6;
		    bgScore.cameras = [camGame];
        // add(bgScore);

        var daLoop:Int = 0;
        var separatedScore:String = Std.string(_scoreUp).lpad('0', 10);
		for (i in 0...separatedScore.length)
		{
			var numScore:FlxSprite = new FlxSprite();
            var texNumScore = FlxAtlasFrames.fromSparrow(Img.load('FreePlay/digital_numbers'), 'assets/images/FreePlay/digital_numbers.xml');
            numScore.frames = texNumScore;


            for(j in 0 ... 9)
                switch (j)
                {
                    case 0: numScore.animation.addByPrefix('digital0', 'ZERO DIGITAL0', 24, false);
                    case 1: numScore.animation.addByPrefix('digital1', 'ONE DIGITAL0', 24, false);
                    case 2: numScore.animation.addByPrefix('digital2', 'TWO DIGITAL0', 24, false);
                    case 3: numScore.animation.addByPrefix('digital3', 'THREE DIGITAL0', 24, false);
                    case 4: numScore.animation.addByPrefix('digital4', 'FOUR DIGITAL0', 24, false);
                    case 5: numScore.animation.addByPrefix('digital5', 'FIVE DIGITAL0', 24, false);
                    case 6: numScore.animation.addByPrefix('digital6', 'SIX DIGITAL0', 24, false);
                    case 7: numScore.animation.addByPrefix('digital7', 'SEVEN DIGITAL0', 24, false);
                    case 8: numScore.animation.addByPrefix('digital8', 'NINE DIGITAL0', 24, false);
                    case 9: numScore.animation.addByPrefix('digital9', 'EIGHT DIGITAL0', 24, false);
                }
                
            numScore.scale.set(0.45, 0.45);
            numScore.animation.play('digital0');
            numScore.x = 720 +(50 * daLoop);
            numScore.y += 5; 
            scoreSprArray.push(numScore);
            scoreSprGroup.add(numScore);

            daLoop++;
        }

        var highscore:FlxSprite = new FlxSprite(0,0);
        var texHigh = FlxAtlasFrames.fromSparrow(Img.load('FreePlay/highscore'), 'assets/images/FreePlay/highscore.xml');
            highscore.frames = texHigh;

            highscore.x = scoreSprArray[0].x;
            highscore.y += 10;
            
            highscore.animation.addByPrefix('idle', 'highscore small instance 1', 24, true);
            highscore.animation.play('idle');

            highscore.cameras = [camHUD];
        add(highscore);

        var CleanAcc:FlxSprite = new FlxSprite();
        CleanAcc.loadGraphic(Img.load('FreePlay/clearBox')); // Загружаем изображение

        CleanAcc.x = highscore.x + highscore.width + 100;
        CleanAcc.y += 10;
        CleanAcc.cameras = [camHUD];
        add(CleanAcc);

        scoreSprGroup.cameras = [camHUD];
        add(scoreSprGroup);

        var text = "Score " + dataSong[7] + "\n" + dataSong[8] + " " + dataSong[9] + "/" + dataSong[10];
        
        textScore = new FlxText (0, 0, bgScore.width);
        textScore.text = text;

        textScore.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textScore.scrollFactor.set();
		textScore.borderSize = 1.25;
        textScore.cameras = [camGame];

        textScore.x = 1280 - bgScore.width;

        add(textScore);

        debugTxt = new FlxText(FlxG.width/2 + 200, 70, 100, '');
		debugTxt.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugTxt.scrollFactor.set();
		debugTxt.borderSize = 1.25;
        debugTxt.cameras = [camGame];
		// debugTxt.cameras = [camHUD];

		add(debugTxt);

        var infText:FlxText = new FlxText(0, FlxG.height-20, FlxG.width, 'ctrl - options, alt - view all records');
		    infText.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		    infText.scrollFactor.set();
		    infText.cameras = [camGame];
       

        var infBG:FlxSprite = new FlxSprite(0, FlxG.height-20);
		    infBG.makeGraphic (FlxG.width, 30,FlxColor.fromString('#000000'));
		    infBG.cameras = [camGame];
		    infBG.alpha = 0.7;
		

        createMenu();
        updateTexts();

        add(infBG);
        add(infText);

        blackBG = new FlxSprite(0,0);
		blackBG.makeGraphic (FlxG.width,FlxG.height,FlxColor.BLACK);
        blackBG.alpha = 0.7;
		blackBG.cameras = [camOther];
		blackBG.scrollFactor.set();
		blackBG.screenCenter(X);
        add(blackBG);

        createMenuOptions();
        updateTextsOptions();
        updateSelection();

        if (FlxG.sound.music == null)
            FlxG.sound.playMusic('assets/music/freakyMenu.ogg', 1);

        bfDJ.playAnim('intro');
        if (FlxG.sound.music != null) 
            Conductor.songPosition = FlxG.sound.music.time;

        FlxG.sound.music.onComplete = SongEnd;
    }

    function SongEnd() 
	{
        curStep = 0;
        curBeat = 0;

        totalSteps = 0;
        totalBeats = 0;

        lastStep = 0;
        lastBeat = 0;
	}

    override public function update(elapsed:Float) 
    {
            super.update(elapsed);
        if (FlxG.sound.music != null)
            Conductor.songPosition = FlxG.sound.music.time;

        if(!blocControl)
        {        
            if (!optionsOpen)
            {

                camOther.visible = false;
                if(controls.justPressed('ui_up'))
                {
                    if (!(select <= 0))
                        select--; 
                    else
                        select = arraySong.length - 1;
                    updateSelection();
                    // trace(select);
                }

                if(controls.justPressed('ui_down'))
                {
                    if (!(select >= arraySong.length - 1))
                        select++;
                    else
                        select = 0;
                    updateSelection();
                    // trace(select);
                }

                if (controls.justPressed('ACCEPT')) 
                {

                    blocControl = true;
                    FlxG.sound.music.stop();
                    if(arraySong[select] != 'random song')
                        // PlayState.curSong = arraySong[select];
                        {
                            PlayState.SONG = Song.loadFromJson(arraySong[select],arraySong[select]);
                            PlayState.EVENT = EventJson.loadFromJson(arraySong[select]);
                            PlayState.songName = arraySong[select];
                        }
                    else
                        // PlayState.curSong = rSong.randSong;
                        {
                            PlayState.SONG = Song.loadFromJson(rSong.randSong,rSong.randSong);
                            PlayState.EVENT = EventJson.loadFromJson(rSong.randSong);
                            PlayState.songName = rSong.randSong;
                        }
                        var mySound:FlxSound = FlxG.sound.play("assets/sounds/confirmMenu.ogg", 0.4);
                            bfDJ.playAnim('hey');
                            mySound.onComplete = function() 
                                SwitshState.switchState(new PlayState()); // Переход в игру
                }
                updateTexts(elapsed);
                if (controls.justPressed('RESET'))
                {
                    if (PlayState.demo)
                        PlayState.demo = false;
                    else
                        PlayState.demo = true;
                    debugTxt.text = PlayState.demo ? 'Demo On' : '';
                }
                if (controls.justPressed('BACK'))
                    {
                        SwitshState.switchState(new MeinMenu());

                    }
                // updateSelection();
            }
            else
            {
                
                if(controls.justPressed('ui_up'))
                {
                    if (!(selectOptions <= 0))
                        selectOptions--; 
                    else
                        selectOptions = menuItemsOptionsString.length - 1;
                    updateSelection();
                    // trace(select);
                }

                if(controls.justPressed('ui_down'))
                {
                    if (!(selectOptions >= menuItemsOptionsString.length - 1))
                        selectOptions++;
                    else
                        selectOptions = 0;
                    updateSelection();
                    // trace(select);
                }

                if(controls.justPressed('ui_left'))
                {
                    updateOptins(-1);
                }

                if(controls.justPressed('ui_right'))
                {
                    updateOptins(1);
                }

                if(controls.justPressed('ACCEPT'))
                {
                    updateOptins(0 , true);
                }

                updateTextsOptions(elapsed);

                camOther.visible = true;

                if (controls.justPressed('BACK'))
                    optionsOpen = false;
            }
            if (controls.justPressed('OPTIONS'))
            {
                // trace('Настройки Открыты');
                optionsOpen = !optionsOpen ;
                updateSelection();

            }
        }

        if(!fullScoreEnd)
        {
            // _scoreUp = FlxMath.lerp(dataSong[7], _scoreUp, Math.exp(-elapsed * 9.6));
            
            var separatedScore:String = Std.string(_scoreUp).lpad('0', 10);
            for (i in 0...separatedScore.length)
            {
                scoreSprArray[i].animation.play('digital' + Std.parseInt(separatedScore.charAt(i)));
            }
        }

    }

    
    function createMenu()
    {
        for (i in 0 ... arraySong.length)
        {
            var item:FlxText = createMenuItem(arraySong[i], 90, (i * 30) + 30, i);
            item.visible = false;
            add(item);
            item.cameras = [camGame];
        }
    }

    function createMenuOptions()
    {
        for (i in 0 ... menuItemsOptionsString.length)
        {
            var item:FlxText = createMenuItem(menuItemsOptionsString[i], 90, (i * 30) + 30, i, true);
            item.visible = false;
            add(item);
            item.cameras = [camOther];
        }
    }

    function createMenuItem(name:String, x:Float, y:Float, its:Int, options:Bool = false):FlxText
	{
		var item:FlxText = new FlxText(x, y);
        item.setFormat('assets/fonts/Menu_Font.ttf', 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        item.scrollFactor.set();
        item.borderSize = 2.25;
        item.text = name;
        item.antialiasing = ClientSetings.data.antialiasing;
		item.scrollFactor.set();
        if (!options)
		    menuItems.push(item);
        else
            menuItemsOptions.push(item);
		return item;
	}

    var shot:Float                                  = 0;  
    var fullScoreEnd:Bool                           = false;  
    function updateSelection():Void 
    {
        FlxG.sound.play("assets/sounds/scrollMenu.ogg", 0.4);
        if (!optionsOpen)
            for (i in 0...menuItems.length) 
            {
                startLoad = true;

                fullScoreEnd = false;

                reloadScore();

                reloadText();

                FlxTween.num(0, dataSong[7], 0.5, { ease: TweenEaseAll.SelectEase("sineInOut"),
                        onComplete: function (twn:FlxTween) {
                            fullScoreEnd = true;
                            _scoreUp = dataSong[7];
                            var separatedScore:String = Std.string(_scoreUp).lpad('0', 10);
                            for (i in 0...separatedScore.length)
                            {
                                scoreSprArray[i].animation.play('digital' + Std.parseInt(separatedScore.charAt(i)));
                            }
                        }},
                        (value:Float) -> {
                            shot = Math.floor(value);
                            _scoreUp = Std.int(shot);
                        });

                menuItems[i].alpha = (i == select) ? 1 : 0.6;
            }
        else
            for (i in 0...menuItemsOptions.length) 
            {
                menuItemsOptions[i].alpha = (i == selectOptions) ? 1 : 0.6;
                if (menuItemsOptionsString[i] == 'ghostTap')
                    menuItemsOptions[i].text = 'Ghost Tap  => ' + ClientSetings.data.ghostTap;
                if (menuItemsOptionsString[i] == 'downScroll')
                    menuItemsOptions[i].text = 'Down Scroll  => ' + ClientSetings.data.downScroll;
                if (menuItemsOptionsString[i] == 'middleScroll')
                    menuItemsOptions[i].text = 'Middle Scroll  => ' + ClientSetings.data.middleScroll;
                if (menuItemsOptionsString[i] == 'opponentStrums')
                    menuItemsOptions[i].text = 'Opponent Strums  => ' + ClientSetings.data.opponentStrums;
                if (menuItemsOptionsString[i] == 'botPlay')
                    menuItemsOptions[i].text = 'BotPlay  => ' + ClientSetings.data.botPlay;
                if (menuItemsOptionsString[i] == 'healthDown')
                    menuItemsOptions[i].text = 'Health Down  => ' + ClientSetings.data.healthDown;
                if (menuItemsOptionsString[i] == 'skipLogoEngine')
                    menuItemsOptions[i].text = 'Skip Logo Engine  => ' + ClientSetings.data.skipLogoEngine;
                if (menuItemsOptionsString[i] == 'FPSmax')
                    menuItemsOptions[i].text = 'FPS max  => ' + ClientSetings.data.FPSmax ;
                if (menuItemsOptionsString[i] == 'sickHit')
                    menuItemsOptions[i].text = 'Sick!!  => ' + ClientSetings.data.sickHit +'ms';
                if (menuItemsOptionsString[i] == 'goodHit')
                    menuItemsOptions[i].text = 'Good!  => ' + ClientSetings.data.goodHit +'ms';
                if (menuItemsOptionsString[i] == 'badHit')
                    menuItemsOptions[i].text = 'bad...  => ' + ClientSetings.data.badHit +'ms';
            }
    }
    var menuItemsOptionsString:Array<String>                = ['downScroll', 'middleScroll', 'opponentStrums', 'ghostTap', 'botPlay', 'healthDown'];
    var NewSeting:Bool                                      = false;
    function updateOptins(keyLR:Int = 0, KeyAccept:Bool = false) {
        for (i in 0...menuItemsOptions.length) 
        {
            if (i == selectOptions)
            {
                if (menuItemsOptionsString[i] == 'ghostTap')
                {
                    if(KeyAccept)
                        NewSeting = !(ClientSetings.data.ghostTap);
                    ClientSetings.data.ghostTap = NewSeting ;
                }
                if (menuItemsOptionsString[i] == 'downScroll')
                {
                    if(KeyAccept)
                        NewSeting = !(ClientSetings.data.downScroll);
                    ClientSetings.data.downScroll = NewSeting ;
                }
                if (menuItemsOptionsString[i] == 'middleScroll')
                {
                    if(KeyAccept)
                        NewSeting = !(ClientSetings.data.middleScroll);
                    ClientSetings.data.middleScroll = NewSeting ;
                }
                if (menuItemsOptionsString[i] == 'opponentStrums')
                {
                    if(KeyAccept)
                        NewSeting = !(ClientSetings.data.opponentStrums);
                    ClientSetings.data.opponentStrums = NewSeting ;
                }
                if (menuItemsOptionsString[i] == 'skipLogoEngine')
                {
                    if(KeyAccept)
                        NewSeting = !(ClientSetings.data.skipLogoEngine);
                    ClientSetings.data.skipLogoEngine = NewSeting ;
                }
                if (menuItemsOptionsString[i] == 'botPlay')
                {
                    if(KeyAccept)
                        NewSeting = !(ClientSetings.data.botPlay);
                    ClientSetings.data.botPlay = NewSeting ;
                }
                if (menuItemsOptionsString[i] == 'healthDown')
                {
                    if(KeyAccept)
                        NewSeting = !(ClientSetings.data.healthDown);
                    ClientSetings.data.healthDown = NewSeting ;
                }
                if (menuItemsOptionsString[i] == 'FPSmax')
                    ClientSetings.data.FPSmax += keyLR;
                if (menuItemsOptionsString[i] == 'sickHit')
                    ClientSetings.data.sickHit += keyLR;
                if (menuItemsOptionsString[i] == 'goodHit')
                    ClientSetings.data.goodHit += keyLR;
                if (menuItemsOptionsString[i] == 'badHit')
                    ClientSetings.data.badHit  += keyLR;
            }
        }
        ClientSetings.saveSettings();
        updateSelection();
    }

    var _drawDistance:Int                                   = 4;
	var _lastVisibles:Array<Int>                            = [];
	public function updateTexts(elapsed:Float = 0.0)
	{
		lerpSelected = FlxMath.lerp(select, lerpSelected, Math.exp(-elapsed * 9.6));
		for (i in _lastVisibles)
		{
			menuItems[i].visible = menuItems[i].active = false;
		}
		_lastVisibles = [];

        // if (posText <= 150)
        //     posText += Std.parseInt(Math.exp(-elapsed * 9.6));
		var min:Int = Math.round(Math.max(0, Math.min(arraySong.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(arraySong.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:FlxText = menuItems[i];
			item.visible = item.active = true;
			item.x = ((i - lerpSelected) * 20)  +  150;
			item.y = ((i - lerpSelected) * 1.3 * 120) +  FlxG.height/2 - 100 ;

			_lastVisibles.push(i);
		}
	}
    var _lastVisiblesOptions:Array<Int>                     = [];
    public function updateTextsOptions(elapsed:Float = 0.0)
	{
		lerpSelectedOptions = FlxMath.lerp(selectOptions, lerpSelectedOptions, Math.exp(-elapsed * 9.6 /(1/60)));
		for (i in _lastVisiblesOptions)
		{
			menuItemsOptions[i].visible = menuItemsOptions[i].active = false;
		}
		_lastVisiblesOptions = [];

		var min:Int = Math.round(Math.max(0, Math.min(menuItemsOptionsString.length, lerpSelectedOptions - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(menuItemsOptionsString.length, lerpSelectedOptions + _drawDistance)));
		for (i in min...max)
		{
			var item:FlxText = menuItemsOptions[i];
			item.visible = item.active = true;
			item.x = ((i - lerpSelectedOptions) * 20)  +  150;
			item.y = ((i - lerpSelectedOptions) * 1.3 * 120) +  FlxG.height/2 - 100 ;

			_lastVisiblesOptions.push(i);
		}
	}

    var startLoad:Bool                                      = false;
    function reloadScore() {
        if(!startLoad) return;

        startLoad = false;

        var maxScore:Int = 0;
        var pos:Int = 0;
        var nameSong = arraySong[select].trim().replace(" ", "-").toLowerCase();

        if(_FullData.dataSongs.length == 0)
        {
            dataSong = [0, 0, 0, 0, 0, 0, 0, 0, 0.0,"not clear"];
            return ;
        }

        for(i in 0 ... _FullData.dataSongs.length)
        {
            var dataName = _FullData.dataSongs[i].name.trim().replace(" ", "-");

            if(nameSong == dataName) pos = i;
        }

        var dataName = _FullData.dataSongs[pos].name.trim().replace(" ", "-");

        if(nameSong != dataName) 
        {
            dataSong = [0, 0, 0, 0, 0, 0, 0, 0, 0.0,"not clear"];
            return;
        }
        for(score in _FullData.dataSongs[pos].save)
            if(maxScore < score[7])
                maxScore = score[7];

        for(j in 0 ... _FullData.dataSongs[pos].save.length)
        {    
            var data:Array<Dynamic> = _FullData.dataSongs[pos].save[j];
            if(data[7] == maxScore)
                dataSong = data;
        }
    }

    function reloadText() {
        var text:String;
        if(dataSong[9] != "not clear")
            text = "Score " + dataSong[7] + "\n" + dataSong[8] + " " + dataSong[9] + "/" + dataSong[10];
        else
            text = "Score " + dataSong[7];                            
        textScore.text = text;
        textScore.updateHitbox();
    }

    override function beatHit() 
    {
        super.beatHit();
        if (curBeat % 1 == 0)
            if (bfDJ.animation.curAnim.finished || bfDJ.animation.name == 'idle')	
            {
                bfDJ.animation.stop();
                bfDJ.playAnim('idle');
                // trace('Dance');
            }
    }
}