# Images

If you are using the Component module and doing something simple, you probably won't need to use these classes; use `SpriteComponent` or `AnimationComponent` instead.

You must have an appropriate folder structure and add the files to the `pubspec.yaml` file, like this:

```yaml
flutter:
  assets:
    - assets/images/player.png
    - assets/images/enemy.png
```

It has to be a PNG file and it can have transparency.

## Sprite

Flame offers a `Sprite` class that represents a piece of an image (or the whole).

You can create a `Sprite` giving it a pre-loaded `Image` via the `fromImage` constructor, or you can use the nameless constructor to pass a file name and have the image loaded asynchronously.

For example, this will create a sprite representing the whole image of the file passed, automatically triggering its loading:

```dart
    Sprite player = Sprite('player.png');
```

You could also specify the coordinates in the original image where the sprite is located. This allows you to use sprite sheets and reduce the number of images in memory, for example:

```dart
    Sprite playerFrame = Sprite('player.png', x = 32.0, width = 16.0);
```

The default values are `0.0` for `x` and `y` and `null` for `width` and `height` (meaning it will use the full width/height of the source image).

The `Sprite` class has a `loaded` method that returns whether the image has been loaded, and a render method, that allows you to render the image onto a `Canvas`:

```dart
    Sprite block = Sprite('block.png');

    // in your render method
    block.render(canvas, 16.0, 16.0); //canvas, width, height
```

You must pass the size to the render method, and the image will be resized accordingly.

The render method will do nothing while the sprite has not been loaded, so you don't need to worry. The image is cached in the `Images` class, so you can safely create many sprites with the same filename.

All render methods from the Sprite class can receive a `Paint` instance as the optional named parameter `overridePaint` that parameter will override the current `Sprite` paint instance for that render call.

Sprites can also be used as widgets, to do so just use `Flame.util.spriteAsWidget`

A complete example using sprite as widgets can be found [here](/doc/examples/animation_widget).

## SpriteBatch

If you have a sprite sheet (also called an image atlas, which is an image with smaller images inside), and would like to render it effectively - `SpriteBatch` does the job.

Give it the filename of the image, and then add rectangles which describes various part of the image, in addition to transforms (position, scale and rotation) and optional colors.

You render it with a `Canvas` and an optional `Paint`, `BlendMode` and `CullRect`.

A `SpriteBatchComponent` is also available for your convenience.

See example [here](/doc/examples/sprite_batch).

## Svg

Flame provides a simple API to render SVG images in your game.

Svg support is provided by the `flame_svg` external package, be sure to put it on your pubspec to use it

To use it just import the `Svg` class from `'package:flame_svg/flame_svg.dart'`, and use the following snippet to render it on the canvas:

```dart
    Svg svgInstance = Svg('android.svg');

    final position = Position(100, 100);
    final width = 300;
    final height = 300;

    svgInstance.renderPosition(canvas, position, width, height);
```

## Flame.images

The `Flame.images` is a lower level utility for loading images, very similar to the `Flame.audio` instance.

Flutter has a collection of types related to images, and converting everything properly from a local asset to the Image that can be drawn on Canvas is a bit of a pain. This class allows you to obtain an Image that can be drawn on a Canvas using the `drawImageRect` method.

It automatically caches any image loaded by filename, so you can safely call it many times.

To load and draw an image, you can use the `load` method, like this:

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

The Animation class helps you create a cyclic animation of sprites.

You can create it by passing a list of equally sized sprites and the stepTime (that is, how many seconds it takes to move to the next frame):

```dart
  Animation a = Animation.spriteList(sprites, stepTime: 0.02);
```

After the animation is created, you need to call its `update` method and render the current frame's sprite on your game instance, for example:

```dart
class MyGame extends Game {
  Animation a;

  MyGame() {
    a = Animation(...);
  }

  void update(double dt) {
    a.update(dt);
  }

  void render(Canvas c) {
    a.getSprite().render(c);
  }
}
```

A better alternative to generate a list of sprites is to use the `sequenced` constructor:

```dart
  const amountOfFrames = 8;
  Animation a = Animation.sequenced('player.png', amountOfFrames, textureWidth: 16.0);
```

In which you pass the file name, the number of frames and the sprite sheet is automatically split for you according to the 4 optional parameters:

* textureX : x position on the original image to start (defaults to 0)
* textureY : y position on the original image to start (defaults to 0)
* textureWidth : width of each frame (defaults to null, that is, full width of the sprite sheet)
* textureHeight : height of each frame (defaults to null, that is, full height of the sprite sheet)
* destroyOnFinish : a bool indicating if this AnimationComponent should be destroyed when the animation has reached its end

So, in our example, we are saying that we have 8 frames for our player animation, and they are displayed in a row. So if the player height is also 16 pixels, the sprite sheet is 128x16, containing 8 16x16 frames.

This constructor makes creating an Animation very easy using sprite sheets.

If you use Aseprite for your animations, Flame does provide some support for Aseprite animation's JSON data. To use this feature you will need to export the Sprite Sheet's JSON data, and use something like the following snippet:

```dart
    Animation animation = await Animation.fromAsepriteData(
      "chopper.png", // Sprite Sheet image path
      "./assets/chopper.json" // Sprite Sheet animation JSON data
    );
```

_Note: trimmed sprite sheets are not supported by flame, so if you export your sprite sheet this way, it will have the trimmed size, not the sprite original size._

Animations, after created, have an update and render method; the latter renders the current frame, and the former ticks the internal clock to update the frames.

Animations are normally used inside `AnimationComponent`s, but custom components with several Animations can be created as well.


Animations can also be used as widgets, to do so, just use `Flame.util.animationAsWidget`

A complete example of using animations as widgets can be found [here](/doc/examples/animation_widget).

## FlareAnimation

Flame provides a simple wrapper of [Flare](https://rive.app/#LearnMore) animations so you can use them in Flame games.

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

FlareAnimations are normally used inside `FlareComponent`s, that way `BaseGame` will handle calling `render` and `update` automatically.
You can see a full example of the SpriteSheet class [here](/doc/examples/flare).

## SpriteSheet

Sprite sheets are big images with several frames of the same sprite on it and is a very good way to organize and keep your animations stored. Flame provides a very simple utility class to deal with SpriteSheets, with it you can load your sprite sheet image and extract animations from it. Below is a very simple example of how to use it:

```dart
import 'package:flame/spritesheet.dart';

final spritesheet = SpriteSheet(
  imageName: 'spritesheet.png',
  textureWidth: 16,
  textureHeight: 16,
  columns: 10,
  rows: 2,
);

final animation = spritesheet.createAnimation(0, stepTime: 0.1);
```

Now you can use the animation directly or use it in an animation component.

You can also get a single frame of the sprite sheet using the `getSprite` method:

```dart
spritesheet.getSprite(0, 0) // row, column;
```

You can see a full example of the SpriteSheet class [here](/doc/examples/spritesheet).
