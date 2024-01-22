# Adding Enemies

Now that the starship is able to shoot, we need something for the player to shoot at! So for
this step we will work on adding enemies to the game.

So first things first, let's create an `Enemy` class that will represent the enemies in game:

```dart
class Enemy extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {

  Enemy({
    super.position,
  }) : super(
          size: Vector2.all(enemySize),
          anchor: Anchor.center,
        );


  static const enemySize = 50.0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'enemy.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        stepTime: .2,
        textureSize: Vector2.all(16),
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    position.y += dt * 250;

    if (position.y > game.size.y) {
      removeFromParent();
    }
  }
}
```

Note that for now, the `Enemy` class is super similar to the `Bullet` one, the only differences are
their sizes, animation information and that bullets travel from bottom to top, while enemies travel from
top to bottom, so nothing new here.

Next we need to make the enemies spawn in the game, the logic that we will do here will be simple,
we will simply make enemies spawn from the top of the screen at a random position on the `x` axis.

Once again, we could manually make all the time based event in the game's `update` method, maintain
a random instance to get the enemy x position and so on and so forth, but Flame provides us a
way to avoid having to write all that by ourselves, we can use the `SpawnComponent`! So in the
`SpaceShooterGame.onLoad` method let's add the following code:

```dart
    add(
      SpawnComponent(
        factory: (index) {
          return Enemy();
        },
        period: 1,
        area: Rectangle.fromLTWH(0, 0, size.x, -Enemy.enemySize),
      ),
    );
```

The `SpawnComponent` will take a couple of arguments, let's review them as they appear in the code:

- `factory` receives a function which has the index of the component that should be created. We
don't use the index in our code, but it is useful to create more advanced spawn routines.
This function should return the created component, in our case a new instance of `Enemy`.
- `period` simply define the interval in which a new component will be spawned.
- `area` defines the possible area where the components can be placed once created. In our case they
should be placed in the area above the screen top, so they can be seen as they are arriving into the
playable area.

And this concludes this short step!

```{flutter-app}
:sources: ../tutorials/space_shooter/app
:page: step5
:show: popup code
```
