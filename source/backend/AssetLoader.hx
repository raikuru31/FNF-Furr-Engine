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
}
