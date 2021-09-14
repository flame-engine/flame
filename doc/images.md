# Images

To start off you must have an appropriate folder structure and add the files to the `pubspec.yaml`
file, like this:

```yaml
flutter:
  assets:
    - assets/images/player.png
    - assets/images/enemy.png
```

It has to be png files and they can have transparency.

## Loading images

Flame bundles an utility class called `Images` that allows you to easily load and cache images from
the assets directory into memory.

Flutter has a handful of types related to images, and converting everything properly from a local
asset to an `Image` that can be drawn on Canvas is a bit convoluted. This class allows you to obtain
an `Image` that can be drawn on the `Canvas` using the `drawImageRect` method.

It automatically caches any image loaded by filename, so you can safely call it many times.

The methods for loading and clearing the cache are: `load`, `loadAll`, `clear` and `clearCache`.
They return a `Future` for the loaded Image.

To synchronously retrieve a previously cached image, the `fromCache` method can be used. If an image
with that key was not previously loaded, it will throw an exception.

### Standalone usage

It can manually be used by instantiating it:

```dart
import 'package:flame/images.dart';
final imagesLoader = Images();
Image image = await imagesLoader.load('yourImage.png');
```

But Flame also offers two ways of using this class without instantiating it yourself.

### Flame.images

There is a singleton, provided by the `Flame` class, that can be used as a global image cache.

Example:

```dart
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

// inside an async context
Image image = await Flame.images.load('player.png');

final playerSprite = Sprite(image);
```

### Game.images

The `Game` class offers some utility methods for handling images loading too. It bundles an instance
of the `Images` class, that can be used to load image assets to be used during the game. The game
will automatically free the cache when the game widget is removed from the widget tree.

The `onLoad` method from the `Game` class is a great place for the initial assets to be loaded.

Example:

```dart
class MyGame extends Game {

  Sprite player;

  @override
  Future<void> onLoad() async {
    final playerImage = await images.load('player.png'); // Note that you could also use Sprite.load for this
    player = Sprite(playerImage);
  }
}
```

Loaded assets can also be retrieved while the game is running by `images.fromCache`, for example:

```dart
class MyGame extends Game {

  // attributes omitted

  @override
  Future<void> onLoad() async {
    // other loads omitted
    await images.load('bullet.png');
  }

  void shoot() {
    // This is just an example, in your game you probably don't want to instantiate new [Sprite]
    // objects every time you shoot.
    final bulletSprite = Sprite(images.fromCache('bullet.png'));
    _bullets.add(bulletSprite);
  }
}
```

## Sprite

Flame offers a `Sprite` class that represents an image, or a region of an image.

You can create a `Sprite` by providing it an `Image` and coordinates that defines the piece of the
image that that sprite represents.

For example, this will create a sprite representing the whole image of the file passed:

```dart
final image = await images.load('player.png');
Sprite player = Sprite(image);
```

You can also specify the coordinates in the original image where the sprite is located. This allows
you to use sprite sheets and reduce the number of images in memory, for example:

```dart
final image = await images.load('player.png');
final playerFrame = Sprite(
  image,
  srcPosition: Vector2(32.0, 0),
  srcSize: Vector2(16.0, 16.0),
);
```

The default values are `(0.0, 0.0)` for `srcPosition` and `null` for `srcSize` (meaning it will use
the full width/height of the source image).

The `Sprite` class has a render method, that allows you to render the sprite onto a `Canvas`:

```dart
final image = await images.load('block.png');
Sprite block = Sprite(image);

// in your render method
block.render(canvas, 16.0, 16.0); //canvas, width, height
```

You must pass the size to the render method, and the image will be resized accordingly.

All render methods from the `Sprite` class can receive a `Paint` instance as the optional named
parameter `overridePaint` that parameter will override the current `Sprite` paint instance for that
render call.

`Sprite`s can also be used as widgets, to do so just use `SpriteWidget` class.

A complete example using sprite as widgets can be found
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/widget/sprite_widget.dart).

## SpriteBatch

If you have a sprite sheet (also called an image atlas, which is an image with smaller images
inside), and would like to render it effectively - `SpriteBatch` handles that job for you.

Give it the filename of the image, and then add rectangles which describes various part of the
image, in addition to transforms (position, scale and rotation) and optional colors.

You render it with a `Canvas` and an optional `Paint`, `BlendMode` and `CullRect`.

A `SpriteBatchComponent` is also available for your convenience.

See the examples
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/sprites/spritebatch.dart).

## ImageComposition

In some cases you may want to merge multiple images into a single image; this is called
[Compositing](https://en.wikipedia.org/wiki/Compositing). This can be useful for example when
working with the [SpriteBatch](#spritebatch) API to optimize your drawing calls.

For such usecases Flame comes with the `ImageComposition` class. This allows you to add multiple
images, each at their own position, onto a new image:

```dart
final composition = ImageComposition()
  ..add(image1, Vector2(0, 0))
  ..add(image2, Vector2(64, 0));
  ..add(image3,
    Vector2(128, 0),
    source: Rect.fromLTWH(32, 32, 64, 64),
  );

Image image = await composition.compose();
```

**Note:** Composing images is expensive, we do not recommend you run this every tick as it affect
the performance badly. Instead we recommend to have your compositions pre-rendered so you can just
reuse the output image.

## Svg

Flame provides a simple API to render SVG images in your game.

Svg support is provided by the `flame_svg` external package, be sure to put it in your pubspec file
to use it.

To use it just import the `Svg` class from `'package:flame_svg/flame_svg.dart'`, and use the
following snippet to render it on the canvas:

```dart
Svg svgInstance = Svg('android.svg');

final position = Vector2(100, 100);
final size = Vector2(300, 300);

svgInstance.renderPosition(canvas, position, size);
```

or use the [SvgComponent]:

```dart
class MyGame extends FlameGame {
    Future<void> onLoad() async {
      final svgInstance = await Svg.load('android.svg');
      final size = Vector2.all(100);
      final svgComponent = SvgComponent.fromSvg(size, svgInstance);
      svgComponent.x = 100;
      svgComponent.y = 100;

      add(svgComponent);
    }
}
```

## Animation

The Animation class helps you create a cyclic animation of sprites.

You can create it by passing a list of equally sized sprites and the stepTime (that is, how many
seconds it takes to move to the next frame):

```dart
final a = SpriteAnimation.spriteList(sprites, stepTime: 0.02);
```

After the animation is created, you need to call its `update` method and render the current frame's
sprite on your game instance.

Example:

```dart
class MyGame extends Game {
  SpriteAnimation a;

  MyGame() {
    a = SpriteAnimation(...);
  }

  void update(double dt) {
    a.update(dt);
  }

  void render(Canvas c) {
    a.getSprite().render(c);
  }
}
```

A better alternative to generate a list of sprites is to use the `fromFrameData` constructor:

```dart
const amountOfFrames = 8;
final a = SpriteAnimation.fromFrameData(
    imageInstance,
    SpriteAnimationFrame.sequenced(
      amount: amountOfFrames,
      textureSize: Vector2(16.0, 16.0),
      stepTime: 0.1,
    ),
);
```

This constructor makes creating an `Animation` very easy when using sprite sheets.

In the constructor you pass an image instance and the frame data, which contains some parameters
that can be used to describe the animation. Check the documentation on the constructors available on
the `SpriteAnimationFrameData` class to see all the parameters.

If you use Aseprite for your animations, Flame does provide some support for Aseprite animation's
JSON data. To use this feature you will need to export the Sprite Sheet's JSON data, and use
something like the following snippet:

```dart
final image = await images.load('chopper.png');
final jsonData = await assets.readJson('chopper.json');
final animation = SpriteAnimation.fromAsepriteData(image, jsonData);
```

**Note:** trimmed sprite sheets are not supported by flame, so if you export your sprite sheet this
kway, it will have the trimmed size, not the sprite original size.

Animations, after created, have an update and render method; the latter renders the current frame,
and the former ticks the internal clock to update the frames.

Animations are normally used inside `SpriteAnimationComponent`s, but custom components with several
Animations can be created as well.

A complete example of using animations as widgets can be found
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/widgets/sprite_animation_widget.dart).

## FlareAnimation

Flame provides a simple wrapper of [Flare](https://rive.app/#LearnMore) animations so you can use
them in Flame games.

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

FlareAnimations are normally used inside `FlareComponent`s, that way `FlameGame` will handle calling
`render` and `update` automatically.

You can see a full example of how to use Flare together with Flame in the example
[here](https://github.com/flame-engine/flame_flare/tree/main/example).

## SpriteSheet

Sprite sheets are big images with several frames of the same sprite on it and is a very good way to
organize and keep your animations stored. Flame provides a very simple utility class to deal with
SpriteSheets, with it you can load your sprite sheet image and extract animations from it. Below is
a very simple example of how to use it:

```dart
import 'package:flame/sprite.dart';

final spritesheet = SpriteSheet(
  image: imageInstance,
  srcSize: Vector2.all(16.0),
);

final animation = spritesheet.createAnimation(0, stepTime: 0.1);
```

Now you can use the animation directly or use it in an animation component.

You can also get a single frame of the sprite sheet using the `getSprite` method:

```dart
spritesheet.getSprite(0, 0) // row, column;
```

You can see a full example of the `SpriteSheet` class
[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/sprites/spritesheet.dart).

## `Flame.images.decodeImageFromPixels()`

The [dart-ui decodeImageFromPixels](https://api.flutter.dev/flutter/dart-ui/decodeImageFromPixels.html)
currently does not support the web platform. So if you are looking for a way to manipulate pixel
data on the web this method can be used as a replacement for `dart-ui decodeImageFromPixels`:

```dart
Image image = await Flame.images.decodeImageFromPixels(
  data, // A Uint8List containing pixel data in the RGBA format.
  200,
  200,
);
```
