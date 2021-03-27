# Looping Background Music

With the `Bgm` class you can manage looping of background music tracks with regards to application
(or game) lifecycle state changes.

When the application is terminated, or sent to background, `Bgm` will automatically pause
the currently playing music track. Similarly, when the application is resumed, `Bgm` will resume the
background music. Manually pausing and resuming your tracks is also supported.

The `Bgm` class is handled by the [flame_audio](https://github.com/flame-engine/flame_audio) library
so you first have to add that to your dependency list in your `pubspec.yaml` file:

```yaml
dependencies:
  flame_audio: <VERSION>
```

The latest version can be found on [pub.dev](https://pub.dev/packages/flame_audio/install).

For this class to function properly, the observer must be registered by calling the following:

```dart
FlameAudio.bgm.initialize();
```

**IMPORTANT Note:** The `initialize` function must be called at a point in time where an instance of
the `WidgetsBinding` class already exists. Best practice is to put this call inside of your game's
`onLoad` method`.

In cases where you're done with background music but still want to keep the application/game
running, use the `dispose` function to remove the observer.

```dart
FlameAudio.bgm.dispose();
```

To play a looping background music track, run:

```dart
import 'package:flame_audio/flame_audio.dart';

FlameAudio.bgm.play('adventure-track.mp3');
```

**Note:** The `Bgm` class will always use the static instance of `FlameAudio` for storing cached
music files.

You must have an appropriate folder structure and add the files to the `pubspec.yaml` file, as
explained in [Flame Audio documentation](audio.md).

## Caching music files

The following functions can be used to preload (and unload) music files into the cache. These
functions are just aliases for the ones in `FlameAudio` with the same names.

Again, please refer to the [Flame Audio documentation](audio.md) if you need more info.

```dart
import 'package:flame_audio/flame_audio.dart';

FlameAudio.bgm.load('adventure-track.mp3');
FlameAudio.bgm.loadAll([
  'menu.mp3',
  'dungeon.mp3',
]);
FlameAudio.bgm.clear('adventure-track.mp3');
FlameAudio.bgm.clearCache();
```

## Methods

### Play

The `play` function takes in a `String` that should be a path that points to the location of the
music file to be played (following the Flame Audio folder structure requirements).

You can pass an additional optional `double` parameter which is the `volume` (defaults to `1.0`).

Examples:

```dart
FlameAudio.bgm.play('bgm/boss-fight/level-382.mp3');
```

```dart
FlameAudio.bgm.play('bgm/world-map.mp3', volume: .25);
```

### Stop

To stop a currently playing background music track, just call `stop`.

```dart
FlameAudio.bgm.stop();
```

### Pause and Resume

To manually pause and resume background music you can use the `pause` and `resume` functions.

`FlameAudio.bgm` automatically handles pausing and resuming the currently playing background music
track. Manually `pausing` prevents the app/game from auto-resuming when focus is given back to the
app/game.

```dart
FlameAudio.bgm.pause();
```

```dart
FlameAudio.bgm.resume();
```
