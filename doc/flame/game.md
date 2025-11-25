# FlameGame

The base of almost all Flame games is the `FlameGame` class, this is the root of your component
tree. We refer to this component-based system as the Flame Component System (FCS). Throughout the
documentation, FCS is used to reference this system.

The `FlameGame` class implements a `Component` based `Game`. It has a tree of components
and calls the `update` and `render` methods of all components that have been added to the game.

Components can be added to the `FlameGame` directly in the constructor with the named `children`
argument, or from anywhere else with the `add`/`addAll` methods. Most of the time however, you want
to add your children to a `World`, the default world exist under `FlameGame.world` and you add
components to it just like you would to any other component.

A simple `FlameGame` implementation that adds two components, one in `onLoad` and one directly in
the constructor can look like this:

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

/// A component that renders the crate sprite, with a 16 x 16 size.
class MyCrate extends SpriteComponent {
  MyCrate() : super(size: Vector2.all(16));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('crate.png');
  }
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    await add(MyCrate());
  }
}

void main() {
  final myGame = FlameGame(world: MyWorld());
  runApp(
    GameWidget(game: myGame),
  );
}
```

```{note}
If you instantiate your game in a build method your game will be rebuilt every
time the Flutter tree gets rebuilt, which usually is more often than you'd like.
To avoid this, you can either create an instance of your game first and
reference it within your widget structure or use the `GameWidget.controlled`
constructor.
```

To remove components from the list on a `FlameGame` the `remove` or `removeAll` methods can be used.
The first can be used if you just want to remove one component, and the second can be used when you
want to remove a list of components. These methods exist on all `Component`s, including the world.

The `FlameGame` has a built-in `World` called `world` and a `CameraComponent` instance called
`camera`, you can read more about those in the [Camera section](camera.md).


## Game Loop

The `GameLoop` module is a simple abstraction of the game loop concept. Basically, most games are
built upon two methods:

- The render method takes the canvas for drawing the current state of the game.
- The update method receives the delta time in microseconds since the last update and allows you to
  move to the next state.

The `GameLoop` is used by all of Flame's `Game` implementations.


## Resizing

Every time the game needs to be resized, for example when the orientation is changed, `FlameGame`
will call all of the `Component`s `onGameResize` methods and it will also pass this information to
the camera and viewport.

The `FlameGame.camera` controls which point in the coordinate space that should be at the anchor of
your viewfinder, [0,0] is in the center (`Anchor.center`) of the viewport by default.


## Lifecycle

The `FlameGame` lifecycle callbacks, `onLoad`, `render`, etc. are called in the following sequence:

```{include} diagrams/flame_game_life_cycle.md
```

When a `FlameGame` is first added to a `GameWidget` the lifecycle methods `onGameResize`, `onLoad`
and `onMount` will be called in that order. Then `update` and `render` are called in sequence for
every game tick.  If the `FlameGame` is removed from the `GameWidget`  then `onRemove` is called.
If the `FlameGame` is added to a new `GameWidget` the sequence repeats from `onGameResize`.

```{note}
The order of `onGameResize`and `onLoad` are reversed from that of other
`Component`s. This is to allow game element sizes to be calculated before
resources are loaded or generated.
```

The `onRemove` callback can be used to clean up children and cached data:

```dart
  @override
  void onRemove() {
    // Optional based on your game needs.
    removeAll(children);
    processLifecycleEvents();
    Flame.images.clearCache();
    Flame.assets.clearCache();
    // Any other code that you want to run when the game is removed.
  }
```

```{note}
Clean-up of children and resources in a `FlameGame` is not done automatically
and must be explicitly added to the `onRemove` call.
```


## Debug mode

Flame's `FlameGame` class provides a variable called `debugMode`, which by default is `false`. It
can, however, be set to `true` to enable debug features for the components of the game. **Be aware**
that the value of this variable is passed through to its components when they are added to the
game, so if you change the `debugMode` at runtime, it will not affect already added components by
default.

To read more about the `debugMode` on Flame, please refer to the [Debug Docs](other/debug.md)


## Change background color

To change the background color of your `FlameGame` you have to override `backgroundColor()`.

In the following example, the background color is set to be fully transparent, so that you can see
the widgets that are behind the `GameWidget`. The default is opaque black.

```dart
class MyGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);
}
```

Note that the background color can't change dynamically while the game is running, but you could
just draw a background that covers the whole canvas if you would want it to change dynamically.


## SingleGameInstance mixin

An optional mixin `SingleGameInstance` can be applied to your game if you are making a single-game
application. This is a common scenario when building games: there is a single full-screen
`GameWidget` that hosts a single `Game` instance.

Adding this mixin provides performance advantages in certain scenarios. In particular, a component's
`onLoad` method is guaranteed to start when that component is added to its parent, even if the
parent is not yet mounted itself. Consequently, `await`-ing on `parent.add(component)` is guaranteed
to always finish loading the component.

Using this mixin is simple:

```dart
class MyGame extends FlameGame with SingleGameInstance {
  // ...
}
```


## Low-level Game API

```{include} diagrams/low_level_game_api.md
```

The abstract `Game` class is a low-level API that can be used when you want to implement the
functionality of how the game engine should be structured. `Game` does not implement any `update` or
`render` function for example.

The class also has the lifecycle methods `onLoad`, `onMount` and `onRemove` in it, which are
called from the `GameWidget` (or another parent) when the game is loaded + mounted, or removed.
`onLoad` is only called the first time the class is added to a parent, but `onMount` (which is
called after `onLoad`) is called every time it is added to a new parent. `onRemove` is called when
the class is removed from a parent.

```{note}
The `Game` class allows for more freedom of how to implement things, but you
are also missing out on all of the built-in features in Flame if you use it.
```

An example of how a `Game` implementation could look like is:

```dart
class MyGameSubClass extends Game {
  @override
  void render(Canvas canvas) {
    // ...
  }

  @override
  void update(double dt) {
    // ...
  }
}

void main() {
  final myGame = MyGameSubClass();
  runApp(
    GameWidget(
      game: myGame,
    )
  );
}
```


## Pause/Resuming/Stepping game execution

A Flame `Game` can be paused and resumed in two ways:

- With the use of the `pauseEngine` and `resumeEngine` methods.
- By changing the `paused` attribute.

When pausing a `Game`, the `GameLoop` is effectively paused, meaning that no updates or new renders
will happen until it is resumed.

While the game is paused, it is possible to advanced it frame by frame using the `stepEngine`
method.
It might not be much useful in the final game, but can be very helpful in inspecting game state step
by step during the development cycle.


### Backgrounding

The game will be automatically paused when the app is sent to the background,
and resumed when it comes back to the foreground. This behavior can be disabled by setting
`pauseWhenBackgrounded` to `false`.

```dart
class MyGame extends FlameGame {
  MyGame() {
    pauseWhenBackgrounded = false;
  }
}
```

On the current Flutter stable (3.13), this flag is effectively ignored on
non-mobile platforms including the web.


## HasPerformanceTracker mixin

While optimizing a game, it can be useful to track the time it took for the game to update and render
each frame. This data can help in detecting areas of the code that are running hot. It can also help
in detecting visual areas of the game that are taking the most time to render.

To get the update and render times, just add the `HasPerformanceTracker` mixin to the game class.

```dart
class MyGame extends FlameGame with HasPerformanceTracker {
  // access `updateTime` and `renderTime` getters.
}
```
