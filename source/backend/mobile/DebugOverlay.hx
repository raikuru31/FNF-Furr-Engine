package backend.mobile;

import flixel.FlxG;
import flixel.group.FlxSpriteGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.system.System;

/**
 * Небольшая плашка в углу: FPS, память, версия движка и на чём запущено.
 */
class DebugOverlay extends FlxSpriteGroup
{
	var txt:FlxText;
	var _frames:Int = 0;
	var _acc:Float = 0;
	var _fps:Int = 0;

	public function new()
	{
		super();

		txt = new FlxText(14, 12, 900, '', 24);
		txt.setFormat(null, 24, FlxColor.WHITE, LEFT);
		txt.scrollFactor.set(0, 0);
		txt.alpha = 0.85;
		add(txt);
	}

	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);

		_frames++;
		_acc += elapsed;
		if (_acc >= 0.5)
		{
			_fps = Std.int(_frames / _acc + 0.5);
			_frames = 0;
			_acc = 0;
		}

		var ramMb:Int = Std.int(System.totalMemory / (1024 * 1024));

		var backend:String = 'desktop';
		#if android
		backend = 'android';
		#elseif html5
		backend = 'html5';
		#elseif linux
		backend = 'linux';
		#elseif windows
		backend = 'windows';
		#end

		var target:String = 'desktop';
		#if mobile
		target = 'mobile';
		#end

		txt.text = 'FPS ' + _fps + '   |   RAM ' + ramMb + ' MB   |   FurrEngine ' + states.TitleState.verEngine + '   |   ' + backend + ' / ' + target;
	}
}
