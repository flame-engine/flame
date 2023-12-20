# Enemies and Bullets collision

Right, we real close to a playable game, we have enemies, we have the ability to shoot bullets
at them! We need now to do something when a bullet hits an enemy.

Flame provides a collision system out of the box, which we will use to implement a logic which when
a bullet and an enemy comes into contact, both are removed!

First thing we need to do is to let our `FlameGame` that we want collisions between components to
be checked. In order to do so, simply add the `HasCollisionDetection` missing to the declaration
of the game class:

```dart
class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection {
    // ...
}
```

With that, flame now will start to check if components collided with each other. Next we need to
identify which components can cause collisions.

In our case those are the `Bullet` and `Enemy` components and we need to add a hitbox to them.

A hitbox is nothing more than the dimension which define the area of a component that can hit
other objects. Flame offers a collection of classes to define a hitbox, the simplest of them is
the `RectangleHitbox`, which like the name implies will make a rectangular area the component's
hitbox.

Hitboxes are also components, so, in order to add them to our components we can simply add 
the following line on both the `Bullet` and `Enemy` `onLoad` method:

```dart
add(RectangleHitbox());
```

From this point on, Flame will take care of checking the collision between those two components,
we need now to do something when they came in contact.

We can start that by receiving the collision events in one of the classes. I will choose the
`Enemy` class to be the one responsible to listenning to events, since in theory, there will
mostly likelly have fewer enemies than bullets, so we can less checkings if we keep that logic
on the enemies.

To listen collision event we need to simply add the `CollisionCallbacks` mixin to a component,
by doing so we will be able to override some methods like: `onCollisionStart`, `onCollisionEnd`
and so on.

So let's do that and make a few changes to the `Enemy` class:

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

As you can see, we simply added the mixin to the class, overriden the `onCollisionStart` method,
where we check with the component that collided with us was a `Bullet` and if it was, then
we remove both the current `Enemy` instance and the `Bullet`.

If you run the game now you will finally be able to defeat the enemies crawling down the screen!

To add some final touches, let's add some explosion animations and add more action to the game!

First, let's create the explosion class:

```dart
class Explosion extends SpriteAnimationComponent
    with HasGameReference<SpaceShooterGame> {
  Explosion({
    super.position,
  }) : super(size: Vector2.all(150));

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

    anchor = Anchor.center;
    removeOnFinish = true;
  }
}
```

Not much new in it, the biggest difference on it compared to the other animations components is
that we are passing `loop: false` in the `SpriteAnimationData.sequenced` constructor and we are
setting `removeOnFinish = true;`. We do that so when the animation is finished, it will
automatically be removed from the game!

And to finalize, we make a small change in the `onCollisionStart` method from the `Enemy` class
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

And that is it! We finally a game which provides all the minimum necessary elements for a space
shooter, from here you can use what you learned to build more features in the game like making
the player suffer damage if it clashes with and enemy, or make the enemy shoot back, or maybe
both?

Good hunting pilot, and happy coding!
