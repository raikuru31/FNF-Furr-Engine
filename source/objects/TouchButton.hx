package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.input.touch.FlxTouch;
import flixel.math.FlxRect;
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
