package backend;

import lime.system.System as LimeSystem;
import sys.io.File;

/**
 * Файл сохранений data.json.
 *
 * На десктопе он лежит рядом с игрой (рабочая папка), а на Android писать в
 * рабочую папку нельзя, поэтому там используется внутренняя папка приложения.
 * Если файла нет — создаётся пустая заготовка, иначе первый же переход в
 * Free Play падал с [file_contents,data.json].
 */
class DataFile
{
	public static inline var DEFAULT_CONTENT:String = '{\n    "dataSongs":[],\n    "dataWeeks":[]\n}';

	public static function path():String
	{
		#if mobile
		return LimeSystem.applicationStorageDirectory + "data.json";
		#else
		return "data.json";
		#end
	}

	public static function exists():Bool
	{
		try
		{
			return sys.FileSystem.exists(path());
		}
		catch (e:Dynamic)
		{
			return false;
		}
	}

	/** Создаёт data.json с пустой структурой, если его ещё нет. */
	public static function ensure():Void
	{
		if (exists())
			return;

		try
		{
			File.saveContent(path(), DEFAULT_CONTENT);
		}
		catch (e:Dynamic) {}
	}

	public static function read():String
	{
		try
		{
			return File.getContent(path());
		}
		catch (e:Dynamic)
		{
			ensure();
			try
			{
				return File.getContent(path());
			}
			catch (e2:Dynamic)
			{
				return DEFAULT_CONTENT;
			}
		}
	}

	public static function write(content:String):Void
	{
		try
		{
			File.saveContent(path(), content);
		}
		catch (e:Dynamic) {}
	}
}
