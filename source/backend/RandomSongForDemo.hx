package backend;

class RandomSongForDemo {
    
    public var randSong:String;

    public function new() {
        var path = "assets/data"; // Укажите нужный путь
		
        var folders:Array<String> = AssetLoader.listDirs(path);

        if (folders.length == 0) {
            trace("Папки с песнями не найдены");
            return;
        }

        var randomNumber:Int = Std.random(folders.length);
		
        randSong = folders[randomNumber];
    }
}