# Audio

To play an audio is really simple!

Start by adding an entry in your `pubspec.yaml` for each file you want to use (and make sure that the files exist in the paths that you provide).

For the examples below, your `pubspec.yaml` file needs to contain something like this:

```yaml
flutter:
  assets:
    - assets/audio/explosion.mp3
    - assets/audio/music.mp3
```

Then simply run:

```dart
    import 'package:flame/flame.dart';

    Flame.audio.play('explosion.mp3');
    Flame.audio.playLongAudio('music.mp3');
```

Or, if you prefer:

```dart
    import 'package:flame/flame_audio.dart';

    FlameAudio audio = FlameAudio();

    audio.play('explosion.mp3'); // Or
    audio.playLongAudio('music.mp3');
```

The difference is that each instance shares a different cache. Normally you would want to use the `Flame.audio` instance and totally share the cache.

You must have an appropriate folder structure and add the files to the `pubspec.yaml` file, as explained above.

It can be an MP3, OGG or a WAV file (those are the ones I tested and it worked)

This uses the [audioplayers](https://github.com/luanpotter/audioplayer) lib, in order to allow playing multiple sounds simultaneously (crucial in a game). You can check the link for more in-depth explanations.

If you want to play indefinitely, just use `loop` function:

```dart
    Flame.audio.loop('music.mp3'); // Or
    Flame.audio.loopLongAudio('music.mp3');
```

Alternatively, you can use [the `Bgm` class (via `Flame.bgm`)](bgm.md) to play looping background music tracks. The `Bgm` class lets Flame manage the auto pausing and resuming of background music tracks when pausing/resuming the game/app.

The difference between the `play/loop` and `playLongAudio/loopLongAudio` is that `play/loop` makes uses of optimized features that allow sounds to be looped without gaps between their iterations, and almost no drop on the game frame rate will happen. You should whenever possible, prefer these methods. `playLongAudio/loopLongAudio` allows for audios of any length to be played, but they do create frame rate drop, and the looped audio will feature a small gap between iterations.

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
