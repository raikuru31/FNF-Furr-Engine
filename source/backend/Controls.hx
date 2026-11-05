package backend;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;

class Controls {

    public var keyboardBinds:Map<String, Array<FlxKey>>;


	// Клавиатура складывается с виртуальными кнопками (mobile).
	// На мобильном FLX_NO_KEYBOARD отключает FlxG.keys целиком, поэтому
	// все обращения к нему закрыты проверкой FLX_KEYBOARD.

	public function holdPressed(key:String) {
		#if FLX_KEYBOARD
		if (FlxG.keys.anyPressed(keyboardBinds[key]) == true) return true;
		#end
		return touchIsDown(key);
	}
	public function justPressed(key:String) {
		#if FLX_KEYBOARD
		if (FlxG.keys.anyJustPressed(keyboardBinds[key]) == true) return true;
		#end
		return touchJustPressed(key);
	}
	public function justReleased(key:String) {
		#if FLX_KEYBOARD
		if (FlxG.keys.anyJustReleased(keyboardBinds[key]) == true) return true;
		#end
		return touchJustReleased(key);
	}

	// ---------------------------------------------------------------
	// Состояние виртуальных кнопок. Пишется из objects.TouchControls,
	// читается здесь, поэтому вся логика игры (ChekKey и прочее)
	// остаётся без изменений.
	// ---------------------------------------------------------------

	public static var touchHeld:Map<String, Bool> = [];
	static var touchPrev:Map<String, Bool> = [];

	public static function touchDown(key:String):Void {
		touchHeld[key] = true;
	}

	public static function touchUp(key:String):Void {
		touchHeld[key] = false;
	}

	public static function touchIsDown(key:String):Bool {
		return touchHeld[key] == true;
	}

	public static function touchJustPressed(key:String):Bool {
		return touchHeld[key] == true && touchPrev[key] != true;
	}

	public static function touchJustReleased(key:String):Bool {
		return touchPrev[key] == true && touchHeld[key] != true;
	}

	/** Вызывать в конце кадра, после того как ввод обработан. */
	public static function endTouchFrame():Void {
		for (key in touchHeld.keys())
			touchPrev[key] = touchHeld[key];
	}

	/** Сброс всех нажатий (например, при паузе или смене состояния). */
	public static function resetTouch():Void {
		for (key in touchHeld.keys())
			touchHeld[key] = false;
		for (key in touchPrev.keys())
			touchPrev[key] = false;
	}

    public static var instance:Controls;
	public function new()
	{
		keyboardBinds = ClientSetings.keyBinds;
	}
}
