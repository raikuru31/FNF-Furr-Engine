package backend;

import data.Week.StoryWeek;
import haxe.io.Path;
import haxe.Json;

class StoryLoad {
    
    public static function loadWeek(folder:String) {
        var weekPath:String = 'assets/weeks/$folder';
        var weekJson = AssetLoader.getText(weekPath).trim();
        var weekData:StoryWeek = Json.parse(weekJson);
        return weekData;
    }

    public static function collectFilesByExtension(directoryPath:String, targetExtension:String):Array<String> {
    var files = [];
    
    // Удаляем точку из расширения, если она есть (например, ".json" → "json")
    targetExtension = targetExtension.replace(".", "").toLowerCase();
    
    // Читаем список файлов (на Android — из сгенерированного filelist.json)
    files = AssetLoader.listFiles(directoryPath, targetExtension);

    return files;
}
}