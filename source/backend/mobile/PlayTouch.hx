package backend.mobile;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.touch.FlxTouch;
import backend.Controls;

/**
 * Сенсорное управление геймплеем.
 *
 * Зоны считаются в координатах ИГРОВОГО поля (не окна): четыре колонки
 * шириной ZONE_W, выровненные по центру, на всю высоту, плюс угол паузы.
 * Касание переводится из координат окна через ScreenMap, поэтому нажатия
 * по чёрным полям больше не засчитываются.
 */
class PlayTouch extends FlxBasic
{
	public static var ACTIONS:Array<String> = ['note_left', 'note_down', 'note_up', 'note_right'];

	public static inline var ZONE_W:Float = 150;
	public static inline var ZONE_GAP:Float = 16;

	public static inline var PAUSE_W:Float = 170;
	public static inline var PAUSE_H:Float = 150;

	/** Когда персонаж умер, любое касание = ACCEPT (возрождение). */
	public var acceptAnywhere:Bool = false;

	/** Режим меню паузы: верх = вверх, низ = вниз, середина = выбор. */
	public var menuMode:Bool = false;

	public function new()
	{
		super();
	}

	/** X-координата зоны ноты в координатах игры. */
	public static function zoneX(index:Int):Float
	{
		var total:Float = 4 * ZONE_W + 3 * ZONE_GAP;
		var start:Float = (FlxG.width - total) / 2;
		return start + index * (ZONE_W + ZONE_GAP);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var held:Map<String, Bool> = [];
		for (a in ACTIONS)
			held.set(a, false);
		held.set('PAUSE', false);
		held.set('ACCEPT', false);
		held.set('ui_up', false);
		held.set('ui_down', false);

		for (touch in FlxG.touches.list)
		{
			if (!touch.pressed)
				continue;

			var x:Float = ScreenMap.toGameX(touch.screenX);
			var y:Float = ScreenMap.toGameY(touch.screenY);

			if (acceptAnywhere)
			{
				held.set('ACCEPT', true);
				continue;
			}

			if (menuMode)
			{
				if (y < FlxG.height * 0.3)
					held.set('ui_up', true);
				else if (y > FlxG.height * 0.7)
					held.set('ui_down', true);
				else
					held.set('ACCEPT', true);
				continue;
			}

			if (x >= FlxG.width - PAUSE_W && y <= PAUSE_H)
			{
				held.set('PAUSE', true);
				continue;
			}

			for (i in 0...4)
			{
				var zx:Float = zoneX(i);
				if (x >= zx && x <= zx + ZONE_W)
				{
					held.set(ACTIONS[i], true);
					break;
				}
			}
		}

		for (a in ACTIONS)
			setAction(a, held.get(a) == true);
		setAction('PAUSE', held.get('PAUSE') == true);
		setAction('ACCEPT', held.get('ACCEPT') == true);
		setAction('ui_up', held.get('ui_up') == true);
		setAction('ui_down', held.get('ui_down') == true);
	}

	inline function setAction(action:String, on:Bool):Void
	{
		if (on)
			Controls.touchDown(action);
		else
			Controls.touchUp(action);
	}

	/** Сброс всех зон, чтобы после смерти/паузы ничего не «залипало». */
	public function releaseAll():Void
	{
		for (a in ACTIONS)
			Controls.touchUp(a);
		Controls.touchUp('PAUSE');
		Controls.touchUp('ACCEPT');
		Controls.touchUp('ui_up');
		Controls.touchUp('ui_down');
	}
}
