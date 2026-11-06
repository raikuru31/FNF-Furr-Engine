package path;

import flxanimate.frames.FlxAnimateFrames;
import flxanimate.FlxAnimate;
import flixel.graphics.FlxGraphic;


@:access(openfl.display.BitmapData)
class Img {
	public static var currentSavedAssets:Map<String, FlxGraphic>    = [];
	public static var localTrackedAssets:Array<String>              = [];


    public static function load(name:String):FlxGraphic 
    {
        var file:String = 'assets/images/' + name + '.png';

        if(currentSavedAssets.exists(file))
        {
            localTrackedAssets.push(file);
			return currentSavedAssets.get(file);
        }
        return cache(file);
    }

    public static function cache(file:String):FlxGraphic  
    {
        var bitmap:BitmapData = null;

        bitmap = AssetLoader.getBitmapData(file);

        if (bitmap == null)
        {
            trace('\nThere is no picture here :( \n\n$file');
            return null;
        }
        else
            if(ClientSetings.data.cacheGpu)
            {
                // Скопирывал с Psych Engine
                bitmap.lock();
                if (bitmap.__texture == null)
                {
                    bitmap.image.premultiplied = true;
                    bitmap.getTexture(FlxG.stage.context3D);
                }
                bitmap.getSurface();
                bitmap.disposeImage();
                bitmap.image.data = null;
                bitmap.image = null;
                bitmap.readable = true; 
            }

        var graph:FlxGraphic = FlxGraphic.fromBitmapData(bitmap, false, file);
		graph.persist = true;
		graph.destroyOnNoUse = false;

		currentSavedAssets.set(file, graph);
		localTrackedAssets.push(file);
        
        return graph;
    }

    public static function clearCache() {

        for (key in currentSavedAssets.keys())
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key) )
			{
				destroyGraphic(currentSavedAssets.get(key)); // get rid of the graphic
				currentSavedAssets.remove(key); // and remove the key from local cache map
			}
		}
    }

    inline static function destroyGraphic(graphic:FlxGraphic)
	{
		// free some gpu memory
		if (graphic != null && graphic.bitmap != null && graphic.bitmap.__texture != null)
			graphic.bitmap.__texture.dispose();
		FlxG.bitmap.remove(graphic);
	}

    public static function loadAtlosAnimate(path:String)
    {
        var imgpng = load(path + '/spritemap1');
        var imgjson = AssetLoader.getText('assets/images/' + path + '/spritemap1.json');
        var imgAnim = AssetLoader.getText('assets/images/' + path + '/Animation.json');

        var tex = FlxAnimateFrames.fromSpriteMap(imgjson, imgpng);
        var newFrames = new FlxAnimateFrames().addAtlas(tex);
        var spr:FlxAnimate = new FlxAnimate();
        spr.loadSeparateAtlas(imgAnim, newFrames);
        return spr;
    }
}