# Util

On this page you can find documentation for some utility classes and methods.

## Device Class

This class can be accessed from `Flame.device` and it has some methods that can be used to control
the state of the device, for instance you can change the screen orientation and set whether the
application should be fullscreen or not.

### `Flame.device.fullScreen()`

When called, this disables all `SystemUiOverlay` making the app full screen.
When called in the main method, it makes your app full screen (no top nor bottom bars).

**Note:** It has no effect when called on the web.

### `Flame.device.setLandscape()`

This method sets the orientation of the whole application (effectively, also the game) to landscape
and depending on operating system and device setting, should allow both left and right landscape
orientations. To set the app orientation to landscape on a specific direction, use either
`Flame.device.setLandscapeLeftOnly` or `Flame.device.setLandscapeRightOnly`.

**Note:** It has no effect when called on the web.

### `Flame.device.setPortrait()`

This method sets the orientation of the whole application (effectively, also the game) to portrait
and depending on operating system and device setting, it should allow for both up and down portrait
orientations. To set the app orientation to portrait for a specific direction, use either
`Flame.device.setPortraitUpOnly` or `Flame.device.setPortraitDownOnly`.

**Note:** It has no effect when called on the web.

### `Flame.device.setOrientation()` and `Flame.device.setOrientations()`

If a finer control of the allowed orientations is required (without having to deal with
`SystemChrome` directly), `setOrientation` (accepts a single `DeviceOrientation` as a parameter) and
`setOrientations` (accepts a `List<DeviceOrientation>` for possible orientations) can be used.

**Note:** It has no effect when called on the web.

## Timer

Flame provides a simple utility class to help you handle countdowns and timer state changes like
events.

Countdown example:

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

Interval example:

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

`Timer` instances can also be used inside a `FlameGame` game by using the `TimerComponent` class.

`TimerComponent` example:

```dart
import 'package:flame/timer.dart';
import 'package:flame/components/timer_component.dart';
import 'package:flame/game.dart';

class MyFlameGame extends FlameGame {
  MyFlameGame() {
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

Flame bundles a collection of utility extensions, these extensions are meant to help the developer
with shortcuts and conversion methods, here you can find the summary of those extensions.

They can all be imported from `package:flame/extensions.dart`

### Canvas

Methods:
 - `scaleVector`: Just like `canvas scale` method, but takes a `Vector2` as an argument.
 - `translateVector`: Just like `canvas translate` method, but takes a `Vector2` as an argument.
 - `renderPoint`: renders a single point on the canvas (mostly for debugging purposes).
 - `renderAt` and `renderRotated`: if you are directly rendering to the `Canvas`, you can use these
  functions to easily manipulate coordinates to render things on the correct places. They change the
  `Canvas` transformation matrix but reset afterwards.

### Color

Methods:
 - `darken`: Darken the shade of the color by an amount between 0 to 1.
 - `brighten`: Brighten the shade of the color by an amount between 0 to 1.

Factories:
- `fromRGBHexString`: Parses an RGB color from a valid hex string (e.g. #1C1C1C).
- `fromARGBHexString`: Parses an ARGB color from a valid hex string (e.g. #FF1C1C1C).

### Image

Methods:
 - `pixelsInUint8`: Retrieves the pixel data as a `Uint8List`, in the `ImageByteFormat.rawRgba`
 pixel format, for the image.
 - `getBoundingRect`: Get the bounding rectangle of the `Image` as a `Rect`.
 - `size`: The size of an `Image` as `Vector2`.
 - `darken`: Darken each pixel of the `Image` by an amount between 0 to 1.
 - `brighten`: Brighten each pixel of the `Image` by an amount between 0 to 1.

### Offset

Methods;
 - `toVector2`; Creates an `Vector2` from the `Offset`.
 - `toSize`: Creates a `Size` from the `Offset`.
 - `toPoint`: Creates a `Point` from the `Offset`.
 - `toRect`: Creates a `Rect` starting in (0,0) and its bottom right corner is the [Offset].

### Rect

Methods:
 - `toOffset`: Creates an `Offset` from the `Rect`.
 - `toVector2`: Creates a `Vector2` starting in (0,0) and goes to the size of the `Rect`.
 - `containsPoint` Whether this `Rect` contains a `Vector2` point or not.
 - `intersectsSegment`; Whether the segment formed by two `Vector2`s intersects this `Rect`.
 - `intersectsLineSegment`: Whether the `LineSegment` intersects the `Rect`.
 - `toVertices`: Turns the four corners of the `Rect` into a list of `Vector2`.
 - `toMathRectangle`: Converts this `Rect` into a `math.Rectangle`.
 - `toGeometryRectangle`: Converts this `Rect` into a `Rectangle` from flame-geom.

### math.Rectangle

Methods:
 - `toRect`: Converts this math `Rectangle` into an ui `Rect`.

### Size

Methods:
 - `toVector2`; Creates an `Vector2` from the `Size`.
 - `toOffset`: Creates a `Offset` from the `Size`.
 - `toPoint`: Creates a `Point` from the `Size`.
 - `toRect`: Creates a `Rect` starting in (0,0) with the size of `Size`.

### Vector2

This class comes from the `vector_math` package and we have some useful extension methods on top of
what is offered by that package.

Methods:
 - `toOffset`: Creates a `Offset` from the `Vector2`.
 - `toPoint`: Creates a `Point` from the `Vector2`.
 - `toRect`: Creates a `Rect` starting in (0,0) with the size of `Vector2`.
 - `toPositionedRect`: Creates a `Rect` starting from [x, y] in the `Vector2` and has the size of
  the `Vector2` argument.
 - `lerp`: Linearly interpolates the `Vector2` towards another Vector2.
 - `rotate`: Rotates the `Vector2` with an angle specified in radians, it rotates around the
  optionally defined `Vector2`, otherwise around the center.
 - `scaleTo`: Changes the length of the `Vector2` to the length provided, without changing
  direction.
 - `moveToTarget`: Smoothly moves a Vector2 in the target direction by a given distance.

Factories:
 - `fromInts`: Create a `Vector2` with ints as input.

Operators:
 - `&`: Combines two `Vector2`s to form a Rect, the origin should be on the left and the size on the
  right.
 - `%`: Modulo/Remainder of x and y separately of two `Vector2`s.

### Matrix4

This class comes from the `vector_math` package. We have created a few extension methods on top
of what is already offered by `vector_math`.

Methods:
  - `translate2`: Translate the `Matrix4` by the given `Vector2`.
  - `transform2`: Create a new `Vector2` by transforming the given `Vector2` using the `Matrix4`.
  - `transformed2`: Transform the input `Vector2` into the output `Vector2`.

Getters:
  - `m11`: The first row and first column.
  - `m12`: The first row and second column.
  - `m13`: The first row and third column.
  - `m14`: The first row and fourth column.
  - `m21`: The second row and first column.
  - `m22`: The second row and second column.
  - `m23`: The second row and third column.
  - `m24`: The second row and fourth column.
  - `m31`: The third row and first column.
  - `m32`: The third row and second column.
  - `m33`: The third row and third column.
  - `m34`: The third row and fourth column.
  - `m41`: The fourth row and first column.
  - `m42`: The fourth row and second column.
  - `m43`: The fourth row and third column.
  - `m44`: The fourth row and fourth column.

Factories:
 - `scale`: Create a scaled `Matrix4`. Either by passing a `Vector4` or `Vector2` as it's first 
    argument, or by passing x y z doubles.
