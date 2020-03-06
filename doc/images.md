# Images, Sprites, and Animations

These are the base image-related classes that can be used either on their own, or as part of a [component](doc/components.md) in the component system of [`BaseGame`](/README.md#game-loop).

You must have an appropriate folder structure and add all image files to the `pubspec.yaml` file (as explained in the [README](/README.md#structure).

## Image

The [`Image` class](https://api.flutter.dev/flutter/dart-ui/Image-class.html) that Flame uses comes from the [`dart:ui` library](https://api.flutter.dev/flutter/dart-ui/dart-ui-library.html):

```dart
import 'dart:ui';
```

It must be a PNG file. It can have transparency.

You can pre-load your images up front and avoid delays with the `load()` or `loadAll()` methods:

```dart
// in an async prepare function for your game
await Flame.images.loadAll(['player.png', 'enemy.png']);
```

To render an `Image` on the `Canvas`, it needs to be used in a `Sprite` or `Animation` as shown below.

## Sprite

The `Sprite` class represents a single piece of an image (or the whole image). There multiple constructors for creating a `Sprite`, depending on the source:

* `Sprite()` (same as `Sprite.fromImage()`) creates a `Sprite` from a cached `Image` object
* `Sprite.fromImage()` creates a `Sprite` from a cached `Image` object **(best practice)**
* `Sprite.fromImageCache()` creates a `Sprite` from a cached image object by file name
* `Sprite.fromFile()` (an async method) creates a `Sprite` from an image file (cached or not)

For example, this will create a sprite representing the whole image of the file passed, automatically triggering its loading:

```dart
Sprite player = await Sprite.fromFile('player.png');
```

You can also specify the coordinates in the original image where the sprite is located; this allows you to use sprite sheets and reduce the number of images in memory; for example:

```dart
Sprite playerFrame = Sprite.fromImage(playerSheet, x: 32, width: 16);
```

`Sprite` optional named parameters:

* `x:` x position in the image to start clipping from (defaults to 0)
* `y:` y position in the image to start clipping from (defaults to 0)
* `width:` width of each frame (defaults to null, that is, full width of the image)
* `height:` height of each frame (defaults to null, that is, full height of the image)

The `Sprite` class has a `loaded()` method that returns whether the image has been loaded, and a render method that allows you to render the image into a `Canvas`:

```dart
Sprite block = await Sprite.fromFile('block.png');

// in your render method
block.render(canvas, width: 16.0, height: 16.0);
```

You can optionally pass a new size to the render method, and the image will be resized accordingly.

The render method will do nothing while the sprite has not been loaded, so you don't need to worry. The image is cached in the `Images` class, so you can safely create many sprites with the same fileName.

All render methods from the Sprite class can receive a `Paint` instance on the optional named parameter `overridePaint` that parameter will override the current `Sprite` paint instance for that render call.

Sprites can also be used as widgets, to do so, just use `Flame.util.spriteAsWidget`

A complete example of using sprite as widgets can be found [here](examples/animation_widget).

## Svg

Flame provides a simple API to render SVG images on your game.

To use it just import the `Svg` class from `'package:flame/svg.dart'`, and use the following snippet to render it on the canvas:

```dart
Svg svgInstance = Svg('android.svg');

final position = Position(100, 100);
final width = 300;
final height = 300;

svgInstance.renderPosition(canvas, position, width, height);
```

## Flame.images

The `Flame.images` is a lower level utility for loading images, very similar to the `Flame.audio` instance.

Flutter has a collection of types related to images, and converting everything properly from a local asset to the Image that can be drawn on Canvas is a small pain. This class allows you to obtain an Image that can be drawn on a Canvas using the `drawImageRect` method.

It automatically caches any image loaded by filename, so you can safely call it many times.

To load and draw an image, you can use the `load()` method, like so:

```dart
import 'package:flame/flame.dart';

// inside an async context
Image image = await Flame.images.load('player.png');

// or
Flame.images.load('player.png').then((Image image) {
  var paint = Paint()..color = Color(0xffffffff);
  var rect = Rect.fromLTWH(0.0, 0.0, image.width.toDouble(), image.height.toDouble());
  canvas.drawImageRect(image, rect, rect, paint);
});
```

The methods for loading and clearing the cache are identical to the Audio ones: `load`, `loadAll`, `clear` and `clearAll`. They return a `Future` for the Image loaded.

Also similarly to Audio, you can instantiate your own copy of `Images` (each instance shares a different cache):

```dart
Image image = await new Images().load('asd');
```

## Animation

The `Animation` class helps you create a cyclic animation of sprites. There multiple constructors for creating an `Animation`, depending on the source:

* `Animation()` creates an `Animation` from a List of `Frame`s **(not common use)**
* `Animation.fromSpriteList()` creates an `Animation` from a List of `Sprite`s
* `Animation.fromImage()` creates an `Animation` from a cached sprite sheet `Image` **(best practice)**
* `Animation.fromImageCache()` creates an `Animation` from a cached sprite sheet by file name
* `Animation.fromFile()` (an async method) creates an `Animation` from a sprite sheet file (cached or not)
* `Animation.fromAsepriteData()` (an async method) creates an `Animation` from [Aseprite](https://github.com/aseprite/aseprite) PNG and JSON file pairs

An important parameter in animation construction is the `stepTime` value (or the `stepTimes[]` List). `stepTime` is how many seconds to show each frame. The `stepTimes[]` List allows for variable timing across the frames of the animation. The default `stepTime` is `0.1` seconds. The `stepTimes[]` List, if given, overrides the `stepTime` value, if given.

```dart
Image image = Flame.images.fromCache('spritesheet.png');
int frameCount = 8;
int frameWidth = image.width ~/ frameCount;
int frameHeight = image.height;

Animation a = Animation.fromImage(
  image,
  stepTime:    0.02,
  frameCount:  8,
  frameWidth:  frameWidth,
  frameHeight: frameHeight,
);
```

`Animation` optional named parameters (depending on constructor used):

* `frameX:` x position in the image to start slicing from (defaults to 0)
* `frameY:` y position in the image to start slicing from (defaults to 0)
* `frameWidth:` width of each frame (defaults to null, that is, full width of the sprite sheet)
* `frameHeight:` height of each frame (defaults to null, that is, full height of the sprite sheet)
* `firstFrame:` which frame in the sprite sheet starts this animation (zero based, defaults to 0)
* `frameCount:` how many sprites this animation is composed of (defaults to 1)
* `stepTime:` the duration of each frame, in seconds (defaults to 0.1)
* `stepTimes:` list of stepTime values, one for each frame (overrides stepTime if given)
* `reverse:` reverses the animation frames if set to true (defaults to false)
* `loop:` whether the animation loops (defaults to true)
* `paused:` returns the animation in a paused state (default to false)

After the animation is created, call its `update()` method to tick its internal clock, then `render()` the current frame's sprite on your game instance. For example:

```dart
class MyGame extends Game {
  Animation a;

  MyGame() {
    a = Animation(...);
  }

  void update(double t) {
    a.update(t);
  }

  void render(Canvas c) {
    a.getCurrentSprite().render(c);
  }
}
```

If you use Aseprite for your animations, Flame does provide some support for Aseprite animation's JSON data, to use this feature, you will need to export the Sprite Sheet's JSON data, and use something like the following snippet:

```dart
Animation animation = await Animation.fromAsepriteData(
  "chopper.png", // Sprite Sheet image path
  "./assets/chopper.json" // Sprite Sheet animation JSON data
);
```

_Note: Flame does not yet support reading of trimmed-sprite-sheet data (that is, data about tightly-packed frames of different sizes and/or rotations) such as sprites in TPS files._

Animations can also be used as widgets, to do so, just use `Flame.util.animationAsWidget`

A complete example of using animations as widgets can be found [here](/doc/examples/animation_widget).

## FlareAnimation

Flame provides a simple wrapper of [Flare](https://www.2dimensions.com/about-flare) animations so you can use them on Flame games.

Check the following snippet on how to use this wrapper:

```dart
class MyGame extends Game {
  FlareAnimation flareAnimation;
  bool loaded = false;

  MyGame() {
    _start();
  }

  void _start() async {
    flareAnimation = await FlareAnimation.load("assets/FLARE_FILE.flr");
    flareAnimation.updateAnimation("ANIMATION_NAME");

    flareAnimation.width = 306;
    flareAnimation.height = 228;

    loaded = true;
  }

  @override
  void render(Canvas canvas) {
    if (loaded) {
      flareAnimation.render(canvas, x: 50, y: 50);
    }
  }

  @override
  void update(double dt) {
    if (loaded) {
      flareAnimation.update(dt);
    }
  }
}
```

You can see a full example of the Flare class [here](/doc/examples/flare).
