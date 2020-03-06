[![Pub](https://img.shields.io/pub/v/flame.svg?style=popout)](https://pub.dartlang.org/packages/flame) [![Build Status - Travis](https://travis-ci.org/flame-engine/flame.svg?branch=master)](https://travis-ci.org/flame-engine/flame) [![Discord](https://img.shields.io/discord/509714518008528896.svg)](https://discord.gg/pxrBmy4)

# :fire: flame

<img src="https://i.imgur.com/vFDilXT.png" width="400">

A minimalist Flutter game engine.

Any help is appreciated! Comment, suggestions, issues, PR's! Give us a star to help!

## Help

We have a Flame help channel on Fireslime's Discord, join it [here](https://discord.gg/pxrBmy4). Also we now have a [FAQ](FAQ.md), so please search your questions there first.

## Goals

The goal of this project is to provided a complete set of out-of-the-way solutions for the common problems every game developed in Flutter will share.

Currently it provides you with: a few utilities, images/sprites/sprite sheets, audio, a game loop and a component/object system.

You can use whatever ones you want, as they are all somewhat independent.

## Support

Support us by becoming a patron on Patreon

[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/fireslime)

Or making a single donation buying us a coffee:

[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/fireslime)

You can also show support by showing on your repository that your game is made with Flame by using one of the following badges:

[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)

```
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=flat-square)](https://flame-engine.org)
[![Powered by Flame](https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg?style=for-the-badge)](https://flame-engine.org)
```

## Contributing

Found a bug on Flame and want to contribute with a PR? PRs are always very welcome, just be sure to create your PR from the `develop` branch.

## External Modules

Flame is modular, and you can always pick and choose. Some modules are extracted to separate plugins; some are bundled with flame, and some must be added separately.

* [audioplayers](https://github.com/luanpotter/audioplayers) is the audio engine behind flame. It's included.
* [tiled](https://github.com/feroult/tiled.dart) adds support for parsing and using TMX files from Tiled. It's included.
* [box2d](https://github.com/feroult/box2d.dart) adds wrappers over Box2D for the physics engine. It's included.

* [flame_gamepad](https://github.com/fireslime/flame_gamepad) adds support to gamepad. Android only. It's not included, add to your pubspec as desired.
* [play_games](https://github.com/luanpotter/play_games) integrates to Google Play Games Services (GPGS). Adds login, achievements, saved games and leaderboard. Android only. It's not included, add to your pubspec as desired. Be sure to check the instructions on how to configure, as it's not trivial.

## Usage

Just drop it in your `pubspec.yaml`:

```yaml
dependencies:
  flame: ^0.18.1
```

And start using it!

__Important__

We strive to keep Flame working on the Flutter's stable channel, currently on version v1.7.8+hotfix.2, be sure to check which channel are you using if you encounter any trouble.

## Documentation

The complete documentation can be found [here](doc/README.md).

A very cool docs site can be found [here](https://flame-engine.org/).

## Getting started

Check out this great series of articles/tutorials written by [Alekhin](https://github.com/japalekhin)

Note that these are a bit outdated and don't show how to use the [Component](doc/components.md) system, but still useful.

 - [Create a Mobile Game with Flutter and Flame – Beginner Tutorial](https://jap.alekhin.io/create-mobile-game-flutter-flame-beginner-tutorial)
 - [2D Casual Mobile Game Tutorial – Step by Step with Flame and Flutter (Part 1 of 5)](https://jap.alekhin.io/2d-casual-mobile-game-tutorial-flame-flutter-part-1)
 - [Game Graphics and Animation Tutorial – Step by Step with Flame and Flutter (Part 2 of 5)](https://jap.alekhin.io/game-graphics-and-animation-tutorial-flame-flutter-part-2)
 - [Views and Dialog Boxes Tutorial – Step by Step with Flame and Flutter (Part 3 of 5)](https://jap.alekhin.io/views-dialog-boxes-tutorial-flame-flutter-part-3)
 - [Scoring, Storage, and Sound Tutorial – Step by Step with Flame and Flutter (Part 4 of 5)](https://jap.alekhin.io/scoring-storage-sound-tutorial-flame-flutter-part-4)
 - [Game Finishing and Packaging Tutorial – Step by Step with Flame and Flutter (Part 5 of 5)](https://jap.alekhin.io/game-finishing-packaging-tutorial-flame-flutter-part-5)
 
We also offer a curated list of Games, Libraries and Articles over at [awesome-flame](https://github.com/flame-engine/awesome-flame).

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

You can pre-load your audios up front and avoid delays with the `loadAll()` method:

```dart
// in an async prepare function for your game
await Flame.audio.loadAll(['explosion.mp3']);
```

To play an audio, just use the `Flame.audio.play()` method:

```dart
import 'package:flame/flame.dart';

Flame.audio.play('explosion.mp3');
```

[Complete Audio Guide](doc/audio.md)

[Looping Background Music Guide](doc/bgm.md)

### Images, Sprites, and Animations

You can pre-load your images up front and avoid delays with the `loadAll()` method:

```dart
// in an async prepare function for your game
await Flame.images.loadAll(['player.png', 'enemy.png']);
```

If you want to load an `Image` and render it on the `Canvas`, you can use the `Sprite` class:

```dart
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';

Image image = await Flame.images.load('player.png');

Sprite sprite = Sprite(image);

// in your render loop
sprite.render(canvas);
```

An `Animation` can be defined from an `Image` in a similar way using the `Animation.fromImage()` constructor.

Note that the render method will do nothing while the image is being loaded. You can check for completion using the `loaded` method, or use `async` functions to handle loading up front.

[Complete Images Guide](doc/images.md)

### Component System

If using the `BaseGame` class instead of the `Game` class, as your core game loop, you can use Flame's component system to manage your game objects. 

The base abstract `Component` class implements and automatically calls the usual methods of `update()` and `render()` (among other utility methods).

The intermediate inheritance `PositionComponent` class controls the position and final size of your game objects by adding `x`, `y`, `width`, `height` and `angle`, as well as some useful methods like `distance()` and `angleBetween()`.

The high-level components of `SpriteComponent` and `AnimationComponent` are intended for easy component creation from their respective `Sprite` and `Animation` objects.

For example, to create a `SpriteComponent` from a `Sprite`:

```dart
import 'package:flame/components/component.dart';

// on your constructor or init logic
Image image = Flame.images.fromCache('player.png');
Sprite sprite = Sprite.fromImage(image);

const size = 128.0; // render size, not sprite source size
final player = SpriteComponent(
  sprite,
  width:  size,
  height: size,
  x:      ..., // starting X position
  y:      ..., // starting Y position
  angle:  ..., // starting rotation (in radians)
);
```

Every `Component` has a few other methods that you can optionally implement, that are used by the `BaseGame` class. If you are not using `BaseGame`, you can alternatively use these methods on your own game loop.

The `resize()` method is called whenever the screen is resized, and in the beginning once when the component is added via the `add()` method. You need to apply here any changes to the x, y, width and height of your component, or any other changes, due to the screen resizing. You can start these variables here, as the sprite won't be rendered until everything is set.

The `destroy()` method can be implemented to return true and warn the `BaseGame` that your object is marked for destruction, and it will be remove after the current update loop. It will then no longer be rendered or updated.

The `isHUD()` method can be implemented to return true (default false) to make the `BaseGame` ignore the `camera` for this element.

Other high-level components:

* `ParallaxComponent` can render a parallax background with several frames
* `Box2DComponent` has a physics engine built-in (using the [Box2D](https://github.com/google/box2d.dart) port for Dart)

[Complete Components Guide](doc/components.md)

### Game Loop

The Game Loop module is a simple abstraction over the game loop concept. Basically most games are built upon two methods: 

* `render()` makes the canvas ready for drawing the current state of the game.
* `update()` receives the delta time in milliseconds since last update and allows you to move the next state.

The lower-level `Game` class can be subclassed and will provide both these methods for you to implement. In return it will provide you with a `widget` property that returns the game widget, that can be rendered in your app.

You can either render it directly in your `runApp`, or you can have a bigger structure, with routing, other screens and menus for your game.

To start, just add your game widget directly to your runApp, like so:

```dart
void main() {
    Game game = MyGameImpl();
    runApp(game.widget);
}
```

The more fully-featured `BaseGame` class implements a component-based `Game` class for you. Basically, it keep a list of `Component`s and passes the `update()` and `render()` calls appropriately. You can still extend those methods to add custom behavior. You will also get a few other features for free. Like, the passing of `resize()` methods (every time the screen is resized the information will be passed to the resize methods of all your components). Also, a basic camera feature (that will translate all your non-HUD components in order to center in the camera you specified).

A very simple `BaseGame` implementation example can be seen below:

```dart
void main() async {
  ...
  await Flame.images.load('crate.png');
}

class MyCrate extends SpriteComponent {
    static final Image image = Flame.images.fromCache('crate.png');

    // creates a component that renders the crate.png sprite, with size 16 x 16
    MyCrate() : super(
      Sprite.fromImage(image),
      width:  16.0,
      height: 16.0,
    );

    @override
    void resize(Size size) {
        // we don't need to set x and y in the constructor, we can set them here
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

Inside `package:flame/gestures.dart` you can find a whole set of `mixin` which can be included on your game class instance to be able to receive touch input events

__Example__

```dart
class MyGame extends Game with TapDetector {
  // Other methods ommited

  @override
  void onTapDown(TapDownDetails details) {
    print("Player tap down on ${details.globalPosition.dx} - ${details.globalPosition.dy}");
  }

  @override
  void onTapUp(TapUpDetails details) {
    print("Player tap up on ${details.globalPosition.dx} - ${details.globalPosition.dy}");
  }
}
```

[Complete Input Guide](doc/input.md)

## Credits

 * All the friendly contributors and people who are helping in the community.
 * My own [audioplayers](https://github.com/luanpotter/audioplayer) lib, which in turn is forked from [rxlabz's](https://github.com/rxlabz/audioplayer).
 * The Dart port of [Box2D](https://github.com/google/box2d.dart).
 * [inu-no-policemen's post on reddit](https://www.reddit.com/r/dartlang/comments/69luui/minimal_flutter_game_loop/), which helped me a lot with the basics
 * Everyone who answered my beginner's questions on Stack Overflow
