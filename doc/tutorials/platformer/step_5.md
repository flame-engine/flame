# 5. Controlling Movement

If you were waiting for some serious coding, this chapter is it.  Prepare yourself as we dive in!


## Keyboard Controls

The first step will be to allow control of Ember via the keyboard.  We need to start by adding the
appropriate mixins to the game class and Ember. Add the following:

`lib/ember_quest.dart'

```dart
import 'package:flame/events.dart';

class EmberQuestGame extends FlameGame with HasKeyboardHandlerComponents {
```

`lib/actors/ember.dart`

```dart
class EmberPlayer extends SpriteAnimationComponent
    with KeyboardHandler, HasGameRef<EmberQuestGame> {
```

Now we can add a new method:

```dart
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    return true;
  }
```

Like before, if this did not trigger an auto-import, you will need the following:

```dart
import 'package:flutter/services.dart';
```

To control Ember's movement, it is easiest to set a variable where we think of the direction of
movement like a normalized vector, meaning the value will be restricted to -1, 0, or 1.  So let's
set a variable at the top of the class:

```dart
  int horizontalDirection = 0;
```

Now in our `onKeyEvent` method, we can register the key pressed by adding:

```dart
@override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalDirection = 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyA) ||
            keysPressed.contains(LogicalKeyboardKey.arrowLeft))
        ? -1
        : 0;
    horizontalDirection += (keysPressed.contains(LogicalKeyboardKey.keyD) ||
            keysPressed.contains(LogicalKeyboardKey.arrowRight))
        ? 1
        : 0;

    return true;
  }
```

Let's make Ember move by adding a few lines of code and creating our `update` method.  First, we
need to define a velocity variable for Ember.  Add the following at the top of your class:

```dart
final Vector2 velocity = Vector2.zero();
final double moveSpeed = 200;
```

This establishes a base velocity of 0 and stores `moveSpeed` so we can adjust as necessary to suit
how the game-play should be. Next, add the `update` method with the following:


```dart
  @override
  void update(double dt) {
    velocity.x = horizontalDirection * moveSpeed;
    position += velocity * dt;
    super.update(dt);
  }
```

If you run the game now, Ember moves left and right using the arrow keys or the `A` and `D` keys.
You may have noticed that Ember doesn't look back if you are going left, to fix that, add the
following code at the end of your `update` method:

```dart
if (horizontalDirection < 0 && scale.x > 0) {
  flipHorizontally();
} else if (horizontalDirection > 0 && scale.x < 0) {
  flipHorizontally();
}
```

Now Ember looks in the direction they are traveling.


## Collisions

It is time to get into the thick of it with collisions.  I highly suggest reading the
[documentation](../../flame/collision_detection.md) to understand how collisions work in Flame.  The
first thing we need to do is make the game aware that collisions are going to occur using the
`HasCollisionDetection` mixin.  Add that to `lib/ember_quest.dart` like:

```dart
class EmberQuestGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
```

Next, add the `CollisionCallbacks` mixin to `lib/actors/ember.dart` like:

```dart
class EmberPlayer extends SpriteAnimationComponent
    with KeyboardHandler, CollisionCallbacks, HasGameRef<EmberQuestGame> {
```

If it did not auto-import, you will need the following:

```dart
import 'package:flame/collisions.dart';
```

Now add the following `onCollision` method:

```dart
@override
void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  if (other is GroundBlock || other is PlatformBlock) {
    if (intersectionPoints.length == 2) {
      // Calculate the collision normal and separation distance.
      final mid = (intersectionPoints.elementAt(0) +
        intersectionPoints.elementAt(1)) / 2;

      final collisionNormal = absoluteCenter - mid;
      final separationDistance = (size.x / 2) - collisionNormal.length;
      collisionNormal.normalize();

      // If collision normal is almost upwards,
      // ember must be on ground.
      if (fromAbove.dot(collisionNormal) > 0.9) {
        isOnGround = true;
      }

      // Resolve collision by moving ember along
      // collision normal by separation distance.
      position += collisionNormal.scaled(separationDistance);
      }
    }

  super.onCollision(intersectionPoints, other);
}
```

You will need to import the following:

```dart
import '../objects/ground_block.dart';
import '../objects/platform_block.dart';
```

As well as create these class variables:

```dart
  final Vector2 fromAbove = Vector2(0, -1);
  bool isOnGround = false;
```

For the collisions to be activated for Ember, we need to add a `CircleHitbox`, so in the `onLoad`
method, add the following:

```dart
add(
  CircleHitbox(),
);
```

Now that we have the basic collisions created, we can add gravity so Ember exists in a game world
with very basic physics.  To do that, we need to create some more variables:

```dart
  final double gravity = 15;
  final double jumpSpeed = 600;
  final double terminalVelocity = 150;

  bool hasJumped = false;
```

Now we can add Ember's ability to jump by adding the following to our `onKeyEvent` method:

```dart
hasJumped = keysPressed.contains(LogicalKeyboardKey.space);
```

Finally, in our `update` method we can tie this all together with:

```dart
// Apply basic gravity
velocity.y += gravity;

// Determine if ember has jumped
if (hasJumped) {
  if (isOnGround) {
    velocity.y = -jumpSpeed;
    isOnGround = false;
  }
  hasJumped = false;
}

// Prevent ember from jumping to crazy fast as well as descending too fast and 
// crashing through the ground or a platform.
velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);
```

Earlier I mentioned that Ember was in the center of the grass, to solve this and show how collisions
and gravity work with Ember, I like to add a little drop-in when you start the game.  So in
`lib/ember_quest.dart` in the `initializeGame` method, change the following:

```dart
_ember = EmberPlayer(
  position: Vector2(128, canvasSize.y - 128),
);
```

If you run the game now, Ember should be created and fall to the ground; then you can jump around!


### Collisions with Objects

Adding the collisions with the other objects is fairly trivial. All we need to do is add the
following to the bottom of the `onCollision` method:

```dart
if (other is Star) {
  other.removeFromParent();
}

if (other is WaterEnemy) {
  hit();
}
```

When Ember collides with a star, the game will remove the star, and to implement the `hit` method for
when Ember collides with an enemy, we need to do the following:

Add the following variable at the top of your class:

```dart
bool hitByEnemy = false;
```

Additionally, add this method to your class:

```dart
// This method runs an opacity effect on ember
// to make it blink.
void hit() {
  if (!hitByEnemy) {
    hitByEnemy = true;
  }
  add(
    OpacityEffect.fadeOut(
    EffectController(
      alternate: true,
      duration: 0.1,
      repeatCount: 6,
    ),
    )..onComplete = () {
      hitByEnemy = false;
    },
  );
}
```

If the auto-imports did not occur, you will need to add the following imports to your file:

```dart
import 'package:flame/effects.dart';

import '../objects/star.dart';
import 'water_enemy.dart';
```

If you run the game now, you should be able to move around, make stars disappear, and if you
collide with an enemy, Ember should blink.


## Adding the Scrolling

This is our last task with Ember.  We need to restrict Ember's movement because as of now, Ember can
go off-screen and we never move the map.  So to implement this feature, we simply need to add the
following to our `update` method:

```dart
game.objectSpeed = 0;
// Prevent ember from going backwards at screen edge.
if (position.x - 36 <= 0 && horizontalDirection < 0) {
  velocity.x = 0;
}
// Prevent ember from going beyond half screen.
if (position.x + 64 >= game.size.x / 2 && horizontalDirection > 0) {
  velocity.x = 0;
  game.objectSpeed = -moveSpeed;
}
```

If you run the game now, Ember can't move off-screen to the left, and as Ember moves to the right,
once they get to the middle of the screen, the rest of the objects scroll by.  This is because we
are now updating `game.objectSpeed` which we established early on in the series.  Additionally,
you will see the next random segment be generated and added to the level based on the work we did in
Ground Block.

```{note}
As I mentioned earlier, I would add a section on how this game could be adapted
to a traditional level game. As we built the segments in [](step_3.md), we
could add a segment that has a door or a special block. For every `X` number of
segments loaded, we could then add that special segment. When Ember reaches that
object, we could reload the level and start all over maintaining the stars 
collected and health.
```

We are almost done!  In [](step_6.md), we will add the health system, keep track of
the score, and provide a HUD to relay that information to the player.
