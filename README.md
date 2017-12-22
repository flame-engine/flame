# :fire: flame

A minimalist Flutter game engine.

**Now audio works on iOS, thanks to [@feroult](https://github.com/feroult)!**

## Roadmap

Any help is appreciated! Comment, suggestions, issues, PR's! Give us a star to help!

These features are things that I saw evolving into games using flutter that I believe should be introduced into the engine:

 * Rotation around sprint center (currently it rotates around the corner)
 * Find an unobtrusive compromise to automatically call `Flame.util.enableEvents();` and fix the `--supermixin` problem
 * Think of a good structure to add tests (might be hard to do)

## Goals

The goal of this project is to provided a minimalist set of out-of-the-way solutions for the common problems every game developed in Flutter will share.

Currently it provides you with: a few utilities, images/sprites, audio, a game loop and a component/object system.

You can use whatever ones you want, as they are all independent.

## Usage

Just drop it in your `pubspec.yaml`:

```
dependencies:
  flame: ^0.6.1
```

And start using it! There is a very good QuickStart tutorial [here](https://medium.com/@luanpotter27/a-comprehensive-flame-tutorial-or-how-to-make-games-with-flutter-74f22c4ecbfa), with everything you need to know!

## Structure

The only structure you are required to comply is a assets folder with two subfolders: audio and images.

An example:

```
  Flame.audio.play('explosion.mp3');

  Flame.images.load('player.png');
  Flame.images.load('enemy.png');
```

The file structure would have to be:

```
.
└── assets
    ├── audio
    │   └── explosion.mp3
    └── images
        ├── enemy.png
        └── player.png
```

Don't forget to add these files to your `pubspec.yaml` file:

```
flutter:
  assets:
    - assets/audio/explosion.mp3
    - assets/images/player.png
    - assets/images/enemy.png
```

## Modules

The modular approach allows you to use any of these modules independently, or together, or as you wish.

### Audio

To play audio, it's really simple! Just run, at any moment:

```
    import 'package:flame/flame.dart';

    Flame.audio.play('explosion.mp3');
```

Or, if you prefer:

```
    import 'package:flame/audio.dart';

    Audio audio = new Audio();
    audio.play('explosion.mp3');
```

You must have an appropriate folder structure and add the files to the `pubspec.yaml` file, as explained above.

It has to be an MP3 or a OGG file (tested with WAV and it didn't work).

This uses the [audioplayers](https://github.com/luanpotter/audioplayer) lib, in
order to allow playing multiple sounds simultaneously (crucial in a game).

If you want to play indefinitely, just use loop:

```
    Flame.audio.loop('music.mp3');
```

**Beware**: in order to use loop or any platform binding callbacks, you need to call this
utility function first thing on your application code:

```
    Flame.util.enableEvents();
```

**TODO**: find a way to know if events are enabled and call this automatically somehow.

Finally, you can pre-load your audios. Audios need to be stored in the memory the first
time they are requested; therefore, the first time you play each mp3 you might get a
delay. In order to pre-load your audios, just use:

```
    Flame.audio.load('explosion.mp3');
```

You can load all your audios in beginning so that they always play smoothly.

There's lots of logs; that's reminiscent of the original AudioPlayer plugin. Useful while
debug, but afterwards you can disable them with:

```
    Flame.audio.disableLog();
```

### Images

Flutter has a collection of types related to images, and converting everything properly
form a local asset to the Image that can be drawn on Canvas is a small pain.

This module allows you to obtain an Image that can be drawn on a Canvas using the `drawImageRect` method.

Just use:
```
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

Similarly to Audio, you can instantiate your own copy of Image:

```
    Image image = await new Images().load('asd');
```

If you are using the Component module, you probably should not use this one; use SpriteComponent instead!

You must have an appropriate folder structure and add the files to the `pubspec.yaml` file, as explained above.

It has to be a PNG file. It can have transparency.

### Component

This class represent a single object on the screen, being a floating rectangle or a rotating sprite.

The base abstract class has the common expected methods update and render to be implemented.

The intermediate inheritance `PositionComponent` adds x, y and angle to your Components,
as well as some useful methods like distance and angleBetween.

And finally, the most complete implementation, `SpriteComponent`, which makes rendering sprites really easy:

```
    import 'package:flame/component.dart';

    const size = 128.0; // size that will be drawn on the screen
    // it will resize the image according
    var player = new SpriteComponent.square(size, 'player.png');
    // the image sprite will be loaded by the Images module
    
    // screen coordinates
    player.x = ...
    player.y = ...
    player.angle = ...
    // tip: use canvas.translate to convert coordiantes
    
    player.render(canvas); // it will render if the image is ready
```

You can also use the rectangle constructor if you want a non-square sprite:

```
    var object = new SpriteComponent.rectangle(width, height, imagePath);
```

### Game Loop

The Game Loop module is a simple abstraction over the game loop concept.

Extend the abstract class Game and just implement render and update; they will be called properly once you start.

```
    import 'package:flame/game.dart';
    import 'package:flame/component.dart';

    class MyGame extends Game {
        var objs = <Component>[];

        update(double t) {
            components.forEach((Component obj) => obj.update(t));
        }

        render(Canvas canvas) {
            components.forEach((Component obj) => obj.render(canvas));
        }
    }    
   
    var game = new MyGame();
    game.objs.add(new SpriteObject( ... ));
    game.start();
``` 

The render method takes the canvas ready for drawing the current state of the game.

The update method receives the delta time in milliseconds since last update and allows
you to move the next state.

### Util

This module will incorporate a few utility functions that are good to have in any game
environment. For now, there is only two:

 * initialDimensions : returns a Future with the dimension (Size) of the screen. This has
   to be done in a hacky way because of the reasons described in the code.
 * enableEvents : this is also a hack that allows you to use the Service bindings with
   platform specific code callbacks. Normally they would only work if you called runApp
   with a widget, since we draw on canvas for the game, that's never called. This makes sure it works.
 * text : helper to write text to the Canvas; the methods are a bit convoluted, this might give a hand.

Ideas are appreciated!

## Credits

 * My own [audioplayers](https://github.com/luanpotter/audioplayer) lib, wich in turn is forked from [rxlabz's](https://github.com/rxlabz/audioplayer).
 * [inu-no-policemen's post on reddit](https://www.reddit.com/r/dartlang/comments/69luui/minimal_flutter_game_loop/), which helped me a lot with the basics
 * Everyone who answered my beginner's questions on Stack Overflow
