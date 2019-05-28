# Images

If you are using the Component module and doing something simple, you probably won't need to use these classes; use `SpriteComponent` or `AnimationComponent` instead.

You must have an appropriate folder structure and add the files to the `pubspec.yaml` file, as explained above.

It has to be a PNG file. It can have transparency.

## Sprite

Flame offers a `Sprite` class that represents a piece of an image (or the whole).

You can create a `Sprite` giving it a pre-loaded `Image` via the `fromImage` constructor, or you can use the nameless constructor to pass a file name and have the image loaded asynchronously.

For example, this will create a sprite representing the whole image of the file passed, automatically triggering its loading:

```dart
    Sprite player = new Sprite('player.png');
```

You could also specify the coordinates in the original image where the sprite is located; this allows you to use sprite sheets and reduce the number of images in memory; for example:

```dart
    Sprite playerFrame = new Sprite('player.png', x = 32.0, width = 16.0);
```

The default values are `0.0` for `x` and `y` and `null` for `width` and `height` (meaning it will use the full width/height of the source image).

The `Sprite` class has a `loaded` method that returns whether the image has been loaded, and a render method, that allows you to render the image into a `Canvas`:

```dart
    Sprite block = new Sprite('block.png');

    // in your render method
    block.render(canvas, 16.0, 16.0); //canvas, width, height
```

You must pass the size to the render method, and the image will be resized accordingly.

The render method will do nothing while the sprite has not been loaded, so you don't need to worry. The image is cached in the `Images` class, so you can safely create many sprites with the same fileName.

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

Flutter has a collection of types related to images, and converting everything properly form a local asset to the Image that can be drawn on Canvas is a small pain. This class allows you to obtain an Image that can be drawn on a Canvas using the `drawImageRect` method.

It automatically caches any image loaded by filename, so you can safely call it many times.

To load and draw an image, you can use the `load` method, like so:

```dart
    import 'package:flame/flame.dart';

    // inside an async context
    Image image = await Flame.images.load('player.png');
    
    // or
    Flame.images.load('player.png').then((Image image) {
      var paint = new Paint()..color = new Color(0xffffffff);
      var rect = new Rect.fromLTWH(0.0, 0.0, image.width.toDouble(), image.height.toDouble());
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

You can create it by passing a list of equal sized sprites and the stepTime (that is, how many seconds it takes to move to the next frame):

```dart
  Animation a = new Animation.spriteList(sprites, stepTime: 0.02);
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

So, in our example, we are saying that we have 8 frames for our player animation, and they are displayed in a row. So if the player height is also 16 pixels, the sprite sheet is 128x16, containing 8 16x16 frames.

This constructor makes creating an Animation very easy using sprite sheets.

If you use Aseprite for your animations, Flame does provide some support for Aseprite animation's JSON data, to use this feature, you will need to export the Sprite Sheet's JSON data, and use something like the following snippet:

```dart
    Animation animation = await Animation.fromAsepriteData(
      "chopper.png", // Sprite Sheet image path
      "./assets/chopper.json" // Sprite Sheet animation JSON data
    );
```

_Note: trimmed sprite sheets are not supported by flame, so if you export your sprite sheet this way, it will have the trimmed size, not the sprite original size._

Animations, after created, have an update and render method; the latter renders the current frame, and the former ticks the internal clock to update the frames.

Animations are normally used inside `AnimationComponent`s, but custom components with several Animations can be created as well.

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

    flareAnimation.x = 50;
    flareAnimation.y = 50;

    flareAnimation.width = 306;
    flareAnimation.height = 228;

    loaded = true;
  }

  @override
  void render(Canvas canvas) {

    if (loaded) {
      flareAnimation.render(canvas);
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
