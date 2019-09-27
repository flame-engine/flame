# Looping Background Music

To play a looping background music track, run:

```dart
import 'package:flame/flame.dart';

Flame.bgm.play('adventure-track.mp3');
```

Or, if you prefer:

```dart
import 'package:flame/bgm.dart';

Bgm audio = Bgm();
audio.play('adventure-track.mp3');
```

**Note:** The `Bgm` class will always use the static instance of `FlameAudio` in `Flame.audio` for storing cached music files.

You must have an appropriate folder structure and add the files to the `pubspec.yaml` file, as explained in [Flame Audio documentation](audio.md).

The following functions can be used to preload (and unload) music files into the cache. These functions are just aliases for the ones in `Flame.audio` with the same names.

Again, please refer to the [Flame Audio documentation](audio.md) if you need more info.

```dart
Flame.audio.load('adventure-track.mp3');
Flame.audio.loadAll([
  'menu.mp3',
  'dungeon.mp3',
]);
Flame.audio.clear('adventure-track.mp3');
Flame.bgm.clearAll();
```

## Methods

### Play

Both on `play` and `loop` you can pass an additional optional double parameter, the `volume` (defaults to `1.0`).

### Stop

### Resume

### Pause
