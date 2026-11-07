package backend.mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;

/**
 * Отладочная визуализация зон касания.
 * Рисуется в координатах игры — ровно там же, где PlayTouch считает попадания.
 */
class TouchZonesDebug extends FlxSpriteGroup
{
	var rects:Array<FlxSprite> = [];
	var labels:Array<FlxText> = [];
	var actions:Array<String> = ['note_left', 'note_down', 'note_up', 'note_right', 'PAUSE'];
	var colors:Array<Int> = [0xFFFF3B30, 0xFF34C759, 0xFF0A84FF, 0xFFFFD60A, 0xFFFF00FF];

	public function new()
	{
		super();

		for (i in 0...actions.length)
		{
			var r:FlxSprite = new FlxSprite();
			r.makeGraphic(8, 8, colors[i]);
			r.alpha = 0.22;
			r.scrollFactor.set(0, 0);
			add(r);
			rects.push(r);

			var t:FlxText = new FlxText(0, 0, 300, actions[i], 26);
			t.setFormat(null, 26, colors[i], LEFT);
			t.alpha = 0.95;
			t.scrollFactor.set(0, 0);
			add(t);
			labels.push(t);
		}
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (i in 0...4)
			place(i, PlayTouch.zoneX(i), 0, PlayTouch.ZONE_W, FlxG.height);

		place(4, FlxG.width - PlayTouch.PAUSE_W, 0, PlayTouch.PAUSE_W, PlayTouch.PAUSE_H);
	}

	function place(index:Int, x:Float, y:Float, w:Float, h:Float):Void
	{
		var r:FlxSprite = rects[index];
		r.setPosition(x, y);
		r.setGraphicSize(Std.int(w), Std.int(h));
		r.updateHitbox();

		labels[index].setPosition(x + 8, y + 8);
	}
}
