package states;

import data.Week.StoryWeek;

import charectors.CharectorsOther;

import backend.StoryLoad;
import backend.Song;
import backend.EventJson;

class StoryState extends MusicBeatState
{
    var bgBlack:FlxSprite                           = null;
    var bgForProps:FlxSprite                        = null;

    public var props:FlxTypedGroup<FlxSprite>       = new FlxTypedGroup<FlxSprite>();
    public var week:FlxTypedGroup<FlxSprite>        = new FlxTypedGroup<FlxSprite>();

    var defficultiwsText:FlxTypedGroup<FlxSprite>   = new FlxTypedGroup<FlxSprite>();

    var weekSprArray:Array<FlxSprite>               = [];
    var dataWeeks:Array<StoryWeek>                  = [];

    var difficulties:Array<String>                  = [];

    var sprDifficulties:Array<FlxSprite>            = [];

    var ui:Array<FlxSprite>                         = [];

    public static var select:Int                    = 0;
    public static var selectDef:Int                 = 1;

    var dadArray:Array<CharectorsOther>             = [];
    var gfArray:Array<CharectorsOther>              = [];
    var bfArray:Array<CharectorsOther>              = [];

    var dad:CharectorsOther                         = null;
    var gf:CharectorsOther                          = null;
    var bf:CharectorsOther                          = null;

    var textSong:FlxText                            = null;

    override public function create():Void
    {
        super.create();

        persistentUpdate = true;
        persistentDraw = true;

        Conductor.changeBPM(102);


        if (FlxG.sound.music != null) 
            Conductor.songPosition = FlxG.sound.music.time;

        bgBlack = new FlxSprite().makeGraphic(1280, 720, FlxColor.BLACK);
        add(bgBlack);

        bgForProps = new FlxSprite().makeGraphic(1280, 360, FlxColor.fromString('#FFD863'));
        bgForProps.y+=50;

        var files = StoryLoad.collectFilesByExtension("assets/weeks", "json");
        trace(files);

        for (j in 0 ... 2)
        {   
            trace('Spr ui create now!!');
            var spr:FlxSprite = new FlxSprite(1220, 500);
            var tex = FlxAtlasFrames.fromSparrow('assets/images/storymenu/ui/arrows.png', 'assets/images/storymenu/ui/arrows.xml');
            spr.frames = tex;

            trace('Spr ui create!!');
            spr.animation.addByPrefix('staticLeft', 'leftIdle');
            spr.animation.addByPrefix('staticRight', 'rightIdle');

            spr.animation.addByPrefix('pressedLeft', 'leftConfirm', 24, false);
            spr.animation.addByPrefix('pressedRight', 'rightConfirm', 24, false );

            spr.antialiasing = ClientSetings.data.antialiasing;

            trace('Anim ui add!!');
            spr.x += 360 * (j - 1);
            week.add(spr);
            ui.push(spr);

            trace('Ui done!!');
            if(j == 0)
            {
                playAnimSpr(spr, 'staticLeft');
            }
            else
            {
            playAnimSpr(spr, 'staticRight');
            }
        }

        var i:Int = 0;
        for (nameFilse in files)
        {
        
            // trace(nameFilse);
            var item:StoryWeek = StoryLoad.loadWeek(nameFilse);
            // trace(item);
            dataWeeks.push(item);

            var spr:FlxSprite = new FlxSprite().loadGraphic("assets/images/storymenu/titles/" + item.weekImg +".png");
            spr.screenCenter(X);
            spr.y = (FlxG.height / 2) + 70 + (120 * i);
            i++;
            spr.antialiasing = ClientSetings.data.antialiasing;
            weekSprArray.push(spr);
            week.add(spr);

            var newdad:CharectorsOther = new CharectorsOther(100, 50, item.charectors[0], "storymenu/props");
            var newbf:CharectorsOther = new CharectorsOther(FlxG.width/2 - 200, 75, item.charectors[2], "storymenu/props");
            newbf.flipX = false;
            var newgf:CharectorsOther = new CharectorsOther(FlxG.width - 400, 80, item.charectors[1], "storymenu/props");

            props.add(newdad);
            props.add(newbf);
            props.add(newgf);

            trace("Alpha");
            newdad.alpha = 0.000001;
            newbf.alpha = 0.000001;
            newgf.alpha = 0.000001;

            dadArray.push(newdad);
            gfArray.push(newgf);
            bfArray.push(newbf);
        }

        difficulties = dataWeeks[select].difficulties;

        sprDifficulties = [];
        defficultiwsText.clear();

        for(def in difficulties)
        {
            trace('Create Def!!');
        
            createDef(def);
        }

        for(i in 0 ... sprDifficulties.length)
            if(i == selectDef)
                sprDifficulties[i].alpha = 1;
            else
                sprDifficulties[i].alpha = 0.000001;

        dad = dadArray[select];
        dad.alpha = 1;
        props.add(dad);

        gf = gfArray[select];
        gf.alpha = 1;
        props.add(gf);

        bf = bfArray[select];
        bf.alpha = 1;
        bf.flipX = false;
        props.add(bf);
        
        add(week);

        add(defficultiwsText);
        
        add(bgForProps);

        textSong = new FlxText(0, bgForProps.y+390, 400, "song");
        textSong.setFormat('assets/fonts/Menu_Font.ttf', 30, FlxColor.fromString('#F15C4D'), CENTER);
        textSong.text = "song";
        textSong.antialiasing = ClientSetings.data.antialiasing;

        for (songString in dataWeeks[select].song)
            textSong.text += '\n' + songString[0]; 
        add(textSong);

        add(props);

        trace(dataWeeks);

        updateTexts();
        updateSelectionWeek();


    }

    function createDef(def:String) {
        var defPath:String = "assets/images/storymenu/difficulties/" + def +".png";
        if(AssetLoader.exists(defPath))
        {        
            var spr:FlxSprite = new FlxSprite(ui[0].x+50, ui[0].y + 5).loadGraphic(defPath);
            spr.alpha = 0.000001;
            spr.x = spr.width < 300 ? ui[0].x + 50 + ((300 - spr.width) / 2): ui[0].x + 50;
            spr.antialiasing = ClientSetings.data.antialiasing;
            sprDifficulties.push(spr);
            defficultiwsText.add(spr);
        }
        else
        {
            var text:FlxText = new FlxText(0, ui[0].y + 5, 300, "", 20);
            text.setFormat('assets/fonts/vcr.ttf', 40, FlxColor.WHITE, CENTER);
            text.text = def;
            text.scrollFactor.set();
            text.x = text.width < 300 ? ui[0].x + 50 + ((300 - text.width) / 2): ui[0].x + 50;
            text.antialiasing = ClientSetings.data.antialiasing;
            text.alpha = 0.000001;
            sprDifficulties.push(text);
            defficultiwsText.add(text);
        }
    }

    function playAnimSpr(spr:FlxSprite, anim:String) 
    {
        spr.animation.play(anim);
        if(spr.animation.curAnim != null)
        {
            spr.centerOffsets();
            spr.centerOrigin();
        }
    }

    var blocControl:Bool                            = false;
    override public function update(elapsed:Float) 
    {
        super.update(elapsed);
        if (FlxG.sound.music != null)
        {    // Conductor.songPosition = song.time;
            Conductor.songPosition = FlxG.sound.music.time;
        }
        if(!blocControl)
        {
            if(controls.justPressed('ui_up'))
            {
                if (!(select <= 0))
                    select--; 
                else
                    select = dataWeeks.length - 1;
                updateSelectionWeek();
                // trace(select);
            }

            if(controls.justPressed('ui_down'))
            {
                if (!(select >= dataWeeks.length - 1))
                    select++;
                else
                    select = 0;
                updateSelectionWeek();
                        // trace(select);
            }

            if(controls.justPressed('ui_left'))
            {
                if (!(selectDef <= 0))
                    selectDef--; 
                else
                    selectDef = difficulties.length - 1;
                playAnimSpr(ui[0], 'pressedLeft');
                for(i in 0 ... sprDifficulties.length)
                    if(i == selectDef)
                    {            
                        sprDifficulties[i].y = ui[0].y - 15;
                        sprDifficulties[i].alpha = 1;
                        FlxTween.tween(sprDifficulties[i], {y : ui[0].y + 5}, 0.1, {ease: TweenEaseAll.SelectEase("quadout")});
                    }
                    else
                        sprDifficulties[i].alpha = 0.000001;
                // updateSelectionWeek();
                // trace(select);
            }

            if(controls.justPressed('ui_right'))
            {
                if (!(selectDef >= difficulties.length - 1))
                    selectDef++;
                else
                    selectDef = 0;
                playAnimSpr(ui[1], 'pressedRight');
                for(i in 0 ... sprDifficulties.length)
                    if(i == selectDef)
                    {            
                        sprDifficulties[i].y = ui[0].y - 15;
                        sprDifficulties[i].alpha = 1;
                        FlxTween.tween(sprDifficulties[i], {y : ui[0].y + 5}, 0.1, {ease: TweenEaseAll.SelectEase("quadout")});
                    }
                    else
                        sprDifficulties[i].alpha = 0.000001;
                // updateSelectionWeek();
                        // trace(select);
            }
            if(controls.justReleased('ui_left'))
                playAnimSpr(ui[0], 'staticLeft');
            if(controls.justReleased('ui_right'))
                playAnimSpr(ui[1], 'staticRight');

            if (controls.justPressed('ACCEPT')) 
            {
                FlxG.sound.music.stop();

                blocControl = true;
                
                if(bf.hasAnimation('hey'))
                    bf.playAnim('hey');
                else
                    if (!danceGF)
                        {
                            if (!(bf.hasAnimation('idle')))
                            {bf.animation.stop();bf.playAnim('danceLeft'); }
                            else
                            {bf.animation.stop();bf.playAnim('idle'); }
                        }
                        else
                        {bf.animation.stop();bf.playAnim('danceRight'); }

                if(dad.hasAnimation('hey'))
                    dad.playAnim('idle');
                else
                    if (!danceGF)
                    {
                        if (!(dad.hasAnimation('idle')))
                        {dad.animation.stop();dad.playAnim('danceLeft'); }
                        else
                        {dad.animation.stop();dad.playAnim('idle'); }
                    }
                    else
                    {dad.animation.stop();dad.playAnim('danceRight'); }

                if(gf.hasAnimation('hey'))
                    gf.playAnim('hey');
                else
                    if (!danceGF)
                    {
                        if (!(gf.hasAnimation('idle')))
                        {gf.animation.stop();gf.playAnim('danceLeft'); danceGF = true;}
                        else
                        {gf.animation.stop();gf.playAnim('idle'); danceGF = true;}
                    }
                    else
                    {gf.animation.stop();gf.playAnim('danceRight'); danceGF = false;}
                //Создаём временный лист всех треков недели
                var songAr:Array<Dynamic> = [];
                for(songName in dataWeeks[select].song)
                    {
                        var def:String;

                        if(difficulties[selectDef] == 'normal') 
                            def = songName[0];
                        else
                            def = songName[0] + '-' + difficulties[selectDef];

                        var folder:String = songName[0];
                        var array:Array<String> = [def, folder];
                        songAr.push(array);
                    }
                trace(songAr);
                
                

                //Загружаем все нужные данные и передаём этот лист
                
                PlayState.SONG = Song.loadFromJson(songAr[0][0] ,songAr[0][1]);
                PlayState.EVENT = EventJson.loadFromJson(songAr[0][1]);
                PlayState.songName = songAr[0][1];
                PlayState.songList = songAr;
                PlayState.isStori = true;

                var mySound:FlxSound = FlxG.sound.play("assets/sounds/confirmMenu.ogg", 0.4);
                    mySound.onComplete = function() 
                        SwitshState.switchState(new PlayState()); // Переход в игру
            }

            if (controls.justPressed('BACK'))
            {
                SwitshState.switchState(new MeinMenu());
            }
        }
        updateTexts(elapsed);


    }

    function updateSelectionWeek() {

        FlxG.sound.play("assets/sounds/scrollMenu.ogg", 0.4);
        
        textSong.text = "song";
        for (songString in dataWeeks[select].song)
            textSong.text += '\n' + songString[0]; 
        // bf.kill();
        bf.alpha = 0.000001;
        bf = bfArray[select];
        bf.alpha = 1;

        // gf.kill();
        gf.alpha = 0.000001;
        gf = gfArray[select];
        gf.alpha = 1;

        // dad.kill();
        dad.alpha = 0.000001;
        dad = dadArray[select];
        dad.alpha = 1;

        // trace(select);
        // trace(bfArray);

        difficulties = dataWeeks[select].difficulties;

        sprDifficulties = [];
        defficultiwsText.clear();

        for(def in difficulties)
        {
            // trace('Create Def!!');
        
            createDef(def);
        }

        for(i in 0 ... sprDifficulties.length)
        if(i == selectDef)
            sprDifficulties[i].alpha = 1;
        else
            sprDifficulties[i].alpha = 0.000001;
    }

    var danceGF:Bool                                = false;

    override function beatHit() 
    {
        super.beatHit();
        // bf.playAnim('idle');
        // trace('Beat !');
        if (bf.animation.curAnim.finished || bf.animation.name == 'danceLeft' || bf.animation.name == 'danceRight' || bf.animation.name == 'idle')	
        {
            if (!danceGF)
            {
                if (!(bf.hasAnimation('idle')))
                {bf.animation.stop();bf.playAnim('danceLeft');}
                else
                {bf.animation.stop();bf.playAnim('idle');}
            }
            else
            {bf.animation.stop();bf.playAnim('danceRight');}
                
        }
        if (dad.animation.curAnim.finished || dad.animation.name == 'danceLeft' || dad.animation.name == 'danceRight' || dad.animation.name == 'idle')	
        {
            if (!danceGF)
            {
                if (!(dad.hasAnimation('idle')))
                {dad.animation.stop();dad.playAnim('danceLeft');}
                else
                {dad.animation.stop();dad.playAnim('idle');}
            }
            else
            {dad.animation.stop();dad.playAnim('danceRight');}
                
        }

        if (gf.animation.curAnim.finished || gf.animation.name == 'danceLeft' || gf.animation.name == 'danceRight' || gf.animation.name == 'idle')	
        {
            if (!danceGF)
            {
                if (!(gf.hasAnimation('idle')))
                {gf.animation.stop();gf.playAnim('danceLeft'); danceGF = true;}
                else
                {gf.animation.stop();gf.playAnim('idle'); danceGF = true;}
            }
            else
            {gf.animation.stop();gf.playAnim('danceRight'); danceGF = false;}
                
        }
    }

    var _drawDistance:Int                           = 4;
    var _lastVisibles:Array<Int>                    = [];
    var lerpSelected:Float                          = 0;

    public function updateTexts(elapsed:Float = 0.0)
    {
        lerpSelected = FlxMath.lerp(select, lerpSelected, Math.exp(-elapsed * 9.6));
        for (i in _lastVisibles)
        {
            weekSprArray[i].visible = weekSprArray[i].active = false;
        }
        _lastVisibles = [];

        var min:Int = Math.round(Math.max(0, Math.min(weekSprArray.length, lerpSelected - _drawDistance)));
        var max:Int = Math.round(Math.max(0, Math.min(weekSprArray.length, lerpSelected + _drawDistance)));
        for (i in min...max)
        {
            var item:FlxSprite = weekSprArray[i];
            item.visible = item.active = true;
            item.y = ((i - lerpSelected) * 1.3 * 90) +  FlxG.height/2 + 70 ;

            if(item.y < FlxG.height/2 - 100)
                item.visible = item.active = false;

            _lastVisibles.push(i);
        }
    }    
}