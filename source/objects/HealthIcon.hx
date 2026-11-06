package objects;
// Сделал максимально похожую миханику определения анимаций как в Psych Engine
// И вроди всё покачто норма работает :')
class HealthIcon extends FlxSprite{
    
    var charector:String                    = '';
    var isPlayer:Bool                       = false;
    public var iSize:Float                  = 0;
    public var autoAdjustOffset:Bool        = true;
    private var _iconOffsets:Array<Float>   = [0, 0];

    public function new(charector:String = 'cat', isPlayer:Bool = false) 
    {
        super();
        this.isPlayer = isPlayer;
        ChangeIcon(charector);
        scrollFactor.set();
    }

    public function ChangeIcon(charector:String) 
    {
        if(this.charector != charector) {
            var pathIcon = 'icons/icon-' + charector ;
            if (!(AssetLoader.exists("assets/images/" + pathIcon + ".png")))
                pathIcon = 'icons/' + charector;

            if (!(AssetLoader.exists("assets/images/" + pathIcon + ".png")))
                pathIcon = 'icons/icon-cat';

            var graphic = Img.load(pathIcon);
            iSize = Math.round(graphic.width / graphic.height);
            // trace(iSize);
            loadGraphic(graphic, true, Math.floor(graphic.width / iSize), Math.floor(graphic.height));
            _iconOffsets[0] = (width - 150) / iSize;
            _iconOffsets[1] = (height - 150) / iSize;
            updateHitbox();

            animation.add(charector, [for(i in 0...frames.frames.length) i], 0, false, isPlayer);
            animation.play(charector);
            this.charector = charector;

            antialiasing = true;
        }

    }

	override function updateHitbox()
	{
		super.updateHitbox();
		if(autoAdjustOffset)
		{
			offset.x = _iconOffsets[0];
			offset.y = _iconOffsets[1];
		}
	}
}