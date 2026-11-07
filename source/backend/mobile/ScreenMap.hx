package backend.mobile;

import flixel.FlxG;

/**
 * Пересчёт координат между окном (stage) и игровым полем.
 *
 * Игра рисуется в прямоугольнике FlxG.width x FlxG.height и центрируется
 * в окне, поэтому по краям остаются поля. Касание приходит в координатах окна,
 * а зоны хитбоксов удобнее держать в координатах игры.
 */
class ScreenMap
{
	public static function scale():Float
	{
		var sw:Float = FlxG.stage.stageWidth;
		var sh:Float = FlxG.stage.stageHeight;
		if (sw <= 0 || sh <= 0)
			return 1;

		var s:Float = Math.min(sw / FlxG.width, sh / FlxG.height);
		return s > 0 ? s : 1;
	}

	public static function offsetX():Float
	{
		return (FlxG.stage.stageWidth - FlxG.width * scale()) / 2;
	}

	public static function offsetY():Float
	{
		return (FlxG.stage.stageHeight - FlxG.height * scale()) / 2;
	}

	public static function toGameX(screenX:Float):Float
	{
		return (screenX - offsetX()) / scale();
	}

	public static function toGameY(screenY:Float):Float
	{
		return (screenY - offsetY()) / scale();
	}

	public static function toScreenX(gameX:Float):Float
	{
		return gameX * scale() + offsetX();
	}

	public static function toScreenY(gameY:Float):Float
	{
		return gameY * scale() + offsetY();
	}
}
