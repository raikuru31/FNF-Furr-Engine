package objects;

// import openfl.filters.AtlasBlurShader;

class Note extends FlxSprite
{
    public var blockHit:Bool            = false;
    
    public var imgpng:FlxGraphic        = null;
    public var imgxml:String            = null;

    public var textyre:String           = null;
    public var tex:FlxAtlasFrames       = null;
    
    public var strumTime:Float          = 0;

	public var mustPress:Bool           = false;
	public var noteData:Int             = 0;
	public var canBeHit:Bool            = false;
	public var tooLate:Bool             = false;
	public var wasGoodHit:Bool          = false;
    public var missNote: Bool           = false;
    public var badHit:Bool              = false;
	public var prevNote:Note            = null;
    public var nextNote:Note            = null;

	public var sustainLength:Float      = 0;
	public var isSustainNote:Bool       = false;

	public var noteScore:Float          = 1;

    public var offsetX:Float            = 0;
	public var offsetY:Float            = 0;

	public static var swagWidth:Float   = 115;

    public var lowPriority:Bool         = false;
    public var lateHitMult:Float        = 1;
    public var earlyHitMult:Float       = 1;

    private var reloadNotes:Bool        = false;

    public var noteType:String          = null;

    public var ignoreNote:Bool          = false;

    public var AltAlpha:Float           = 1;
    
    public function new( strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, img:String = 'NOTE_assets') 
    {
        super();

        if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		this.isSustainNote = sustainNote;
		this.strumTime = strumTime;
		this.noteData = noteData;
        this.textyre = img;

        reloadNote();
    }

    public function reloadNote()
    {
        
        if(!reloadNotes)
            x += 50;

        if (noteType == 'Phantom Note')
        {
            ignoreNote = true;
            AltAlpha = 0.3;

            textyre = 'HURTNOTE_assets';
        }

        imgpng = Img.load(textyre);
        imgxml = AssetLoader.getText('assets/images/' + textyre + '.xml');

        tex = FlxAtlasFrames.fromSparrow(imgpng,imgxml);
        frames = tex;

        
        animation.addByPrefix('greenScroll', 'green0');
		animation.addByPrefix('greenholdend', 'green hold end0');
		animation.addByPrefix('greenhold', 'green hold piece');


		animation.addByPrefix('redScroll', 'red0');
		animation.addByPrefix('redholdend', 'red hold end0');
		animation.addByPrefix('redhold', 'red hold piece');


		animation.addByPrefix('blueScroll', 'blue0');
		animation.addByPrefix('blueholdend', 'blue hold end0');
		animation.addByPrefix('bluehold', 'blue hold piece');


		animation.addByPrefix('purpleScroll', 'purple0');
		animation.addByPrefix('purpleholdend', 'pruple hold end0');
		animation.addByPrefix('purplehold', 'purple hold piece');
        

        updateHitbox();
        if(!reloadNotes)
            setGraphicSize(Std.int(width * 0.7));

        var arScroll:Array<String> = ['purpleScroll', 'blueScroll', 'greenScroll', 'redScroll'];

        if (!reloadNotes)
            x += swagWidth * noteData;

        animation.play(arScroll[noteData]);

        if (prevNote != null)
			prevNote.nextNote = this;

        if (isSustainNote && prevNote != null)
        {
            if(!reloadNotes)
            {
                noteScore * 0.2;
                // alpha = 0.6;
            }
            var arhold:Array<String> = ['purplehold', 'bluehold', 'greenhold', 'redhold'];
            updateHitbox();
        
            
            if (prevNote.isSustainNote)
            {
                prevNote.animation.play(arhold[prevNote.noteData]);
                prevNote.updateHitbox();
                earlyHitMult = 1;
                if (!reloadNotes)
                {
                    prevNote.scale.y *= Conductor.StepBit / 100 * 1.5;
                    prevNote.scale.y *=  PlayState.SONG.speed;
                    // prevNote.scale.y *= Conductor.StepBit / 100 * 1.05;
                }
            }
            earlyHitMult = 0;
           
            
            flipY = !ClientSetings.data.downScroll ? false : true ;
            animation.play(arhold[noteData] + 'end');
            updateHitbox();
        }
        reloadNotes = true; 
        antialiasing = ClientSetings.data.antialiasing;
    }

    public function reSize(size:Float) {
        if(isSustainNote && animation.curAnim != null && !animation.curAnim.name.endsWith('end'))
		{
			scale.y *= size;
			updateHitbox();
		}
    }

    public function canBeHitNow():Bool 
        return !tooLate && !wasGoodHit && !blockHit && mustPress;

    public function delNote():Void
    {
        kill();
	    destroy();
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (mustPress)
            {

                canBeHit = (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * lateHitMult) &&
                            strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * earlyHitMult));   

                if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset && !wasGoodHit)
                    tooLate = true;
            }
            else
            {
                canBeHit = false;
    
                if (!wasGoodHit && strumTime <= Conductor.songPosition)
                    {
                        if(!isSustainNote || prevNote.wasGoodHit )
                            wasGoodHit = true;
                    }
            }
    
            if (tooLate)
            {
                if (alpha > 0.2)
                    alpha = 0.2;
                alpha = 0.2;
            }
    }
}