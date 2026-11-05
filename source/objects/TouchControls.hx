package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxRect;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import backend.Controls;

/**
 * Одна экранная кнопка.
 * Работает по мультитачу: каждая кнопка «запоминает» свой touchPointID,
 * поэтому можно держать стрелку и одновременно жать вторую.
 */
class TouchButton extends FlxSprite
{
	public var action:String;
	public var isDown:Bool = false;

	var touchId:Int = -1;
	var _bounds:FlxRect = FlxRect.get();

	public function new(x:Float, y:Float, action:String, ?size:Int = 150)
	{
		super(x, y);
		this.action = action;
		makeGraphic(size, size, FlxColor.WHITE);
		alpha = 0.22;
		scrollFactor.set(0, 0);
	}

	function insideTouch(touch:FlxTouch):Bool
	{
		var r:FlxRect = getScreenBounds(_bounds);
		return touch.screenX >= r.x && touch.screenX <= r.right && touch.screenY >= r.y && touch.screenY <= r.bottom;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		var nowDown:Bool = false;
		for (touch in FlxG.touches.list)
		{
			if (touchId < 0 && touch.justPressed && insideTouch(touch))
				touchId = touch.touchPointID;

			if (touchId >= 0 && touch.touchPointID == touchId)
			{
				if (touch.pressed)
					nowDown = true;
				if (touch.justReleased)
					touchId = -1;
			}
		}

		if (nowDown != isDown)
		{
			isDown = nowDown;
			if (isDown)
				Controls.touchDown(action);
			else
				Controls.touchUp(action);
		}
	}
}

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
	}

	function addButton(x:Float, y:Float, action:String, label:String, size:Int):Void
	{
		var b:TouchButton = new TouchButton(x, y, action, size);
		buttons.push(b);
		add(b);

		var t:FlxText = new FlxText(x, y + size * 0.3, size, label, 48);
		t.setFormat(null, 48, FlxColor.WHITE, CENTER);
		t.scrollFactor.set(0, 0);
		t.alpha = 0.75;
		add(t);
	}
}
