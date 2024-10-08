# Enemies and Bullets collision

Right, we are really close to a playable game, we have enemies and we have the ability to shoot bullets
at them! We now need to do something when a bullet hits an enemy.

Flame provides a collision detection system out of the box, which we will use to implement our
logic when a bullet and an enemy come into contact. The result will be that both are removed!

First we need to let our `FlameGame` know that we want collisions between components to
be checked. In order to do so, simply add the `HasCollisionDetection` mixin to the declaration
of the game class:

```dart
class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection {
    // ...
}
```

With that, Flame now will start to check if components have collided with each other. Next we need to
identify which components can cause collisions.

In our case those are the `Bullet` and `Enemy` components and we need to add hitboxes to them.

A hitbox is nothing more than a defined part of the component's area that can hit
other objects. Flame offers a collection of classes to define a hitbox, the simplest of them is
the `RectangleHitbox`, which like the name implies, will set a rectangular area as the component's
hitbox.

Hitboxes are also components, so we can simply add them to the components that we want to have hitboxes.
Let's start by adding the following line to the `Enemy` class:

```dart
add(RectangleHitbox());
```

For the bullet we will do the same, but with a slight difference:

```dart
add(
  RectangleHitbox(
    collisionType: CollisionType.passive,
  ),
);
```

The `collisionType`s are very important to understand, since they can directly impact the game
performance!

There are three types of collisions in Flame:

- `active` collides with other hitboxes of type active or passive
- `passive` collides with other hitboxes of type active
- `inactive` will not collide with any other hitbox

Usually it is smart to mark `hitboxes` from components that will have a higher number of instances
as passive, so they will be taken into account for collision, but they themselves will not check
their own collisions, drastically reducing the number of checking, giving a better performance
to the game!

And since in this game we anticipate that there will be more bullets than enemies, we set the
bullets to have a passive collision type!

From this point on, Flame will take care of checking the collision between those two components and
we now need to do something when this occurs.

We start by receiving the collision events in one of the classes. Since `Bullet`s have a
passive collision type, we will also add the collision checking logic to the `Enemy` class.

To listen for collision events we need to add the `CollisionCallbacks` mixin to the component.
By doing so we will be able to override some methods like `onCollisionStart()` and `onCollisionEnd()`.

So let's make a few changes to the `Enemy` class:

```dart
class Enemy extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame>, CollisionCallbacks {

  // Other methods omitted

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      removeFromParent();
      other.removeFromParent();
    }
  }
}
```

As you can see, we added the mixin to the class, overrode the `onCollisionStart` method,
where we check whether the component that collided with us was a `Bullet` and if it was, then
we remove both the current `Enemy` instance and the `Bullet`.

If you run the game now you will finally be able to defeat the enemies crawling down the screen!

To add some final touches, let's add some explosion animations to introduce more action to the game!

First, let's create the explosion class:

```dart
class Explosion extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Explosion({
    super.position,
  }) : super(
          size: Vector2.all(150),
          anchor: Anchor.center,
          removeOnFinish: true,
        );


  @override
  Future<void> onLoad() async {
    await super.onLoad();

    animation = await game.loadSpriteAnimation(
      'explosion.png',
      SpriteAnimationData.sequenced(
        amount: 6,
        stepTime: .1,
        textureSize: Vector2.all(32),
        loop: false,
      ),
    );
  }
}
```

There is not much new in it, the biggest difference compared to the other animation components is
that we are passing `loop: false` in the `SpriteAnimationData.sequenced` constructor and that we are
setting `removeOnFinish: true;`. We do that so that when the animation is finished, it will
automatically be removed from the game!

And finally, we make a small change in the `onCollisionStart()` method in the `Enemy` class
in order to add the explosion to the game:

```dart
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Bullet) {
      removeFromParent();
      other.removeFromParent();
      game.add(Explosion(position: position));
    }
  }
```

And that is it! We finally have a game which provides all the minimum necessary elements for a space
shooter, from here you can use what you learned to build more features in the game like making
the player suffer damage if it clashes with an enemy, or make the enemies shoot back, or maybe
both?

Good hunting pilot, and happy coding!

```{flutter-app}
:sources: ../tutorials/space_shooter/app
:page: step6
:show: popup code
```
