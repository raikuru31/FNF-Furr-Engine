package backend.mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import backend.Controls;

/**
 * Видимые подсказки-стрелки внизу экрана.
 *
 * Сами зоны нажатия невидимые и лежат в координатах окна (см. PlayTouch),
 * а этот слой нужен игроку, чтобы понимать, куда жать: стрелки подсвечиваются,
 * когда зона нажата, и мигают при попадании в ноту.
 */
class TouchArrows extends FlxSpriteGroup
{
	public static var ACTIONS:Array<String> = ['note_left', 'note_down', 'note_up', 'note_right'];

	var arrows:Array<FlxText> = [];
	var flash:Array<Float> = [0.0, 0.0, 0.0, 0.0];
	var pauseIcon:FlxText = null;

	public function new()
	{
		super();

		var labels:Array<String> = ['←', '↓', '↑', '→'];
		var size:Int = 96;
		var y:Float = FlxG.height - size - 40;
		var step:Float = (FlxG.width - 120) / 4;

		for (i in 0...4)
		{
			var t:FlxText = new FlxText(60 + step * i, y, step, labels[i], 74);
			t.setFormat(null, 74, FlxColor.WHITE, CENTER);
			t.alpha = 0.35;
			t.scrollFactor.set(0, 0);
			add(t);
			arrows.push(t);
			flash[i] = 0.0;
		}

		// Видимая иконка паузы в правом верхнем углу — там же, где зона нажатия
		pauseIcon = new FlxText(FlxG.width - 150, 24, 120, 'II', 56);
		pauseIcon.setFormat(null, 56, FlxColor.WHITE, CENTER);
		pauseIcon.alpha = 0.45;
		pauseIcon.scrollFactor.set(0, 0);
		add(pauseIcon);
	}

	/** Подсветить стрелку при попадании в ноту. */
	public function hit(action:String):Void
	{
		var idx:Int = ACTIONS.indexOf(action);
		if (idx >= 0)
			flash[idx] = 0.25;
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		for (i in 0...4)
		{
			var action:String = ACTIONS[i];
			var down:Bool = Controls.touchIsDown(action);
			var f:Float = flash[i];
			if (f > 0)
			{
				f -= elapsed;
				if (f < 0) f = 0;
				flash[i] = f;
			}

			var active:Bool = down || f > 0;
			arrows[i].alpha = active ? 1.0 : 0.35;
		}

		if (pauseIcon != null)
			pauseIcon.alpha = Controls.touchIsDown('PAUSE') ? 1.0 : 0.45;
	}
}
