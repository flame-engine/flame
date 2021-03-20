# Audio

To play a audio is really simple!

First you have to add `flame_audio` to your dependency list in your `pubspec.yaml` file:

```yaml
dependencies:
  flame_audio: 0.1.0-rc4
```

The you should add entries in the `assets` section for each file that you want to use (and make sure
that the files exist in the paths that you provide).

For the examples below, your `pubspec.yaml` file needs to contain something like this:

```yaml
flutter:
  assets:
    - assets/audio/explosion.mp3
    - assets/audio/music.mp3
```

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
almost no drop on the game frame rate will happen. You should whenever possible, prefer these
methods.

`playLongAudio/loopLongAudio` allows for audios of any length to be played, but they do create frame
rate drop, and the looped audio will have a small gap between iterations.

You can use [the `Bgm` class (via `FlameAudio.bgm`)](bgm.md) to play looping background music
tracks. The `Bgm` class lets Flame manage the auto pausing and resuming of background music tracks
when pausing/resuming the game.

The file formats that have been tested and works are MP3, OGG and WAV.

This bridge library uses [audioplayers](https://github.com/luanpotter/audioplayer) in order to allow
for playing multiple sounds simultaneously (crucial in a game). You can check the link for a more
in-depth explanation.

Finally, you can pre-load your audios. Audios need to be stored in the memory the first time they
are requested; therefore, the first time you play each mp3 you might get a delay. In order to
pre-load your audios, just use:

```dart
FlameAudio.audioCache.load('explosion.mp3');
```

You can load all your audios in the beginning in your game's `onLoad` method so that they always
play smoothly. To load multiple audio files, use the `loadAll` method:

```dart
FlameAudio.audioCache.loadAll(['explosion.mp3', 'music.mp3'])
```

Finally, you can use the `clear` method to remove a file that has been loaded into the cache:

```dart
FlameAudio.audioCache.clear('explosion.mp3');
```

There is also a `clearAll` method, that clears the whole cache.

This might be useful if, for instance, your game has multiple levels and each has a different
soundtrack.

Both load methods return a `Future` for the `File`s loaded.

Both on `play` and `loop` you can pass an additional optional double parameter, the `volume`
(defaults to `1.0`).

Both the `play` and `loop` methods return an instance of an `AudioPlayer` from the
[audioplayers](https://github.com/luanpotter/audioplayer) lib, that allows you to stop, pause and
configure other parameters.
