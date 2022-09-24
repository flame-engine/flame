# Looping Background Music

With the `Bgm` class, you can manage looping of background music tracks with regards to application
(or game) lifecycle state changes.

When the application is terminated, or sent to background, `Bgm` will automatically pause
the currently playing music track. Similarly, when the application is resumed, `Bgm` will resume the
background music. Manually pausing and resuming your tracks is also supported.

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

You must have an appropriate folder structure and add the files to the `pubspec.yaml` file, as
explained in [Flame Audio documentation](audio.md).


## Caching music files

The `Bgm` class will use the static instance of `FlameAudio` for storing cached
music files by default.

So in order to pre-load music, you can use the same recommendations from the
[Flame Audio documentation](audio.md).

You can optionally create your own `Bgm` instances with different backing `AudioCache`s,
if you so desire.


## Methods


### Play

The `play` function takes in a `String` that should be a path that points to the location of the
music file to be played (following the Flame Audio folder structure requirements).

You can pass an additional optional `double` parameter which is the `volume` (defaults to `1.0`).

Examples:

```dart
FlameAudio.bgm.play('music/boss-fight/level-382.mp3');
```

```dart
FlameAudio.bgm.play('music/world-map.mp3', volume: .25);
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
