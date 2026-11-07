package;
import openfl.events.Event;
import lime.app.Application;
import states.LogoState;
#if !neko
#if windows
import debug.FPSCounter;
#end
#end
import flixel.FlxGame;
import openfl.display.Sprite;

import openfl.Lib;
import flash.events.UncaughtErrorEvent;

class Main extends Sprite
{	
	#if !neko
	#if windows
	public static var fpsVar:FPSCounter;
	#end
	#end
	var gameSettings = {
		width: 1280, // WINDOW width
		height: 720, // WINDOW height
		zoom: -1.0, // game state bounds
		// initialState: TitleState, // initial game state

		#if !neko
		initialState:LogoState, // initial game state
		#end

		#if neko
		initialState:PlayState, // initial game state
		#end
		
		framerate: 60, // default framerate
		skipSplash: true, // if the default flixel splash screen should be skipped
		startFullscreen: false // if the game should start at fullscreen mode
	};


	public static function main():Void
	{
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		if(stage != null)
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
	}


	function init(?event:Event):Void
  	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
			removeEventListener(Event.ADDED_TO_STAGE, init);

		setupGame();
  	}

	function setupGame():Void
	{
		// Ловим ошибки ДО создания игры: иначе падение при инициализации
		// первого состояния останется без лога
		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, Error.onError);

		var game:FlxGame = new FlxGame(gameSettings.width, gameSettings.height, gameSettings.initialState,  gameSettings.framerate, gameSettings.framerate, gameSettings.skipSplash, gameSettings.startFullscreen);
		addChild(game);

		#if !neko
			#if windows
				fpsVar = new FPSCounter(10, 3, 0xFFFFFF);
				addChild(fpsVar);
			#end
		#end

		FlxG.fixedTimestep = false;
		FlxG.game.focusLostFramerate = 60;
		
		Controls.instance = new Controls();

		// Экранное управление для меню (мобильная сборка)
		backend.mobile.MobileUI.init();

		// FlxG.game.focusLostFramerate = 60;
	}
}

