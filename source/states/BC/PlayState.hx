package states;

import backend.EventJson;
import openfl.media.Sound;
import backend.Song;
import backend.Stagebg;
import charectors.BF;
import flixel.FlxObject;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.sound.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import objects.MyStrumNote;
import objects.Note;
import objects.Section.SwagSection;
import states.TitleState;

class PlayState extends MusicBeatState
{

	public var rSong:RandomSongForDemo = new RandomSongForDemo();
	public static var demo:Bool = false;

	public var strumsBlocked:Array<Bool> = [];

	public var noteKillOffset:Float = 350;

	public static var SONG:SwagSong;
	public static var EVENT:EventFiles;
	public static var ratingStuff:Array<Dynamic> = [
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

	public var generatedMusic:Bool = false;
	public var danceGF:Bool = false;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camPosHart:Bool = false;

	public var boifrend:BF;
	public var Dad:BF;
	public var gf:BF;

	public var singAnim:Array<String> = ['singLEFT', 'singDOWN', 'singUP', 'singRIGHT'];
	public var missAnim:Array<String> = ['singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'];
	public var BG:FlxSprite;

	public var startTimer:FlxTimer;
	public var startingSong:Bool = false;
	public var startedCountdown:Bool = false;

	public var music:FlxSound;
	public var inst:FlxSound;
	public var voicesOp:FlxSound;
	public var voicesPl:FlxSound;

	
	public static var curSong:String = 'fresh';

	public var previousFrameTime:Int = 0;
	
	public var textcurBeat:FlxText;
	public var textCurSong:FlxText;

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var strumLineNotes:FlxTypedGroup<MyStrumNote> = new FlxTypedGroup<MyStrumNote>();
	private var playerStrums:FlxTypedGroup<MyStrumNote> = new FlxTypedGroup<MyStrumNote>();
	private var dadStrums:FlxTypedGroup<MyStrumNote> = new FlxTypedGroup<MyStrumNote>();

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var camZooming:Bool = false;

	public var defaultCamZoom:Float = 1.05;
	public var camZoomingDecay:Float = 1;

	private var camFollow:FlxObject;

	public var boyfriendCameraOffset:Array<Float> = null;
	public var opponentCameraOffset:Array<Float> = null;
	public var girlfriendCameraOffset:Array<Float> = null;

	public static var debag:Bool = false;

	public var scoreTxt: FlxText;
	public var score:Int = 0;
	public var combo:Int = 0;
	public var miss:Int = 0;
	var scoreTxtTween:FlxTween;

	var Nowplaying:FlxText;
	var bgBlac:FlxSprite;
	var bgBlue:FlxSprite;

	var timeClik:FlxText;

	var randomScore:Int;//Хотите собрать максимум очков?
	// молитесь у бога рандома  :)


	private var keysArray:Array<String>;

	public var timerTxt:FlxText;

	public var debugTxt:FlxText;

	public var stage:Stagebg;

	var eventData:Array<Events>;
	var eventOn:Bool = false;
	var curStepTxt:FlxText;
	override public function create():Void
	{	
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

		//загружаем файл уровня 
		// if (SONG == null)
		// 	SONG = Song.loadFromJson(curSong,curSong);
		// else
			SONG = Song.loadFromJson(curSong,curSong);
			EVENT = EventJson.loadJson(curSong);
		// trace(EVENT.event);

		if (SONG.player3 == null)
				SONG.player3 = 'gf';
		
		stage = new Stagebg(SONG.stage);
		trace (SONG.bpm);

		startingSong = true;
		Conductor.songPosition = -5000;

		//Камеры игры
		camGame = new FlxCamera();
		camGame.bgColor = FlxColor.BLACK;
		FlxG.cameras.reset(camGame);
		camGame.zoom = 0.5;

		camHUD = new FlxCamera();
        camHUD.bgColor = FlxColor.TRANSPARENT; 
        camHUD.width = FlxG.width;
        camHUD.height = FlxG.height;
        camHUD.x = 0;
        camHUD.y = 0;
        FlxG.cameras.add(camHUD);

		scoreTxt = new FlxText(0, FlxG.height - 60, FlxG.width, "Yes", 20);
		scoreTxt.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();
		scoreTxt.borderSize = 1.25;
		add(scoreTxt);
		scoreTxt.cameras = [camHUD];

		debugTxt = new FlxText(FlxG.width/2 - 50, 70, 100, 'Debug');
		debugTxt.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugTxt.scrollFactor.set();
		debugTxt.borderSize = 1.25;
		debugTxt.cameras = [camHUD];

		add(debugTxt);

		curStepTxt = new FlxText(60, 300, 100, 'Step');
		curStepTxt.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		curStepTxt.scrollFactor.set();
		curStepTxt.borderSize = 1.25;
		curStepTxt.cameras = [camHUD];

		add(curStepTxt);

		timeClik = new FlxText(FlxG.width/2 + 300, 300, 100, '');
		timeClik.setFormat('assets/fonts/vcr.ttf', 20, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeClik.scrollFactor.set();
		timeClik.cameras = [camHUD];

		add(timeClik);

		//Сбор инормации с .json файла уровня 
		generateSong(curSong);

		loadStage();

		// add(stage.BgStage);
		
		stage.spriteGroup.cameras = [camGame];
		add(stage.spriteGroup);

		if(girlfriendCameraOffset == null)
			girlfriendCameraOffset = [0, 0];

		if(opponentCameraOffset == null)
			opponentCameraOffset = [0, 0];

		if(boyfriendCameraOffset == null)
			boyfriendCameraOffset = [0, 0];

		var camPos:FlxPoint = FlxPoint.get(girlfriendCameraOffset[0], girlfriendCameraOffset[1]);
		if(gf != null)
		{
			camPos.x += gf.getGraphicMidpoint().x + gf.xPosCam + stage.gf_cam_pos[0];
			camPos.y += gf.getGraphicMidpoint().y + gf.yPosCam + stage.gf_cam_pos[1];
		}

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);
		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);

		// Текст который стоит удалить
		var text = new FlxText(0, 20, 100, "Blat ybeite mena, ia hochy cdoxnyt viebite mena nahyi gde nado stjlko vsaoi hyiti sdelat hto ahyet i ne vstat Version Engine 6.0 Hto nax axyeno idy");
		add(text);
		text.cameras = [camHUD];

		

		add(gf);
		gf.cameras = [camGame];

		add(boifrend);
		boifrend.cameras = [camGame];

		add(Dad);
		Dad.cameras = [camGame];

		if(Dad.notFound)
			{add(Dad.notFoundPathJson); Dad.notFoundPathJson.cameras = [camGame];}
		if(boifrend.notFound)
			{add(boifrend.notFoundPathJson); boifrend.notFoundPathJson.cameras = [camGame];}
		if(gf.notFound)
			{add(gf.notFoundPathJson); gf.notFoundPathJson.cameras = [camGame];}

		notes.cameras = [camHUD];

		
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		strumLineNotes.cameras = [camHUD];
		add(strumLineNotes);

		add(notes);

		// trace(Dad.xPosCam);
		// trace(Dad.yPosCam);
		// trace(boifrend.xPosCam);
		// trace(boifrend.yPosCam);

		startCountdown();

		nowPlay();

		timer();

		// trace(holnah.randSong);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

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
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
				startSong();

			}
		}
		else
		{
			Conductor.songPosition = inst.time;
			// trace('beat ' + totalBeats);
			// trace('step ' + totalSteps);
		}
		
		//спавн нот в правельной последовательности
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
		
		if (generatedMusic)
			{

				ChekKey();
				if (!demo)
					debugTxt.text = debag ? 'Debug Bot' : 'Debug' ;
				else
					debugTxt.text = 'Demo';
				
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.y > FlxG.height)
					{
						daNote.active = false;
						daNote.visible = false;
					}
					else
					{
						daNote.visible = true;
						daNote.active = true;
					}
					//Бот нажимает клавиши опонента
					if (!daNote.mustPress && daNote.wasGoodHit)
						opponentNoteHit(daNote);

					//Бот нажимает со с стороны игрока
					if (debag && daNote.canBeHit && (daNote.isSustainNote || daNote.strumTime <= Conductor.songPosition))
						goodNoteHit(daNote);		
					
					//Скорость прокрутки стрелак
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * PlayState.SONG.speed));


					if (!debag && daNote.tooLate && !daNote.canBeHit)
					{
						invalidateNote(daNote);
						noteMiss(daNote);
					}

					if (Conductor.songPosition - daNote.strumTime > noteKillOffset)
					{
						daNote.active = daNote.visible = false;
						invalidateNote(daNote);
						// noteMiss();
					}
						
				});
			}

		timerTxt.text = Math.floor(Conductor.songPosition / 60000) + ':' + Math.floor((Conductor.songPosition % 60000)/ 1000) +'/'+  Math.floor(inst.length / 60000) + ':' + Math.floor((inst.length % 60000)/ 1000);
		
		curStepTxt.text = 'Step ' + curStep;
		if (FlxG.keys.justPressed.B){
			if (debag)
				debag = false;
			else
				debag = true;
		}

		if (controls.justPressed('PAUSE')){SongEnd();}
		if(controls.justPressed('RESET'))
		{
			demo = demo ? false : true;
			debag = demo ? true : false;
		}
		
		
		updateScoreText();
		movetCam();
		debugModText();
	}

	function startCountdown():Void
	{
		generateStaticArrows(0,'NOTE_assets_Lycur');
		generateStaticArrows(1);

		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.Bit * 5;

		var swagCounter:Int = 0;

		startTimer = new FlxTimer().start(Conductor.Bit / 1000, function(tmr:FlxTimer)
		{
			Dad.animation.stop();
			boifrend.animation.stop();
			Dad.playAnim('idle');
			boifrend.playAnim('idle');
			if (!danceGF)
			{gf.playAnim('danceLeft'); danceGF = true;}
			else
			{gf.playAnim('danceRight'); danceGF = false;}

			startedCountdown = true;
			Conductor.songPosition = 0;
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
		previousFrameTime = FlxG.game.ticks;
		// lastReportedPlayheadPosition = 0;
		trace('Song Start!!');
		// new FlxTimer().start((Conductor.StepBit / 1000), onStep, 0);
		startingSong = false;
		inst.play();
		inst.onComplete = SongEnd;
		if (voicesOp.length > 0)
			voicesOp.play();
		if (voicesPl.length > 0)
			voicesPl.play();

	}
	
	override function stepHit() 
	{
		super.stepHit();
		if (eventOn)
			chekEvent(eventData);
	}
	
	override function beatHit() 
	{
		super.beatHit();

		if (generatedMusic)
			{
				notes.sort(FlxSort.byY, FlxSort.DESCENDING);
			}

		if (boifrend.animation.curAnim.finished && curBeat % 2 == 0)
		{
			boifrend.animation.stop();
			boifrend.playAnim('idle');
		}

		if (Dad.animation.curAnim.finished && curBeat % 2 == 0)
		{
			Dad.animation.stop();
			Dad.playAnim('idle');
		}

		if (gf.animation.curAnim.finished || gf.animation.name == 'danceLeft' || gf.animation.name == 'danceRight')	
		{
			if (!danceGF)
			{gf.animation.stop();gf.playAnim('danceLeft'); danceGF = true;}
			else
			{gf.animation.stop();gf.playAnim('danceRight'); danceGF = false;}
		}

		if (curBeat % 4 == 0)
		{
			if (camZooming && FlxG.camera.zoom < 1.35 )
			{
				FlxG.camera.zoom += 0.015 * 1;
				camHUD.zoom += 0.03 * 1;
			}
		}
	}

	function SongEnd() 
	{
		
		if (!demo)
		{
			FlxG.sound.playMusic(AssetPaths.freakyMenu__ogg, 1);
			MusicBeatState.switchState(new TitleState());
		}
		else
		{
			curSong = rSong.randSong;
			MusicBeatState.switchState(new PlayState());
		}


	}


	private function generateStaticArrows(player:Int, textur:String = 'NOTE_assets'):Void
	{
		for (i in 0...4)
		{
			var targetAlpha:Float = 1;
		
			var babyArrow:MyStrumNote = new MyStrumNote(0, 25, i, player, textur);

			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, { alpha: targetAlpha}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			babyArrow.alpha = targetAlpha;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
			{
				dadStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
			babyArrow.playerPosition();
		}
	}

	private function generateSong(dataPath:String):Void
	{
			var songData = SONG;
			if (EVENT.event.length > 0)
				{eventData = EVENT.event; eventOn = true;}
			else 
				eventOn = false;
			// trace(eventData[0]);
			trace( 'Bf charector ' + songData.player1);
			trace( 'Dad charector ' + songData.player2);
			trace( 'Gf charector ' + songData.player3);
			trace( 'bpm ' + songData.bpm);
			Conductor.changeBPM(songData.bpm);

			// curSong = songData.song;
			trace(songData.song);
			// if (SONG.needsVoices)
			// 	vocals = new FlxSound().loadEmbedded("assets/music/" + curSong + "_Voices" + TitleState.soundExt);
			// else
			// 	vocals = new FlxSound();
	
			// FlxG.sound.list.add(vocals);

			inst = FlxG.sound.load(Sound.fromFile("assets/songs/"+ curSong +"/Inst.ogg"), 1, false);


			var voicesOpPath:String = "assets/songs/" + curSong + "/Voices-Opponent.ogg";
			var voicesPlPath:String = "assets/songs/" + curSong + "/Voices-Player.ogg";
			var voicesPath:String = "assets/songs/" + curSong + "/Voices.ogg";

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
					voicesPl.loadEmbedded(Sound.fromFile("assets/songs/" + curSong + "/Voices.ogg"));

			FlxG.sound.list.add(voicesOp);
			FlxG.sound.list.add(voicesPl);




			
			if (SONG.song != 'tutorial')
				camZooming = true;

			Dad = new BF(stage.dad_pos[0], stage.dad_pos[1], songData.player2, false, true);
			
			gf = new BF(stage.gf_pos[0], stage.gf_pos[1], songData.player3);
	
			boifrend = new BF(stage.bf_pos[0], stage.bf_pos[1], songData.player1);

			defaultCamZoom = stage.camZoom;
			if (boifrend.flipX)
				boifrend.flipX = false;
			else
				boifrend.flipX = true;

			if (SONG.player2 == 'camellia')
				{Dad.flipX = false;}


			notes = new FlxTypedGroup<Note>();
			notes.cameras = [camHUD];
			// add(notes);
			unspawnNotes = [];
			var noteData:Array<SwagSection>;
	
			// NEW SHIT
			noteData = songData.notes;
	
			var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
			for (section in noteData)
			{
	
				for (songNotes in section.sectionNotes)
				{
					var daStrumTime:Float = songNotes[0];
					var daNoteData:Int = Std.int(songNotes[1] % 4);
	
					var gottaHitNote:Bool = section.mustHitSection;

					
	
					if (songNotes[1] > 3)
					{
						gottaHitNote = !section.mustHitSection;
					}
	
					var oldNote:Note;
					if (unspawnNotes.length > 0)
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
					else
						oldNote = null;
	
					var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
					swagNote.sustainLength = songNotes[2];
					swagNote.scrollFactor.set(0, 0);
	
					var susLength:Float = swagNote.sustainLength;
	
					susLength = susLength / Conductor.StepBit;
					unspawnNotes.push(swagNote);
					for (susNote in 0...Math.floor(susLength))
					{
						oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
	
						var sustainNote:Note = new Note(daStrumTime + (Conductor.StepBit * susNote) + Conductor.StepBit, daNoteData, oldNote, true);
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
				daBeats += 1;
			}
	
			trace(unspawnNotes.length);
			// playerCounter += 1;
	
			unspawnNotes.sort(sortByShit);
	
			generatedMusic = true;
			// trace('LOADED FROM JSON: ' + songData.notes);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);

	function goodNoteHit(note:Note):Void
	{

		if (note.wasGoodHit) return;

		// note.wasGoodHit = true;

		randomScore = Std.random(100);
			if (!note.wasGoodHit)
			{
				voicesPl.volume = 1;

				if (!note.isSustainNote)
				{
					combo++;
					timeClik.text = "" + (Math.round((Conductor.songPosition - note.strumTime )*100) / 100) ;
				}
				if (combo <= 250)
					score += 150;
				else if (combo <= 350)
					score += 200;
				else if (combo <= 400)
					score += 250 + randomScore;
				else if (combo <= 1000)
					score += 300 + randomScore;
				else if (combo >= 1000)
					score += 500 + randomScore;
				
				boopScoreText();
				// trace('combo' + combo+' score '+score);
				boifrend.playAnim(singAnim[note.noteData], true);

				if(!debag)
				{
					var spr = playerStrums.members[note.noteData];
					if(spr != null) spr.playAnim('confirm', true);
				}
				else strumPlayAnim(false, Std.int(Math.abs(note.noteData)), Conductor.StepBit * 1.25 / 1000 / 1);
	
				invalidateNote(note);
			}
	}

	function opponentNoteHit(note:Note) {

		if (voicesOp.length <= 0)
			voicesPl.volume = 1;
		Dad.playAnim(singAnim[note.noteData], true);

		strumPlayAnim(true, Std.int(Math.abs(note.noteData)), Conductor.StepBit * 1.25 / 1000 / 1);

		invalidateNote(note);
	}

	public function invalidateNote(note:Note):Void {
		note.kill();
		notes.remove(note, true);
		note.destroy();
	}
	
	function movetCam() 
	{
		var sec:Int = Std.int(curStep / 16);


		if (generatedMusic && PlayState.SONG.notes[sec] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[sec].mustHitSection);
			}
	
			if (camFollow.x != Dad.getMidpoint().x + 150 && !PlayState.SONG.notes[sec].mustHitSection)
			{
				camFollow.setPosition(Dad.getMidpoint().x - Dad.xPosCam + stage.dad_cam_pos[0], Dad.getMidpoint().y + Dad.yPosCam + stage.dad_cam_pos[1]);

				if (SONG.song.toLowerCase() == 'tutorial')
				{
					tweenCamIn();
				}
			}
	
			if (PlayState.SONG.notes[sec].mustHitSection && camFollow.x != boifrend.getMidpoint().x - 100)
			{
				camFollow.setPosition(boifrend.getMidpoint().x - boifrend.xPosCam + stage.bf_cam_pos[0], boifrend.getMidpoint().y + boifrend.yPosCam + stage.bf_cam_pos[1]);
	
				if (SONG.song.toLowerCase() == 'tutorial')
				{
					FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.StepBit * 4 / 1000), {ease: FlxEase.elasticInOut});
				}
			}
		}		
	}

	function tweenCamIn():Void
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.StepBit * 4 / 1000), {ease: FlxEase.elasticInOut});

	function loadStage():Void
	{
		// if (stage == 'camellia')
		// {
		// 	var city = new FlxSprite(-150, -100,'assets/images/stages/camellia/BG_CITY.png');
		// 	city.scrollFactor.set(0.5,0.5);
		// 	city.scale.y = 1.55;
		// 	city.scale.x = 1.55;
		// 	add(city);
		// 	city.cameras = [camGame];

		// 	var wall = new FlxSprite(-150, -100,'assets/images/stages/camellia/BG_WALL.png');
		// 	wall.scrollFactor.set(1,1);
		// 	wall.scale.y = 1.55*2;
		// 	wall.scale.x = 1.55*2;
		// 	add(wall);
		// 	wall.cameras = [camGame];

		// 	var floor = new FlxSprite(-150, -100,'assets/images/stages/camellia/FG_Floor.png');
		// 	wall.scrollFactor.set(0.9,0.9);
		// 	floor.scale.y = 1.55*2;
		// 	floor.scale.x = 1.55*2;
		// 	add(floor);
		// 	floor.cameras = [camGame];

		// 	boifrend.xPosCam = -400;
		// }
		// else
		// {
		// 	BG = new FlxSprite(0,0, 'assets/images/menuBG.png');
		// 	add(BG);
		// 	BG.cameras = [camGame];
		// }
	}

	function updateScoreText() 
		scoreTxt.text = 'Score : ' + score + ' | Combo : ' + combo + ' | miss : '+ miss;
	
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

		add(bgBlue);
		add(bgBlac);
		add(textCurSong);
		add(Nowplaying);
		nowPlayTween();
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
		timerTxt = new FlxText(0, 0, FlxG.width, '00:00');
		timerTxt.setFormat('assets/fonts/vcr.ttf', 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timerTxt.scrollFactor.set();
		timerTxt.borderSize = 1.25;
		timerTxt.cameras = [camHUD];

		add(timerTxt);
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

	public function noteMiss(daNote:Note) {
		voicesPl.volume = 0;
		pressMiss(daNote.noteData, daNote.isSustainNote);
	}
	public function pressMiss(key:Int, isHoldNota:Bool) {
		if (!isHoldNota)
			FlxG.sound.play("assets/sounds/missnote"+ (Std.random(2)+1) +".ogg", 0.4);
		boifrend.playAnim(missAnim[key], true);
		miss++;
		score-= 12;
		combo = 0;
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
			iEvent = iEvent < evData.length - 1 ? iEvent + 1 : evData.length - 1;
		}
	}
	private function charactersChange(v1:String, v2:String) 
	{
		switch (v1)
		{
			case 'bf':
				boifrend.personagaChange(v2);
				if (boifrend.flipX)
					boifrend.flipX = false;
				else
					boifrend.flipX = true;
			case 'dad':
				Dad.personagaChange(v2);
			case 'gf':
				gf.personagaChange(v2);		
		}	
	}
	private function playAnimate(v1:String, v2:String)
	{
		switch (v1)
		{
			case 'bf':
				boifrend.playAnim(v2);
			case 'dad':
				Dad.playAnim(v2);
				trace('play Animate');
			case 'gf':
				gf.playAnim(v2);		
		}		
	}


	public function ChekKey():Void
	{
		var holdArray:Array<Bool> = [];
		var pressArray:Array<Bool> = [];
		var releaseArray:Array<Bool> = [];

		for (key in keysArray)
		{

			pressArray.push(controls.justPressed(key));
			holdArray.push(controls.holdPressed(key));
			releaseArray.push(controls.justReleased(key));
		}

		//нажата ли клавиша
		if (pressArray.contains(true))
			for (i in 0...pressArray.length)
				if(pressArray[i])
					keyPresed(i);

		if (generatedMusic)
			{
				if (notes.length > 0) {
					for (n in notes) { // I can't do a filter here, that's kinda awesome
						var canHit:Bool = (n != null && n.canBeHit
							&& n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit );
	
						if (canHit && n.isSustainNote) {
							var released:Bool = !holdArray[n.noteData];
	
							if (!released)
								goodNoteHit(n);
						}
					}
				}
			}
		
		// trace(releaseArray[1]);
		//Отпущена ли клавиша
		if( releaseArray.contains(true))
			for (i in 0...releaseArray.length)
				if(releaseArray[i])
					keyReleased(i);
	}

	public function keyPresed(key:Int) {
		if(debag) return;

		var lastTime:Float = Conductor.songPosition;

		// obtain notes that the player can hit
		var noteHitBlat: Array<Note> = notes.members.filter(function(n:Note):Bool {
			var canHit:Bool = n != null && !strumsBlocked[n.noteData] && n.canBeHit && n.mustPress && !n.tooLate && !n.wasGoodHit && !n.blockHit;
			return canHit && n.noteData == key && !n.isSustainNote;
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
			goodNoteHit(iaEbalEtiNots);
		}
		else
			if (!ClientSetings.data.ghostTap)
				pressMiss(key,false);

		
		var spr:MyStrumNote = playerStrums.members[key];
		if(strumsBlocked[key] != true && spr != null && spr.animation.curAnim.name != 'confirm')
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

		
		var spr:MyStrumNote = playerStrums.members[key];
		if(spr != null)
		{
			spr.playAnim('static');
			spr.resetAnim = 0;
		}
	}

}
	