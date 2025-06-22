# Getting Started


## About Flame

Flame is a modular Flutter game engine that provides a complete set of out-of-the-way solutions for
games. It takes advantage of the powerful infrastructure provided by Flutter but simplifies the code
you need to build your projects.

It provides you with a simple yet effective game loop implementation, and the necessary
functionalities that you might need in a game. For instance; input, images, sprites, sprite sheets,
animations, collision detection, and a component system that we call Flame Component System (FCS for
short).

We also provide stand-alone packages that extend the Flame functionality which can be found in the
[Bridge Packages](bridge_packages/bridge_packages.md) section.

You can pick and choose whichever parts you want, as they are all independent and modular.

The engine and its ecosystem are constantly being improved by the community, so please feel free to
reach out, open issues and PRs as well as make suggestions.

Give us a star if you want to help give the engine exposure and grow the community. :)


## Installation

Add the `flame` package as a dependency in your `pubspec.yaml` by running the following command:

```console
flutter pub add flame
```

The latest version can be found on [pub.dev](https://pub.dev/packages/flame/install).

then run `flutter pub get` and you are ready to start using it!


## Getting started

There is a set of tutorials that you can follow to get started in the
[tutorials folder](https://github.com/flame-engine/flame/tree/main/doc/tutorials).

Simple examples for all features can be found in the
[examples folder](https://github.com/flame-engine/flame/tree/main/examples).

To run Flame you need use the `GameWidget`, which is just another widget that can live anywhere in
your widget tree. You can use it as the root widget of your app, or as a child of another widget.

Here is a simple example of how to use the `GameWidget`:

```dart
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    GameWidget(
      game: FlameGame(),
    ),
  );
}
```

In Flame we provide a concept called the Flame Component System (FCS), which is a way to organize
your game objects in a way that makes it easy to manage them. You can read more about it in the
[Components](flame/components.md) section.

When you want to start a new game you either have to extend the `FlameGame` class or the `World`
class. The `FlameGame` is the root of your game and is responsible for managing the game loop and
the components. The `World` class is a component that can be used to create a world in your game.

So to create a simple game you can do something like this:

```dart
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(
    GameWidget(
      game: FlameGame(world: MyWorld()),
    ),
  );
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    add(Player(position: Vector2(0, 0)));
  }
}
```

As you can see, we have created a `MyWorld` class that extends the `World` class. We have overridden
the `onLoad` method to add a `Player` component (which doesn't exist yet) to the world. In the
`FlameGame` class we by default have a `camera` that is watching the world, and by default it is
looking at the (0, 0) position of the world in the center of the screen, to learn more about the
camera and the world you can read the [Camera Component](flame/camera.md) section.

The `Player` component can be whatever type of component that you want, to get started we recommend
to use the `SpriteComponent` class, which is a component that can render a sprite (image) on the
screen.

For example something like this:

```dart
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/extensions.dart';

class Player extends SpriteComponent {
  Player({super.position}) :
    super(size: Vector2.all(200), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.png');
  }
}
```

In this example, we have created a `Player` class that extends the `SpriteComponent` class. We have
overridden the `onLoad` method to set the sprite of the component to a sprite that we load from an
image file called `player.png`. The image has to be in the `assets/images` directory in your project
(see the [Assets Directory Structure](flame/structure.md)) and you have to add it to the
[assets section](https://docs.flutter.dev/ui/assets/assets-and-images) of your `pubspec.yaml` file.
In this class we also set the size of the component to 200x200 and the [anchor](flame/components.md#anchor)
to the center of the component by sending them to the `super` constructor. We also let the user of
the `Player` class set the position of the component when creating it
(`Player(position: Vector2(0, 0))`).

To handle input on a component you can add any of our [input mixins](flame/inputs/inputs.md) to the
component. For example, if you want to handle tap input you can add the `TapCallbacks` mixin to the
player component, and receive tap events within the bounds of the player component. Or if you want
to handle tap input on the whole world you can add the `TapCallbacks` mixin to the extended `World`
class.

The following example handles taps on the player component, and when the player component is
tapped the size of the player will increase by 50 pixels in both width and height.

```dart
import 'package:flame/components.dart';
import 'package:flame/geometry.dart';
import 'package:flame/extensions.dart';

class Player extends SpriteComponent with TapCallbacks {
  Player({super.position}) :
    super(size: Vector2.all(200), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('player.png');
  }
  
  @override
  void onTapUp(TapUpEvent info) {
    size += Vector2.all(50);
  }
}
```

This is just a simple example of how to get started with Flame, there are many more features that you
can use (and probably need) to create your game, but this should give you a good starting point.

You can also check out the [awesome flame repository](https://github.com/flame-engine/awesome-flame#user-content-articles--tutorials),
it contains quite a lot of good tutorials and articles written by the community to get you started
with Flame.


## Outside of the scope of the engine

Games sometimes require complex feature sets depending on what the game is all about. Some of these
feature sets are outside of the scope of the Flame Engine ecosystem, in this section you can find
them, and also some recommendations of packages/services that can be used:


### Multiplayer (netcode)

Flame doesn't bundle any network feature, which may be needed to write online multiplayer games.

If you are building a multiplayer game, here are some recommendations of packages/services:

- [Nakama](https://github.com/obrunsmann/flutter_nakama/): An open-source server designed
 to power modern games and apps.
- [Firebase](https://firebase.google.com/): Provides dozens of services that can be used to write
simpler multiplayer experiences.
- [Supabase](https://supabase.com/): A cheaper alternative to Firebase, based on Postgres.
