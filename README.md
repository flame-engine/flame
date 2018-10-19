# :fire: flame

<img src="https://i.imgur.com/vFDilXT.png" width="400">

A minimalist Flutter game engine.

Any help is appreciated! Comment, suggestions, issues, PR's! Give us a star to help!

## Goals

The goal of this project is to provided a complete set of out-of-the-way solutions for the common problems every game developed in Flutter will share.

Currently it provides you with: a few utilities, images/sprites/sprite sheets, audio, a game loop and a component/object system.

You can use whatever ones you want, as they are all somewhat independent.

## Usage

Just drop it in your `pubspec.yaml`:

```yaml
dependencies:
  flame: ^0.9.5
```

And start using it!

The complete documentation can be found [here](doc/README.md).

Bellow is an overview that should suffice to build a simple game, and work your way up from there.

The [flame-example](https://github.com/luanpotter/flame-example/tree/0.8.x) game has been updated to use the newer APIs (0.8.2) on a new branch.

There is a very good QuickStart tutorial for version `0.6.1` [here](https://medium.com/@luanpotter27/a-comprehensive-flame-tutorial-or-how-to-make-games-with-flutter-74f22c4ecbfa). The API has changed a lot, so refer this documentation for updated information. Soon I plan to release an updated tutorial.

## Structure

The only structure you are required to comply is a assets folder with two sub folders: audio and images.

An example:

```dart
  Flame.audio.play('explosion.mp3');

  Flame.images.load('player.png');
  Flame.images.load('enemy.png');
```

The file structure would have to be:

```
.
└── assets
    ├── audio
    │   └── explosion.mp3
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

To play an audio, just use the `Flame.audio.play` method:

```dart
    import 'package:flame/flame.dart';

    Flame.audio.play('explosion.mp3');
```

You can pre-load your audios in the beginning and avoid delays with the `loadAll` method:

```dart
    // in a async prepare function for your game
    await Flame.audio.loadAll(['explosion.mp3']);
```

[Complete Audio Guide](doc/audio.md)

### Images

If you are using the Component module and doing something simple, you probably won't need to use these classes; use `SpriteComponent` or `AnimationComponent` instead.

If you want to load an image and render it on the `Canvas`, you can use the `Sprite` class:

```dart
    import 'package:flame/sprite.dart';

    Sprite sprite = new Sprite('player.png');

    // in your render loop
    sprite.render(canvas, width, height);
```

Note that the render method will do nothing while the image has not been loaded; you can check for completion using the `loaded` method.

[Complete Images Guide](doc/images.md)

### Component

This class represent a single object on the screen, being a floating rectangle or a rotating sprite.

The base abstract class has the common expected methods update and render to be implemented.

The intermediate inheritance `PositionComponent` adds `x`, `y`, `width`, `height` and `angle` to your Components, as well as some useful methods like distance and angleBetween.

The most commonly used implementation, `SpriteComponent`, can be created with a `Sprite`:

```dart
    import 'package:flame/components/component.dart';

    Sprite sprite = new Sprite('player.png');

    const size = 128.0;
    var player = new SpriteComponent.fromSprite(size, size, sprite); // width, height, sprite

    // screen coordinates
    player.x = ... // 0 by default
    player.y = ... // 0 by default
    player.angle = ... // 0 by default

    player.render(canvas); // it will render only if the image is loaded and the x, y, width and height parameters are not null
```

Every `Component` has a few other methods that you can optionally implement, that are used by the `BaseGame` class. If you are not using the base game, you can alternatively use these methods on your own game loop.

The `resize` method is called whenever the screen is resized, and in the beginning once when the component is added via the `add` method. You need to apply here any changes to the x, y, width and height of your component, or any other changes, due to the screen resizing. You can start these variables here, as the sprite won't be rendered until everything is set.

The `destroy` method can be implemented to return true and warn the `BaseGame` that your object is marked for destruction, and it will be remove after the current update loop. It will then no longer be rendered or updated.

The `isHUD` method can be implemented to return true (default false) to make the `BaseGame` ignore the `camera` for this element.

There are also other implementations:

* The `AnimationComponent` takes an `Animation` object and renders a cyclic animated sprite (more details about Animations [here](doc/images.md#Animation))
* The `ParallaxComponent` can render a parallax background with several frames
* The `Box2DComponent`, that has a physics engine built-in (using the [Box2D](https://github.com/google/box2d.dart) port for Dart)

[Complete Components Guide](doc/components.md)

### Game Loop

The Game Loop module is a simple abstraction over the game loop concept. Basically most games are built upon two methods: 

* The render method takes the canvas ready for drawing the current state of the game.
* The update method receives the delta time in milliseconds since last update and allows you to move the next state.

The class `Game` can be subclassed and will provide both these methods for you to implement. In return it will provide you with a `widget` property that returns the game widget, that can be rendered in your app.

You can either render it directly in your `runApp`, or you can have a bigger structure, with routing, other screens and menus for your game.

To start, just add your game widget directly to your runApp, like so:

```dart
    main() {
        Game game = new MyGameImpl();
        runApp(game.widget);
    }
```

Instead of implementing the low level `Game` class, you should probably use the more full-featured `BaseGame` class.

The `BaseGame` implements a `Component` based `Game` for you; basically it has a list of `Component`s and repasses the `update` and `render` calls appropriately. You can still extend those methods to add custom behavior, and you will get a few other features for free, like the repassing of `resize` methods (every time the screen is resized the information will be passed to the resize methods of all your components) and also a basic camera feature (that will translate all your non-HUD components in order to center in the camera you specified).

A very simple `BaseGame` implementation example can be seen below:

```dart
    class MyCrate extends SpriteComponent {

        // creates a component that renders the crate.png sprite, with size 16 x 16
        MyCrate() : SpriteComponent.fromSprite(16.0, 16.0, new Sprite('crate.png'));

        @override
        void resize(Size size) {
            // we don't need to set the x and y in the constructor, we can set then here
            this.x = (size.width - this.width)/ 2;
            this.y = (size.height - this.height) / 2;
        }
    }

    class MyGame extends BaseGame {
        MyGame() {
            add(new MyCrate()); // this will call resize the first time as well
        }
    }
```

### Input

In order to handle user input, you can use the libraries provided by Flutter for regular apps: [Gesture Recognizers](https://flutter.io/gestures/).

However, in order to bind them, use the `Flame.util.addGestureRecognizer` method; in doing so, you'll make sure they are properly unbound when the game widget is not being rendered, and so the rest of your screens will work appropriately.

For example, to add a tap listener ("on click"):

```dart
    Flame.util.addGestureRecognizer(new TapGestureRecognizer()
        ..onTapDown = (TapDownDetails evt) => game.handleInput(evt.globalPosition.dx, evt.globalPosition.dy));
```

Where `game` is a reference to your game object and `handleInput` is a method you create to handle the input inside your game.

If your game doesn't have other screens, just call this after your `runApp` call, in the `main` method.

[Complete Input Guide](doc/input.md)

### Gamepad

Gamepad is partially supported on Android, you easily listen to key up and down events using `Flame.gamepad.addListener` method, check the link below for the complete guide

[Complete Gamepad Guide](doc/gamepad.md)

## Credits

 * All the friendly contributors and people who are helping in the community.
 * My own [audioplayers](https://github.com/luanpotter/audioplayer) lib, which in turn is forked from [rxlabz's](https://github.com/rxlabz/audioplayer).
 * The Dart port of [Box2D](https://github.com/google/box2d.dart).
 * [inu-no-policemen's post on reddit](https://www.reddit.com/r/dartlang/comments/69luui/minimal_flutter_game_loop/), which helped me a lot with the basics
 * Everyone who answered my beginner's questions on Stack Overflow
