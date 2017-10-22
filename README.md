# :fire: flame

A minimalist Flutter game engine.

## WIP

Audio doesn't work on iOS; the rest should (not tested).

Help is appreciated, check the Audio section for more details.

## Goals

The goal of this project is to provided a minimalist set of out-of-the-way solutions for the common problems every game developed in Flutter will share.

Currently it provides you with: a few utilities, images/sprites, audio, a game loop and a component/object system.

You can use whatever ones you want, as they are all independent.

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

It has to be an MP3 file.

This uses the [audioplayers](https://github.com/luanpotter/audioplayer) lib, in order to allow playing multiple sounds simultaneously (crucial in a game).
Therefore, it doesn't work on iOS yet; check their README for more details on that.

### Images

Flutter has a collection of types related to images, and converting everything properly form a local asset to the Image that can be drawn on Canvas is a small pain.

This module allows you to obtain an Image that can be drawn on a Canvas using the `drawImageRect` method.

Just use:
```
    import 'package:flame/flame.dart';

    // inside an async context
    Image image = await Flame.images.load('player.png');
    
    // or
    Flame.images.load('player.png').then((Image image) {
      Paint paint = new Paint()..color = new Color(0xffffffff);
      Rect rect = new Rect.fromLTWH(0.0, 0.0, image.width.toDouble(), image.height.toDouble());
      canvas.drawImageRect(image, rect, rect, paint);
    });
```
Similarly to Audio, you can instantiate your own copy of Image:

```
    Image image = await new Images().load('asd');
```

If you are using the Component module, you probably shouldn't use this one; use SpriteComponent instead!

You must have an appropriate folder structure and add the files to the `pubspec.yaml` file, as explained above.

It has to be a PNG file. It can have transparency.

### Component

This class represent a single object on the screen, being a floating rectangle or a rotating sprite.

The base abstract class has the common expected methods update and render to be implemented.

But you can use the default implementation, `SpriteComponent`, which makes rendering sprites really easy:

```
    import 'package:flame/component.dart';

    const size = 128.0; // size that will be drawn on the screen
    // it will resize the image according
    SpriteComponent player = new SpriteComponent(size, 'player.png');
    // the image sprite will be loaded by the Images module
    
    // screen coordinates
    player.x = ...
    player.y = ...
    player.angle = ...
    // tip: use canvas.translate to convert coordiantes
    
    player.render(canvas); // it will render if the image is ready
```

### Game Loop

The Game Loop module is a simple abstraction over the game loop concept.

Extend the abstract class Game and just implement render and update; they will be called properly once you start.

```
    import 'package:flame/game.dart';
    import 'package:flame/component.dart';

    class MyGame extends Game {
        List<Component> objs = new List();

        update(double t) {
            components.forEach((Component obj) { obj.update(t); });
        }

        render(Canvas canvas) {
            components.forEach((Component obj) { obj.render(canvas); });
        }
    }    
   
    Game game = new MyGame();
    game.objs.add(new SpriteObject( ... ));
    game.start();
``` 

The render method takes the canvas ready for drawing the current state of the game.

The update method receives the delta time in milliseconds since last update and allows you to move the next state.

### Util

This module will incorporate a few utility functions that are good to have in any game environment. For now, there is only one:

 * initialDimensions : returns a Future with the dimension (Size) of the screen. This has to be done in a hacky way because of the reasons described in the code.

Ideas are appreciated!

## Credits

 * My own [audioplayers](https://github.com/luanpotter/audioplayer) lib, wich in turn is forked from [rxlabz's](https://github.com/rxlabz/audioplayer).
 * [inu-no-policemen's post on reddit](https://www.reddit.com/r/dartlang/comments/69luui/minimal_flutter_game_loop/), which helped me a lot with the basics
 * Everyone who answered my beginner's questions on Stack Overflow