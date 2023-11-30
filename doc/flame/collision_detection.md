# Collision Detection

Collision detection is needed in most games to detect and act upon two components intersecting each
other. For example an arrow hitting an enemy or the player picking up a coin.

In most collision detection systems you use something called hitboxes to create more precise
bounding boxes of your components. In Flame the hitboxes are areas of the component that can react
to collisions (and make [gesture input](inputs/gesture_input.md#gesturehitboxes)) more accurate.

The collision detection system supports three different types of shapes that you can build hitboxes
from, these shapes are Polygon, Rectangle and Circle. Multiple hitbox can be added
to a component to form the area which can be used to either detect collisions
or whether it contains a point or not,
the latter is very useful for accurate gesture detection. The collision detection does not handle
what should happen when two hitboxes collide, so it is up to the user to implement what will happen
when for example two `PositionComponent`s have intersecting hitboxes.

Do note that the built-in collision detection system does not take collisions between two hitboxes
that overshoot each other into account, this could happen when they either move very fast or
`update` being called with a large delta time (for example if your app is not in the foreground).
This behavior is called tunneling, if you want to read more about it.

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

You can also add `HasCollisionDetection` directly to another `Component` instead
of the `FlameGame`,
for example to the `World` that is used for the `CameraComponent`.
If that is done, hitboxes that are added in that component's tree will only be compared to other
hitboxes in that subtree, which makes it possible to have several worlds with collision detection
within one `FlameGame`.

Example:

```dart
class CollisionDetectionWorld extends World with HasCollisionDetection {}
```

```{note}
Hitboxes will only be connected to one collision detection system and that is
the closest parent that has the `HasCollisionDetection` mixin.
```


### CollisionCallbacks

To react to a collision you should add the `CollisionCallbacks` mixin to your component.
Example:


```{flutter-app}
:sources: ../flame/examples
:page: collision_detection
:show: widget code infobox
:width: 180
:height: 160
```

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

In this example we use Dart's `is` keyword to check what kind of component we collided with.
The set of points is where the edges of the hitboxes intersect.

Note that the `onCollision` method will be called on both `PositionComponent`s if they have both
implemented the `onCollision` method, and also on both hitboxes. The same goes for the
`onCollisionStart` and `onCollisionEnd` methods, which are called when two components and hitboxes
starts or stops colliding with each other.

When a `PositionComponent` (and hitbox) starts to collide with another `PositionComponent`
both `onCollisionStart` and `onCollision` are called, so if you don't need to do something specific
when a collision starts you only need to override `onCollision`, and vice versa.

If you want to check collisions with the screen edges, as we do in the example above, you can use
the predefined [ScreenHitbox](#screenhitbox) class.

By default all hitboxes are hollow, this means that one hitbox can be fully enclosed by another
hitbox without triggering a collision. If you want to set your hitboxes to be solid you can set
`isSolid = true`. A hollow hitbox inside of a solid hitbox will trigger a collision, but not the
other way around. If there are no intersections with the edges on a solid hitbox the center
position is instead returned.


## ShapeHitbox

The `ShapeHitbox`s are normal components, so you add them to the component that you want to add
hitboxes to just like any other component:

```dart
class MyComponent extends PositionComponent {
  @override
  void onLoad() {
    add(RectangleHitbox());
  }
}
```

If you don't add any arguments to the hitbox, like above, the hitbox will try to fill its parent as
much as possible. Except for having the hitboxes trying to fill their parents,
there are two ways to
initiate hitboxes and it is with the normal constructor where you define the hitbox by itself, with
a size and a position etc. The other way is to use the `relative` constructor which defines the
hitbox in relation to the size of its intended parent.


In some specific cases you might want to handle collisions only between hitboxes, without
propagating `onCollision*` events to the hitbox's parent component. For example, a vehicle could
have a body hitbox to control collisions and side hitboxes to check the possibility to turn left
or right.
So, colliding with a body hitbox means colliding with the component itself, whereas colliding with
a side hitbox does not mean a real collision and should not be propagated to hitbox's parent.
For this case you can set `triggersParentCollision` variable to `false`:

```dart
class MyComponent extends PositionComponent {

  late final MySpecialHitbox utilityHitbox;

  @override
  void onLoad() {
    utilityHitbox = MySpecialHitbox();
    add(utilityHitbox);
  }

  void update(double dt) {
    if (utilityHitbox.isColliding) {
      // do some specific things if hitbox is colliding
    }
  }
// component's onCollision* functions, ignoring MySpecialHitbox collisions.
}

class MySpecialHitbox extends RectangleHitbox {
  MySpecialHitbox() {
    triggersParentCollision = false;
  }

// hitbox specific onCollision* functions

}
```

You can read more about how the different shapes are defined in the
[ShapeComponents](components.md#shapecomponents) section.

Remember that you can add as many `ShapeHitbox`s as you want to your `PositionComponent` to make up
more complex areas. For example a snowman with a hat could be represented by three `CircleHitbox`s
and two `RectangleHitbox`s as its hat.

A hitbox can be used either for collision detection or for making gesture detection more accurate
on top of components, see more regarding the latter in the section about the
[GestureHitboxes](inputs/gesture_input.md#gesturehitboxes) mixin.


### CollisionType

The hitboxes have a field called `collisionType` which defines when a hitbox should collide with
another. Usually you want to set as many hitboxes as possible to `CollisionType.passive` to make
the collision detection more performant. By default the `CollisionType` is `active`.

The `CollisionType` enum contains the following values:

- `active` collides with other `Collidable`s of type active or passive
- `passive` collides with other `Collidable`s of type active
- `inactive` will not collide with any other `Collidable`s

So if you have hitboxes that you don't need to check collisions against each other you can mark
them as passive by setting `collisionType: CollisionType.passive` in the constructor,
this could for example be ground components or maybe your enemies don't need
to check collisions between each other, then they could be marked as `passive` too.

Imagine a game where there are a lot of bullets, that can't collide with each other, flying towards
the player, then the player would be set to `CollisionType.active` and the bullets would be set to
`CollisionType.passive`.

Then we have the `inactive` type which simply doesn't get checked at all
in the collision detection.
This could be used for example if you have components outside of the screen that you don't care
about at the moment but that might later come back in to view so they are not completely removed
from the game.

These are just examples of how you could use these types, there will be a lot more use cases for
them so don't doubt to use them even if your use case isn't listed here.


### PolygonHitbox

It should be noted that if you want to use collision detection or `containsPoint` on the `Polygon`,
the polygon needs to be convex. So always use convex polygons or you will most likely run into
problems if you don't really know what you are doing.
It should also be noted that you should always define the vertices in your polygon
in a counter-clockwise order.

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

In the `CompositeHitbox` you can add multiple hitboxes so that
they emulate being one joined hitbox.

If you want to form a hat for example you might want
to use two [](#rectanglehitbox)s to follow that
hat's edges properly, then you can add those hitboxes to an instance of this class and react to
collisions to the whole hat, instead of for just each hitbox separately.


## Broad phase

If your game field isn't huge and does not have a lot of collidable components - you don't have to
worry about the broad phase system that is used, so if the standard implementation is performant
enough for you, you probably don't have to read this section.

A broad phase is the first step of collision detection where potential collisions are calculated.
Calculating these potential collisions is faster than to checking the intersections exactly,
and it removes the need to check all hitboxes against each other and
therefore avoiding O(n²).

The broad phase produces a set of potential collisions (a set of
`CollisionProspect`s). This set is then used to check the exact intersections between
hitboxes (sometimes called "narrow phase").

By default, Flame's collision detection is using a sweep and prune broadphase step. If your game
requires another type of broadphase you can write your own broadphase by extending `Broadphase` and
manually setting the collision detection system that should be used.

For example, if you have implemented a broadphase built on a magic algorithm
instead of the standard sweep and prune, then you would do the following:

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  MyGame() : super() {
    collisionDetection =
        StandardCollisionDetection(broadphase: MagicAlgorithmBroadphase());
  }
}
```


## Quad Tree broad phase

If your game field is large and the game contains a lot of collidable
components (more than a hundred), standard sweep and prune can
become inefficient. If it does, you can try to use the quad tree broad phase.

To do this, add the `HasQuadTreeCollisionDetection` mixin to your game instead of
`HasCollisionDetection` and call the `initializeCollisionDetection` function on game load:

```dart
class MyGame extends FlameGame with HasQuadTreeCollisionDetection {
  @override
  void onLoad() {
    initializeCollisionDetection(
      mapDimensions: const Rect.fromLTWH(0, 0, mapWidth, mapHeight),
      minimumDistance: 10,
    );
  }
}
```

When calling `initializeCollisionDetection` you should pass it the correct map dimensions, to make
the quad tree algorithm to work properly. There are also additional parameters to make the system
more efficient:

- `minimumDistance`: minimum distance between objects to consider them as possibly colliding.
  If `null` - the check is disabled, it is default behavior
- `maxObjects`: maximum objects count in one quadrant. Default to 25.
- `maxDepth`: maximum nesting levels inside quadrant. Default to 10

If you use the quad tree system, you can make it even more efficient by implementing the
`onComponentTypeCheck` function of the `CollisionCallbacks` mixin in your components.
It is useful if you need to prevent collisions of items of different types.
The result of the calculation is cached so
you should not check any dynamic parameters here, the function is intended to be used as a pure
type checker:

```dart
class Bullet extends PositionComponent with CollisionCallbacks {

  @override
  bool onComponentTypeCheck(PositionComponent other) {
    if (other is Player || other is Water) {
      // do NOT collide with Player or Water
      return false;
    }
    // Just return true if you're not interested in the parent's type check result.
    // Or call super and you will be able to override the result with the parent's
    // result.
    return super.onComponentTypeCheck(other);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    // Removes the component when it comes in contact with a Brick.
    // Neither Player nor Water would be passed to this function
    // because these classes are filtered out by [onComponentTypeCheck]
    // in an earlier stage.
    if (other is Brick) {
      removeFromParent();
    }
    super.onCollisionStart(intersectionPoints, other);
  }
}
```

After intensive gameplay a map could become over-clusterized with a lot of empty quadrants.
Run `QuadTree.optimize()` to perform a cleanup of empty quadrants:

```dart
class QuadTreeExample extends FlameGame
        with HasQuadTreeCollisionDetection {

  /// A function called when intensive gameplay session is over
  /// It also might be scheduled, but no need to run it on every update.
  /// Use right interval depending on your game circumstances
  onGameIdle() {
    (collisionDetection as QuadTreeCollisionDetection)
            .quadBroadphase
            .tree
            .optimize();
  }
}

```

```{note}
Always experiment with different collision detection approaches
and check how they perform on your game.
It is not unheard of that `QuadTreeBroadphase` is significantly 
_slower_ than the default.
Don't assume that the more sophisticated approach is always faster.
```


## Ray casting and Ray tracing

Ray casting and ray tracing are methods for sending out rays from a point in your game and being
able to see what these rays collide with and how they reflect after hitting something.

For all of the following methods, if there are any hitboxes that you wish to ignore,
you can add the `ignoreHitboxes` argument which is a list of the hitboxes
that you wish to disregard for the call.
This can be quite useful for example if you are casting rays from within a hitbox,
which could be on your player or NPC;
or if you don't want a ray to bounce off a `ScreenHitbox`.


### Ray casting

Ray casting is the operation of casting out one or more rays from a point and see if they hit
anything, in Flame's case, hitboxes.

We provide two methods for doing so, `raycast` and `raycastAll`. The first one just casts out
a single ray and gets back a result with information about what and where the ray hit, and some
extra information like the distance, the normal and the reflection ray.
The second one, `raycastAll`,
works similarly but sends out multiple rays uniformly around the origin, or within an angle
centered at the origin.

By default, `raycast` and `raycastAll` scan for the nearest hit irrespective of
how far it lies from the ray origin.
But in some use cases, it might be interesting to find hits only within a certain
range. For such cases, an optional `maxDistance` can be provided.

To use the ray casting functionality you have to have the `HasCollisionDetection` mixin on your
game. After you have added that you can call `collisionDetection.raycast(...)` on your game class.

Example:

```{flutter-app}
:sources: ../flame/examples
:page: ray_cast
:show: widget code infobox
:width: 180
:height: 160
```

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  @override
  void update(double dt) {
    super.update(dt);
    final ray = Ray2(
        origin: Vector2(0, 100),
        direction: Vector2(1, 0),
    );
    final result = collisionDetection.raycast(ray);
  }
}
```

In this example one can see that the `Ray2` class is being used, this class defines a ray from an
origin position and a direction (which are both defined by `Vector2`s). This particular ray starts
from `0, 100` and shoots a ray straight to the right.

The result from this operation will either be `null` if the ray didn't hit anything, or a
`RaycastResult` which contains:

- Which hitbox the ray hit
- The intersection point of the collision
- The reflection ray, i.e. how the ray would reflect on the hitbox that it hix
- The normal of the collision, i.e. a vector perpendicular to the face of the hitbox that it hits

If you are concerned about performance you can pre create a `RaycastResult` object that you send in
to the method with the `out` argument, this will make it possible for the method to reuse this
object instead of creating a new one for each iteration. This can be good if you do a lot of
ray casting in your `update` methods.


#### raycastAll

Sometimes you want to send out rays in all, or a limited range, of directions from an origin. This
can have a lot of applications, for example you could calculate the field of view of a player or
enemy, or it can also be used to create light sources.

Example:

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  @override
  void update(double dt) {
    super.update(dt);
    final origin = Vector2(200, 200);
    final result = collisionDetection.raycastAll(
      origin,
      numberOfRays: 100,
    );
  }
}
```

In this example we would send out 100 rays from (200, 200) uniformly spread in all directions.

If you want to limit the directions you can use the `startAngle` and the `sweepAngle` arguments.
Where the `startAngle` (counting from straight up) is where the rays will start and then the rays
will end at `startAngle + sweepAngle`.

If you are concerned about performance you can re-use the `RaycastResult` objects that are created
by the function by sending them in as a list with the `out` argument.


### Ray tracing

Ray tracing is similar to ray casting, but instead of just checking what the ray hits you can
continue to trace the ray and see what its reflection ray (the ray bouncing off the hitbox) will
hit and then what that casted reflection ray's reflection ray will hit and so on, until you decide
that you have traced the ray for long enough. If you imagine how a pool ball would bounce on a pool
table for example, that information could be retrieved with the help of ray tracing.

Example:

```{flutter-app}
:sources: ../flame/examples
:page: ray_trace
:show: widget code infobox
:width: 180
:height: 160
```

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  @override
  void update(double dt) {
    super.update(dt);
    final ray = Ray2(
        origin: Vector2(0, 100),
        direction: Vector2(1, 1)..normalize()
    );
    final results = collisionDetection.raytrace(
      ray,
      maxDepth: 100,
    );
    for (final result in results) {
      if (result.intersectionPoint.distanceTo(ray.origin) > 300) {
        break;
      }
    }
  }
}
```

In the example above we send out a ray from (0, 100) diagonally down to the right
and we say that we want it the bounce on at most 100 hitboxes,
it doesn't necessarily have to get 100 results since at
some point one of the reflection rays might not hit a hitbox and then the method is done.

The method is lazy, which means that it will only do the calculations that you ask for, so you have
to loop through the iterable that it returns to get the results, or do `toList()` to directly
calculate all the results.

In the for-loop it can be seen how this can be used, in that loop we check whether the current
reflection rays intersection point (where the previous ray hit the hitbox) is further away than 300
pixels from the origin of the starting ray, and if it is we don't care about the rest
of the results (and then they don't have to be calculated either).

If you are concerned about performance you can re-use the `RaycastResult` objects that are created
by the function by sending them in as a list with the `out` argument.


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


## Examples

- [https://examples.flame-engine.org/#/Collision%20Detection_Collidable%20AnimationComponent]
- [https://examples.flame-engine.org/#/Collision%20Detection_Circles]
- [https://examples.flame-engine.org/#/Collision%20Detection_Multiple%20shapes]
- [https://github.com/flame-engine/flame/tree/main/examples/lib/stories/collision_detection]
