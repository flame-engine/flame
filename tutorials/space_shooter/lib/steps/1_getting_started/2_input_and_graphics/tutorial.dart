const tutorial = ['''
# Controlling the player and adding some graphics
''','''
Now that the bases for our game and a component for our player, lets add some interactive to it,
lets begin that by allowing the player to be controlled by the mouse/gestures.

There are a couple of ways of doing that on Flame, for this step we will do that by using one of
Flame's gestures detectors: `PanDetector`.

This detector will make our game class receive pan (or drag) events, to use it, it as simple as
adding the `PanDetector` mixin to our game class and override its listeners methods, for our game
we will use the `onPadUpdate` method, our game class will look like the following:
''','''```
import 'package:flame/input.dart';

class SpaceShooterGame extends FlameGame with PanDetector {
  late Player player;

  @override
  Future<void>? onLoad() async {
    // omitted
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
  }
}
```''','''
At this point our game should be receiving all the pan updates inputs, but we are not doing
anything with those events.

We need now a way to move our player, we can simply do that by saving our `Player` component to a
variable inside our game class, and a method `move` to our `Player` and just connect them, we can
implement that with something like this:
''','''```
class Player extends PositionComponent {
  @override
  void render(Canvas canvas) {
    canvas.drawRect(toRect(), Paint()..color = Colors.white);
  }

  void move(Vector2 delta) {
    position.add(delta);
  }
}

class SpaceShooterGame extends FlameGame with PanDetector {
  late Player player;

  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    player = Player()
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
```''','''
That is it! is you drag the screen, the player should follow your movement and we have just
implemented our first interactive game!

Before we move to our next step, lets replace that boring white rectangle to a some cool graphics.

Flame provides many classes to help us with graphical rendering, for this step we are going to use
the `Sprite` class.

`Sprite` are used in Flame to render static images, or portions of it on the game. To render a
`Sprite` inside a `FlameGame`, we can use the `SpriteComponent` class.

So lets refactor our current implementation, lets replace our inheritance from `PositionComponent`
to `SpriteComponent` and load a sprite. Our code will look like the follow now:
''','''```
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
```''','''
And now, you should see a small blue spaceship on the screen!

A couple of notes worth mentioning:
 - Unlike `PositionComponent`, `SpriteComponent` has an implementation from the `render` method
that actually renders something, so we don't need to override it anymore.
 - `FlameGame` has a couple of methods for loading assets, like `loadSprite`, those methods are
quite handful, because when used, `FlameGame` will take care of cleaning any cache when the game
is removed from the Flutter widget tree.

Before we close this step, there is one small improvement that we can do. Right now, we are loading
the sprite and passing it to our component. For now, this may seen fine, but imagine a game with
dozen of components, if the game is respnsible for loading their assets, our code can get a mess
quite fast.

Just like `FlameGame`, components also have a `onLoad` method that can be overridden to initialize
components. But before we implement our player own load method, note that we use a attribute and
the `loadSprite` method, which belongs to the `FlameGame`.

That is not a problem, everytime our component needs to access things on its game class, we can mix
our component with the `HasGameRef` mixin, that will add a new variable to our component called
`gameRef` which will point to the game where the component is running. Now, lets refactor our game:
''','''```
class Player extends SpriteComponent with HasGameRef<SpaceShooterGame> {
  @override
  Future<void>? onLoad() async {
    await super.onLoad();

    final playerSprite = await gameRef.loadSprite('player-sprite.png');
    sprite = playerSprite;

    x = gameRef.size.x / 2;
    y = gameRef.size.y / 2;
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
  Future<void>? onLoad() async {
    await super.onLoad();

    player = Player();

    add(player);
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.game);
  }
}
```''','''
If you run the game now, you will not notice any visual differences, but now we have a more
scalable structure to grow our game on.
'''
];
