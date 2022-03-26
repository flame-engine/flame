# Collision detection

Collision detection is needed in most games to detect and act upon two components intersecting each
other. For example an arrow hitting an enemy or the player picking up a coin.

In most collision detection systems you use something called hitboxes to create more precise
bounding boxes of your components. In Flame the hitboxes are areas of the component that can react
to collisions (and make [gesture input](inputs/gesture-input.md#gesturehitboxes)) more accurate.

The collision detection system supports three different types of shapes that you can build hitboxes
from, these shapes are Polygon, Rectangle and Circle. Multiple hitbox can be added to a component to
form the area which can be used to either detect collisions or whether it contains a point or not,
the latter is very useful for accurate gesture detection. The collision detection does not handle
what should happen when two hitboxes collide, so it is up to the user to implement what will happen
when for example two `PositionComponent`s have intersecting hitboxes.

Do note that the built-in collision detection system does not take collisions between two hitboxes
that overshoot each other into account, this could happen when they either move very fast or
`update` being called with a large delta time (for example if your app is not in the foreground).
This behaviour is called tunneling, if you want to read more about it.

Also note that the collision detection system has a limitation that makes it not work properly if
you have certain types of combinations of flips and scales of the ancestors of the hitboxes.


## Mixins

### HasCollisionDetection

If you want to use collision detection in your game you have to add the `HasCollisionDetection`
mixin to your game so that it can keep track of the components that can collide.

Example:

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  // ...
}
```

Now when you add `ShapeHitbox`s to components that are then added to the game, they will
automatically be checked for collisions.


### CollisionCallbacks

To react to a collision you should add the `CollisionCallbacks` mixin to your component.
Example:

```dart
class MyCollidable extends PositionComponent with CollisionCallbacks {
  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    if (other is ScreenHitbox) {
      //...
    } else if (other is YourOtherComponent) {
      //...
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    if (other is ScreenHitbox) {
      //...
    } else if (other is YourOtherComponent) {
      //...
    }
  }
}
```

In this example we use Dart's `is` keyword to check what kind of component we collided with. The set
of points is where the edges of the hitboxes intersect.

Note that the `onCollision` method will be called on both `PositionComponent`s if they have both
implemented the `onCollision` method, and also on both hitboxes. The same goes for the
`onCollisionStart` and `onCollisionEnd` methods, which are called when two components and hitboxes
starts or stops colliding with each other.

When a `PositionComponent` (and hitbox) starts to collide with another `PositionComponent`
both `onCollisionStart` and `onCollision` are called, so if you don't need to do something specific
when a collision starts you only need to override `onCollision`, and vice versa.

If you want to check collisions with the screen edges, as we do in the example above, you can use
the predefined [ScreenHitbox](#screenhitbox) class.


## ShapeHitbox

The `ShapeHitbox`s are normal components, so you add them to the component that you want to add
hitboxes to just like any other component:

```dart
class MyComponent extends PositionComponent {
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }
}
```

If you don't add any arguments to the hitbox, like above, the hitbox will try to fill its parent as
much as possible. Except for having the hitboxes trying to fill their parents, there are two ways to
initiate hitboxes and it is with the normal constructor where you define the hitbox by itself, with
a size and a position etc. The other way is to use the `relative` constructor which defines the
hitbox in relation to the size of its intended parent.

You can read more about how the different shapes are defined in the
[ShapeComponents](components.md#shapecomponents) section.

Remember that you can add as many `ShapeHitbox`s as you want to your `PositionComponent` to make up
more complex areas. For example a snowman with a hat could be represented by three `CircleHitbox`s
and two `RectangleHitbox`s as its hat.

A hitbox can be used either for collision detection or for making gesture detection more accurate 
on top of components, see more regarding the latter in the section about the
[GestureHitboxes](inputs/gesture-input.md#gesturehitboxes) mixin.


### CollisionType

The hitboxes have a field called `collisionType` which defines when a hitbox should collide with
another. Usually you want to set as many hitboxes as possible to `CollisionType.passive` to make
the collision detection more performant. By default the `CollisionType` is `active`.

The `CollisionType` enum contains the following values:

- `active` collides with other `Collidable`s of type active or passive
- `passive` collides with other `Collidable`s of type active
- `inactive` will not collide with any other `Collidable`s

So if you have hitboxes that you don't need to check collisions against each other you can mark
them as passive by setting `collisionType = CollisionType.passive`, this could for example be
ground components or maybe your enemies don't need to check collisions between each other, then they
could be marked as `passive` too.

Imagine a game where there are a lot of bullets, that can't collide with each other, flying towards
the player, then the player would be set to `CollisionType.active` and the bullets would be set to
`CollisionType.passive`.

Then we have the `inactive` type which simply doesn't get checked at all in the collision detection.
This could be used for example if you have components outside of the screen that you don't care
about at the moment but that might later come back in to view so they are not completely removed
from the game.

These are just examples of how you could use these types, there will be a lot more use cases for
them so don't doubt to use them even if your use case isn't listed here.


### PolygonHitbox

It should be noted that if you want to use collision detection or `containsPoint` on the `Polygon`,
the polygon needs to be convex. So always use convex polygons or you will most likely run into
problems if you don't really know what you are doing. It should also be noted that you should always
define the vertices in your polygon in a counter-clockwise order.

The other hitbox shapes don't have any mandatory constructor, that is because they can have a
default calculated from the size of the collidable that they are attached to, but since a
polygon can be made in an infinite number of ways inside of a bounding box you have to add the
definition in the constructor for this shape.

The `PolygonHitbox` has the same constructors as the [](components.md#polygoncomponent), see that
section for documentation regarding those.


### RectangleHitbox

The `RectangleHitbox` has the same constructors as the [](components.md#rectanglecomponent), see
that section for documentation regarding those.


### CircleHitbox

The `CircleHitbox` has the same constructors as the [](components.md#circlecomponent), see that
section for documentation regarding those.


## ScreenHitbox

`ScreenHitbox` is a component which represents the edges of your viewport/screen. If you add a
`ScreenHitbox` to your game your other components with hitboxes will be notified when they
collide with the edges. It doesn't take any arguments, it only depends on the `size` of the game
that it is added to. To add it you can just do `add(ScreenHitbox())` in your game, if you don't
want the `ScreenHitbox` itself to be notified when something collides with it. Since
`ScreenHitbox` has the `CollisionCallbacks` mixin you can add your own `onCollisionCallback`,
`onStartCollisionCallback` and `onEndCollisionCallback` functions to that object if needed.


## CompositeHitbox

In the `CompositeHitbox` you can add multiple hitboxes so that they emulate being one joined hitbox.

If you want to form a hat for example you might want to use two [](#rectanglehitbox)s to follow that
hat's edges properly, then you can add those hitboxes to an instance of this class and react to
collisions to the whole hat, instead of for just each hitbox separately.


## Broad phase

Usually you don't have to worry about the broad phase system that is used, so if the standard
implementation is performant enough for you, you probably don't have to read this section.

A broad phase is the first step of collision detection where potential collisions are calculated.
To calculate these potential collisions are a lot cheaper to calculate than to check the exact
intersections from the directly and it removes the need to check all hitboxes against each other
and therefore avoiding O(n²). The broad phase produces a set of potential collisions (a set of
`CollisionProspect`s), this set is then used to check the exact intersections between hitboxes, this
is sometimes called narrow phase.

By default Flame's collision detection is using a sweep and prune broadphase step, if your game
requires another type of broadphase you can write your own broadphase by extending `Broadphase` and
manually setting the collision detection system that should be used.

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


## Comparison to Forge2D

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


## Migration from the collision detection system in v1.0

The collision detection system introduced in v1.1 is easier to use, and much more efficient than the
one that was in v1.0, but while making these improvements some breaking changes had to be made.

There is no longer a `Collidable` mixin, instead your game automatically knows when a hitbox has
been added to one of your components when the `HasCollisionDetection` mixin is added to your game.

To receive the callbacks from collisions that your component is involved in you should add the
`CollisionCallbacks` mixin to your component, and then override the same methods as you did
previously.

Since the hitboxes now are `Component`s you add them to your component with `add` instead of
`addHitbox` which was used previously.


### Name changes

 - `ScreenCollidable` -> `ScreenHitbox`
 - `HitboxCircle` -> `CircleHitbox`
 - `HitboxRectangle` -> `RectangleHitbox`
 - `HitboxPolygon` -> `PolygonHitbox`
 - `Collidable` -> `CollisionCallbacks` (Only needed when you want to receive the callbacks)
 - `HasHitboxes` -> `GestureHitboxes` (Only when you need hitboxes for gestures)
 - `CollidableType` -> `CollisionType`


## Examples

- https://examples.flame-engine.org/#/Collision%20Detection_Circles
- https://examples.flame-engine.org/#/Collision%20Detection_Multiple%20shapes
- https://examples.flame-engine.org/#/Collision%20Detection_Shapes%20without%20components
- https://github.com/flame-engine/flame/tree/main/examples/lib/stories/collision_detection
