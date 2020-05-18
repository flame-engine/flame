# Util

Some stuff just doesn't fit anywhere else.

## Position

Throughout the variety of modules needed to build a game, Dart and Flutter have a few different classes to handle the concept of a 2D double point; specially common in the APIs are math.Point and ui.Offset.

The Position class is an utility class that helps by allowing easy conversions to and from these type.

It also differs from the default implementations provided (math.Point and ui.Offset) as it's mutable and offers some useful methods for manipulation.

## Util Class

This class, accessible via `Flame.util`, has some sparse functions that are independent and good to have.

It is recommended that the functions in this class be called via the `Flame.util` getter to utilize a single instance prepared by the Flame engine.

### `Flame.util.fullScreen()`

When called, this disables all `SystemUiOverlay` making the app full screen.
When called in the main method, makes your app full screen (no top nor bottom bars)

### `Flame.util.setLandscape()`

This method sets the orientation of the whole application (effectively, also the game) to landscape and depending on operating system and device setting, should allow both left and right landscape orientations. To set the app orientation to landscape on a specific direction, use either `Flame.util.setLandscapeLeftOnly` or `Flame.util.setLandscapeRightOnly`.

### `Flame.util.setPortrait()`

This method sets the orientation of the whole application (effectively, also the game) to portrait and depending on operating system and device setting, should allow both up and down landscape orientations. To set the app orientation to portrait on a specific direction, use either `Flame.util.setPortraitUpOnly` or `Flame.util.setPortraitDownOnly`.

### `Flame.util.setOrientation()` and `Flame.util.setOrientations()`

If a finer control of the allowed orientations is required (without having to deal with `SystemChrome` directly), `setOrientation` (accepts a single `DeviceOrientation` as a parameter) and `setOrientations` (accepts a `List<DeviceOrientation>` for possible orientations) can be used.

### `Flame.util.initialDimensions()`

Returns a `Future` with the dimension (`Size`) of the screen. This has to be done in a hacky way because of the reasons described in the code. If you are using `BaseGame`, you probably won't need to use these, as every `Component` will receive this information.

**Note**: Call this function first thing in an `async`hronous `main` and `await` its value to avoid the "size bug" that affects certain devices when building for production.

### `Flame.util.addGestureRecognizer()` and `Flame.util.removeGestureRecognizer()`

These two functions help with registering (and de-registering) gesture recognizers so that the game can accept input. More about these two functions [here](/doc/input.md#Input).

### Other functions

* `text`: discussed [here](/doc/text.md)
* `drawWhere`: a very simple function that manually applies an offset to the `Canvas`, render stuff given via a function and then reset the `Canvas`, without using the `Canvas`' built-in `save`/`restore` functionality. This might be useful because `BaseGame` uses the state of the canvas, and you should not mess with it.
 
## Timer

Flame provides a simple utility class to help you handle countdowns and event like events.

__Countdown example:__

```dart
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flame/time.dart';

class MyGame extends Game {
  final TextConfig textConfig = TextConfig(color: const Color(0xFFFFFFFF));
  final countdown = Timer(2);

  MyGame() {
    countdown.start();
  }

  @override
  void update(double dt) {
    countdown.update(dt);
    if (countdown.isFinished()) {
      // do something ...
    }
  }

  @override
  void render(Canvas canvas) {
    textConfig.render(canvas, "Countdown: ${countdown.current.toString()}",
        Position(10, 100));
  }
}

```

__Interval example:__

```dart
import 'dart:ui';

import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/text_config.dart';
import 'package:flame/time.dart';

class MyGame extends Game {
  final TextConfig textConfig = TextConfig(color: const Color(0xFFFFFFFF));
  Timer interval;

  int elapsedSecs = 0;

  MyGame() {
    interval = Timer(1, repeat: true, callback: () {
      elapsedSecs += 1;
    });
    interval.start();
  }

  @override
  void update(double dt) {
    interval.update(dt);
  }

  @override
  void render(Canvas canvas) {
    textConfig.render(canvas, "Elapsed time: $elapsedSecs", Position(10, 150));
  }
}

```

Timer instances can also be used inside a `BaseGame` game by using the `TimerComponent` class.

__Timer Component__

```dart
import 'package:flame/time.dart';
import 'package:flame/components/timer_component.dart';
import 'package:flame/game.dart';

class MyBaseGame extends BaseGame {
  MyBaseGame() {
    add(
      TimerComponent(
        Timer(10, repeat: true, callback: () {
          print("10 seconds elapsed");
        })
        ..start()
      )
    );
  }
}
```
