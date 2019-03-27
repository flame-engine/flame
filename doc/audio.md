# Audio

To play an audio, it's really simple! Just run, at any moment:

```dart
    import 'package:flame/flame.dart';

    Flame.audio.playSfx('explosion.mp3');
    Flame.audio.playMusic('music.mp3');
```

Or, if you prefer:

```dart
    import 'package:flame/flame_audio.dart';

    FlameAudio audio = new FlameAudio();
    audio.playSfx('explosion.mp3');
    audio.playMusic('music.mp3');
```

The difference is that each instance shares a different cache. Normally you would want to use the `Flame.audio` instance and totally share the cache.

You must have an appropriate folder structure and add the files to the `pubspec.yaml` file, as explained above.

It can be an MP3, OGG or a WAV file (those are the ones I tested and it worked)

This uses the [audioplayers](https://github.com/luanpotter/audioplayer) lib, in order to allow playing multiple sounds simultaneously (crucial in a game). You can check the link for more in-depth explanations.

If you want to play indefinitely, just use `loop` function:

```dart
    Flame.audio.loopMusic('music.mp3');
```

Finally, you can pre-load your audios. Audios need to be stored in the memory the first time they are requested; therefore, the first time you play each mp3 you might get a delay. In order to pre-load your audios, just use:

```dart
    Flame.audio.load('explosion.mp3');
```

You can load all your audios in beginning so that they always play smoothly; to load multiple audios, use the `loadAll` method:

```dart
    Flame.audio.loadAll(['explosion.mp3', 'music.mp3'])
```

Finally, you can use the `clear` method to remove something from the cache:

```dart
    Flame.audio.clear('explosion.mp3');
```

There is also a `clearAll` method, that clears the whole cache.

This might be useful if, for instance, your game has multiple levels and each has a different soundtrack.

Both load methods return a `Future` for the `File`s loaded.

Both on `play` and `loop` you can pass an additional optional double parameter, the `volume` (defaults to `1.0`).

Both the `play` and `loop` methods return an instance of a `AudioPlayer` from the [audioplayers](https://github.com/luanpotter/audioplayer) lib, that allows you to stop, pause and configure other specifications.

There's lots of logs; that's reminiscent of the original AudioPlayer plugin. Useful while debug, but afterwards you can disable them with:

```dart
    Flame.audio.disableLog();
```
