# Util

On this page you can find documentation for some deviceities classes and methods.

## Device Class

This class, accessible via `Flame.device`, has some functions that can be used to control the state of the device, like changing the screen orientation for example.

### `Flame.device.fullScreen()`

When called, this disables all `SystemUiOverlay` making the app full screen.
When called in the main method, makes your app full screen (no top nor bottom bars)

_Has no effect when called on web._

### `Flame.device.setLandscape()`

This method sets the orientation of the whole application (effectively, also the game) to landscape and depending on operating system and device setting, should allow both left and right landscape orientations. To set the app orientation to landscape on a specific direction, use either `Flame.device.setLandscapeLeftOnly` or `Flame.device.setLandscapeRightOnly`.

_Has no effect when called on web._

### `Flame.device.setPortrait()`

This method sets the orientation of the whole application (effectively, also the game) to portrait and depending on operating system and device setting, should allow both up and down landscape orientations. To set the app orientation to portrait on a specific direction, use either `Flame.device.setPortraitUpOnly` or `Flame.device.setPortraitDownOnly`.

_Has no effect when called on web._

### `Flame.device.setOrientation()` and `Flame.device.setOrientations()`

If a finer control of the allowed orientations is required (without having to deal with `SystemChrome` directly), `setOrientation` (accepts a single `DeviceOrientation` as a parameter) and `setOrientations` (accepts a `List<DeviceOrientation>` for possible orientations) can be used.

_Has no effect when called on web._
 
## Timer

Flame provides a simple deviceity class to help you handle countdowns and event like events.

__Countdown example:__

```dart
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/text_config.dart';
import 'package:flame/timer.dart';
import 'package:flame/vector2.dart';

class MyGame extends Game {
  final TextConfig textConfig = TextConfig(color: const Color(0xFFFFFFFF));
  final countdown = Timer(2);

  MyGame() {
    countdown.start();
  }

  @override
  void update(double dt) {
    countdown.update(dt);
    if (countdown.finished) {
      // Prefer the timer callback, but this is better in some cases
    }
  }

  @override
  void render(Canvas canvas) {
    textConfig.render(
      canvas,
      "Countdown: ${countdown.current.toString()}",
      Vector2(10, 100),
    );
  }
}

```

__Interval example:__

```dart
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/text_config.dart';
import 'package:flame/timer.dart';
import 'package:flame/vector2.dart';

class MyGame extends Game {
  final TextConfig textConfig = TextConfig(color: const Color(0xFFFFFFFF));
  Timer interval;

  int elapsedSecs = 0;

  MyGame() {
    interval = Timer(
      1,
      callback: () => elapsedSecs += 1,
      repeat: true,
    );
    interval.start();
  }

  @override
  void update(double dt) {
    interval.update(dt);
  }

  @override
  void render(Canvas canvas) {
    textConfig.render(canvas, "Elapsed time: $elapsedSecs", Vector2(10, 150));
  }
}

```

Timer instances can also be used inside a `BaseGame` game by using the `TimerComponent` class.

__Timer Component__

```dart
import 'package:flame/timer.dart';
import 'package:flame/components/timer_component.dart';
import 'package:flame/game.dart';

class MyBaseGame extends BaseGame {
  MyBaseGame() {
    add(
      TimerComponent(
        Timer(
          10,
          callback: () => print("10 seconds elapsed"),
          repeat: true,
        )
        ..start()
      )
    );
  }
}
```

## Extensions

Flame bundles a collection of deviceity extensions, these extensions are meant to help the developer with shortcuts and converion methods, here you can find the summary of those extensions

They can all be imported on `package:flame/extensions/...`

### Canvas

Methods:
 - `scaleVector`: Just like `canvas scale` method, but takes a `Vector2` as an argument.
 - `translateVector`: Just like `canvas translate` method, but takes a `Vector2` as an argument.
 - `rendereAt` and `renderRotated`: if you are directly rendering to the `Canvas`, you can use these functions to easily manipulate coordinates to render things on the correct places. They change the `Canvas` transformation matrix but reset afterwards.
