package backend;

class RandomSongForDemo {
    
    public var randSong:String;

    public function new() {
        var path = "assets/data"; // Укажите нужный путь
		
        // Проверяем, существует ли директория
        if (!AssetLoader.exists(path)){
            trace("Директория не существует!");
            return;
        }
		
        // Проверяем, является ли путь директорией
        if (!FileSystem.isDirectory(path)) {
            trace("Указанный путь не является директорией!");
            return;
        }
		
        // Получаем список всех элементов в директории
        var items = FileSystem.readDirectory(path);
		
        // Фильтруем только папки
        var folders = [for (item in items) if (FileSystem.isDirectory('$path/$item')) item];
		
        var randomNumber:Int = Std.random(folders.length);
		
        randSong = folders[randomNumber];
    }
}