package backend;

import openfl.display.BitmapData;
import openfl.utils.Assets;
import sys.io.File;
import sys.FileSystem;

/**
 * Единая точка загрузки файлов из assets.
 *
 * На десктопе игра читала `assets/...` обычным File.getContent, потому что
 * рабочая папка совпадала с папкой проекта. На Android этих файлов в файловой
 * системе нет — они лежат ВНУТРИ APK, и достать их можно только через Assets.
 * Поэтому сначала идёт Assets (работает и на Android, и на десктопе),
 * а File остаётся запасным путём.
 */
class AssetLoader
{
	public static function getText(path:String):String
	{
		var data:String = null;
		try
		{
			data = Assets.getText(path);
		}
		catch (e:Dynamic) {}

		if (data != null && data.length > 0)
			return data;

		return File.getContent(path);
	}

	public static function exists(path:String):Bool
	{
		try
		{
			if (Assets.exists(path))
				return true;
		}
		catch (e:Dynamic) {}

		try
		{
			return FileSystem.exists(path);
		}
		catch (e:Dynamic) {}

		return false;
	}

	public static function getBitmapData(path:String):BitmapData
	{
		var bitmap:BitmapData = null;

		try
		{
			bitmap = Assets.getBitmapData(path);
		}
		catch (e:Dynamic) {}

		if (bitmap != null)
			return bitmap;

		try
		{
			if (FileSystem.exists(path))
				return BitmapData.fromFile(path);
		}
		catch (e:Dynamic) {}

		return null;
	}

	/**
	 * Список подпапок каталога.
	 * На Android файловой системы с ассетами нет, поэтому если обычное чтение
	 * не сработало — берём заранее сгенерированный <path>/songlist.json.
	 */
	public static function listDirs(path:String):Array<String>
	{
		var result:Array<String> = [];

		try
		{
			var items:Array<String> = FileSystem.readDirectory(path);
			for (item in items)
				if (FileSystem.isDirectory(path + "/" + item))
					result.push(item);
		}
		catch (e:Dynamic) {}

		if (result.length > 0)
			return result;

		try
		{
			var raw:String = getText(path + "/songlist.json");
			var parsed:Array<Dynamic> = haxe.Json.parse(raw);
			for (item in parsed)
				result.push(Std.string(item));
		}
		catch (e:Dynamic) {}

		return result;
	}

	/**
	 * Список файлов с нужным расширением.
	 * Как и listDirs, на Android опирается на заранее сгенерированный filelist.json.
	 */
	public static function listFiles(path:String, ext:String):Array<String>
	{
		var result:Array<String> = [];
		var want:String = ext.toLowerCase();
		if (want.indexOf(".") == 0)
			want = want.substr(1);

		try
		{
			for (item in FileSystem.readDirectory(path))
			{
				var full:String = path + "/" + item;
				if (!FileSystem.isDirectory(full))
				{
					var dot:Int = item.lastIndexOf(".");
					var e:String = dot >= 0 ? item.substr(dot + 1).toLowerCase() : "";
					if (e == want)
						result.push(item);
				}
			}
		}
		catch (e:Dynamic) {}

		if (result.length > 0)
			return result;

		try
		{
			var raw:String = getText(path + "/filelist.json");
			var parsed:Array<Dynamic> = haxe.Json.parse(raw);
			for (item in parsed)
				result.push(Std.string(item));
		}
		catch (e:Dynamic) {}

		return result;
	}
}
