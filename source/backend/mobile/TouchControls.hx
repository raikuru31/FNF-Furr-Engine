package backend.mobile;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import backend.Controls;

/**
 * Набор кнопок для игры: четыре стрелки внизу экрана.
 * Подключается в PlayState под #if mobile.
 */
class TouchControls extends FlxSpriteGroup
{
	public var buttons:Array<TouchButton> = [];

	public function new()
	{
		super();

		var size:Int = 150;
		var gap:Int = 24;
		var margin:Int = 32;
		var y:Float = FlxG.height - size - margin;

		addButton(margin, y, 'note_left', '←', size);
		addButton(margin + size + gap, y, 'note_down', '↓', size);
		addButton(FlxG.width - margin - size * 2 - gap, y, 'note_up', '↑', size);
		addButton(FlxG.width - margin - size, y, 'note_right', '→', size);

		// Пауза: маленькая кнопка в правом верхнем углу
		var ps:Int = 84;
		addButton(FlxG.width - margin - ps, margin, 'PAUSE', 'II', ps);
	}

	function addButton(x:Float, y:Float, action:String, label:String, size:Int):Void
	{
		var b:TouchButton = new TouchButton(x, y, action, size);
		buttons.push(b);
		add(b);

		var fontSize:Int = Std.int(size * 0.32);
		var t:FlxText = new FlxText(x, y + size * 0.3, size, label, fontSize);
		t.setFormat(null, fontSize, FlxColor.WHITE, CENTER);
		t.scrollFactor.set(0, 0);
		t.alpha = 0.75;
		add(t);
	}
}
