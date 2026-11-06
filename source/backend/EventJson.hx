package backend;

import data.Event.EventFiles;
import haxe.Json;

class EventJson {
    public static var pathEvent:String;
    public static function loadFromJson(nameFolder:String) {
        pathEvent = 'assets/data/' + nameFolder.toLowerCase() + '/event.json';
        if (AssetLoader.exists(pathEvent))
        {
            var eventFiles = AssetLoader.getText(pathEvent).trim();
            var eventF:EventFiles = Json.parse(eventFiles);
            return eventF;
        }
        else 
        {
            return {event: []};
        }
    }
}