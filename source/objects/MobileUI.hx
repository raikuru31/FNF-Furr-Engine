package objects;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Кнопки для меню на мобильном: четыре направления + «подтвердить» и «назад».
 * В игре (PlayState) они не нужны — там свои стрелки.
 */
class MenuTouchControls extends FlxSpriteGroup
{
	public function new()
	{
		super();

		var size:Int = 110;
		var gap:Int = 12;
		var margin:Int = 24;
		var y:Float = FlxG.height - margin - size;

		// Крестовина слева
		addButton(margin, y, 'ui_left', '←', size);
		addButton(margin + size + gap, y, 'ui_down', '↓', size);
		addButton(margin + (size + gap) * 2, y, 'ui_up', '↑', size);
		addButton(margin + (size + gap) * 3, y, 'ui_right', '→', size);

		// Подтвердить и назад справа
		var rx:Float = FlxG.width - margin - size * 2 - gap;
		addButton(rx, y, 'ACCEPT', '✓', size);
		addButton(rx + size + gap, y, 'BACK', '✕', size);
	}

	function addButton(x:Float, y:Float, action:String, label:String, size:Int):Void
	{
		add(new TouchButton(x, y, action, size));

		var fontSize:Int = Std.int(size * 0.38);
		var t:FlxText = new FlxText(x, y + size * 0.26, size, label, fontSize);
		t.setFormat(null, fontSize, FlxColor.WHITE, CENTER);
		t.scrollFactor.set(0, 0);
		t.alpha = 0.8;
		add(t);
	}
}

/**
 * Подключает экранное меню к каждому состоянию, кроме игрового.
 * Вызывать один раз после создания FlxGame.
 */
class MobileUI
{
	static var inited:Bool = false;

	public static function init():Void
	{
		#if mobile
		if (inited) return;
		inited = true;
		FlxG.signals.postStateSwitch.add(onStateSwitch);
		#end
	}

	static function onStateSwitch():Void
	{
		#if mobile
		var state = FlxG.state;
		if (state == null) return;

		// В игре свои кнопки со стрелками
		if (Std.isOfType(state, states.PlayState)) return;

		state.add(new MenuTouchControls());
		#end
	}
}
