package charectors;

import flxanimate.FlxAnimate;
import flxanimate.frames.FlxAnimateFrames;


class CharectorsWinState extends FlxAnimate{
    
    public var imgpng:FlxGraphic;
    public var imgAnim:String;
    public var imgjson:String;
    
    var newFrames:FlxAnimateFrames = new FlxAnimateFrames();

    public function new(x:Float, y:Float, ch:String, res:String, ?folderch:String) {
        super(x, y);
        
        if(folderch == null)
        {
            // imgpng = BitmapData.fromFile('assets/images/ResultState/results-'+ ch +'/results'+ res +'/spritemap1.png');
            imgpng = Img.load('ResultState/results-'+ ch +'/results'+ res +'/spritemap1');
            imgjson = AssetLoader.getText('assets/images/ResultState/results-'+ ch +'/results'+ res +'/spritemap1.json');
            imgAnim = AssetLoader.getText('assets/images/ResultState/results-'+ ch +'/results'+ res +'/Animation.json');
        }
        else
        {
            // imgpng = BitmapData.fromFile('assets/images/ResultState/results-'+ ch +'/results'+ res +'/'+folderch+'/spritemap1.png');
            imgpng = Img.load('ResultState/results-'+ ch +'/results'+ res +'/'+folderch+'/spritemap1');
            imgjson = AssetLoader.getText('assets/images/ResultState/results-'+ ch +'/results'+ res +'/'+folderch+'/spritemap1.json');
            imgAnim = AssetLoader.getText('assets/images/ResultState/results-'+ ch +'/results'+ res +'/'+folderch+'/Animation.json');
        }

        var tex = FlxAnimateFrames.fromSpriteMap(imgjson, imgpng);
        newFrames.addAtlas(tex);
        loadSeparateAtlas(imgAnim, newFrames);

        antialiasing = ClientSetings.data.antialiasing;
    }
}       