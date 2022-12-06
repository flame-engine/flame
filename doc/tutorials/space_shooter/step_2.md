# Controlling the player and adding some graphics

Now that we have the base for our game and a component for our player, let's add some interactivity
to it. We can begin by allowing the player to be controlled by mouse/touch gestures.

There are a couple of ways of doing that in Flame. For this tutorial, we will do that by using one
of Flame's gesture detectors: `PanDetector`.

This detector will make our game class receive pan (or drag) events. To do so, we just need to add
the `PanDetector` mixin to our game class and override its listener methods; in our case, we will
use the `onPanUpdate` method. The updated code will look like the following:

```dart
import 'package:flame/input.dart';

class SpaceShooterGame extends FlameGame with PanDetector {
  late Player player;

  @override
  Future<void> onLoad() async {
    // omitted
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
  }
}

```

At this point, our game should be receiving all the pan update inputs, but we are not doing anything
with these events.

We now need a way to move our player. That can be achieved by simply saving our `Player` component
to a variable inside our game class, adding a method `move` to our `Player`, and just connect
them:

```dart
class Player extends PositionComponent { 
  static final _paint = Paint()..color = Colors.white;
  
  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }

  void move(Vector2 delta) {
    position.add(delta);
  }
}

class SpaceShooterGame extends FlameGame with PanDetector {
  late Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = Player()
      ..position = size / 2
      ..width = 50
      ..height = 100
      ..anchor = Anchor.center;

    add(player);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.game);
  }
}
```

That is it! If you drag the screen, the player should follow your movement and we have just
implemented our very first interactive game!

Before we move to our next step, let's replace that boring white rectangle with some cool graphics.

Flame provides many classes to help us with graphical rendering. For this step, we are going to use
the `Sprite` class.

`Sprite`s are used in Flame to render static images or portions of them in the game. To render a
`Sprite` inside a `FlameGame`, we should use the `SpriteComponent` class, which wraps the `Sprite`
features into a component.

So let's refactor our current implementation, first, we can replace our inheritance from
`PositionComponent` to `SpriteComponent` (which is a component that extends from
`PositionComponent`) and load the sprite:

```dart
class Player extends SpriteComponent {
  void move(Vector2 delta) {
    position.add(delta);
  }
}

class SpaceShooterGame extends FlameGame with PanDetector {
  late Player player;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final playerSprite = await loadSprite('player-sprite.png');
    player = Player()
      ..sprite = playerSprite
      ..x = size.x / 2
      ..y = size.y / 2
      ..width = 50
      ..height = 100
      ..anchor = Anchor.center;

    add(player);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.game);
  }
}
```

And now, you should see a small blue spaceship on the screen!

A couple of notes worth mentioning:

- Unlike `PositionComponent`, `SpriteComponent` has an implementation for the `render` method, so we
can delete the previous override.
- `FlameGame` has a couple of methods for loading assets, like `loadSprite`. Those methods are
quite useful, because when used, `FlameGame` will take care of cleaning any cache when the game is
removed from the Flutter widget tree.

Before we close this step, there is one small improvement that we can do. Right now, we are loading
the sprite and passing it to our component. For now, this may seem fine, but imagine a game with
a lot of components; if the game is responsible for loading assets for all components, our code can
become a mess quite fast.

Just like `FlameGame`, components also have an `onLoad` method that can be overridden to do
initializations. But before we implement our player's load method, note that we use an attribute and
the `loadSprite` method from the `FlameGame` class.

That is not a problem! Every time our component needs to access things from its game class, we can
mix our component with the `HasGameRef` mixin; that will add a new variable to our component called
`gameRef` which will point to the game instance where the component is running. Now, let's refactor
our game a little bit:

```dart
class Player extends SpriteComponent with HasGameRef<SpaceShooterGame> {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    sprite = await gameRef.loadSprite('player-sprite.png');

    position = gameRef.size / 2;
    width = 100;
    height = 150;
    anchor = Anchor.center;
  }

  void move(Vector2 delta) {
    position.add(delta);
  }
}

class SpaceShooterGame extends FlameGame with PanDetector {
  late Player player;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    player = Player();

    add(player);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.game);
  }
}
```

If you run the game now, you will not notice any visual differences, but now we have a more scalable
structure for developing our game. And that closes this step!

```{flutter-app}
:sources: ../tutorials/space_shooter/app
:page: step2
:show: popup code
```
