# Audio

Playing audio is essential for any game, so we made it simple!

First you have to add [flame_audio](https://github.com/flame-engine/flame_audio) to your dependency
list in your `pubspec.yaml` file:

```yaml
dependencies:
  flame_audio: <VERSION>
```

The latest version can be found on [pub.dev](https://pub.dev/packages/flame_audio/install).

After installing the `flame_audio` package you can add audio files in the assets section of your
`pubspec.yaml` file. Make sure that the audio files exists in the paths that you provide.

The default directory for `FlameAudio` is `assets/audio` (which can be changed) and for `AudioPool`
the default directory is `assets/audio/sfx`.

For the examples below, your `pubspec.yaml` file needs to contain something like this:

```yaml
flutter:
  assets:
    - assets/audio/explosion.mp3
    - assets/audio/music.mp3
```

(The default directory for `FlameAudio` is `assets/audio` (which can be changed) and for `AudioPool`
the default directory is `assets/audio/sfx`.)

Then you have the following methods at your disposal:

```dart
import 'package:flame_audio/flame_audio.dart';

// For shorter reused audio clips, like sound effects
FlameAudio.play('explosion.mp3');

// For looping an audio file
FlameAudio.loop('music.mp3');

// For playing a longer audio file
FlameAudio.playLongAudio('music.mp3');

// For looping a longer audio file
FlameAudio.loopLongAudio('music.mp3');

// For background music that should be paused/played when the pausing/resuming the game
FlameAudio.bgm.play('music.mp3');
```

The difference between the `play/loop` and `playLongAudio/loopLongAudio` is that `play/loop` makes
use of optimized features that allow sounds to be looped without gaps between their iterations, and
almost no drop on the game frame rate will happen. You should whenever possible, prefer the former
methods.

`playLongAudio/loopLongAudio` allows for audios of any length to be played, but they do create frame
rate drop, and the looped audio will have a small gap between iterations.

You can use [the `Bgm` class](bgm.md) (via `FlameAudio.bgm`) to play looping background music
tracks. The `Bgm` class lets Flame automatically manage the pausing and resuming of background music
tracks when the game is backgrounded or comes back to the foreground.

Some file formats that work across devices and that we recommend are: MP3, OGG and WAV.

This bridge library (flame_audio) uses [audioplayers](https://github.com/bluefireteam/audioplayers)
in order to allow for playing multiple sounds simultaneously (crucial in a game). You can check the
link for a more in-depth explanation.

Finally, you can pre-load your audios. Audios need to be stored in the memory the first time they
are requested; therefore, the first time you play each mp3 you might get a delay. In order to
pre-load your audios, just use:

```dart
await FlameAudio.audioCache.load('explosion.mp3');
```

You can load all your audios in the beginning in your game's `onLoad` method so that they always
play smoothly. To load multiple audio files, use the `loadAll` method:

```dart
await FlameAudio.audioCache.loadAll(['explosion.mp3', 'music.mp3'])
```

Finally, you can use the `clear` method to remove a file that has been loaded into the cache:

```dart
FlameAudio.audioCache.clear('explosion.mp3');
```

There is also a `clearCache` method, that clears the whole cache.

This might be useful if, for instance, your game has multiple levels and each has a different
set of sounds and music.

Both load methods return a `Future` for the `File`s loaded.

Both on `play` and `loop` you can pass an additional optional double parameter, the `volume`
(defaults to `1.0`).

Both the `play` and `loop` methods return an instance of an `AudioPlayer` from the
[audioplayers](https://github.com/bluefireteam/audioplayers) lib, that allows you to stop, pause and
configure other parameters.
