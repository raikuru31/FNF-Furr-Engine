package backend.mobile;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.input.touch.FlxTouch;
import backend.Controls;

/**
 * Сенсорное управление для самого геймплея (PlayState).
 *
 * Никаких камер и спрайтов: попадания считаются в координатах окна
 * (FlxG.stage.stageWidth/stageHeight), поэтому кнопки работают независимо от
 * того, сколько камер в состоянии и какая из них куда смотрит.
 *
 * Четыре вертикальные зоны на всю высоту экрана — по одной на стрелку,
 * плюс отдельная зона паузы в правом верхнем углу.
 */
class PlayTouch extends FlxBasic
{
	public static inline var ACTIONS:Array<String> = ['note_left', 'note_down', 'note_up', 'note_right'];

	/** Зона паузы: правый верхний угол, в пикселях окна. */
	public var pauseZoneW:Float = 170;
	public var pauseZoneH:Float = 150;

	/** Когда персонаж умер, любое касание = ACCEPT (возрождение). */
	public var acceptAnywhere:Bool = false;

	/** Режим меню паузы: верх экрана = вверх, низ = вниз, середина = выбор. */
	public var menuMode:Bool = false;

	public function new()
	{
		super();
	}

	inline function stageW():Float
	{
		return FlxG.stage.stageWidth > 0 ? FlxG.stage.stageWidth : FlxG.width;
	}

	inline function stageH():Float
	{
		return FlxG.stage.stageHeight > 0 ? FlxG.stage.stageHeight : FlxG.height;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var w:Float = stageW();
		var h:Float = stageH();
		var colW:Float = w / 4;

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

			var x:Float = touch.screenX;
			var y:Float = touch.screenY;

			if (acceptAnywhere)
			{
				held.set('ACCEPT', true);
				continue;
			}

			if (menuMode)
			{
				if (y < h * 0.3)
					held.set('ui_up', true);
				else if (y > h * 0.7)
					held.set('ui_down', true);
				else
					held.set('ACCEPT', true);
				continue;
			}

			// Угол паузы не должен засчитываться как нота
			if (x >= w - pauseZoneW && y <= pauseZoneH)
			{
				held.set('PAUSE', true);
				continue;
			}

			var index:Int = Std.int(x / colW);
			if (index < 0) index = 0;
			if (index > 3) index = 3;

			held.set(ACTIONS[index], true);
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
	}
}
