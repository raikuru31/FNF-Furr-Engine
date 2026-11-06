package backend;

import haxe.Json;
import haxe.format.JsonParser;
import lime.utils.Assets;
import objects.Section.SwagSection;

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var events:Array<Dynamic>;
	var bpm:Int;
	var sections:Int;
	var needsVoices:Bool;
	var speed:Float;
	var stage:String;

	var player1:String;
	var player2:String;
	var player3:String;

	var gfVersion:String;

	var format:String;
	
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var mustHitSection:Bool;
	var bpm:Int;
	var altAnim:Bool;
	var gfSection:Bool;
	var changeBPM:Bool;
	var sectionBeats:Float;
}

class Song
{
	public var song:String					= null;
	public var notes:Array<SwagSection>		= null;
	public var events:Array<Dynamic>		= null;
	public var bpm:Int						= 0;
	public var sections:Int					= 0;
	public var needsVoices:Bool 			= true;
	public var speed:Float 					= 1;

	public var player1:String 				= 'bf';
	public var player2:String 				= 'dad';
	public var player3:String 				= 'gf';
	public var stage:String 				= 'stage';

	public var format:String 				= 'FurrEngine_0.1';

	public var sectionNotes:Array<Dynamic> 	= [];

	public var mustHitSection:Bool 			= true;
	public var altAnim:Bool 				= false;
	public var gfSection:Bool 				= false; 
	public var changeBPM:Bool 				= false;

	public function new(song, notes, bpm, sections)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
		this.sections = sections;
		
	}

	public static function loadFromJson(jsonInput:String, ?folder:String):SwagSong
	{

		var rawJson = AssetLoader.getText('assets/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json').trim();
		trace('assets/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json');
		// var rawJson = Assets.getText('assets/data/tutorial/tutorial-hard.json').trim();
		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		var swagShit:SwagSong = cast Json.parse(rawJson).song;

		if(swagShit.gfVersion != null)
			swagShit.player3 = swagShit.gfVersion;
		for (i in 0...swagShit.notes.length)
		{
			if(swagShit.notes[i].changeBPM != true)
				swagShit.notes[i].changeBPM = false;
		}
		// trace(swagShit.notes[0]);

		// FIX THE CASTING ON WINDOWS/NATIVE
		// Windows???
		// trace(songData);

		// trace('LOADED FROM JSON: ' + songData.notes);
		/* 
			for (i in 0...songData.notes.length)
			{
				trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
				// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
			}

				daNotes = songData.notes;
				daSong = songData.song;
				daSections = songData.sections;
				daBpm = songData.bpm;
				daSectionLengths = songData.sectionLengths; */

		return swagShit;
	}
}