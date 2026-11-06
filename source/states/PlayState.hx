package states;

import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import flixel.FlxBasic;
import flixel.group.FlxSpriteGroup;

import data.Event.EventFiles;
import data.Event.Events;

import openfl.media.Sound;

import backend.Song;
import backend.Stagebg;
import backend.EventJson;


import objects.MyStrumNote;
import objects.MySpleshForNote;
import objects.Note;
import objects.HealthIcon;
import objects.Visualizer;
import backend.mobile.PlayTouch;

import charectors.BF;

import states.LevelSelect;
import states.ResultState;

import scriptsUrlsFE.HsShit;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState 						= null;
	var HScript:HsShit 											= null;

	public var rSong:RandomSongForDemo 							= new RandomSongForDemo();
	public static var demo:Bool 								= false;
	public static var songList:Array<Dynamic> 					= [];
	public static var isStori:Bool 								= false;
	public static var songListPos:Int 							= 0;

	public var NOTE_Y:Int 										= 25;
	public var NOTE_Y_DOWNSCROLL:Int 							= FlxG.height - 190;

	public var noteKillOffset:Float 							= 350;

	public static var songName:String 							= 'Fresh';
	public static var SONG:SwagSong 							= null;
	public static var EVENT:EventFiles 							= null;

	public var generatedMusic:Bool 								= false;
	public var danceGF:Bool 									= false;

	public var camGame:FlxCamera								= null;
	public var camHUD:FlxCamera									= null;
	public var camDead:FlxCamera								= null; 
	public var camOther:FlxCamera								= null; 

	public var HUD:FlxSpriteGroup 								= new FlxSpriteGroup();

	public var boyfriendGroup:FlxTypedGroup<BF> 				= new FlxTypedGroup<BF>();
	public var girlfriendGroup:FlxTypedGroup<BF> 				= new FlxTypedGroup<BF>();
	public var DadGroup:FlxTypedGroup<BF> 						= new FlxTypedGroup<BF>();

	var dadArrye:Array<BF>			 							= [];
	var bfArrye:Array<BF> 										= [];
	var gfArrye:Array<BF> 										= [];

	public var boyfriend:BF										= null;
	public var deadBf:BF										= null;
	public var Dad:BF											= null;
	public var gf:BF											= null;

	public var iconP1:HealthIcon								= null;
	public var iconP2:HealthIcon								= null;

	public var singAnim:Array<String> 							= ['singLEFT', 
																   'singDOWN', 
																   'singUP', 
																   'singRIGHT'];

	public var missAnim:Array<String> 							= ['singLEFTmiss', 
																   'singDOWNmiss', 
																   'singUPmiss', 
																   'singRIGHTmiss'];
	public var BG:FlxSprite;

	public var startTimer:FlxTimer								= null;
	public var startingSong:Bool 								= false;
	public var startedCountdown:Bool 							= false;
	
	public var music:FlxSound									= null;
	public var inst:FlxSound									= null;
	public var voicesOp:FlxSound								= null;
	public var voicesPl:FlxSound								= null;

	
	public var curSong:String									= "";
	
	public var textcurBeat:FlxText								= null;
	public var textCurSong:FlxText								= null;

	private var strumLine:FlxSprite								= null;
	// private var curSection:Int = 0;

	public var strumLineNotes:FlxTypedGroup<MyStrumNote> 		= new FlxTypedGroup<MyStrumNote>();
	public var playerStrums:FlxTypedGroup<MyStrumNote> 			= new FlxTypedGroup<MyStrumNote>();
	public var dadStrums:FlxTypedGroup<MyStrumNote> 			= new FlxTypedGroup<MyStrumNote>();
	public var spleshPlayer:FlxTypedGroup<MySpleshForNote> 		= new FlxTypedGroup<MySpleshForNote>();

	// Сенсорное управление для мобильной сборки
	#if mobile
	public var playTouch:PlayTouch 								= null;
	#end

	private var notes:FlxTypedGroup<Note>						= null;
	private var unspawnNotes:Array<Note> 						= [];
	private var noteGroup:FlxTypedGroup<FlxBasic> 				= new FlxTypedGroup<FlxBasic>();

	private var camZooming:Bool 								= true;

	public var defaultCamZoom:Float 							= 1.05;
	public var camZoomingDecay:Float 							= 1;

	private var camFollow:FlxObject								= null;

	public var boyfriendCameraOffset:Array<Float> 				= null;
	public var DadCameraOffset:Array<Float> 					= null;
	public var girlfriendCameraOffset:Array<Float> 				= null;

	public static var debag:Bool								= false;

	public var health(default, set):Float 						= 0.5;
	public var scoreTxt:FlxText									= null;
	public var score:Int 										= 0;
	public var combo:Int 										= 0;
	public var miss:Int 										= 0;

	var Nowplaying:FlxText										= null;
	var bgBlac:FlxSprite										= null;
	var bgBlue:FlxSprite										= null;

	private var keysArray:Array<String>							= null;

	public var debugTxt:FlxText									= null;

	public var stage:Stagebg									= null;

	var eventData:Array<Events>									= null;
	var eventOn:Bool 											= false;

	var timerTxt:FlxText										= null;

	var curStepTxt:FlxText										= null;
	var timeClik:FlxText										= null;
	
	var vis:Visualizer											= null;

	public var ratingHitGroup:FlxSpriteGroup 					= new FlxSpriteGroup();

	function set_health(arg:Float) {
		
		if (arg >= 1)
		{
			arg = 1;
			healthDad.visible = false;
		}
		else
			healthDad.visible = true;

		if (arg <= 0)
			arg = 0;

		healthDad.makeGraphic(Std.int(720 * (1 - arg)), 16,FlxColor.fromRGB(Dad.healthbar_colors[0], Dad.healthbar_colors[1], Dad.healthbar_colors[2]));

		health = arg;
		
		return arg;
	}

	override public function create():Void
	{	
		trace('Da Syka Blat Mi Idom Igrat?');
		//Так блять я конечно ебал ваши скрипты но они очень нужны, прям пиздец как нужны
		instance = this;

		//загружаем файлы уровня 
		if (SONG == null)
			SONG = Song.loadFromJson(songName,songName);
	
		if (EVENT == null)
			EVENT = EventJson.loadFromJson(songName);

		//Я ЕБАЛ ЭТИ СКРИПТЫ ЕБАНЫЕ ПУСКАЙ ИДУТ НАХУЙ 
		initHxScript('assets/stage/' + SONG.stage + '.hx');
		setForScript('startingSong', startingSong);

		debag = ClientSetings.data.botPlay;
		

		if (demo)
			debag = true;

		super.create();
		
		//Масив для упращения кода 
		keysArray = [
			'note_left',
			'note_down',
			'note_up',
			'note_right'
		];

		// curSong = holnah.randSong;

		
		// trace(EVENT.event);

		if (SONG.player3 == null)
				SONG.player3 = 'gf';
		
		trace (SONG.bpm);

		startingSong = true;
		Conductor.songPosition = -Conductor.Bit * 5 + Conductor.offset;

		//Камеры игры
		camGame = initFurrCamera();
		setForScript('camGame', camGame);

		camDead = new FlxCamera();
        camDead.bgColor = FlxColor.BLACK; 
		camDead.visible = false;
        FlxG.cameras.add(camDead, false);
		setForScript('camDead', camDead);

		camHUD = new FlxCamera();
        camHUD.bgColor.alpha = 0; 
        FlxG.cameras.add(camHUD, false);
		setForScript('camHUD', camHUD);

		camOther = new FlxCamera();
		camOther.bgColor.alpha = 0; 
		camOther.visible = false;
        FlxG.cameras.add(camOther, false);
		setForScript('camOther', camOther);
		createMenu();

		var cam = new FlxCamera();
        cam.bgColor.alpha = 0; 
        FlxG.cameras.add(cam);
		if (ClientSetings.data.visualizerVisible)
		{
			vis = new Visualizer(0, 400);
        	vis.cameras = [camHUD];
        	add(vis);
		}

		debugTxt = new FlxText(0, 0, 160, 'Debug');
		debugTxt.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugTxt.scrollFactor.set();
		debugTxt.borderSize = 1.25;
		debugTxt.cameras = [camHUD];
		debugTxt.x = (FlxG.width - debugTxt.width) / 2;
		debugTxt.y = ClientSetings.data.downScroll ? 90 : 60;
		HUD.add(debugTxt);
		

		#if test 
		curStepTxt = new FlxText(60, 300, 100, 'Step');
		curStepTxt.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curStepTxt.scrollFactor.set();
		curStepTxt.borderSize = 1.25;
		curStepTxt.cameras = [camHUD];

		HUD.add(curStepTxt);
	
		// add(curStepTxt);

		timeClik = new FlxText(FlxG.width/2 + 300, 300, 100, '');
		timeClik.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeClik.scrollFactor.set();
		timeClik.cameras = [camHUD];

		// add(timeClik);

		HUD.add(timeClik);

		#end
		// Спавн основных стрелок
		generateStaticArrows(0);
		generateStaticArrows(1);

		#if mobile
		// Экранное управление: четыре вертикальные зоны на всю высоту экрана
		playTouch = new PlayTouch();
		add(playTouch);
		#end

		setForScript("defPosNotePlayerX", playerStrums.members[0].x);
        setForScript("defPosNotePlayerY", playerStrums.members[0].y);

        setForScript("defPosNoteOpponentX", dadStrums.members[0].x);
        setForScript("defPosNoteOpponentY", dadStrums.members[0].y);

		setForScript('playerStrums', playerStrums);
		setForScript('dadStrums', dadStrums);


		generateStaticSplash(1);

		//Сбор инормации с .json файла уровня 
		generateSong(curSong);

		// add(stage.BgStage);

		stage.spriteGroup.cameras = [camGame];
		add(stage.spriteGroup);

		callForScript("onCreate");

		//Код предназначеный чтоб делать окно прозрачным 
		// var bg_alhpa:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.fromRGB(24 , 24, 24));
        // if (defaultCamZoom < 1)
        //     bg_alhpa.scale.scale(1 / defaultCamZoom);
        // bg_alhpa.scrollFactor.set();
        // bg_alhpa.cameras = [camGame];
        // add(bg_alhpa);
        // FlxTransWindow.getWindowsTransparent();

		// if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [gf.getMidpoint().x + gf.xPosCam + stage.gf_cam_pos[0], gf.getMidpoint().y + gf.yPosCam + stage.gf_cam_pos[1]];

		// if(DadCameraOffset == null)
			DadCameraOffset = [Dad.getMidpoint().x + Dad.xPosCam + stage.dad_cam_pos[0], Dad.getMidpoint().y + Dad.yPosCam + stage.dad_cam_pos[1]];

		// if(boyfriendCameraOffset == null)
			boyfriendCameraOffset = [boyfriend.getMidpoint().x - boyfriend.xPosCam - stage.bf_cam_pos[0], boyfriend.getMidpoint().y + boyfriend.yPosCam + stage.bf_cam_pos[1]];

		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);

		if (SONG.song == 'Tutorial')
		{
			Dad.visible = false;
			DadCameraOffset = girlfriendCameraOffset;
		}
		camFollow = new FlxObject(0, 0);

		camFollow.setPosition(camPos.x, camPos.y);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		camDead.follow(camFollow, LOCKON, 0.04);

		if(eventOn)
			if(ClientSetings.data.cacheSpr)
			{
				add(girlfriendGroup);
				girlfriendGroup.cameras = [camGame];
				add(DadGroup);
				DadGroup.cameras = [camGame];
				add(boyfriendGroup);
				boyfriendGroup.cameras = [camGame];
			}
			else
			{
				add(gf);
				gf.cameras = [camGame];

				add(Dad);
				Dad.cameras = [camGame];

				add(boyfriend);
				boyfriend.cameras = [camGame];
			}
		else
		{
			add(gf);
			gf.cameras = [camGame];

			add(Dad);
			Dad.cameras = [camGame];

			add(boyfriend);
			boyfriend.cameras = [camGame];
		}	

		add(deadBf);
			deadBf.cameras = [camDead];
		if(Dad.notFound)
			{add(Dad.notFoundPathJson); Dad.notFoundPathJson.cameras = [camGame];}
		if(boyfriend.notFound)
			{add(boyfriend.notFoundPathJson); boyfriend.notFoundPathJson.cameras = [camGame];}
		if(gf.notFound)
			{add(gf.notFoundPathJson); gf.notFoundPathJson.cameras = [camGame];}

		// notes.cameras = [camHUD];

		
		strumLine = new FlxSprite(0, !ClientSetings.data.downScroll ? NOTE_Y : NOTE_Y_DOWNSCROLL).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if(ClientSetings.data.combocam == 0)
		{		
			ratingHitGroup.cameras = [camGame];
		}
		else
			ratingHitGroup.cameras = [camHUD];

		add(ratingHitGroup);

		noteGroup.cameras = [camHUD];
		noteGroup.add(strumLineNotes);
		noteGroup.add(notes);
		noteGroup.add(spleshPlayer);
		add(noteGroup);
		// trace(Dad.xPosCam);
		// trace(Dad.yPosCam);
		// trace(boyfriend.xPosCam);
		// trace(boyfriend.yPosCam);



		startCountdown();

		timer();

		scoreTxt_and_BG();

		healthBar();

		nowPlay();

		// add(debugTxt);

		// 
		HUD.cameras = [camHUD];
		if (!ClientSetings.data.hidHUD)
			add(HUD);

		if (!demo)
			debugTxt.text = debag ? 'BotPlay' : '' ;
		else
			debugTxt.text = 'Demo';
		// trace(holnah.randSong);
		callForScript("onCreatePost");
	}

	var openPauseMenu:Bool 										= false;

	var menu:Array<String> 										= ['Resume', 
																   'Restart Song', 
																   'Change Difficulty', 
																   'Options', 
																   'Exit to menu'];

	var select:Int 												= 0;
	var menuItems:Array<FlxText> 								= [];
	var lerpSelected:Float 										= 0;
	function createMenu() {
		var blackBG = new FlxSprite(0,0);
		blackBG.makeGraphic (FlxG.width,FlxG.height,FlxColor.BLACK);
        blackBG.alpha = 0.7;
		blackBG.cameras = [camOther];
		blackBG.scrollFactor.set();
		blackBG.screenCenter(X);
        add(blackBG);

		for (i in 0 ... menu.length)
        {
            var item:FlxText = createMenuItem(menu[i], 90, (i * 30) + 30, i);
            item.visible = false;
            add(item);
            item.cameras = [camOther];
        }
	}

	function updateSelection():Void 
    {
        FlxG.sound.play("assets/sounds/scrollMenu.ogg", 0.4);
        for (i in 0...menuItems.length) 
            menuItems[i].alpha = (i == select) ? 1 : 0.6;
	}

	function createMenuItem(name:String, x:Float, y:Float, its:Int):FlxText
	{
		var item:FlxText = new FlxText(x, y);
        item.setFormat('assets/fonts/Menu_Font.ttf', 60, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        item.scrollFactor.set();
        item.borderSize = 2.25;
        item.text = name;
        item.antialiasing = ClientSetings.data.antialiasing;
		item.scrollFactor.set();
		menuItems.push(item);
		return item;
	}

	var _drawDistance:Int 										= 4;
	var _lastVisibles:Array<Int> 								= [];

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
		var min:Int = Math.round(Math.max(0, Math.min(menu.length, lerpSelected - _drawDistance)));
		var max:Int = Math.round(Math.max(0, Math.min(menu.length, lerpSelected + _drawDistance)));
		for (i in min...max)
		{
			var item:FlxText = menuItems[i];
			item.visible = item.active = true;
			item.x = ((i - lerpSelected) * 20)  +  150;
			item.y = ((i - lerpSelected) * 1.3 * 120) +  FlxG.height/2 - 100 ;

			_lastVisibles.push(i);
		}
	}

	var youDead:Bool 											= false;
	var startDead:Bool 											= false;
	var deadSfx:FlxSound										= null;
	var deadSong:FlxSound										= null;
	var deadEndNow:Bool 										= false;

	var closeMenu:Bool 											= false;

	var sped:Float												= 1;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		#if mobile
		if (playTouch != null)
		{
			playTouch.menuMode = openPauseMenu;
			playTouch.acceptAnywhere = youDead && !deadEndNow;
		}
		#end

		// if (controls.justReleased('note_up'))
		// 	trace('1');

		//Зум камер
		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, Math.exp(-elapsed * 3.125 * camZoomingDecay * 1));
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += elapsed * 1000;
				if (Conductor.songPosition >= 0)
				startSong();

			}
		}
		else
		{
			Conductor.songPosition = FlxG.sound.music.time;
			// trace('beat ' + totalBeats);
			// trace('step ' + totalSteps);
		}
		
		//Создание нот в правельной последовательности
		if (unspawnNotes[0] != null)
		{

			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
				{
					var dunceNote:Note = unspawnNotes[0];
					notes.insert(0, dunceNote);

					var index:Int = unspawnNotes.indexOf(dunceNote);
					unspawnNotes.splice(index, 1);
				}
		}

		if (openPauseMenu){

			if(controls.justPressed('ui_up'))
			{
				if (!(select <= 0))
					select--; 
				else
					select = menu.length - 1;
				updateSelection();
				// trace(select);
			}

			if(controls.justPressed('ui_down'))
			{
				if (!(select >= menu.length - 1))
					select++;
				else
					select = 0;
				updateSelection();
				// trace(select);
			}
		
			if (controls.justPressed('ACCEPT'))
			{
				switch (select)
				{
					case 0: closePauseMenu();
							closeMenu = true;
					case 1: SwitshState.switchState(new PlayState());
					case 3: SwitshState.switchState(new OptinsState()); OptinsState.isPlayState = true;
					case 4: 
						FlxG.sound.playMusic('assets/music/freakyMenu.ogg', 0.3);

						if (songList.length == 0)
							SwitshState.switchState(new LevelSelect());
						else
						{
							SwitshState.switchState(new StoryState());
							songList = [];
						}
				}
			}
			updateTexts(elapsed);
		}

		if (youDead)
		{
			FlxG.sound.music.pause();
			if (voicesOp.playing) {
				voicesOp.pause();
			}
			if (voicesPl.playing) {
				voicesPl.pause();
			}
			
			if (!startDead)
			{

				camFollow.setPosition(boyfriendCameraOffset[0] - 100, boyfriendCameraOffset[1] - 100);

				camDead.visible = true;
				camHUD.visible = false;
				deadSfx.play();
				deadBf.playAnim('firstDeath');
				


				deadSfx.onComplete = function() 
				{
					if(!deadEndNow)
					{
						@:privateAccess{
						FlxG.sound.play(deadSong._sound, 1, true);
						FlxG.sound.music.onComplete = function(){}
						}
						FlxG.sound.music.play();
						// deadSong.play(true);
						deadBf.playAnim('deathLoop');
					}
				}

				startDead = true;
			}
			
			if (controls.justPressed('ACCEPT') && !deadEndNow)
			{
				deadEndNow = true;
				// deadSong.pause();
				FlxG.sound.music.pause();
				deadBf.playAnim('deathConfirm');
				var confirmSong:FlxSound = FlxG.sound.play("assets/music/gameOverEnd.ogg");
            	// confirmSong.onComplete = function() 
                    // MusicBeatState.switchState(new PlayState());
			}
			if (controls.justPressed('BACK') && !deadEndNow)
			{
				if (deadSong.playing) {
					deadSong.pause();
				}
				if (deadSfx.playing) {
					deadSfx.pause();
				}
				SongEnd();
			}

			if (deadEndNow)
				if (deadBf.alpha > 0)
				{
					deadBf.alpha -= 0.005;
				}
				else
					SwitshState.switchState(new PlayState());
		}
		
		if (generatedMusic && !openPauseMenu && !youDead)
		{
			#if mobile
			syncVoices(false);
			#end

			callForScript("onUpdate", elapsed);

			ChekKey();
			for(i in 0 ... unspawnNotes.length)
			{
				var key = unspawnNotes[i].noteData;
				if(!unspawnNotes[i].mustPress)
				{
						//unspawnNotes[i].textyre = 'NOTE_assets_Lycur';
						// unspawnNotes[i].reloadNote();
						unspawnNotes[i].x = dadStrums.members[key].x + (dadStrums.members[key].width - unspawnNotes[i].width) / 2;
						
						if(unspawnNotes[i].isSustainNote)
							unspawnNotes[i].x = dadStrums.members[key].x + (dadStrums.members[key].width - unspawnNotes[i].width) / 2;
							// unspawnNotes[i].x -= 17;
						if(!ClientSetings.data.opponentStrums)
							unspawnNotes[i].alpha =  0;
				}
				if(unspawnNotes[i].mustPress)
				{
					//unspawnNotes[i].textyre = 'NOTE_assets_Lycur';
					// unspawnNotes[i].reloadNote();
					unspawnNotes[i].x = playerStrums.members[key].x + (playerStrums.members[key].width - unspawnNotes[i].width) / 2;
					if(unspawnNotes[i].isSustainNote)
						unspawnNotes[i].x = playerStrums.members[key].x + (playerStrums.members[key].width - unspawnNotes[i].width) / 2;
				}
			}

			notes.forEachAlive(function(daNote:Note)
			{
				if(!ClientSetings.data.downScroll )
					daNote.active = daNote.visible = daNote.y > FlxG.height ? false : true ;
				else
					daNote.active = daNote.visible = daNote.y > FlxG.height + 350 ? false : true ;

				//Скорость прокрутки стрелак
				if (!ClientSetings.data.downScroll) 
					sped = strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * PlayState.SONG.speed);
				else 
					sped = strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * PlayState.SONG.speed);

				if (ClientSetings.data.downScroll)
					if (daNote.isSustainNote)
					sped -= ((daNote.frameHeight * daNote.scale.y) - (Note.swagWidth / 2));

				daNote.y = sped;

				if(!daNote.mustPress)
				{
					daNote.x = dadStrums.members[daNote.noteData].x + (dadStrums.members[daNote.noteData].width - daNote.width) / 2;
					daNote.alpha = dadStrums.members[daNote.noteData].alpha;
					if(!ClientSetings.data.opponentStrums)
						daNote.alpha =  0;
				}
				else
				{
					daNote.x = playerStrums.members[daNote.noteData].x + (playerStrums.members[daNote.noteData].width - daNote.width) / 2;
					daNote.alpha = playerStrums.members[daNote.noteData].alpha;
					
				}
				

				//Бот нажимает клавиши опонента
				if (!daNote.mustPress && daNote.wasGoodHit && !daNote.ignoreNote)
					opponentNoteHit(daNote);

				//Бот нажимает со с стороны игрока
				if (debag && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition) && !daNote.ignoreNote)
					goodNoteHit(daNote);	

				if (daNote.mustPress && !debag && daNote.tooLate && !daNote.missNote && !daNote.ignoreNote)
				{
					noteMiss(daNote);
					// trace('note miss');
				}

				if (Conductor.songPosition - daNote.strumTime > noteKillOffset && !daNote.isSustainNote)
				{
					daNote.active = daNote.visible = false;
					invalidateNote(daNote);
					// trace('note dell');
				}
			});

			timerTxt.text = Math.floor(Conductor.songPosition / 60000) + ':' + Math.floor((Conductor.songPosition % 60000)/ 1000) +'/'+  Math.floor(inst.length / 60000) + ':' + Math.floor((inst.length % 60000)/ 1000);
		
			if(!demo)
			{
				if (controls.justPressed('PAUSE')){PauseMenu();trace('Open Pause menu!!');}
				if(controls.justPressed('RESET')){health = 0;}
			}
			else
			{
				if (controls.justPressed('EXIT_DEMO'))
				{
					demo = false;
					SongEnd();
				}
			}
			
			// if (eventOn)
			// 	chekEvent(eventData);
				
			updateScoreText();
			movetCam();

			if (debag)
				debugModText();
			
			// healthDad.scale.set(health, 1);
			// healthDad.width = 720 * (1 - health);
			// healthDad.makeGraphic(Std.int(720 * (1 - health)), 16,FlxColor.fromRGB(Dad.healthbar_colors[0], Dad.healthbar_colors[1], Dad.healthbar_colors[2]));		
			if (health <= 0)
				youDead = true;


			updateIcons(elapsed);
			callForScript("onUpdatePost", elapsed);
		}
	}

	function PauseMenu() {	
		openPauseMenu = true;
		camOther.visible = openPauseMenu;
		FlxG.sound.music.pause();
			if (voicesOp.playing)
				voicesOp.pause();
			if (voicesPl.playing)
				voicesPl.pause();
	}

	function closePauseMenu() {
		trace('Close Menu!!');
		openPauseMenu = false;
		camOther.visible = openPauseMenu;
		FlxG.sound.music.play();
		if (voicesOp.length > 0)
			voicesOp.play();
		if (voicesPl.length > 0)
			voicesPl.play();
	}

	function startCountdown():Void
	{
		Conductor.songPosition -= Conductor.Bit * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.Bit / 1000, function(tmr:FlxTimer)
		{
			Dad.animation.stop();
			boyfriend.animation.stop();
			Dad.playAnim('idle');
			boyfriend.playAnim('idle');
			if (!danceGF)
			{gf.playAnim('danceLeft'); danceGF = true;}
			else
			{gf.playAnim('danceRight'); danceGF = false;}

			startedCountdown = true;
			// Conductor.songPosition = 0;
			Conductor.songPosition -= Conductor.Bit * 5;

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play('assets/sounds/intro3.ogg', 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic('assets/images/ready.png');
					ready.scrollFactor.set();
					ready.screenCenter();
					ready.cameras = [camHUD];
					ready.y = ready.y - 120; 
    				ready.antialiasing = ClientSetings.data.antialiasing;
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.Bit / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro2.ogg', 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic('assets/images/set.png');
					set.scrollFactor.set();
					set.screenCenter();
					set.cameras = [camHUD];
					set.y = set.y - 120; 
    				set.antialiasing = ClientSetings.data.antialiasing;
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.Bit / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/intro1.ogg', 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic('assets/images/go.png');
					go.scrollFactor.set();
					go.screenCenter();
					go.cameras = [camHUD];
					go.y = go.y - 120; 
    				go.antialiasing = ClientSetings.data.antialiasing;
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.Bit / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play('assets/sounds/introGo.ogg', 0.6);
				case 4:
					Conductor.songPosition = -300;
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	function startSong():Void
	{
		trace('Song Start!!');
		startingSong = false;
		setForScript("startingSong", startingSong);

		@:privateAccess{
		FlxG.sound.playMusic(inst._sound, 1, false);
		FlxG.sound.music.onComplete = SongEnd;
		if (voicesOp.length > 0)
			voicesOp.play();
		if (voicesPl.length > 0)
			voicesPl.play();

		// Голоса стартуют на несколько кадров позже инструментала, из-за чего
		// на слабых устройствах рассинхрон слышен сразу. Подтягиваем их к
		// текущей позиции инструментала.
		syncVoices(true);

		setForScript("dataMusic", FlxG.sound.music);

		if (ClientSetings.data.visualizerVisible)
				vis.snd = FlxG.sound.music;

		callForScript("onStartSong");

		}
	}
	
	/**
	 * Подтягивает голоса к инструменталу.
	 * @param force  выставить позицию принудительно (сразу после старта)
	 */
	public function syncVoices(force:Bool = false):Void
	{
		if (FlxG.sound.music == null)
			return;

		var target:Float = FlxG.sound.music.time;

		if (voicesPl != null && voicesPl.length > 0 && voicesPl.playing)
		{
			if (force || Math.abs(voicesPl.time - target) > 80)
				voicesPl.time = target;
		}

		if (voicesOp != null && voicesOp.length > 0 && voicesOp.playing)
		{
			if (force || Math.abs(voicesOp.time - target) > 80)
				voicesOp.time = target;
		}
	}

	override function stepHit() 
	{
		super.stepHit();
		if (eventOn)
			chekEvent(eventData);
		#if test
		curStepTxt.text = 'Step ' + curStep;
		#end
		// if( curStep == 10)
			// HScript.doTweenNotePlayer(0, {x: 200}, 0.5, 'linear');
		setForScript("curStep", curStep);
		callForScript("onStepHit");
	}

	override function beatHit() 
	{
		super.beatHit();
	
		// if (boyfriend.animation.curAnim.finished && curBeat % 2 == 0 &&
		// 	!(controls.holdPressed('note_left') ||controls.holdPressed('note_up') 
		// 	|| controls.holdPressed('note_down') || controls.holdPressed('note_right')))

		iconP1.scale.set(1.2, 1.2);
		iconP2.scale.set(1.2, 1.2);

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		// if (boyfriend.animation.curAnim.finished && curBeat % 2 == 0)	
		// {
		// 	boyfriend.animation.stop();
		// 	boyfriend.playAnim('idle');
		// }

		// if (Dad.animation.curAnim.finished && curBeat % 2 == 0)
		// {
		// 	Dad.animation.stop();
		// 	Dad.playAnim('idle');
		// }
		if(generatedMusic && !startingSong && !openPauseMenu)
		{
			if (boyfriend.animation.curAnim.finished || boyfriend.animation.name == 'danceLeft' || boyfriend.animation.name == 'danceRight' )	
			{
				if (!danceGF)
				{
					if (!(boyfriend.hasAnimation('idle')))
					{boyfriend.animation.stop();boyfriend.playAnim('danceLeft');}
					else
					{boyfriend.playAnim('idle');}
				}
				else
				{boyfriend.animation.stop();boyfriend.playAnim('danceRight');}
					
			}

			if (Dad.animation.curAnim.finished || Dad.animation.name == 'danceLeft' || Dad.animation.name == 'danceRight' )	
			{
				if (!danceGF)
				{
					if (!(Dad.hasAnimation('idle')))
					{Dad.animation.stop();Dad.playAnim('danceLeft');}
					else
					{Dad.playAnim('idle');}
				}
				else
				{Dad.animation.stop();Dad.playAnim('danceRight');}
					
			}

			if (gf.animation.curAnim.finished || gf.animation.name == 'danceLeft' || gf.animation.name == 'danceRight')	
			{
				if (!danceGF)
				{
					if (!(gf.hasAnimation('idle')))
					{gf.animation.stop();gf.playAnim('danceLeft');}
					else
					{gf.playAnim('idle');}
				}
				else
				{gf.animation.stop();gf.playAnim('danceRight'); }
					
			}

			danceGF = !danceGF;
			// if (curBeat % 4 == 0 && zoomCamBit == 0)
			// 	camerasZoom();
			if (zoomCamBit > 0 && curBeat % zoomCamBit == 0 )
				camerasZoom();

			
		}

		setForScript("curBeat", curBeat);
		callForScript("onBeatHit");
		
	}

	var isAlt:Bool = false;
	override function sectionHit()
	{
		super.sectionHit();
		if (zoomCamBit == 0)
			camerasZoom();
		// if(SONG.notes[curSection].changeBPM != null)
			if (SONG.notes[curSection].changeBPM)
			{
				trace('change bpm!');
				Conductor.bpm = SONG.notes[curSection].bpm;
			}
		
		isAlt = SONG.notes[curSection].altAnim;
		callForScript("onSectionHit");

	}


	function SongEnd() 
	{
		
		FlxG.sound.music.pause();
		if (voicesOp.length > 0)
			voicesOp.pause();
		if (voicesPl.length > 0)
			voicesPl.pause();
		
		if(combo>maxCombo)
			maxCombo = combo;

		if (!demo)
		{
			if(isStori)
			{
				if (songListPos != songList.length - 1)
				{
					ResultState.Score += score;
					ResultState.Sick += Sick;
					ResultState.Good += Good;
					ResultState.Bad += Bad;
					ResultState.Shit += Shit;
					ResultState.hits += totalPlayed;
					ResultState.Miss += miss;
					var max = maxCombo == 0 ? totalPlayed :maxCombo;
					ResultState.MaxCombo = max >= ResultState.MaxCombo ? max : ResultState.MaxCombo;
					ResultState.priceHits += totalNotesHit;
					songListPos++;
					PlayState.SONG = Song.loadFromJson(songList[songListPos][0],songList[songListPos][1]);
					PlayState.EVENT = EventJson.loadFromJson(songList[songListPos][1]);
					PlayState.songName = songList[songListPos][1];
					SwitshState.switchState(new PlayState());
				}
				else
				{	
					ResultState.Score += score;
					ResultState.Sick += Sick;
					ResultState.Good += Good;
					ResultState.Bad += Bad;
					ResultState.Shit += Shit;
					ResultState.hits += totalPlayed;
					ResultState.Miss += miss;
					ResultState.priceHits += totalNotesHit;
					// ResultState.MaxCombo = maxCombo == 0 ? totalPlayed :maxCombo;
					var max = maxCombo == 0 ? totalPlayed :maxCombo;
					ResultState.MaxCombo = max >= ResultState.MaxCombo ? max : ResultState.MaxCombo;
					SwitshState.switchState(new ResultState());
					isStori = false;
					songListPos = 0;
				}
			}
			else
			{
				SwitshState.switchState(new ResultState());
				ResultState.Score = score;
				ResultState.Sick = Sick;
				ResultState.Good = Good;
				ResultState.Bad = Bad;
				ResultState.Shit = Shit;
				ResultState.hits = totalPlayed;
				ResultState.Miss = miss;
				ResultState.priceHits = totalNotesHit;
			
				ResultState.MaxCombo = maxCombo == 0 ? totalPlayed : maxCombo;
			}
		}
		else
		{

			PlayState.SONG = Song.loadFromJson(rSong.randSong,rSong.randSong);
            PlayState.EVENT = EventJson.loadFromJson(rSong.randSong);
            PlayState.songName = rSong.randSong;

			SwitshState.switchState(new PlayState());
		}

		var ocenka:String = "S";
		if(Bad == 0 && Shit == 0 && miss == 0)
			ocenka = "P";
		if(ocenka == "S" && (Math.round(ratingPercent * 100 * 100) / 100) < 95.5 && (Math.round(ratingPercent * 100 * 100) / 100) > 91)
			ocenka = "E";
		if(ocenka == "S" && (Math.round(ratingPercent * 100 * 100) / 100) < 92 && (Math.round(ratingPercent * 100 * 100) / 100) > 61)
			ocenka = "G";
		if(ocenka == "S" && (Math.round(ratingPercent * 100 * 100) / 100) < 62)
			ocenka = "L";

		ResultState.addScore(ResultState.score, curSong.trim().toLowerCase().replace(" ", "-"), [totalPlayed, maxCombo == 0 ? totalPlayed : maxCombo, Sick, Good, Bad, Shit,miss, score, (Math.round(ratingPercent * 100 * 100) / 100), AssessmentName, ocenka]);
		ResultState.listTrek.push(curSong.trim().toLowerCase().replace(" ", "-"));
		// EVENT = null;
		// SONG = null;
	}


	private function generateStaticArrows(player:Int, textur:String = 'NOTE_assets'):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = 1;
		
			var babyArrow:MyStrumNote = new MyStrumNote(0, !ClientSetings.data.downScroll ? NOTE_Y : NOTE_Y_DOWNSCROLL, i, player, textur);

			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, { alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				dadStrums.add(babyArrow);

			strumLineNotes.add(babyArrow);
			babyArrow.playerPosition();

		}
	}

	private function generateStaticSplash(player:Int, textur:String = 'NOTE_assets'):Void
	{
		for (i in 0...4)
		{
			var badySplash:MySpleshForNote = new MySpleshForNote(0, !ClientSetings.data.downScroll ? NOTE_Y : NOTE_Y_DOWNSCROLL, i, player, 'splash'+ClientSetings.data.splashArray[ClientSetings.data.splashType]);
			
			if (player == 1)
			{
			spleshPlayer.add(badySplash);
			}
			// strumLineNotes.add(badySplash);
			badySplash.playerPosition();
			badySplash.visible = ClientSetings.data.splashVisible;
		}
	}

	// var cacheImg = [];
	private function generateSong(dataPath:String):Void
	{
			var songData = SONG;
			if (EVENT.event.length > 0)
				{eventData = EVENT.event; eventOn = true;}
			else 
				eventOn = false;

			trace( 'Bf charector ' + songData.player1);
			trace( 'Dad charector ' + songData.player2);
			trace( 'Gf charector ' + songData.player3);
			trace( 'bpm ' + songData.bpm);

			Conductor.changeBPM(songData.bpm);

			curSong = songData.song;
			setForScript("curSong", curSong);

			trace(songData.song);

			inst = FlxG.sound.load(Sound.fromFile("assets/songs/"+ songName +"/Inst.ogg"), 1, false);


			var voicesOpPath:String = "assets/songs/" + songName + "/Voices-Opponent.ogg";
			var voicesPlPath:String = "assets/songs/" + songName + "/Voices-Player.ogg";
			var voicesPath:String = "assets/songs/" + songName + "/Voices.ogg";

			if (AssetLoader.exists(voicesOpPath))
				voicesOp = new FlxSound().loadEmbedded(Sound.fromFile(voicesOpPath));
			else
				voicesOp = new FlxSound();

			if (AssetLoader.exists(voicesPlPath))
				voicesPl = new FlxSound().loadEmbedded(Sound.fromFile(voicesPlPath));
			else
				voicesPl = new FlxSound();
			
			if (voicesPl.length == 0)
				if (AssetLoader.exists(voicesPath))
					voicesPl.loadEmbedded(Sound.fromFile(voicesPath));

			FlxG.sound.list.add(voicesOp);
			FlxG.sound.list.add(voicesPl);


			var deadSfxPath:String = 'assets/sounds/fnf_loss_sfx.ogg';
			var deadSongPath:String = 'assets/music/gameOver.ogg';

			if (AssetLoader.exists(deadSfxPath))
				deadSfx = new FlxSound().loadEmbedded(Sound.fromFile(deadSfxPath));
			if (AssetLoader.exists(deadSongPath))
				deadSong = new FlxSound().loadEmbedded(Sound.fromFile(deadSongPath));
			
			FlxG.sound.list.add(deadSfx);
			FlxG.sound.list.add(deadSong);

			stage = new Stagebg(songData.stage);

			if(eventOn)
				if(ClientSetings.data.cacheSpr)
				{
					var spr1:BF = new BF(stage.gf_pos[0], stage.gf_pos[1], songData.player3, false, true);
					spr1.alpha = 0.000001;
					girlfriendGroup.add(spr1);
					gfArrye.push(spr1);

					var spr2:BF = new BF(stage.dad_pos[0], stage.dad_pos[1], songData.player2, false, true);
					spr2.alpha = 0.000001;
					DadGroup.add(spr2);
					dadArrye.push(spr2);

					var spr3:BF = new BF(stage.bf_pos[0], stage.bf_pos[1], songData.player1);
					spr3.alpha = 0.000001;
					if (spr3.flipX)
						spr3.flipX = false;
					else
						spr3.flipX = true;
					boyfriendGroup.add(spr3);
					bfArrye.push(spr3);
					

					Dad = dadArrye[0];
					Dad.alpha = 1;
					boyfriend = bfArrye[0];
					boyfriend.alpha = 1;
					gf = gfArrye[0];
					gf.alpha = 1;

				}
				else
				{
					gf = new BF(stage.gf_pos[0], stage.gf_pos[1], songData.player3, false, true);
					Dad = new BF(stage.dad_pos[0], stage.dad_pos[1], songData.player2, false, true);
					boyfriend = new BF(stage.bf_pos[0], stage.bf_pos[1], songData.player1);
					if (boyfriend.flipX)
						boyfriend.flipX = false;
					else
						boyfriend.flipX = true;
				}
			else
			{
				gf = new BF(stage.gf_pos[0], stage.gf_pos[1], songData.player3, false, true);
				Dad = new BF(stage.dad_pos[0], stage.dad_pos[1], songData.player2, false, true);
				boyfriend = new BF(stage.bf_pos[0], stage.bf_pos[1], songData.player1);
				if (boyfriend.flipX)
					boyfriend.flipX = false;
				else
					boyfriend.flipX = true;
			}
			// Dad = dadArrye[0];
			setForScript("Dad", Dad);
			setForScript("Gf", gf);
			setForScript("Bf", boyfriend);

			
			// gf = gfArrye[0];

			
			// boyfriend = bfArrye[0];

			if (eventOn && ClientSetings.data.cacheSpr)
			{	
				boyfriendGroup.add(boyfriend);
				bfArrye.push(boyfriend);
				girlfriendGroup.add(gf);
				gfArrye.push(gf);
				DadGroup.add(Dad);
	        	dadArrye.push(Dad);
				for (i in 0 ... eventData.length)
				{
					var sprEv = eventData[i];
					if (sprEv.eventName == 'charactersChange')
					{
						switch (sprEv.value1)
						{
							case 'bf':
								var spr:BF = new BF(stage.bf_pos[0], stage.bf_pos[1], sprEv.value2);
								spr.alpha = 0.000001;
								if (spr.flipX)
									spr.flipX = false;
								else
									spr.flipX = true;
								boyfriendGroup.add(spr);
								bfArrye.push(spr);
							case 'gf':
								var spr:BF = new BF(stage.gf_pos[0], stage.gf_pos[1], sprEv.value2, false, true);
								spr.alpha = 0.000001;
								girlfriendGroup.add(spr);
								gfArrye.push(spr);
							case 'dad':
								var spr:BF = new BF(stage.dad_pos[0], stage.dad_pos[1], sprEv.value2, false, true);
								spr.alpha = 0.000001;
								DadGroup.add(spr);
								dadArrye.push(spr);
						}
							
					}
				}
			}
			// if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [gf.getMidpoint().x + gf.xPosCam + stage.gf_cam_pos[0], gf.getMidpoint().y + gf.yPosCam + stage.gf_cam_pos[1]];

			// if(DadCameraOffset == null)
			DadCameraOffset = [Dad.getMidpoint().x + Dad.xPosCam + stage.dad_cam_pos[0], Dad.getMidpoint().y + Dad.yPosCam + stage.dad_cam_pos[1]];

			// if(boyfriendCameraOffset == null)
			boyfriendCameraOffset = [boyfriend.getMidpoint().x - boyfriend.xPosCam - stage.bf_cam_pos[0], boyfriend.getMidpoint().y + boyfriend.yPosCam + stage.bf_cam_pos[1]];

			deadBf = new BF(stage.bf_pos[0], stage.bf_pos[1], 'bf-dead');

			defaultCamZoom = stage.camZoom;
			setForScript("defaultCamZoom", defaultCamZoom);

			camDead.zoom = defaultCamZoom;
			// if (boyfriend.flipX)
			// 	boyfriend.flipX = false;
			// else
			// 	boyfriend.flipX = true;

			if (deadBf.flipX)
				deadBf.flipX = false;
			else
				deadBf.flipX = true;

			if (SONG.player2 == 'camellia')
				{Dad.flipX = false;}


			notes = new FlxTypedGroup<Note>();
			notes.cameras = [camHUD];
			// add(notes);
			unspawnNotes = [];
			var noteData:Array<SwagSection>;
	
			// NEW SHIT
			noteData = songData.notes;
				
			var oldNote:Note = null;
			var daBpm = Conductor.bpm;
			for (section in noteData)
			{
				if (section.changeBPM && daBpm != section.bpm)
					daBpm = section.bpm;
	
				for (i in 0 ... section.sectionNotes.length)
				{
					final songNotes: Array<Dynamic> = section.sectionNotes[i];
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);
					var holdLength: Float = songNotes[2];
					var gottaHitNote:Bool ;
					var noteType:String = songNotes[3];
					if (SONG.format == 'psych_v1' || SONG.format == 'psych_v1_convert')
						gottaHitNote = (songNotes[1] < 4);
					else
					{
						gottaHitNote = section.mustHitSection;

						if (songNotes[1] > 3)
						{
							gottaHitNote = !section.mustHitSection;
						}
					}
	
					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.noteType = noteType;
					swagNote.mustPress = gottaHitNote;
					swagNote.sustainLength = holdLength;
					swagNote.scrollFactor.set();
	
					unspawnNotes.push(swagNote);

					var curStepCrochet:Float = 60 / daBpm * 1000 / 4.0;
					final roundSus:Int = Math.round(swagNote.sustainLength / curStepCrochet);
					for (susNote in 0...roundSus)
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
	
						var sustainNote:Note = new Note(daStrumTime + (curStepCrochet * susNote), daNoteData, oldNote, true);
						
						sustainNote.noteType = swagNote.noteType;

						sustainNote.scrollFactor.set();
						unspawnNotes.push(sustainNote);
	
						sustainNote.mustPress = gottaHitNote;

						if (sustainNote.mustPress)
						{
							sustainNote.x += FlxG.width / 2 + 35; // смещение трейла длинной ноты 
						}
						else
						{
							sustainNote.x += 40;
						}

						if(oldNote.isSustainNote)
						{
							// oldNote.scale.y /= playbackRate;
							oldNote.reSize(curStepCrochet / Conductor.StepBit);
						}
					}
	
					swagNote.mustPress = gottaHitNote;
					if (swagNote.mustPress)
					{
						swagNote.x += FlxG.width / 2 - 25; // смещение стрелки 
					}
					else
					{
						swagNote.x += -20;
					}
					
					
				}
			}
	
			trace(unspawnNotes.length);
			// playerCounter += 1;
	

			for(i in 0 ... unspawnNotes.length)
			{
				var key = unspawnNotes[i].noteData;
				if(!unspawnNotes[i].mustPress)
				{
						unspawnNotes[i].reloadNote();
						unspawnNotes[i].x = dadStrums.members[key].x + (dadStrums.members[key].width - unspawnNotes[i].width) / 2;
						

						// if(unspawnNotes[i].isSustainNote)
						// 	unspawnNotes[i].x = dadStrums.members[key].x + (dadStrums.members[key].width - unspawnNotes[i].width) / 2;
						if(!ClientSetings.data.opponentStrums)
							unspawnNotes[i].alpha =  0;
				}
				if(unspawnNotes[i].mustPress)
				{
					unspawnNotes[i].reloadNote();
					unspawnNotes[i].x = playerStrums.members[key].x + (playerStrums.members[key].width - unspawnNotes[i].width) / 2;
					
					// if(!unspawnNotes[i].isSustainNote && unspawnNotes[i].noteData == 0)
					// 	trace(unspawnNotes[i].x);
					
					// if(unspawnNotes[i].isSustainNote)
					// 	unspawnNotes[i].x = playerStrums.members[key].x + (playerStrums.members[key].width - unspawnNotes[i].width) / 2;
				}
			}

			unspawnNotes.sort(sortByTime);
			setForScript('unspawnNotes', unspawnNotes);
			generatedMusic = true;
			// trace('LOADED FROM JSON: ' + songData.notes);
	}

	public static function sortByTime(Obj1:Dynamic, Obj2:Dynamic):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	function sortByShit(Obj1:Note, Obj2:Note):Int
		{
			if (Obj1.lowPriority && !Obj2.lowPriority)
				return 1;
			else if (!Obj1.lowPriority && Obj2.lowPriority)
				return -1;
	
			return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
		}

	function goodNoteHit(note:Note):Void
	{

		if (note.wasGoodHit) return;

		// var key = note.noteData;
		health += 0.012;

		note.wasGoodHit = true;

		voicesPl.volume = 1;
		var hitTime = Math.round((Conductor.songPosition - note.strumTime )*100) / 100;
		if (!note.isSustainNote)
		{
			totalPlayed++;
			combo++;
			#if test
			timeClik.text = '$hitTime'  ;
			#end
			ratingHit(hitTime, note.noteData);

			if (combo >= 250 && combo <= 300)
				score += 150;
			else if (combo <= 400)
				score += 200;
			else if (combo <= 450)
				score += 250;
			else if (combo <= 1000)
				score += 300;
			else if (combo <= 3000)
				score += 500;
			else
				score += 700;
		}


		boopScoreText();
		// trace('combo' + combo+' score '+score);
		// note.
		if (note.noteType == "GF Sing")
		{
			if(gf.not_hold_play_animation)
				if (!note.isSustainNote)
					gf.playAnim(singAnim[note.noteData], true);
			if(!(gf.not_hold_play_animation))
				gf.playAnim(singAnim[note.noteData], true);
		}

		if (note.noteType == "Hey!")
			boyfriend.playAnim('hey', true);

		if (note.noteType != "No Animation" && note.noteType != "GF Sing"  && note.noteType != "Hey!" && note.noteType != "Alt Animation")
			boyfriend.playAnim(singAnim[note.noteData], true);

		if(note.noteType == 'Alt Animation' || isAlt)
			if(boyfriend.hasAnimation(singAnim[note.noteData] + '-alt'))
				boyfriend.playAnim(singAnim[note.noteData] + '-alt', true);
			else
			boyfriend.playAnim(singAnim[note.noteData], true);

		// if (note.prevNote.noteType != "No Animation" && note.prevNote.noteType != "GF Sing"  && note.prevNote.noteType != "Hey!")
		// 	boyfriend.playAnim(singAnim[note.noteData], true);

		if(!debag)
		{
			var spr = playerStrums.members[note.noteData];
			if(spr != null) spr.playAnim('confirm', true);
		}
		else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.StepBit * 1.25 / 1000 / 1);
		
		// if(!note.isSustainNote) invalidateNote(note);
		callForScript("goodNoteHit", note);

		invalidateNote(note);

	}
	
	function opponentNoteHit(note:Note) {

		if (voicesOp.length <= 0)
			voicesPl.volume = 1;

		if (ClientSetings.data.healthDown)
			if (health > 0.05)
				health -= 0.009;

		if (SONG.song == 'Tutorial' || note.noteType == "GF Sing")
		{
			if(gf.not_hold_play_animation)
				if (!note.isSustainNote)
					gf.playAnim(singAnim[note.noteData], true);
			if(!(gf.not_hold_play_animation))
				gf.playAnim(singAnim[note.noteData], true);
		}

		if (note.noteType == "Hey!")
			Dad.playAnim('hey', true);

		if (note.noteType != "No Animation" && note.noteType != "GF Sing" && note.noteType != "Hey!" && note.noteType != 'Alt Animation')
			{
				// if(Dad.not_hold_play_animation)
				// 	if (!note.isSustainNote)
				// 		Dad.playAnim(singAnim[note.noteData], true);
				// if(!(Dad.not_hold_play_animation))
				// 	Dad.playAnim(singAnim[note.noteData], true);
				Dad.playAnim(singAnim[note.noteData], true);
			}
		if(note.noteType == 'Alt Animation' || isAlt)
			if(Dad.hasAnimation(singAnim[note.noteData] + '-alt'))
				Dad.playAnim(singAnim[note.noteData] + '-alt', true);
			else
			Dad.playAnim(singAnim[note.noteData], true);

		if (ClientSetings.data.glovOponent)
			strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.StepBit * 1.25 / 1000 / 1);

		// if(!note.isSustainNote) invalidateNote(note);

		callForScript("opponentNoteHit", note);

		invalidateNote(note);
	}

	public function invalidateNote(note:Note):Void {
		note.delNote();
		notes.remove(note, true);
	}

	function movetCam() 
	{

		if(noTweenCamB)
		{
			DadCameraOffset = girlfriendCameraOffset;
			boyfriendCameraOffset = girlfriendCameraOffset;
		}
		var sec:Int = Std.int(curStep / 16);


		if (generatedMusic && PlayState.SONG.notes[sec] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[sec].mustHitSection);
			}
			if (camFollow.x != Dad.getMidpoint().x + 150 && !PlayState.SONG.notes[sec].mustHitSection)
			{
				camFollow.setPosition(DadCameraOffset[0] + 150, DadCameraOffset[1] - 100);

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.StepBit * 4 / 1000), {ease: FlxEase.elasticInOut});

				}
			}
	
			if (PlayState.SONG.notes[sec].mustHitSection && camFollow.x != boyfriend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boyfriendCameraOffset[0] - 100, boyfriendCameraOffset[1] - 100);
	
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.StepBit * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}		
	}
	
	function updateScoreText() 
	{
		#if !neko
		scoreTxt.text = 'Score : ' + score + ' | Combo : ' + combo + ' | Misses : '+ miss + ' | Rating : '  + (Math.round(ratingPercent * 100 * 100) / 100)+ '%' + ' - ' + ratingName + ' ('+ AssessmentName+')';
			scoreBG.makeGraphic(scoreTxt.text.length * 13, 30,FlxColor.fromString('#000000'));
			scoreBG.screenCenter(X);
			scoreBG.updateHitbox();
		#end
	}
	
	var scoreTxtTween:FlxTween;
	var scoreBgTween:FlxTween;
	function boopScoreText() 
	{
		if(scoreTxtTween != null)
			scoreTxtTween.cancel();

		scoreTxt.scale.set(1.075, 1.075);
		scoreTxtTween = FlxTween.tween(scoreTxt.scale, {x: 1, y: 1}, 0.2, {
			onComplete: function(twn:FlxTween) {
				scoreTxtTween = null;
			}
		});
	}

	function nowPlay():Void 
	{
		textCurSong = new FlxText(-500,125,0, curSong);
		textCurSong.setFormat('assets/fonts/vcr.ttf', 25, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		textCurSong.scrollFactor.set();
		textCurSong.borderSize = 1.25;
		textCurSong.cameras = [camHUD];

		Nowplaying = new FlxText(-500,90,0, 'Now playing');
		Nowplaying.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		Nowplaying.scrollFactor.set();
		Nowplaying.borderSize = 1.25;
		Nowplaying.cameras = [camHUD];


		bgBlac = new FlxSprite (-500,45);
		bgBlac.makeGraphic (300, 150,FlxColor.BLACK);
		bgBlac.cameras = [camHUD];

		bgBlue = new FlxSprite (-500,45);
		bgBlue.makeGraphic (300, 150,FlxColor.BLUE);
		bgBlue.cameras = [camHUD];

		HUD.add(bgBlue);
		HUD.add(bgBlac);
		HUD.add(textCurSong);
		HUD.add(Nowplaying);

		// add(bgBlue);
		// add(bgBlac);
		// add(textCurSong);
		// add(Nowplaying);
		nowPlayTween();
	}
	public var scoreBG:FlxSprite;
	function scoreTxt_and_BG():Void
	{
		scoreTxt = new FlxText(0, FlxG.height - 60, FlxG.width, "Yes", 20);
		scoreTxt.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		scoreTxt.cameras = [camHUD];
    	scoreTxt.antialiasing = ClientSetings.data.antialiasing;

		
		scoreBG = new FlxSprite(0, scoreTxt.y - 5);
		scoreBG.makeGraphic (scoreTxt.text.length * 250, 30,FlxColor.fromString('#000000'));
		scoreBG.cameras = [camHUD];
		scoreBG.alpha = 0.7;
		scoreBG.screenCenter(X);

		HUD.add(scoreBG);
		HUD.add(scoreTxt);

		// add(scoreBG);
		// add(scoreTxt);
	}

	public var healthBg:FlxSprite;
	public var healthDad:FlxSprite;
	public var healthBf:FlxSprite;
	var HEALTBAR_Y:Int = 590;
	var HEALTBAR_Y_DOWNSCROLL:Int = 55;
	public dynamic function updateIconsScale(elapsed:Float)
	{
		var mult:Float = FlxMath.lerp(1, iconP1.scale.x, Math.exp(-elapsed * 9 ));
		iconP1.scale.set(mult, mult);
		iconP1.updateHitbox();

		var mult:Float = FlxMath.lerp(1, iconP2.scale.x, Math.exp(-elapsed * 9 ));
		iconP2.scale.set(mult, mult);
		iconP2.updateHitbox();
	}
	public function updateIcons(elapsed:Float)
	{
		if (iconP1.iSize == 2)
			iconP1.animation.curAnim.curFrame = (Std.int(health*100) < 20) ? 1 : 0;
		else
			iconP1.animation.curAnim.curFrame = (Std.int(health*100) < 20) ? 1 : (Std.int(health*100) > 80) ? 2 : 0;
		
		if (iconP2.iSize == 2)
			iconP2.animation.curAnim.curFrame = (Std.int(health*100) > 80) ? 1 : 0  ; 
		else
			iconP2.animation.curAnim.curFrame = (Std.int(health*100) > 80) ? 1 : (Std.int(health*100) < 20) ? 2 : 0  ; 
	
		midllPosIcon = healthBf.x + (healthBf.width  * (1 - health) - 35);
		if(Std.int(iconP1.x * 100) != Std.int(midllPosIcon * 100))
		{
			iconP1.x = FlxMath.lerp(midllPosIcon, iconP1.x, Math.exp(-elapsed * 9 ));
			iconP2.x = iconP1.x - 110;
		}

		updateIconsScale(elapsed);
	}
	var midllPosIcon:Float = 0;
	function healthBar():Void
	{
		
		healthBg = new FlxSprite(0, !ClientSetings.data.downScroll ? HEALTBAR_Y : HEALTBAR_Y_DOWNSCROLL);
		healthBg.makeGraphic (740, 25,FlxColor.fromString('#000000'));
		healthBg.cameras = [camHUD];
		healthBg.scrollFactor.set();
		healthBg.screenCenter(X);
		
		healthDad = new FlxSprite(healthBg.x + 10 , healthBg.y + 4);
		healthDad.makeGraphic(Std.int(720 * (1 - health)), 16,FlxColor.fromRGB(Dad.healthbar_colors[0], Dad.healthbar_colors[1], Dad.healthbar_colors[2]));
		healthDad.cameras = [camHUD];
		healthDad.scrollFactor.set();
		

		healthBf = new FlxSprite(0, healthBg.y + 4);
		healthBf.makeGraphic (720, 16,FlxColor.fromRGB(boyfriend.healthbar_colors[0], boyfriend.healthbar_colors[1], boyfriend.healthbar_colors[2]));
		healthBf.cameras = [camHUD];
		healthBf.scrollFactor.set();
		healthBf.screenCenter(X);

		iconP1 = new HealthIcon(boyfriend.icon, true);
		iconP1.y = healthBg.y - 75;
		iconP1.cameras = [camHUD];
		midllPosIcon = healthBf.x + (healthBf.width * (1 - health)) - 35;
		iconP1.x = midllPosIcon;

		iconP2 = new HealthIcon(Dad.icon, false);
		iconP2.y = healthBg.y - 75;
		iconP2.cameras = [camHUD];
		iconP2.x = iconP1.x - 110;

		HUD.add(healthBg);
		HUD.add(healthBf);
		HUD.add(healthDad);
		
		HUD.add(iconP2);
		HUD.add(iconP1);
		
	}

	function nowPlayTween() {
		FlxTween.tween(textCurSong, { x: 30, y: 125 }, (Conductor.StepBit * 4 / 1000) , {ease: FlxEase.bounceOut, startDelay: 3 })
			.then(FlxTween.tween(textCurSong, { x: -500 }, 1, { ease: FlxEase.bounceOut, startDelay: 3}));
		FlxTween.tween(Nowplaying, { x: 20, y: 90 }, (Conductor.StepBit * 4 / 1000) , {ease: FlxEase.bounceOut, startDelay: 3 })
			.then(FlxTween.tween(Nowplaying, { x: -500 }, 1, { ease: FlxEase.bounceOut, startDelay: 3}));	
		FlxTween.tween(bgBlue, { x: 30, y: 45 }, (Conductor.StepBit * 4 / 1000) , {ease: FlxEase.bounceOut, startDelay: 3 })
			.then(FlxTween.tween(bgBlue, { x: -500 }, 1, { ease: FlxEase.bounceOut, startDelay: 3}));
		FlxTween.tween(bgBlac, { x: 0, y: 45 }, (Conductor.StepBit * 4 / 1000) , {ease: FlxEase.bounceOut, startDelay: 3 })
			.then(FlxTween.tween(bgBlac, { x: -500 }, 1, { ease: FlxEase.bounceOut, startDelay: 3} ));
	}

	function timer() {
		timerTxt = new FlxText(ClientSetings.data.downScroll ? 450 : 0, 0, FlxG.width, '00:00');
		timerTxt.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timerTxt.scrollFactor.set();
		timerTxt.borderSize = 1.25;
		timerTxt.cameras = [camHUD];
    	timerTxt.antialiasing = ClientSetings.data.antialiasing;
		HUD.add(timerTxt);
		// add(timerTxt);
	}


	var alphaText:Bool = true;
	function debugModText() {
		if (alphaText){
			debugTxt.alpha -= 0.01;
		}
		else
		{
			debugTxt.alpha += 0.01;
		}
		if (debugTxt.alpha == 0){
			alphaText=false;
		}
		else if (debugTxt.alpha == 1)
		{
			alphaText=true;
		}
	}

	function splashPlayAnim(isDad:Bool, key:Int) 
	{
		var spr:MySpleshForNote = null;
		spr = spleshPlayer.members[key];
		if(spr != null) {
			spr.playAnim('pressed', true);
		}
	}

	function strumPlayAnim(isDad:Bool, key:Int, time:Float) 
	{
		var spr:MyStrumNote = null;
		if(isDad) {
			spr = dadStrums.members[key];
		} else {
			spr = playerStrums.members[key];
		}

		if(spr != null) {
			spr.playAnim('confirm', true);
			spr.resetAnim = time;
		}
	}

	var maxCombo:Int = 0;
	public function noteMiss(daNote:Note) {
		daNote.missNote = true;
		voicesPl.volume = 0;
		pressMiss(daNote.noteData, daNote.isSustainNote);
	}
	public function pressMiss(key:Int, isHoldNota:Bool) {
		if(combo>maxCombo)
			maxCombo = combo;
		health -= health > 0.6 ? 0.07 : 0.02;
		totalPlayed++;
		healthDad.visible = true;
		if (!isHoldNota)
			FlxG.sound.play("assets/sounds/missnote"+ (Std.random(2)+1) +".ogg", 0.15);
		boyfriend.playAnim(missAnim[key], true);
		miss++;
		
		score-= combo > 500 ? 150 : 90;
		combo = 0;
		healthDad.makeGraphic(Std.int(720 * (1 - health)), 16,FlxColor.fromRGB(Dad.healthbar_colors[0], Dad.healthbar_colors[1], Dad.healthbar_colors[2]));
		totalNotesHit += 0;
		ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
	}

	var iEvent:Int = 0;
	private function chekEvent(evData:Array<Events>) 
	{
		if (curStep == evData[iEvent].step)
		{
			if(evData[iEvent].eventName == "PlayAnimate")
			{
				playAnimate(evData[iEvent].value1 , evData[iEvent].value2);
			}
			if(evData[iEvent].eventName == "charactersChange")
			{
				charactersChange(evData[iEvent].value1 , evData[iEvent].value2);
				trace('characters Change');
			}
			if(evData[iEvent].eventName == "noTweenCam")
			{
				noTweenCam(evData[iEvent].value1 , evData[iEvent].value2);
				trace('no Move Camera');
			}
			if(evData[iEvent].eventName == "camerasZoom")
			{
				camerasZoom(evData[iEvent].value1 , evData[iEvent].value2);
				trace('cameras Zoom');
			}
			if(evData[iEvent].eventName == "bitZoom")
			{
				bitZoom(evData[iEvent].value1 , evData[iEvent].value2);
				trace('cameras Zoom');
			}		
			if(evData[iEvent].eventName == "defZoom")
			{
				defZoom(evData[iEvent].value1 , evData[iEvent].value2);
				trace('defolt zoom');
			}	
			
			iEvent = iEvent < evData.length - 1 ? iEvent + 1 : evData.length - 1;
		}
	}
	private function charactersChange(v1:String, v2:String) 
	{
		//Старый способ изменения персонажа
		//Рабочий но постоянно подгружает по новому спрайты
		// switch (v1)
		// {
		// 	case 'bf':
		// 		boyfriend.personagaChange(v2);
		// 		boyfriendCameraOffset = [boyfriend.getMidpoint().x - boyfriend.xPosCam - stage.bf_cam_pos[0], boyfriend.getMidpoint().y + boyfriend.yPosCam + stage.bf_cam_pos[1]];
		// 		if (boyfriend.flipX)
		// 			boyfriend.flipX = false;
		// 		else
		// 			boyfriend.flipX = true;
		// 		healthBf.color = FlxColor.fromRGB(boyfriend.healthbar_colors[0], boyfriend.healthbar_colors[1], boyfriend.healthbar_colors[2]);
		// 		iconP1.ChangeIcon(boyfriend.icon);
		// 	case 'dad':
		// 		Dad.personagaChange(v2);
		// 		DadCameraOffset = [Dad.getMidpoint().x + Dad.xPosCam + stage.dad_cam_pos[0], Dad.getMidpoint().y + Dad.yPosCam + stage.dad_cam_pos[1]];
		// 		healthDad.color = FlxColor.fromRGB(Dad.healthbar_colors[0], Dad.healthbar_colors[1], Dad.healthbar_colors[2]);
		// 		iconP2.ChangeIcon(Dad.icon);
		// 	case 'gf':
		// 		gf.personagaChange(v2);
		// 		girlfriendCameraOffset = [gf.getMidpoint().x + gf.xPosCam + stage.gf_cam_pos[0], gf.getMidpoint().y + gf.yPosCam + stage.gf_cam_pos[1]];

		// }
		switch (v1)
		{
			case 'bf':
				if(ClientSetings.data.cacheSpr)
					for(i in 0 ... bfArrye.length)
						if(bfArrye[i].name == v2)
						{
							boyfriend.alpha = 0.000001;
							boyfriend = bfArrye[i];
							boyfriend.alpha = 1;
						}
				if(!ClientSetings.data.cacheSpr)
					boyfriend.personagaChange(v2);
				boyfriendCameraOffset = [boyfriend.getMidpoint().x - boyfriend.xPosCam - stage.bf_cam_pos[0], boyfriend.getMidpoint().y + boyfriend.yPosCam + stage.bf_cam_pos[1]];
				healthBf.color = FlxColor.fromRGB(boyfriend.healthbar_colors[0], boyfriend.healthbar_colors[1], boyfriend.healthbar_colors[2]);
				iconP1.ChangeIcon(boyfriend.icon);
			case 'dad':
				if(ClientSetings.data.cacheSpr)
					for(i in 0 ... dadArrye.length)
						if(dadArrye[i].name == v2)
						{
							Dad.alpha = 0.000001;
							Dad = dadArrye[i];
							Dad.alpha = 1;
						}
				if(!ClientSetings.data.cacheSpr)
					Dad.personagaChange(v2);
				DadCameraOffset = [Dad.getMidpoint().x + Dad.xPosCam + stage.dad_cam_pos[0], Dad.getMidpoint().y + Dad.yPosCam + stage.dad_cam_pos[1]];
				healthDad.color = FlxColor.fromRGB(Dad.healthbar_colors[0], Dad.healthbar_colors[1], Dad.healthbar_colors[2]);
				iconP2.ChangeIcon(Dad.icon);
			case 'gf':
				if(ClientSetings.data.cacheSpr)
					for(i in 0 ... gfArrye.length)
						if(gfArrye[i].name == v2)
						{
							gf.alpha = 0.000001;
							gf = gfArrye[i];
							gf.alpha = 1;
						}
				if(!ClientSetings.data.cacheSpr)
					gf.personagaChange(v2);
				girlfriendCameraOffset = [gf.getMidpoint().x + gf.xPosCam + stage.gf_cam_pos[0], gf.getMidpoint().y + gf.yPosCam + stage.gf_cam_pos[1]];

		}		
	}
	private function playAnimate(v1:String, v2:String)
	{
		switch (v1)
		{
			case 'bf':
				boyfriend.animation.stop();
				boyfriend.playAnim(v2);
			case 'dad':
				Dad.animation.stop();
				Dad.playAnim(v2);
			case 'gf':
				gf.animation.stop();
				gf.playAnim(v2);		
		}		
	}
	public var noTweenCamB:Bool = false;
	private function noTweenCam(v1:String = 'false', v2:String) {
		if (v1 == 'false')
			noTweenCamB = false;
		if (v1 == 'true')
			noTweenCamB = true;
	}
	private function camerasZoom(v1:String = "1", v2:String = "1") {
		if (camZooming && FlxG.camera.zoom < 1.35 )
		{
			FlxG.camera.zoom += 0.015 * Std.parseFloat(v1);
			camHUD.zoom += 0.03 * Std.parseFloat(v2);
		}	
	}
	private var zoomCamBit:Int = 0;
	private function bitZoom(v1:String = "0", v2:String)
		zoomCamBit = Std.parseInt(v1);

	private function defZoom(v1:String = "0", v2:String = "0")
	{
		if (Std.parseFloat(v1) == 0)
		{
			defaultCamZoom = stage.camZoom;
			setForScript("defaultCamZoom", defaultCamZoom);
		}
		else
		{
			defaultCamZoom = Std.parseFloat(v1);
			setForScript("defaultCamZoom", defaultCamZoom);
		}
	}


	public function ChekKey():Void
	{
		var holdArray:Array<Bool> = [for (key in keysArray) controls.holdPressed(key)];
		var pressArray:Array<Bool> = [for (key in keysArray) controls.justPressed(key)];
		var releaseArray:Array<Bool> = [for (key in keysArray) controls.justReleased(key)];

		//нажата ли клавиша
		for (i in 0...pressArray.length)
			if(pressArray[i])
				keyPresed(i);

		if (generatedMusic && notes.length > 0)
			{
				for (n in notes) { 
					if (n != null && n.canBeHit && n.canBeHitNow() && n.isSustainNote) {
						if (holdArray[n.noteData])
							goodNoteHit(n);
					}
				}
			}
		
		// trace(releaseArray[1]);
		//Отпущена ли клавиша
		for (i in 0...releaseArray.length)
			if(releaseArray[i])
				keyReleased(i);
	}

	public function keyPresed(key:Int) {
		if(debag) return;

		var lastTime:Float = Conductor.songPosition;

		// if(Conductor.songPosition >= 0) Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

		// obtain notes that the player can hit
		var noteHitBlat: Array<Note> = notes.members.filter(function(n:Note):Bool {
			return n != null && n.canBeHit && n.canBeHitNow() && n.noteData == key && !n.isSustainNote;
		});
		noteHitBlat.sort(sortByShit);

		if (noteHitBlat.length  != 0){
			var iaEbalEtiNots:Note =  noteHitBlat[0];

			if (noteHitBlat.length > 1) {
				var doubleNote:Note = noteHitBlat[1];

				if (iaEbalEtiNots.noteData == doubleNote.noteData)
				{
					// если до ноты осталось 0 мс, то мы ее удаляем
					if (Math.abs(doubleNote.strumTime - iaEbalEtiNots.strumTime) < 1.0)
						invalidateNote(doubleNote);
					else if (doubleNote.strumTime < iaEbalEtiNots.strumTime)
					{
						// replace the note if its ahead of time (or at least ensure "doubleNote" is ahead)
						iaEbalEtiNots = doubleNote;
					}
				}
			}
			if (!iaEbalEtiNots.ignoreNote)
					goodNoteHit(iaEbalEtiNots);
			else
			{
				if(!iaEbalEtiNots.isSustainNote)
					pressMiss(key,false);
				invalidateNote(iaEbalEtiNots);
			}
				
		}
		else
			if (!ClientSetings.data.ghostTap)
				pressMiss(key,false);

		
		var spr:MyStrumNote = playerStrums.members[key];
		if(spr != null && spr.animation.curAnim.name != 'confirm')
		{
			spr.playAnim('pressed');
			spr.resetAnim = 0;
		}

		Conductor.songPosition = lastTime;

	}


	// Отпущена ли клавиша
	private function keyReleased(key:Int)
	{
		if(debag || !startedCountdown || key < 0 || key >= playerStrums.length) return;

		
		var spr = playerStrums.members[key];
		if(spr != null)
		{
			spr.playAnim('static');
			spr.resetAnim = 0;
		}
	}

	public var totalPlayed:Int = 0;
	public var ratingPercent:Float = 0.0;
	public var totalNotesHit:Float = 0.0;
	public var ratingName:String = '?';
	public var Sick:Int = 0;
    public var Good:Int = 0;
    public var Bad:Int = 0;
    public var Shit:Int = 0;
	var path:String = "assets/images/sick.png";
	var Assessment:Array<String> = ['PFC', 'SFC' , 'GFC', 'BFC', 'FC', 'SDCB', 'Clear'];
	var AssessmentName:String = '?';

	var ratingStuff:Array<Dynamic> = [
		['You Suck!', 0.2], //From 0% to 19%
		['Shit', 0.4], //From 20% to 39%
		['Bad', 0.5], //From 40% to 49%
		['Bruh', 0.6], //From 50% to 59%
		['Meh', 0.69], //From 60% to 68%
		['Nice', 0.7], //69%
		['Good', 0.8], //From 70% to 79%
		['Great', 0.9], //From 80% to 89%
		['Sick!', 1], //From 90% to 99%
		['Perfect!!', 1] //The value on this one isn't used actually, since Perfect is always "1"
	];

	function ratingHit(timeHit:Float, key:Int) {

		timeHit = timeHit < 0 ? timeHit * (-1) : timeHit * 1;

		if (timeHit <= ClientSetings.data.sickHit)
		{
			path = "ui/combo/normal/sick";
			totalNotesHit += 1;
			Sick += 1;
			score += 300;
			splashPlayAnim(false, key);
		}
		else if (timeHit <= ClientSetings.data.goodHit)
		{
			path = "ui/combo/normal/good";
			totalNotesHit += 0.67;
			Good += 1;
			score += 150;
		}
		else if (timeHit <= ClientSetings.data.badHit)
		{
			path = "ui/combo/normal/bad";
			totalNotesHit += 0.34;
			Bad += 1;
			score += 35;
		}
		else
		{
			path = "ui/combo/normal/shit";
			totalNotesHit += 0.05;
			Shit += 1;
			score -=20;
		}

		ratingPercent = Math.min(1, Math.max(0, totalNotesHit / totalPlayed));
		for (i in 0...ratingStuff.length - 1)
			if(ratingPercent >= ratingStuff[i][1])
				ratingName = ratingStuff[i][0];

		for(i in 0 ... Assessment.length)
		{
			if (Good < 1 && Bad < 1 && Shit < 1)
				AssessmentName = Assessment[1];
			else if (Bad < 1 && Shit < 1)
				AssessmentName = Assessment[2];
			else if (Shit < 1)
				AssessmentName = Assessment[3];
			else if (Shit > 0)
				AssessmentName = Assessment[4];
			if (miss > 0 && miss <= 10)
				AssessmentName = Assessment[5];
			if (miss > 10)
				AssessmentName = Assessment[6];
		}

		boopRating();
    }

	function boopRating() {
		if (ClientSetings.data.hidCombo)  return;   
		var rating = new FlxSprite();
		rating.loadGraphic(Img.load(path));
		rating.scale.x = 0.7;
		rating.scale.y = 0.7;
		rating.x = 700;
		rating.y = miss == 0 ? 360 :400;
		rating.acceleration.y = 550 * 1 * 1;
		rating.velocity.y -= FlxG.random.int(140, 175) * 1;
		rating.velocity.x -= FlxG.random.int(0, 10) * 1;
		rating.antialiasing = true;
		rating.updateHitbox();
		if(miss == 0)
		FlxTween.tween(rating, {y : 400}, 0.3, {ease: TweenEaseAll.SelectEase("quadin")});

		

		var comboSpr = new FlxSprite();
		comboSpr.loadGraphic(Img.load("ui/combo/normal/combo"));
		comboSpr.scale.x = 0.45;
		comboSpr.scale.y = 0.45;
		comboSpr.x = 150 + rating.x;
		comboSpr.y = 80 + rating.y;
		comboSpr.acceleration.y = 550 * 1 * 1;
		comboSpr.velocity.y -= FlxG.random.int(140, 175) * 1;
		comboSpr.velocity.x -= FlxG.random.int(0, 10) * 1;
		comboSpr.antialiasing = true;
		comboSpr.updateHitbox();
		if(miss == 0)
		FlxTween.tween(comboSpr, {y : 120 + rating.y}, 0.3, {ease: TweenEaseAll.SelectEase("quadin")});

		ratingHitGroup.add(rating);
		if ((combo >= 10 || combo == 0) && miss == 0)
			ratingHitGroup.add(comboSpr);
			
		


		var daLoop:Int = 0;
		var xThing:Float = 0;

		var separatedScore:String = Std.string(combo).lpad('0', 3);
		for (i in 0...separatedScore.length)
		{
			var numScore:FlxSprite = new FlxSprite();
			numScore.loadGraphic(Img.load("ui/combo/normal/num" + Std.parseInt(separatedScore.charAt(i))));
			// trace("assets/images/num" + Std.parseInt(separatedScore.charAt(i)) + ".png");
			numScore.scale.x = 0.45;
			numScore.scale.y = 0.45;
			numScore.x = (38 * daLoop) - 90 + rating.x;
			numScore.y += 80 + rating.y;
			numScore.acceleration.y = FlxG.random.int(200, 300) * 1 * 1;
			numScore.velocity.y -= FlxG.random.int(140, 160) * 1;
			numScore.velocity.x = FlxG.random.float(-5, 5) * 1;
			numScore.antialiasing = true;

			numScore.updateHitbox();
			if(miss == 0)
			FlxTween.tween(numScore, {y : 120 + rating.y}, 0.3, {ease: TweenEaseAll.SelectEase("quadin")});


			if (combo >= 10 || combo == 0)
				ratingHitGroup.add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2 / 1, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.Bit * 0.002 / 1
			});

			daLoop++;
			if(numScore.x > xThing) xThing = numScore.x;
		}
		FlxTween.tween(rating, {alpha: 0}, 0.2 / 1, {
			onComplete: function(tween:FlxTween)
				{
					rating.destroy();
				},
			startDelay: Conductor.Bit * 0.001 / 1
		});
		FlxTween.tween(comboSpr, {alpha: 0}, 0.2 / 1, {
			onComplete: function(tween:FlxTween)
				{
					comboSpr.destroy();
				},
			startDelay: Conductor.Bit * 0.001 / 1
		});
	}



	public function initHxScript(file:String) {

		if (!(AssetLoader.exists(file))) return;

		var scriptsString:String;
		#if !neko
		try
		{
			HScript = new HsShit();
			scriptsString = HScript.loadScriptFile(file);
			// trace(scriptsString);
			try 
			{
				var scriptPar = HScript.parShit.parseString(scriptsString);
				// trace(scriptPar);
				HScript.loadScript(scriptPar);
			}
			catch (e:Dynamic)
			{
				trace("Ошибка в скрипте : ", e);
				Error.NameError = "Ошибка в скрипте";
				Error.infoError += e;
				Error.onError(e);
			}
		}
		catch (e:Dynamic)
		{
			trace("Ошибка инцализации скрипта : ", e);
			Error.NameError = "Ошибка инцализации скрипта";
			Error.infoError += e;
			Error.onError(e);
		}
		#end
	}

	public function setForScript(variable:String, arg:Dynamic) 
	{
		#if !neko
		try{
		if(HScript != null)
			HScript.intShit.variables.set(variable, arg);
		} catch (e:Dynamic) {
        	trace("Ошибка инцилизации переменной : ", e);
			Error.NameError = "Ошибка инцилизации переменной";
			Error.infoError += e;
            Error.onError(e);
    	}
		#end
	}

	//Эта поебень предназначена для синхранизации переменых скриптов и игры нахуй
	//Для чего я взялся за скрипты, я в душе не ебу
	//Бля ещё надо придумать как спрайты созданные в скрипте и добовлять в игру 
	public function callForScript(nameFunction:String, arg:Dynamic = null) {
    #if !neko
    try {
		if(HScript != null)
			// Проверка существования функции перед вызовом
			if (HScript.intShit.variables.exists(nameFunction)) {
				var func:Dynamic = HScript.intShit.variables.get(nameFunction);
				
				if (arg != null) {
					if (Std.isOfType(arg, Array)) {
						Reflect.callMethod(null, func, arg);
					} else {
						func(arg);
					}
				} else {
					func();
				}
			}
    } catch (e:Dynamic) {
        trace("Script error in " + nameFunction + ": ", e);
		Error.NameError = "Ошибка скрипта в " + nameFunction ;
		Error.infoError += e;
        Error.onError(e);
    }
    #end
}

}
	