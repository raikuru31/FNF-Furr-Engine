package scriptsUrlsFE;

import objects.ABot;

class HsShit
{
    public var intShit:Interp   = null;
    public var parShit:Parser   = null;
    // var script:String;

    var game:PlayState          = PlayState.instance;

    public function new() {

        intShit = new Interp();
        parShit = new Parser();

        trace('Syka Skript Load Now! Pozaza');
        // script = loadScriptFile(path);

        // intShit.variables.set("trace", trace);
        // trace('Create Dad for Script');
        // intShit.variables.set("Dad.x", game.Dad.x);
        try {
            if(game != null)
                @:privateAccess
                {
                    intShit.variables.set("curSong", game.curSong);
                    intShit.variables.set("curStep", game.curStep);
                    intShit.variables.set("curBeat", game.curBeat);
                    intShit.variables.set("Dad", game.Dad);
                    intShit.variables.set("Bf", game.boyfriend);
                    intShit.variables.set("Gf", game.gf);
                    intShit.variables.set("defaultCamZoom", game.defaultCamZoom);
                    intShit.variables.set("camGame", game.camGame);
                    intShit.variables.set("camHUD", game.camHUD);
                    intShit.variables.set("camDead", game.camDead);
                    intShit.variables.set("camOther", game.camOther);
                    intShit.variables.set("add", game.add);
                    intShit.variables.set("playerStrums", game.playerStrums);
                    intShit.variables.set("dadStrums", game.dadStrums);
                    intShit.variables.set("spleshPlayer", game.spleshPlayer);
                    intShit.variables.set("unspawnNotes", game.unspawnNotes);
                    intShit.variables.set("startingSong", game.startingSong);
                    intShit.variables.set("songPosition", Conductor.songPosition);
                    intShit.variables.set("dataMusic",  FlxG.sound.music);
                   

                    if(game.playerStrums.members.length > 0)
                    {                   
                        intShit.variables.set("defPosNotePlayerX", game.playerStrums.members[0].x);
                        intShit.variables.set("defPosNotePlayerY", game.playerStrums.members[0].y);

                        intShit.variables.set("defPosNoteOpponentX", game.dadStrums.members[0].x);
                        intShit.variables.set("defPosNoteOpponentY", game.dadStrums.members[0].y);
                    }
                    // intShit.variables.set("global", {});
                }         
        }
        catch (e:Dynamic)
        {
            trace("Ошибка инцилизации переменных : ", e);
            Error.NameError = "Ошибка инцилизации переменных";
            Error.infoError += e;
            Error.onError(e);
        }
        trace('Load Standart Argyment Now End! Pozaza');

        intShit.variables.set("Sprite", FlxSprite);
        intShit.variables.set("doTween", FlxTween.tween);
        intShit.variables.set("Color", FlxColor.fromString);
        intShit.variables.set("lerp", FlxMath.lerp);
        intShit.variables.set("exp", Math.exp);
        intShit.variables.set("ease", TweenEaseAll.SelectEase);
        intShit.variables.set("Array", Array);
        intShit.variables.set("ABot", ABot);

        intShit.variables.set("allEase", TweenEaseAll.getAllEaseNames());

        intShit.variables.set("loadImage", 
                                function(sprite:FlxSprite, path:String) {
                                        var spr = Img.load(path);
                                        sprite.loadGraphic(spr);
                                });
        intShit.variables.set("loadAnimImage", 
                                function(sprite:FlxSprite, path:String) {
                                        var imgpng = Img.load(path);
                                        var imgxml = AssetLoader.getText('assets/images/' + path + '.xml');
                                        var tex = FlxAtlasFrames.fromSparrow(imgpng, imgxml);
                                        sprite.frames = tex;
                                });

        intShit.variables.set("noteTweenBfX", 
                                function(?tag:String, key:Int, value:Float, time:Float, ease:String = 'linear') {
                                        doTweenNotePlayer(key, {x: value}, time, ease, tag);
                                });     
        intShit.variables.set("noteTweenBfY", 
                                function(?tag:String, key:Int, value:Float, time:Float, ease:String = 'linear') {
                                        doTweenNotePlayer(key, {y: value}, time, ease, tag);
                                });  
        intShit.variables.set("noteTweenDadX", 
                                function(?tag:String, key:Int, value:Float, time:Float, ease:String = 'linear') {
                                        doTweenNoteOpponent(key, {x: value}, time, ease, tag);
                                });  
        intShit.variables.set("noteTweenDadY", 
                                function(?tag:String, key:Int, value:Float, time:Float, ease:String = 'linear') {
                                        doTweenNoteOpponent(key, {y: value}, time, ease, tag);
                                });

        intShit.variables.set("noteTweenDadAlpha", 
                                function(?tag:String, key:Int, value:Float, time:Float, ease:String = 'linear') {
                                        doTweenNoteOpponentAlpha(key, {alpha: value}, time, ease, tag);
                                });
        intShit.variables.set("noteTweenBfAlpha", 
                                function(?tag:String, key:Int, value:Float, time:Float, ease:String = 'linear') {
                                        doTweenNotePlayerAlpha(key, {alpha: value}, time, ease, tag);
                                });

        intShit.variables.set("doTweenAlpha", 
                                function(?tag:String, spr:Dynamic, value:Float, time:Float, ease:String = 'linear') {
                                        doTweenAlpha(spr, {alpha: value}, time, ease, tag);
                                });

        intShit.variables.set("doTweenX", 
                                function(?tag:String, spr:Dynamic, value:Float, time:Float, ease:String = 'linear') {
                                        doTween(spr, {x: value}, time, ease, tag);
                                });
        intShit.variables.set("doTweenY", 
                                function(?tag:String, spr:Dynamic, value:Float, time:Float, ease:String = 'linear') {
                                        doTween(spr, {y: value}, time, ease, tag);
                                });

        intShit.variables.set("doTweenAngly", 
                                function(?tag:String, spr:Dynamic, value:Float, time:Float, ease:String = 'linear') {
                                        doTween(spr, {angly: value}, time, ease, tag);
                                });

        trace('Load Standart Function Now End! Pozaza');
    }

    public function doTweenNotePlayer(key:Int, data:Dynamic, time:Float, easeFlx:String, tag:String) 
    {
        // trace('Tween Startit!!');
        var spr:Dynamic = PlayState.instance.playerStrums.members[key % PlayState.instance.playerStrums.length];
        var sprSpl:Dynamic = PlayState.instance.spleshPlayer.members[key % PlayState.instance.spleshPlayer.length];
        if(tag != null)
        {
            FlxTween.tween(spr, data, time, {
                ease: TweenEaseAll.SelectEase(easeFlx),
                onComplete: function(twn:FlxTween) {
                    game.callForScript("onTweenCompleted", tag);
                }
            });
            // FlxTween.tween(sprSp, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
        }
        else
        {
            FlxTween.tween(spr, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
            // FlxTween.tween(sprSp, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
        }
        FlxTween.tween(sprSpl, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
    }

    
    public function doTweenNoteOpponent(key:Int, data:Dynamic, time:Float, easeFlx:String, tag:String) 
    {
        // trace('Tween Startit!!');
        var spr:Dynamic = PlayState.instance.dadStrums.members[key % PlayState.instance.dadStrums.length];
        if(tag != null)
        {
            FlxTween.tween(spr, data, time, {
                ease: TweenEaseAll.SelectEase(easeFlx),
                onComplete: function(twn:FlxTween) {
                    game.callForScript("onTweenCompleted", tag);
                }
            });
        }
        else
        {
            FlxTween.tween(spr, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
        }
    }

    public function doTweenNotePlayerAlpha(key:Int, data:Dynamic, time:Float, easeFlx:String, tag:String) 
    {
        trace('Tween Startit!!');
        var isKey = key % PlayState.instance.playerStrums.length;
        var spr:Dynamic = PlayState.instance.playerStrums.members[isKey];
        var sprSpl:Dynamic = PlayState.instance.spleshPlayer.members[isKey];
        if(tag != null)
        {
            FlxTween.tween(spr, data, time, {
                ease: TweenEaseAll.SelectEase(easeFlx),
                onComplete: function(twn:FlxTween) {
                    game.callForScript("onTweenCompleted", tag);
                }
            });
            // FlxTween.tween(sprSp, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
        }
        else
        {
            FlxTween.tween(spr, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
            // FlxTween.tween(sprSp, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
        }
        // @:privateAccess
        // {
        //     for (i in 0 ... game.unspawnNotes.length)
        //     { 
        //         if(game.unspawnNotes[i].noteData == isKey && game.unspawnNotes[i].mustPress)
        //             FlxTween.tween(game.unspawnNotes[i], data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
        //     }
        // }
        FlxTween.tween(sprSpl, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
    }

    
    public function doTweenNoteOpponentAlpha(key:Int, data:Dynamic, time:Float, easeFlx:String, tag:String) 
    {
        trace('Tween Startit!!');
        var isKey = key % PlayState.instance.dadStrums.length;
        var spr:Dynamic = PlayState.instance.dadStrums.members[isKey];
        if(tag != null)
        {
            FlxTween.tween(spr, data, time, {
                ease: TweenEaseAll.SelectEase(easeFlx),
                onComplete: function(twn:FlxTween) {
                    game.callForScript("onTweenCompleted", tag);
                }
            });
        }
        else
        {
            FlxTween.tween(spr, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
        }
        // @:privateAccess
        // {
        //     for (i in 0 ... game.unspawnNotes.length)
        //     { 
        //         if(game.unspawnNotes[i].noteData == isKey && !game.unspawnNotes[i].mustPress)
        //             FlxTween.tween(game.unspawnNotes[i], data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});
        //     }
        // }
    }

    public function doTweenAlpha(spr:Dynamic, data:Dynamic, time:Float, easeFlx:String, tag:String) {
        if(tag != null)

            FlxTween.tween(spr, data, time, {
                ease: TweenEaseAll.SelectEase(easeFlx),
                onComplete: function(twn:FlxTween) {
                    game.callForScript("onTweenCompleted", tag);
                }
            });

        else

            FlxTween.tween(spr, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});

    }

    public function doTween(spr:Dynamic, data:Dynamic, time:Float, easeFlx:String, tag:String) {
        if(tag != null)

            FlxTween.tween(spr, data, time, {
                ease: TweenEaseAll.SelectEase(easeFlx),
                onComplete: function(twn:FlxTween) {
                    game.callForScript("onTweenCompleted", tag);
                }
            });

        else

            FlxTween.tween(spr, data, time, {ease: TweenEaseAll.SelectEase(easeFlx)});

    }
    

    public function loadScriptFile(path:String):String 
    {
        return AssetLoader.getText(path); // Читаем файл как текст
    }

    public function loadScript(script:Expr)
    {
        intShit.execute(script);
    }
}
