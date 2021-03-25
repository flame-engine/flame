# Game Loop

The Game Loop module is a simple abstraction over the game loop concept. Basically most games are
built upon two methods:

 - The render method takes the canvas for drawing the current state of the game.
 - The update method receives the delta time in seconds since last update and allows you to move to
   the next state.

The `Game` class can be extended and will provide these gameloop methods and then its instance
Flutter widget tree via the `GameWidget`.

You can add it into the top of you tree (directly as an argument to `runApp`) or inside the usual
app-like widget structure (with scaffold, routes, etc.).

Example of usage directly with `runApp`:

```dart

class MyGameSubClass extends Game {
  @override
  void render(Canvas canvas) {
    // TODO: implement render
  }

  @override
  void update(double t) {
    // TODO: implement update
  }
}
    
  
main() {
  final myGame = MyGameSubClass();
  runApp(
    GameWidget(
      game: myGame,
    )
  );
}
```

**Note:** Do not instantiate your game in a build method. Instead create an instance of your game
 and reference it within your widget structure. Otherwise your game will be rebuilt every time the
 Flutter tree gets rebuilt.

It is important to notice that `Game` is an abstract class with just the very basic implementations
of the gameloop.

As an option and more suitable for most cases, there is the fully featured `BaseGame` class.

The `BaseGame` implements a `Component` based `Game` for you; basically it has a list of
`Component`s and passes the `update` and `render` calls appropriately. You can still extend those
methods to add custom behavior, and you will get a few other features for free, like the passing of
`resize` methods (every time the screen is resized the information will be passed to the resize
methods of all your components) and also a basic camera feature.

The `BaseGame.camera` controls which point in the coordinate space that should be the top-left of
the screen (it defaults to [0,0] like a regular `Canvas`).

A `BaseGame` implementation example can be seen below:

```dart
class MyCrate extends SpriteComponent {
  // creates a component that renders the crate.png sprite, with size 16 x 16
  MyCrate() : super(size: Vector2.all(16));

  Future<void> onLoad() async {
    sprite = await Sprite.load('crate.png');
    anchor = Anchor.center;
  }

  @override
  void onGameResize(Vector2 gameSize) {
    // We don't need to set the position in the constructor, we can it directly here since it will
    // be called once before the first time it is rendered.
    position = gameSize / 2;
  }
}

class MyGame extends BaseGame {
  MyGame() {
    add(MyCrate());
  }
}
```

To remove components from the list on a `BaseGame` the `remove` or `removeAll` methods can be used.
The first if you just want to remove one component, and the second if you want to remove a list of
components.

Any component that which the `remove()` method has been called on will also be removed, that is
simply called like this `yourComponent.remove();`.

## Flutter Widgets and Game instances

Since a Flame game can be wrapped in a widget, it is quite easy to use it alongside other Flutter
widgets. But still, there is a the Widgets overlay API that makes things even easier.

`Game.overlays` enables to any Flutter widget to be shown on top of a game instance, this makes it
very easy to create things like a pause menu, or an inventory screen for example.
This property that will be used to manage the active overlays.

This management happens via the `game.overlays.add` and `game.overlays.remove` methods that marks an
overlay to be shown or hidden, respectively, via a `String` argument that identifies the overlay.
After that it can be specified which widgets represent each overlay in the `GameWidget` declaration
by setting a `overlayBuilderMap`.

```dart
// Inside game methods:
final pauseOverlayIdentifier = "PauseMenu";

overlays.add(pauseOverlayIdentifier); // Marks "PauseMenu" to be rendered.
overlays.remove(pauseOverlayIdentifier); // Marks "PauseMenu" to not be rendered.
```

```dart
// On the widget declaration
final game = MyGame();

Widget build(BuildContext context) {
  return GameWidget(
  game: game,
  overlayBuilderMap: {
    "PauseMenu": (ctx) {
       return Text("A pause menu");
     },
   },
 );
}
```

The order in which the overlays are declared on the `overlayBuilderMap` defines which overlay that
will be rendered first.

Here you can see a
[working example](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/widgets/overlay.dart)
of this feature.

## BaseGame debug mode

Flame's `BaseGame` class provides a variable called `debugMode`, which by default is false. It can
however, be set to true to enable debug features for the components of the game. __Be aware__ that
the value of this variable is passed through to its component when they are added to the game, so if
you change the `debugMode` in runtime, it will not affect already added components by default.

To read more about the `debugMode` on Flame, please refer to the [Debug Docs](debug.md)


