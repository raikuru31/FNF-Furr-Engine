package states.subState;

import states.OptinsState;
import backend.KeyNames;

class OptionsControl extends MusicBeatState {
    var grpOptions:FlxTypedGroup<FlxText>   = null;
    var curSelected:Int                     = 0;
    var curBindSlot:Int                     = 0; // 0 - первый бинд, 1 - второй
    var changingKey:Bool                    = false;
    var sortedActions:Array<String>         = [];

    override function create() {
        super.create();
        
        ClientSetings.loadSettingsControls();
        grpOptions = new FlxTypedGroup<FlxText>();
        add(grpOptions);

        // Сортировка и проверка биндов
        sortedActions = [
            'note_left', 'note_down', 'note_up', 'note_right',
            'ui_up', 'ui_left', 'ui_down', 'ui_right',
            'RESET', 'ACCEPT', 'BACK', 'PAUSE', 'OPTIONS'
        ];

        // Гарантируем два бинда для каждой action
        for (action in sortedActions) {
            if (ClientSetings.keyBinds[action].length < 2) {
                ClientSetings.keyBinds[action].push(NONE);
            }
        }

        // Создаем элементы меню
        var yPos:Float = 50;
        for (action in sortedActions) {
            var text = new FlxText(50, yPos, 0, 
                getFormattedText(action, false), 
                24);
            text.visible = true;
            grpOptions.add(text);
            yPos += 50;
        }

        var infoText = new FlxText(FlxG.width / 2 + 35, FlxG.height - 70, 0, 
            "←/→ - Select a slot | ENTER - Change | ESC - Save and exit", 
            16);
        add(infoText);

        updateSelection();

        #if FLX_MOUSE
        FlxG.mouse.visible = true;
        #end
    }

    function getFormattedText(action:String, forEdit:Bool):String {
        var keys = ClientSetings.keyBinds[action];
        var slot1 = KeyNames.getKeyName(keys[0]);
        var slot2 = KeyNames.getKeyName(keys[1]);
        
        if (forEdit) {
            slot1 = curBindSlot == 0 ? '> $slot1 <' : slot1;
            slot2 = curBindSlot == 1 ? '> $slot2 <' : slot2;
        }
        
        return '${action.toUpperCase()}: [$slot1]  [$slot2]';
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (!changingKey) {

            handleMouseInput();

            #if FLX_KEYBOARD
            // Горизонтальная навигация между слотами
            if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.RIGHT) {
                curBindSlot = FlxMath.wrap(curBindSlot + (FlxG.keys.justPressed.LEFT ? -1 : 1), 0, 1);
                updateSelection();
            }

            // Вертикальная навигация
            if (FlxG.keys.justPressed.UP || FlxG.keys.justPressed.DOWN) {
                curSelected = FlxMath.wrap(curSelected + (FlxG.keys.justPressed.UP ? -1 : 1), 0, sortedActions.length - 1);
                curBindSlot = 0; // Сброс слота при переходе
                updateSelection();
            }

            if (FlxG.keys.justPressed.ENTER) {
                changingKey = true;
                grpOptions.members[curSelected].text = getFormattedText(sortedActions[curSelected], true);
            }
            
            if (FlxG.keys.justPressed.ESCAPE) {
                // ClientSetings.saveSettings();
                ClientSetings.saveSettingsControls();
                FlxG.switchState(new OptinsState());
            }
            #end
        }
        else {
            #if FLX_KEYBOARD
            if (FlxG.keys.justPressed.ANY) {
                var pressedKey = FlxG.keys.firstJustPressed();
                var action = sortedActions[curSelected];
                
                // Обновляем только выбранный слот
                ClientSetings.keyBinds[action][curBindSlot] = pressedKey;
                Controls.instance.keyboardBinds[action][curBindSlot] = pressedKey;

                // Возвращаем нормальный вид
                changingKey = false;
                updateSelection();
                // ClientSetings.saveSettings();
            }
            #end
        }
    }

    function handleMouseInput() {
        #if FLX_MOUSE
        if (FlxG.mouse.justPressed) {
            // Проверяем клик по элементам меню
            for (i in 0...grpOptions.length) {
                var option = grpOptions.members[i];
                if (FlxG.mouse.overlaps(option)) {
                    // Определяем выбранный слот
                    var mouseXRelative = FlxG.mouse.x - option.x;
                    var slotWidth = option.fieldWidth / 2;
                    curBindSlot = mouseXRelative > slotWidth ? 1 : 0;
                    
                    // Обновляем выбор
                    curSelected = i;
                    updateSelection();
                    
                    // Запускаем изменение бинда
                    changingKey = true;
                    grpOptions.members[curSelected].text = getFormattedText(sortedActions[curSelected], true);
                    break;
                }
            }
        }

        // Подсветка при наведении
        for (i in 0...grpOptions.length) {
            var option = grpOptions.members[i];
            if (FlxG.mouse.overlaps(option)) {
                option.color = FlxColor.LIME;
            } else if (i == curSelected) {
                option.color = FlxColor.YELLOW;
            } else {
                option.color = FlxColor.WHITE;
            }
        }
        #end
    }

    function updateSelection() {
        for (i in 0...grpOptions.length) {
            var action = sortedActions[i];
            var text = grpOptions.members[i];
            
            text.text = getFormattedText(action, false);
            text.color = (i == curSelected) ? FlxColor.YELLOW : FlxColor.WHITE;
            
            if (i == curSelected) {
                text.text = getFormattedText(action, changingKey);
                // text.addFormat(new FlxTextFormat(FlxColor.CYAN, false, true, FlxColor.BLACK));
            }
        }
    }
}