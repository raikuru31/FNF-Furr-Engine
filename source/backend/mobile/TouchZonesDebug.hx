package backend.mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;

/**
 * Отладочная визуализация зон касания.
 *
 * Зоны считаются в координатах окна (как в PlayTouch), а рисуются в координатах
 * игры: пересчитываем через масштаб и поля, которые добавляет letterbox.
 * Нужно, чтобы глазами видеть, куда реально попадает палец.
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

		var sw:Float = FlxG.stage.stageWidth;
		var sh:Float = FlxG.stage.stageHeight;
		if (sw <= 0 || sh <= 0)
			return;
		if (sw == 0 || sh == 0)
			return;

		var gw:Float = FlxG.width;
		var gh:Float = FlxG.height;
		var scale:Float = Math.min(sw / gw, sh / gh);
		if (scale <= 0)
			return;

		var offsetX:Float = (sw - gw * scale) / 2;
		var offsetY:Float = (sh - gh * scale) / 2;

		var colW:Float = sw / 4;

		for (i in 0...4)
		{
			var sx:Float = colW * i;
			var sy:Float = 0.0;
			var sWidth:Float = colW;
			var sHeight:Float = sh;
			apply(i, sx, sy, sWidth, sHeight, scale, offsetX, offsetY);
		}

		// Зона паузы
		var pw:Float = 170;
		var ph:Float = 150;
		apply(4, sw - pw, 0, pw, ph, scale, offsetX, offsetY);
	}

	function apply(index:Int, sx:Float, sy:Float, sWidth:Float, sHeight:Float, scale:Float, offsetX:Float, offsetY:Float):Void
	{
		var gx:Float = (sx - offsetX) / scale;
		var gy:Float = (sy - offsetY) / scale;
		var gwid:Float = sWidth / scale;
		var ghei:Float = sHeight / scale;

		var r:FlxSprite = rects[index];
		r.setPosition(gx, gy);
		r.setGraphicSize(Std.int(gwid), Std.int(ghei));
		r.updateHitbox();

		labels[index].setPosition(gx + 10, gy + 10);
	}
}
