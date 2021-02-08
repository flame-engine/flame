# Collision detection
The collision detection system supports three different types of shapes that you can build hitboxes
from, these shapes are Polygon, Rectangle and Circle. A hitbox can be represented by many shapes to
form the area which can be used to either detect collisions or whether it contains a point or not,
the latter is very useful for accurate gesture detection. The collision detection does not handle
what should happen when two hitboxes collide, so it is up to the user to implement what will happen
when two position components have intersecting hitboxes.

## Mixins
### Hitbox
The `Hitbox` mixin is mainly used for two things; to make detection of collisions with other
hitboxes and gestures on top of your `PositionComponent`s more accurate. Say that you have a fairly
round rock as a `SpriteComponent` for example, then you don't want to register input that is in the
corner of the image where the rock is not displayed. Then you can use the `Hitbox` mixin to define
a more accurate polygon for which the input should be within for the event to be counted on your
component.

You can add new shapes to the `Hitbox` just like they are added in the below `Collidable` example.

### Collidable
The `Collidable` mixin is added to a `PositionComponent` that has a `HitBox` and it is used for
detecting collisions with other `Collidable`s. To make your component collidable you would start off
like this:

```dart
class MyCollidable extends PositionComponent with Hitbox, Collidable {
  MyCollidable (
    // This could also be done in onLoad instead of in the constructor
    final shape = HitboxPolygon([
      Vector2(0, 1),
      Vector2(1, 0),
      Vector2(0, -1),
      Vector2(-1, 0),
    ]);
    addShape(shape);
  }
}
```

The `HitboxPolygon` added to the `Collidable` here is a diamond shape(◇).
More about how the different shapes are defined in the [Shapes](#/collision_detection?id=shapes)
section.

Remember that you can add as many `HitboxShape`s as you want to your `Collidable` to make up more
complex shapes. For example a snowman with a hat could be represented by three `HitboxCircle`s and
a polygon as its hat.

To react to a collision you should override the `collisionCallback` in your component.
Example:

```dart
class MyCollidable extends PositionComponent with Hitbox, Collidable {
  ...

  @override
  void collisionCallback(Set<Vector2> points, Collidable other) {
    if (other is CollidableScreen) {
      ...
    } else if (other is YourOtherCollidable) {
      ...
    }
  }
}
```

In this example it can be seen how the Dart `is` keyword is used to check which other `Collidable`
that your component collided with. The set of points is where the hitboxes of the collidables
intersected. If you want to check collisions with the screen edges you can use the predefined
[ScreenCollidable](#/collision_detection?id=screencollidable) class.

### HasCollidables
If you want to use this collision detection in your game you have to add the `HasCollidables` mixin
to your game so that the game knows that it should keep track of which components that can collide.

Example:
```dart
class MyGame extends BaseGame with HasCollidables {
  ...
}
```

Now when you add your `Collidable`'s to your game they will automatically be checked for collisions.

### ScreenCollidable
`ScreenCollidable` is not a mixin, but a pre-made collidable component which represents the edges of
your game/screen. If you add a `ScreenCollidable` to your game your other collidables will be
notified when they collide with the edges. It doesn't take any arguments, it only depends on the
`size` of the game that it is added to, so to add it you can just do `add(ScreenCollidable())` in
your game if you don't want the `ScreenCollidable` itself to be notified when something collides
with it, then you need to extend it and implement the `collisionCallback` for it.

## Shapes
### Shape
A Shape is the base class for representing a scalable geometrical shape. There are currently three
shapes:

- Polygon
- Rectangle (which is just a simplified Polygon)
- Circle

It should be noted that if you want to use collision detection or `containsPoint` on the `Polygon`,
the polygon needs to be convex. So always use convex polygons or you will most likely run into
problems if you don't really know what you are doing.

### HitboxShape
A HitboxShape is a Shape defined from the center position of the component that it is attached to
and it has the same bounding size and angle as the component. A HitboxShape is also the type of
shape that you add to your Hitbox, or Collidable.

## Example
https://github.com/flame-engine/flame/tree/master/doc/examples/collidables