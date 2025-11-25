# Images

To start off you must have an appropriate folder structure and add the files to the `pubspec.yaml`
file, like this:

```yaml
flutter:
  assets:
    - assets/images/player.png
    - assets/images/enemy.png
```

Images can be in any format supported by Flutter, which include: JPEG, WebP, PNG, GIF, animated GIF,
animated WebP, BMP, and WBMP. Other formats would require additional libraries. For example, SVG
images can be loaded via the `flame_svg` library.


## Loading images

Flame bundles an utility class called `Images` that allows you to easily load and cache images from
the assets directory into memory.

Flutter has a handful of types related to images, and converting everything properly from a local
asset to an `Image` that can be drawn on Canvas is a bit convoluted. This class allows you to obtain
an `Image` that can be drawn on the `Canvas` using the `drawImageRect` method.

It automatically caches any image loaded by filename, so you can safely call it many times.

The methods for loading and clearing the cache are: `load`, `loadAll`, `clear` and `clearCache`.
They return `Future`s for loading the images. These futures must be awaited for before the images
can be used in any way. If you do not want to await these futures right away, you can initiate
multiple `load()` operations and then await for all of them at once using `Images.ready()` method.

To synchronously retrieve a previously cached image, the `fromCache` method can be used. If an image
with that key was not previously loaded, it will throw an exception.

To add an already loaded image to the cache, the `add` method can be used and you can set the key
that the image should have in the cache. You can retrieve all the keys in the cache using the `keys`
getter.

You can also use `ImageExtension.fromPixels()` to dynamically create an image during the game.

For `clear` and `clearCache`, do note that `dispose` is called for each removed image from the
cache, so make sure that you don't use the image afterwards.


### Standalone usage

It can manually be used by instantiating it:

```dart
import 'package:flame/cache.dart';
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
    // Note that you could also use Sprite.load for this.
    final playerImage = await images.load('player.png');
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
    // This is just an example, in your game you probably don't want to
    // instantiate new [Sprite] objects every time you shoot.
    final bulletSprite = Sprite(images.fromCache('bullet.png'));
    _bullets.add(bulletSprite);
  }
}
```


## Loading images over the network

The Flame core package doesn't offer a built in method to loading images from the network.

The reason for that is that Flutter/Dart does not have a built in http client, which requires
a package to be used and since there are a couple of packages available out there, we refrain
from forcing the user to use a specific package.

With that said, it is quite simple to load images from the network once a http client package
is chosen by the user. The following snippet shows how an `Image` can be fetched from the web
using the [http](https://pub.dev/packages/http) package.

```dart
import 'package:http/http.dart' as http;
import 'package:flutter/painting.dart';

final response = await http.get('https://url.com/image.png');
final image = await decodeImageFromList(response.bytes);
```

```{note}
Check [`flame_network_assets`](https://pub.dev/packages/flame_network_assets)
for a ready to use network assets solution that provides a built in cache.
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
Here is a complete
[example using sprite as widgets](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/widgets/sprite_widget_example.dart).


### Sprite Bleeding

In some cases when rendering sprites next to each other, when the edges of the sprites are touching,
you may see a rendering artifact called "ghost lines" between them.

This happens especially when the sprites are positioned in coordinates that are not whole numbers,
or when scaling is applied to the canvas.

Those lines appear because floating-point numbers aren't 100% accurate in computer science. Due
to rounding errors, even though the sprites are supposed to be touching, they are not rendered that
way.

One way to avoid this is to use a technique called "bleeding", which consists of adding a very small
margin to the edges of the sprites, so that when they are rendered, they will overlap a bit and thus
avoid rendering the ghost lines.

Flame provides a way to do this by using the `bleed` parameter in the `Sprite` render method. This
is a double value that represents the amount of bleeding to be applied to the edges of the sprite.

For example, if you do:

```dart
final image = await images.load('player.png');
final playerFrame = Sprite(
  image,
  srcPosition: Vector2(32.0, 0),
  srcSize: Vector2(16.0, 16.0),
);
playerFrame.render(canvas, 16.0, 16.0, bleed: 1.0);
```

The sprite will be rendered with a bleed amount of 1.0, meaning that it will have
a value of 1 pixels added to each edge of the sprite.

For users of the `SpriteComponent`, using the bleeding feature is also quite simple, it is just
a matter of passing a value to the `bleed` attribute in the component constructor:

```dart
final sprite = Sprite(...);

final spriteComponent = SpriteComponent(
  sprite: sprite,
  size: Vector2.all(16.0),
  bleed: 1.0, // bleed value
);
```

Note that the amount of the bleed value depends on the size of the sprite, so a bleed value of 1.0
might not make much difference for a sprite of 100x100.


### Sprite Rasterization

Rasterizing a sprite is the process of extracting the selected area of the image from that sprite,
storing it in memory, and returning a new Sprite that contains that rasterized image.

That can be used for a variety of reasons, one of the most useful ones is to avoid texture leaking
when using a sprite sheet.

Texture leaking can happen for the same reason as in the issue explained above (floating point
rounding errors), and it causes parts outside of a sprite selection to also be rendered.

Extracting the sprite selection and rasterizing it before rendering is a way to avoid this issue,
since it then renders an image that only contains the selected area.

Example of using a `RasterSpriteComponent`:

```dart
final sprite = await Sprite.load('flame.png');
final rasterSpriteComponent = RasterSpriteComponent(
  sprite: sprite,
  size: Vector2.all(16.0),
);
```

When using the `RasterSpriteComponent`, it will automatically rasterize the sprite when it is
loaded.

If you need to rasterize a sprite manually, you can use the `Sprite.rasterize` method:

```dart
final image = await images.load('player.png');
final playerFrame = Sprite(
  image,
  srcPosition: Vector2(32.0, 0),
  srcSize: Vector2(16.0, 16.0),
);

final rasterizedSprite = await playerFrame.rasterize();
```

By default, the `rasterize` method will use `Flame.images` to cache the rasterized image,
auto generating a key based on the sprite's source position and size. If you want to use a custom
key for the rasterized image, or use a different cache object, you can pass it as an optional
parameter:

```dart
final rasterizedSprite = await playerFrame.rasterize(
  cacheKey: 'custom_key_for_rasterized_image',
  images: Images(),
);
```


## SpriteBatch

If you have a sprite sheet (also called an image atlas, which is an image with smaller images
inside), and would like to render it effectively - `SpriteBatch` handles that job for you.

Give it the filename of the image, and then add rectangles which describes various part of the
image, in addition to transforms (position, scale and rotation) and optional colors.

You render it with a `Canvas` and an optional `Paint`, `BlendMode` and `CullRect`.

A `SpriteBatchComponent` is also available for your convenience.

See how to use it in the
[SpriteBatch examples](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/sprites/sprite_batch_example.dart)


## ImageComposition

In some cases you may want to merge multiple images into a single image; this is called
[Compositing](https://en.wikipedia.org/wiki/Compositing). This can be useful for example when
working with the [SpriteBatch](#spritebatch) API to optimize your drawing calls.

For such use cases Flame comes with the `ImageComposition` class. This allows you to add multiple
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
Image imageSync = composition.composeSync();
```

As you can see, two versions of composing image are available. Use `ImageComposition.compose()` for
the async approach. Or use the new `ImageComposition.composeSync()` function to rasterize the
image into GPU context using the benefits of the `Picture.toImageSync` function.

**Note:** Composing images is expensive, we do not recommend you run this every tick as it affect
the performance badly. Instead we recommend to have your compositions pre-rendered so you can just
reuse the output image.


## Animation

The Animation class helps you create a cyclic animation of sprites.

You can create it by passing a list of equally sized sprites and the stepTime (that is, how many
seconds it takes to move to the next frame):

```dart
final a = SpriteAnimationTicker(SpriteAnimation.spriteList(sprites, stepTime: 0.02));
```

After the animation is created, you need to call its `update` method and render the current frame's
sprite on your game instance.

Example:

```dart
class MyGame extends Game {
  SpriteAnimationTicker a;

  MyGame() {
    a = SpriteAnimationTicker(SpriteAnimation(...));
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
way, it will have the trimmed size, not the sprite original size.

Animations, after created, have an update and render method; the latter renders the current frame,
and the former ticks the internal clock to update the frames.

Animations are normally used inside `SpriteAnimationComponent`s, but custom components with several
Animations can be created as well.

To learn more, check out the full example code of
[using animations as widgets](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/widgets/sprite_animation_widget_example.dart).


## SpriteSheet

Sprite sheets are big images with several frames of the same sprite on it and is a very good way to
organize and store your animations. Flame provides a very simple utility class to deal with
SpriteSheets, using which you can load your sprite sheet image and extract animations from it as
well. Following is a simple example of how to use it:

```dart
import 'package:flame/sprite.dart';

final spriteSheet = SpriteSheet(
  image: imageInstance,
  srcSize: Vector2.all(16.0),
);

final animation = spriteSheet.createAnimation(0, stepTime: 0.1);
```

Now you can use the animation directly or use it in an animation component.

You can also create a custom animation by retrieving individual `SpriteAnimationFrameData` using
either `SpriteSheet.createFrameData` or `SpriteSheet.createFrameDataFromId`:

```dart
final animation = SpriteAnimation.fromFrameData(
  imageInstance, 
  SpriteAnimationData([
    spriteSheet.createFrameDataFromId(1, stepTime: 0.1), // by id
    spriteSheet.createFrameData(2, 3, stepTime: 0.3), // row, column
    spriteSheet.createFrameDataFromId(4, stepTime: 0.1), // by id
  ]),
);
```

If you don't need any kind of animation and instead only want an instance of a `Sprite` on the
`SpriteSheet` you can use the `getSprite` or `getSpriteById` methods:

```dart
spriteSheet.getSpriteById(2); // by id
spriteSheet.getSprite(0, 0); // row, column
```

See a full example of the [`SpriteSheet` class](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/sprites/sprite_sheet_example.dart)
for more details on how to work with it.
