
package states;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import flixel.math.FlxMath;
import flixel.system.FlxSound;

class Watafak extends FlxState
{
    private var bars:Array<FlxSprite> = [];
    private var numBars:Int = 32; // Увеличим количество полос
    private var targetHeights:Array<Float> = [];
    private var currentHeights:Array<Float> = [];
    private var music:FlxSound;
    
    override public function create():Void
    {
        super.create();
        
        // Настройка цветовой палитры
        FlxG.camera.bgColor = FlxColor.fromRGB(10, 10, 20);
        
        // Создание полос эквалайзера
        var barSpacing:Float = 4;
        var totalWidth:Float = FlxG.width - 40;
        var barWidth:Float = (totalWidth - (numBars - 1) * barSpacing) / numBars;
        
        for (i in 0...numBars)
        {
            var bar = new FlxSprite();
            bar.makeGraphic(Std.int(barWidth), 10, FlxColor.WHITE);
            bar.x = 20 + i * (barWidth + barSpacing);
            bar.y = FlxG.height - 20;
            bar.origin.y = bar.height;
            add(bar);
            bars.push(bar);
            
            targetHeights.push(0);
            currentHeights.push(0);
        }
        
        // Загрузка музыки
        music = FlxG.sound.load('assets/music/freakyMenu.ogg');
        music.play();
    }
    
    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);
        
        if (!music.playing) return;
        
        // Генерация волновой картины
        var time:Float = music.time / 1000;
        var baseFrequency:Float = 0.5 + Math.sin(time) * 0.3;
        
        for (i in 0...numBars)
        {
            // Динамическое смещение частот
            var frequency:Float = baseFrequency + i * 0.02;
            
            // Комбинируем разные волны для сложного паттерна
            var wave1:Float = Math.sin(time * frequency * 8 + i);
            var wave2:Float = Math.cos(time * frequency * 4 + i * 0.5);
            var wave3:Float = Math.sin(time * frequency * 2 - i * 0.3);
            
            var combined:Float = (wave1 + wave2 + wave3) / 3;
            
            // Добавляем случайные импульсы
            if (Math.random() < 0.005) combined += Math.random() * 2;
            
            targetHeights[i] = 50 + Math.abs(combined) * 120;
            
            // Плавная интерполяция высоты
            currentHeights[i] = FlxMath.lerp(currentHeights[i], targetHeights[i], 0.2);
            
            // Обновление графики
            bars[i].scale.y = currentHeights[i];
            bars[i].updateHitbox();
            bars[i].y = FlxG.height - 20 - bars[i].height;
            
            // Цветовая анимация
            var hue:Float = (i * 360 / numBars + time * 50) % 360;
            bars[i].color = FlxColor.fromHSB(hue, 0.8, 0.9);
            
            // Эффект свечения
            bars[i].alpha = 0.7 + Math.sin(time * 5 + i) * 0.2;
        }
    }
}