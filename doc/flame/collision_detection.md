# Collision detection

If you want to have a full-blown physics engine in your game we recommend that you use
Forge2D by adding [flame_forge2d](https://github.com/flame-engine/flame_forge2d) as a dependency.
But if you have a simpler use-case and just want to check for collisions of components and improve
the accuracy of gestures, Flame's built-in collision detection will serve you very well.

If you have the following needs you should at least consider to use
[Forge2D](https://github.com/flame-engine/forge2d):
 - Interacting realistic forces
 - Particle systems that can interact with other bodies
 - Joints between bodies

It is a good idea to just use the Flame collision detection system if you on the other hand only
need some of the following things (since it is simpler to not involve Forge2D):
 - The ability to act on some of your components colliding
 - The ability to act on your components colliding with the screen boundaries
 - Complex shapes to act as a hitbox for your component so that gestures will be more accurate
 - Hitboxes that can tell what part of a component that collided with something

The collision detection system supports three different types of shapes that you can build hitboxes
from, these shapes are Polygon, Rectangle and Circle. Multiple hitbox can be added to a component to
form the area which can be used to either detect collisions or whether it contains a point or not,
the latter is very useful for accurate gesture detection. The collision detection does not handle
what should happen when two hitboxes collide, so it is up to the user to implement what will happen
when for example two `PositionComponent`s have intersecting hitboxes.

Do note that the built-in collision detection system does not take collisions between two hitboxes
that overshoot each other into account, this could happen when they either move too fast or `update`
being called with a large delta time (for example if your app is not in the foreground). This
behaviour is called tunneling, if you want to read more about it.

Also note that the collision detection system has a limitation that makes it not work properly if
you have certain types of combinations of flips and scales of the ancestors of the hitboxes.


## Adding hitboxes

The `HitboxShape`s are normal components, so you add them to the component that you want to add
hitboxes to just like any other component:

`component.add(HitboxRectangle());`

If you don't add any arguments to the hitbox, like above, the hitbox will try to fill its parent as
much as possible. Except for having the hitboxes trying to fill their parents, there are two ways to
initiate hitboxes and it is with the normal constructor where you define the hitbox by itself, with
a size and a position etc. The other way is to use the `fromNormals` constructor which defines the
hitbox in relation to the size of its parent. 

You can read more about how the different shapes (and hitboxes) are defined in the
[](#ShapeComponents) section.

Remember that you can add as many `HitboxShape`s as you want to your `PositionComponent` to make up
more complex areas. For example a snowman with a hat could be represented by three `HitboxCircle`s
and two `HitboxRectangle`s as its hat.


## Mixins

### GestureHitboxes

The `GestureHitboxes` mixin is used to more accurately recognize gestures on top of your
`Component`s. Say that you have a fairly round rock as a `SpriteComponent` for example, then you
don't want to register input that is in the corner of the image where the rock is not displayed,
since a `PositionComponent` is rectangular by default. Then you can use the `GestureHitboxes` mixin
to define a more accurate circle or polygon (or another shape) for which the input should be within
for the event to be registered on your component.

You can add new hitboxes to the component that has the `GestureHitboxes` mixin just like they are
added in the below `Collidable` example.


### HasCollisionDetection
If you want to use collision detection in your game you have to add the `HasCollisionDetection`
mixin to your game so that the game knows that it should use a collision detection system to keep
track of which components that can collide.

Example:
```dart
class MyGame extends FlameGame with HasCollisionDetection {
  // ...
}
```

Now when you add `HitboxShape`s to components that are then added to the game, they will
automatically be checked for collisions.

Advanced note: by default the collision detection is using a sweep and prune broadphase step, if
your game requires another type of broadphase you can write your own broadphase by extending
`Broadphase` and set the collision detection system.

For example if you have implemented a broadphase built on a quad tree instead of the standard
sweep and prune, then you would do the following:

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  MyGame() : super() {
    collisionDetection = 
        StandardCollisionDetection(broadphase: QuadTreeBroadphase());
  }
}
```


### CollisionCallbacks

To react to a collision you should add the `CollisionCallbacks` mixin to your component.
Example:

```dart
class MyCollidable extends PositionComponent with CollisionCallbacks {
  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is ScreenCollidable) {
      //...
    } else if (other is YourOtherComponent) {
      //...
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is ScreenCollidable) {
      //...
    } else if (other is YourOtherComponent) {
      //...
    }
  }
}
```

In this example it can be seen how the Dart `is` keyword is used to check which other
`PositionComponent` that your component collided with. The set of points is where the edges of the
hitboxes collided.

Note that the `onCollision` method will be called on both `PositionComponent`s if they have both
implemented the `onCollision` method, and also on both hitboxes. The same goes for the
`onCollisionStart` and `onCollisionEnd` methods, which are called when two components and hitboxes
starts or stops colliding with each other.

When a `PositionComponent` (and hitbox) starts to collide with another `PositionComponent`
both `onCollisionStart` and `onCollision` are called, so if you don't need to do something specific
when a collision starts you only need to override `onCollision`, and vice versa.

If you want to check collisions with the screen edges, as we do in the example above, you can use
the predefined [ScreenCollidable](#screencollidable) class.


## HitboxShape

A `HitboxShape` is a shape that is used to define a hitbox. A hitbox can be used either for
collision detection or for making gesture detection more accurate on top of components (see the
()[#GestureHitboxes] mixin).


### CollidableType

The hitboxes have a field called `collidableType` which defines when a hitbox should collide with
another. Usually you want to set as many hitboxes as possible to `CollidableType.passive` to make
the collision detection more performant. By default the `CollidableType` is `active`.

The `CollidableType` enum contains the following values:

- `active` collides with other `Collidable`s of type active or passive
- `passive` collides with other `Collidable`s of type active
- `inactive` will not collide with any other `Collidable`s

So if you have hitboxes that you don't need to check collisions against each other you can mark
them as passive by setting `collidableType = CollidableType.passive`, this could for example be
ground components or maybe your enemies don't need to check collisions between each other, then they
could be marked as `passive` too.

Imagine a game where there are a lot of bullets, that can't collide with each other, flying towards
the player, then the player would be set to `CollidableType.active` and the bullets would be set to
`CollidableType.passive`.

Then we have the `inactive` type which simply doesn't get checked at all in the collision detection.
This could be used for example if you have components outside of the screen that you don't care
about at the moment but that might later come back in to view so they are not completely removed
from the game.

These are just examples of how you could use these types, there will be a lot more use cases for
them so don't doubt to use them even if your use case isn't listed here.


### HitboxPolygon

It should be noted that if you want to use collision detection or `containsPoint` on the `Polygon`,
the polygon needs to be convex. So always use convex polygons or you will most likely run into
problems if you don't really know what you are doing. It should also be noted that you should always
define the vertices in your polygon in a counter-clockwise order.

The other hitbox shapes don't have any mandatory constructor, that is because they can have a
default calculated from the size of the collidable that they are attached to, but since a
polygon can be made in an infinite number of ways inside of a bounding box you have to add the
definition in the constructor for this shape.

The `HitboxPolygon` has the same constructors as the ()[#PolygonComponent], see that section for
documentation regarding those.


### HitboxRectangle

The `HitboxRectangle` has the same constructors as the ()[#RectangleComponent], see that section
for documentation regarding those.


### HitboxCircle

The `HitboxCircle` has the same constructors as the ()[#CircleComponent], see that section for
documentation regarding those.


## ShapeComponents

A `ShapeComponent` is the base class for representing a scalable geometrical shape. The shapes have
different ways of defining how they look, but they all have a size and angle that can be modified
and the shape definition will scale or rotate the shape accordingly.

These shapes are meant as a tool for using geometrical shapes in a more general way than together
with the collision detection system, where you want to use the [](#hitboxshape)s.


### PolygonComponent

A `PolygonComponent` is created by giving it a list of points in the constructor, called vertices.
This list will be transformed into a polygon with a size, which can still be scaled and rotated.

For example, this would create a square going from (50, 50) to (100, 100), with it's center in
(75, 75):
```dart
void main() {
  PolygonComponent([
    Vector2(100, 100),
    Vector2(100, 50),
    Vector2(50, 50),
    Vector2(50, 100),
  ]);
}
```

A `PolygonComponent` can also be created with a list of normals, which is points defined in relation
to the given size.

For example you could create a diamond shapes polygon like this:

```dart
void main() {
  PolygonComponent.fromNormals(
    [
      Vector2(0.0, 1.0), // Middle of top wall
      Vector2(1.0, 0.0), // Middle of right wall
      Vector2(0.0, -1.0), // Middle of bottom wall
      Vector2(-1.0, 0.0), // Middle of left wall
    ],
    size: Vector2.all(100),
  );
}
```

The vertices in the example defines percentages of the length from the center to the edge of the
screen in both x and y axis, so for our first item in our list (`Vector2(0.0, 1.0)`) we are pointing
on the middle of the top wall of the bounding box, since the coordinate system here is defined from
the center of the polygon.

![An example of how to define a polygon shape](../images/polygon_shape.png)

In the image you can see how the polygon shape formed by the purple arrows is defined by the red
arrows.


### RectangleComponent

A `RectangleComponent` is created very similarly to how a `PositionComponent` is created, since it
also has a bounding rectangle.

Something like this for example:

```dart
void main() {
  RectangleComponent(
    position: Vector2(10.0, 15.0),
    size: Vector2.all(10),
    angle: pi/2,
    anchor: Anchor.center,
  );
}
```

Dart also already has an excellent way to create rectangles and that class is called `Rect`, you can
create a Flame `RectangleComponent` from a `Rect` by using the `Rectangle.fromRect` factory, and
just like when setting the vertices of the `PolygonComponent`, your rectangle will be sized
according to the `Rect` if you use this constructor.

The following would create a `RectangleComponent` with its top left corner in `(10, 10)` and a size
of `(100, 50)`.

```dart
void main() {
  RectangleComponent.fromRect(
    Rect.fromLTWH(10, 10, 100, 50),
  );
}
```

You can also create a `RectangleComponent` from a normal, or use the default constructor to build
your rectangle from a position, size and angle.

In the example below a `RectangleComponent` of size `(25.0, 30.0)` positioned at `(100, 100)` would
be created.

```dart
void main() {
  RectangleComponent.fromNormal(
    Vector2(0.5, 1.0),
    position: Vector2.all(100),
    size: Vector2(50, 30),
  );
}
```

Since a square is a simplified version of a rectangle, there is also a constructor for creating a
square `RectangleComponent`, the only difference is that the `size` argument is a `double` instead
of a `Vector2`.

```dart
void main() {
  RectangleComponent.square(
    position: Vector2.all(100),
    size: 200,
  );
}
```


### CircleComponent

If you know how long your circle's position and/or how long the radius is going to be from the start
you can use the optional arguments `radius` and `position` to set those.

The following would create a `CircleComponent` with its center in `(100, 100)` with a radius of 5,
and therefore a size of `Vector2(10, 10)`.

```dart
void main() {
  CircleComponent(radius: 5, position: Vector2.all(100), anchor: Anchor.center);
}
```

When creating a `CircleComponent` with the `fromNormal` constructor you can define how long the
radius is in comparison to the shortest edge of the of the bounding box defined by `size`.

The following example would result in a `CircleComponent` that defined a circle with a radius of 40
(a diameter of 80). This is 

```dart
void main() {
  CircleComponent.fromNormal(0.8, size: Vector2.all(100));
}
```


## ScreenCollidable

`ScreenCollidable` is a pre-made collidable component which represents the edges of your
game/screen. If you add a `ScreenCollidable` to your game your other collidables will be
notified when they collide with the edges. It doesn't take any arguments, it only depends on the
`size` of the game that it is added to. To add it you can just do `add(ScreenCollidable())` in
your game, if you don't want the `ScreenCollidable` itself to be notified when something collides
with it. Since `ScreenCollidable` has the `CollisionCallbacks` mixin you can add your own
`onCollisionCallback`, `onStartCollisionCallback` and `onEndCollisionCallback` functions to that
object if needed.


## Examples

- https://examples.flame-engine.org/#/Collision%20Detection_Circles
- https://examples.flame-engine.org/#/Collision%20Detection_Multiple%20shapes
- https://examples.flame-engine.org/#/Collision%20Detection_Shapes%20without%20components
- https://github.com/flame-engine/flame/tree/main/examples/lib/stories/collision_detection
