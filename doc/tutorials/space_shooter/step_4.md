# Adding bullets

For this next step we will add a very important feature to any space shooter game, shooting!

Here is how we will implement it: since we already control our space ship by dragging on the screen
with the mouse/fingers, we will make the ship auto shoot when the player starts dragging and
stop shooting when the gesture/input has ended.

First, let's create a `Bullet` component that will represent the shots in the game.

```dart
class Bullet extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Bullet({
    super.position,
  }) : super(
          size: Vector2(25, 50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'bullet.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .2,
        textureSize: Vector2(8, 16),
      ),
    );
  }
}
```

So far, this does not introduce any new concepts, we just created a component and set
up its animations attributes.

The `Bullet` behavior is a simple one, it always moves towards the top of the screen and should
be removed from the game if it is not visible anymore, so let's add an `update` method to it
and make it happen:

```dart
class Bullet extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Bullet({
    super.position,
  }) : super(
          size: Vector2(25, 50),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    // Omitted
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * -500;

    if (position.y < -height) {
      removeFromParent();
    }
  }
}
```

The above code should be straight forward, but lets break it down:

- We add to the bullet's y axis position at a rate of -500 pixels per second. Remember going up
in the y axis means getting closer to `0` since the top left corner of the screen is `0, 0`.
- If the y is smaller than the negative value of the bullet's height, means that the component is
completely off the screen and it can be removed.

Right, we now have a `Bullet` class ready, so lets start to implement the action of shooting.
First thing, let's create two empty methods in the `Player` class, `startShooting()` and
`stopShooting()`.

```dart
class Player extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {

  // Rest of implementation omitted

  void startShooting() {
    // TODO
  }

  void stopShooting() {
    // TODO
  }
}
```

And let's hook into those methods from the game class by using the `onPanStart()`
and `onPanEnd()` methods from the `PanDetector` mixin that we already have been using for the ship
movement:

```dart
class SpaceShooterGame extends FlameGame with PanDetector {
  late Player player;

  // Rest of implementation omitted

  @override
  void onPanUpdate(DragUpdateInfo info) {
    player.move(info.delta.global);
  }

  @override
  void onPanStart(DragStartInfo info) {
    player.startShooting();
  }

  @override
  void onPanEnd(DragEndInfo info) {
    player.stopShooting();
  }
}
```

We now have everything set up, so let's write the shooting routine in our player class.

Remember, the shooting behavior will be adding bullets through time intervals when the player is
dragging the starship.

We could implement the time interval code and the spawning manually, but Flame
provides a component out of the box for that, the `SpawnComponent`, so let's take advantage of it:


```dart
class Player extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  late final SpawnComponent _bulletSpawner;

  @override
  Future<void> onLoad() async {
    // Loading animation omitted

    _bulletSpawner = SpawnComponent(
      period: .2,
      selfPositioning: true,
      factory: (index) {
        return Bullet(
          position: position +
              Vector2(
                0,
                -height / 2,
              ),
        );

        return bullet;
      },
      autoStart: false,
    );

    game.add(_bulletSpawner);
  }

  void move(Vector2 delta) {
    position.add(delta);
  }

  void startShooting() {
    _bulletSpawner.timer.start();
  }

  void stopShooting() {
    _bulletSpawner.timer.stop();
  }
}
```

Hopefully the code above speaks for itself, but let's look at it in more detail:

- First we declared a `SpawnComponent` called `_bulletSpawner` in our game class, we needed it
to be an variable accessible to the whole component since we will be accessing it in the
`startShooting` and `stopShooting` methods.
- We initialize our `_bulletSpawner` in the `onLoad` method. In the first argument, `period`, we set
how much time in seconds it will take between calls, and we choose `.2` seconds for now.
- We set `selfPositioning: true` so the spawn component doesn't try to position itself 
since we want to handle that ourselves to make the bullets spawn out of the ship.
- The `factory` attribute receives a function that will be called every time the `period` is reached 
and return the create component.
- We set `autoStart: false` so it does not start by default.
- Finally we add the `_bulletSpawner` to our component, so it can be processed in the game loop.
- Note how the `_bulletSpawner` is added to the game instead of the player, since the bullets
are part of the whole game and not the player itself.

With the `_bulletSpawner` all set up, the only missing piece now is starting the
`_bulletSpawner.timer` in `startShooting()` and stopping it in the `stopShooting()`!

And that closes this step, putting us real close to a real game!

```{flutter-app}
:sources: ../tutorials/space_shooter/app
:page: step4
:show: popup code
```

[Next step: Adding Enemies](./step_5.md)
