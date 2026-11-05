# Мобильная сборка FurrEngine

Здесь описано, что уже сделано для Android и что нужно, чтобы получить APK.

## Что делает патч

* **Виртуальные кнопки в игре** — `source/objects/TouchControls.hx`.
  Четыре стрелки (← ↓ ↑ →) плюс кнопка паузы в правом верхнем углу.
  Работает по мультитачу: каждая кнопка «держится» за свой `touchPointID`,
  поэтому можно держать стрелку и одновременно жать вторую.
* **Кнопки в меню** — `source/objects/MobileUI.hx`.
  Крестовина (← ↓ ↑ →) и кнопки «подтвердить»/«назад» добавляются в любое
  состояние, кроме игры.
* **Совмещение ввода** — `source/backend/Controls.hx`.
  `holdPressed` / `justPressed` / `justReleased` теперь возвращают
  «клавиатура ИЛИ тач». Обращения к `FlxG.keys` закрыты `#if FLX_KEYBOARD`,
  потому что в `Project.xml` для мобильных включён `FLX_NO_KEYBOARD`.
* **Компилируемость под мобильные** — `source/states/subState/OptionsControl.hx`
  (клавиатура и мышь под `#if FLX_KEYBOARD` / `#if FLX_MOUSE`).
* **Сборка APK в облаке** — `.github/workflows/android.yml`.

## Как собрать

### Вариант 1: GitHub Actions (без компьютера)

1. Форкни репозиторий на GitHub (или создай свой).
2. Залей в него эти изменения (патч `furr-mobile.patch` или файлы целиком).
3. Открой вкладку **Actions** → **Build Android APK** → **Run workflow**.
4. Через 10–20 минут скачай APK из блока **Artifacts** (внизу страницы запуска).

Workflow сам ставит JDK 17, Android SDK и NDK 21.4, Haxe и haxelibs.

### Вариант 2: на компьютере

```bash
# 1. Инструменты
sudo pacman -S haxe haxelib openjdk17-sdk android-sdk android-ndk   # Arch
# или: apt install haxe default-jdk + Android Studio (SDK/NDK)

# 2. Библиотеки
haxelib setup ~/haxelib
haxelib install flixel 5.6.1
haxelib install flixel-addons 3.2.2
haxelib install tjson 1.4.0
haxelib install hscript
haxelib install flxanimate
haxelib git funkin.vis https://github.com/FunkinCrew/funkin.vis
haxelib git grig.audio https://github.com/FunkinCrew/grig.audio

# 3. Переменные окружения
export ANDROID_SDK_ROOT=$HOME/Android/Sdk
export ANDROID_NDK_HOME=$ANDROID_SDK_ROOT/ndk/21.4.7075529

# 4. Сборка
haxelib run lime build android -release
```

APK появится в `export/release/android/bin/`.

## Известные ограничения (что ещё не сделано)

* **Экран настройки клавиш** на мобильном бесполезен: там нечем нажимать.
  Пока он просто не падает — под `FLX_NO_KEYBOARD` его клавиатурная часть
  отключена.
* **Меню** получают кнопки, но подсостояния (пауза, диалоги) перекрывают их
  и могут блокировать ввод — нужен отдельный слой поверх подсостояний.
* **Свайпы/жесты** не реализованы, только кнопки.
* **Экранная клавиатура** в текстовых полях не поддержана.
* **Разрешение и масштаб**: игра рассчитана на 1280×720, на телефоне
  включается `ratio`-скейлинг lime; кнопки позиционируются от `FlxG.width/height`,
  так что при других пропорциях их стоит проверить глазами.
* **Сохранения** пишутся в песочницу приложения — на Android это нормально,
  но путь `ClientSetings` стоит проверить на первый запуск.

## Что делать после первого билда

1. Собрать, поставить APK, посмотреть, что именно ломается (лог через `adb logcat`
   или встроенный экран ошибок lime).
2. По логу править: чаще всего это пути к `assets/` (регистр букв) и
   `FlxG.save`/файловые операции.
3. Затем добавить слой кнопок поверх подсостояний и настройку «прозрачность
   кнопок» в меню.
