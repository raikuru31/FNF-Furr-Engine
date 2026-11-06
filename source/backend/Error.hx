package backend;

import states.TitleState;
import openfl.events.UncaughtErrorEvent;
import lime.app.Application;
import lime.system.System as LimeSystem;
import sys.io.File;
import sys.FileSystem;

/**
 * Обработчик необработанных исключений.
 *
 * Пишет полный лог в файл (внутренняя папка приложения -> внешняя папка ->
 * попытка в Download), а в нативное окно отдаёт ТОЛЬКО ASCII: lime рисует
 * диалог шрифтом без кириллицы, из-за чего русский текст превращался в "@>87>H;0".
 */
class Error
{
	static inline var APP_PACKAGE:String = 'com.Lycur.FurrEngine';

	public static var NameError:String = '';
	public static var infoError:String = '';

	static var RU_MAP:Map<String, String> = [
		"А" => "A", "Б" => "B", "В" => "V", "Г" => "G", "Д" => "D", "Е" => "E", "Ё" => "E",
		"Ж" => "Zh", "З" => "Z", "И" => "I", "Й" => "Y", "К" => "K", "Л" => "L", "М" => "M",
		"Н" => "N", "О" => "O", "П" => "P", "Р" => "R", "С" => "S", "Т" => "T", "У" => "U",
		"Ф" => "F", "Х" => "H", "Ц" => "C", "Ч" => "Ch", "Ш" => "Sh", "Щ" => "Sch",
		"Ъ" => "", "Ы" => "Y", "Ь" => "", "Э" => "E", "Ю" => "Yu", "Я" => "Ya",
		"а" => "a", "б" => "b", "в" => "v", "г" => "g", "д" => "d", "е" => "e", "ё" => "e",
		"ж" => "zh", "з" => "z", "и" => "i", "й" => "y", "к" => "k", "л" => "l", "м" => "m",
		"н" => "n", "о" => "o", "п" => "p", "р" => "r", "с" => "s", "т" => "t", "у" => "u",
		"ф" => "f", "х" => "h", "ц" => "c", "ч" => "ch", "ш" => "sh", "щ" => "sch",
		"ъ" => "", "ы" => "y", "ь" => "", "э" => "e", "ю" => "yu", "я" => "ya"
	];

	/**
	 * Кириллицу переводим в латиницу, а не в "?", иначе русские ошибки
	 * выглядят как "?????? ?? ??????????" и ничего не говорят.
	 */
	static function asciiOnly(s:String):String
	{
		var out:StringBuf = new StringBuf();
		for (i in 0...s.length)
		{
			var ch:String = s.charAt(i);
			var c:Int = s.charCodeAt(i);

			if (c == 10)
				out.add("\n");
			else if (c >= 32 && c < 127)
				out.add(ch);
			else if (RU_MAP.exists(ch))
				out.add(RU_MAP.get(ch));
			else
				out.add("?");
		}
		return out.toString();
	}

	public static function onError(e:UncaughtErrorEvent):Void
	{
		var stack = haxe.CallStack.exceptionStack();
		var dateNow:String = Date.now().toString().replace(" ", "_").replace(":", "-");

		var parts:Array<String> = [];
		parts.push("=== FurrEngine crash ===");
		parts.push("date: " + dateNow);
		parts.push("engine: " + (TitleState.verEngine == null ? "?" : TitleState.verEngine));
		parts.push("");
		parts.push("exception:");
		parts.push(Std.string(e));
		parts.push("");
		parts.push("stack:");
		parts.push(haxe.CallStack.toString(stack));
		if (infoError != "")
		{
			parts.push("");
			parts.push("info:");
			parts.push(infoError);
		}

		var full:String = parts.join("\n");
		var saved:String = writeLog(full, dateNow);

		var dialog:String = asciiOnly(full);
		if (saved != null)
			dialog += "\n\n(saved: " + asciiOnly(saved) + ")";
		else
			dialog += "\n\n(could not write log file)";

		Application.current.window.alert(dialog, "Uh-Oh!");

		NameError = '';
		infoError = '';
	}

	/**
	 * Пробует несколько мест по очереди и возвращает путь, куда удалось записать.
	 */
	static function writeLog(text:String, stamp:String):String
	{
		var dirs:Array<String> = [];
		var ext:String = "";
		try
		{
			var e:String = Sys.getEnv("EXTERNAL_STORAGE");
			if (e != null && e != "")
				ext = e;
		}
		catch (e:Dynamic) {}

		// 1) Только для этого приложения, но видно в файловых менеджерах
		if (ext != "")
			dirs.push(ext + "/Android/media/" + APP_PACKAGE + "/.Lycur/");
		// 2) .Lycur в корне хранилища (если выдано «Доступ ко всем файлам»)
		if (ext != "")
			dirs.push(ext + "/.Lycur/");
		// 3) .Lycur в «Загрузках» (то же условие)
		if (ext != "")
			dirs.push(ext + "/Download/.Lycur/");
		// 4) Внутренние папки приложения — работают всегда
		try dirs.push(LimeSystem.applicationStorageDirectory + "Crash_Engine/") catch (e:Dynamic) {}
		try dirs.push(LimeSystem.documentsDirectory + "/Crash_Engine/") catch (e:Dynamic) {}

		var name:String = "Crash_FurrEngine_" + stamp + ".txt";

		for (d in dirs)
		{
			try
			{
				if (!FileSystem.exists(d))
					FileSystem.createDirectory(d);
				File.saveContent(d + name, text);
				return d + name;
			}
			catch (e:Dynamic) {}
		}

		return null;
	}
}
