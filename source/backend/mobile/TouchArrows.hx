package backend.mobile;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import backend.Controls;

/**
 * Видимые стрелки под зонами касания.
 *
 * Берём настоящие спрайты из NOTE_assets: серая стрелка в покое, цветная —
 * когда зона нажата или было попадание. Стоят ровно под своими хитбоксами.
 */
class TouchArrows extends FlxSpriteGroup
{
	public static var ACTIONS:Array<String> = ['note_left', 'note_down', 'note_up', 'note_right'];

	static var IDLE_FRAMES:Array<String> = ['arrowLEFT0000', 'arrowDOWN0000', 'arrowUP0000', 'arrowRIGHT0000'];
	static var PRESS_FRAMES:Array<String> = ['left press0000', 'down press0000', 'up press0000', 'right press0000'];

	var arrows:Array<FlxSprite> = [];
	var flash:Array<Float> = [0.0, 0.0, 0.0, 0.0];
	var pauseIcon:FlxText = null;
	var atlas:FlxAtlasFrames = null;

	public function new()
	{
		super();

		try
		{
			atlas = FlxAtlasFrames.fromSparrow('assets/images/NOTE_assets.png', 'assets/images/NOTE_assets.xml');
		}
		catch (e:Dynamic)
		{
			atlas = null;
		}

		var size:Int = 120;
		var y:Float = FlxG.height - size - 30;

		for (i in 0...4)
		{
			var s:FlxSprite = new FlxSprite(0, y);

			if (atlas != null)
			{
				s.frames = atlas;
				s.animation.addByNames('idle', [IDLE_FRAMES[i]], 1, false);
				s.animation.addByNames('press', [PRESS_FRAMES[i]], 1, false);
				s.animation.play('idle');
				s.setGraphicSize(size, size);
				s.updateHitbox();
			}
			else
			{
				s.makeGraphic(size, size, FlxColor.WHITE);
				s.alpha = 0.4;
			}

			s.scrollFactor.set(0, 0);
			s.x = PlayTouch.zoneX(i) + (PlayTouch.ZONE_W - s.width) / 2;
			add(s);
			arrows.push(s);
		}

		pauseIcon = new FlxText(FlxG.width - PlayTouch.PAUSE_W, 24, PlayTouch.PAUSE_W, 'II', 56);
		pauseIcon.setFormat(null, 56, FlxColor.WHITE, CENTER);
		pauseIcon.alpha = 0.45;
		pauseIcon.scrollFactor.set(0, 0);
		add(pauseIcon);
	}

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
			var down:Bool = Controls.touchIsDown(ACTIONS[i]);
			if (flash[i] > 0)
			{
				flash[i] -= elapsed;
				if (flash[i] < 0)
					flash[i] = 0;
			}

			var active:Bool = down || flash[i] > 0;

			if (atlas != null)
			{
				var want:String = active ? 'press' : 'idle';
				if (arrows[i].animation.name != want)
					arrows[i].animation.play(want);
			}
			else
			{
				arrows[i].alpha = active ? 1.0 : 0.4;
			}
		}

		if (pauseIcon != null)
			pauseIcon.alpha = Controls.touchIsDown('PAUSE') ? 1.0 : 0.45;
	}
}
