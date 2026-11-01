# Performance

Just like any other game engine, Flame tries to be as efficient as possible without making the API
too complex. But given its general purpose nature, Flame cannot make any assumption about the type of
game being made. This means game developers will always have some room for performance optimizations
based on how their game functions.

On the other hand, depending on the underlying hardware, there will always be some hard limit on what
can be achieved with Flame. But apart from the hardware limits, there are some common pitfalls that
Flame users can run into, which can be easily avoided by following some simple steps. This section tries
to cover some optimization tricks and ways to avoid the common performance pitfalls.

```{note}
Disclaimer: Each Flame project is very different from the others. As a result, solution
described here cannot guarantee to always produce a significant improvement in performance.
```


## Object creation per frame

Creating objects of a class is very common in any kind of project/game. But object creation is a somewhat
involved operation. Depending on the frequency and amount of objects that are being created, the application
can experience some slow down.

In games, this is something to be very careful of because games generally have a game loop that
updates as fast as possible, where each update is called a frame. Depending on the hardware, a
game can be updating 30, 60, 120 or even higher frames per second. This means if a new object is
created in a frame, the game will end up creating as many number of objects as the frame count
per second.

Flame users generally tend to run into this problem when they override the `update` and `render`
method of a `Component`. For example, in the following innocent looking code, a new `Vector2` and
a new `Paint` object is spawned every frame. But the data inside the objects is essentially the
same across all frames. Now imagine if there are 100 instances of `MyComponent` in a game running
at 60 FPS. That would essentially mean 6000 (100 * 60) new instances of `Vector2` and `Paint`
each will be created every second.

```{note}
It is like buying a new computer every time you want to send an email or buying
a new pen every time you want to write something. Sure it gets the job done, but
it is not very economically smart.
```

```dart
class MyComponent extends PositionComponent {
  @override
  void update(double dt) {
    position += Vector2(10, 20) * dt;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), Paint());
  }
}
```

A better way of doing things would be something like as shown below. This code stores the required `Vector2`
and `Paint` objects as class members and reuses them across all the update and render calls.

```dart
class MyComponent extends PositionComponent {
  final _direction = Vector2(10, 20);
  final _paint = Paint();

  @override
  void update(double dt) {
    position.setValues(
      position.x + _direction.x * dt, 
      position.y + _direction.y * dt,
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), _paint);
  }
}
```

```{note}
To summarize, avoid creating unnecessary objects in every frame. Even a seemingly
small object can affect the performance if spawned in high volume.
```


## Unwanted collision checks

Flame has a built-in collision detection system which can detect when any two `Hitbox`es intersect
with each other. In an ideal case, this system runs on every frame and checks for collision. It is
also smart enough to filter out only the possible collisions before performing the actual
intersection checks.

Despite this, it is safe to assume that the cost of collision detection will increase as the
number of hitboxes increases. But in many games, the developers are not always interested in
detecting collision between every possible pair. For example, consider a simple game where players
can fire a `Bullet` component that has a hitbox. In such a game it is likely that the developers
are not interested in detecting collision between any two bullets, but Flame will still perform
those collision checks.

To avoid this, you can set the `collisionType` for bullet component to `CollisionType.passive`. Doing
so will cause Flame to completely skip any kind of collision check between all the passive hitboxes.

```{note}
This does not mean bullet component in all games must always have a passive hitbox.
It is up to the developers to decide which hitboxes can be made passive based on
the rules of the game. For example, the Rogue Shooter game in Flame's examples uses
passive hitbox for enemies instead of the bullets. 
```


## Object Pooling

As mentioned in the "Object creation per frame" section, creating and destroying objects
frequently can impact performance. For components that are spawned and removed repeatedly
(like bullets, particles, or enemies), object pooling is an effective optimization technique.

Object pooling reuses objects instead of constantly creating and destroying them. Flame
provides the `ComponentPool` class to make object pooling easy and efficient.


### ComponentPool

The `ComponentPool` class manages a pool of reusable components. It automatically handles
the component lifecycle: when a pooled component is removed from its parent, it is
returned to the pool for reuse. The pooled components must mix in `PooledComponent`.

**Creating a pool:**

```dart
class MyGame extends FlameGame {
  late final ComponentPool<Bullet> bulletPool;

  @override
  Future<void> onLoad() async {
    bulletPool = ComponentPool<Bullet>(
      factory: () => Bullet(),
      maxSize: 50,      // Maximum number of bullets to keep in the pool
      initialSize: 10,  // Pre-create 10 bullets for immediate use
    );
  }
}
```

**Acquiring components from the pool:**

When you need a component, use `acquire()` to get one from the pool. If the pool is empty,
a new component will be created automatically using the factory function.

```dart
void spawnBullet(Vector2 position, Vector2 velocity) {
  final bullet = bulletPool.acquire();
  bullet.position.setFrom(position);
  bullet.velocity.setFrom(velocity);
  world.add(bullet);
}
```

**Returning components to the pool:**

Components are returned to the pool **automatically** when they are detached from the
component tree. Simply call `removeFromParent()` on the component, and it can be acquired
again right away, even within the same tick.

```dart
class Bullet extends SpriteComponent with CollisionCallbacks, PooledComponent {
  final Vector2 velocity = Vector2.zero();

  @override
  void onAcquire() {
    // Reset the state left over from the previous use. This runs before
    // acquire() hands the bullet back, so the position and velocity set in
    // spawnBullet are kept.
    velocity.setZero();
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);

    // Remove bullet if it goes off screen. Automatically returned to pool.
    if (position.x < -100 || position.x > gameRef.size.x + 100) {
      removeFromParent();
    }
  }

  @override
  void onCollisionStart(List<Vector2> points, PositionComponent other) {
    super.onCollisionStart(points, other);
    // Return to pool on collision. No manual release needed.
    removeFromParent();
  }
}
```

Moving a pooled component to a new parent does not return it to the pool, and neither
does removing one of its ancestors, since the component stays attached to its parent in
both cases. It is returned once it is removed from its own parent.

Override `onRelease()` in the component to react to it being returned to the pool, for
example to let go of resources that it does not need while it waits to be reused.

If you acquire a component and end up not adding it to the component tree, return it to
the pool with `release()`:

```dart
final bullet = bulletPool.acquire();
if (!canShoot) {
  bulletPool.release(bullet);
}
```


### Pool Management

**Checking available components:**

You can check how many components are currently available in the pool:

```dart
print('Available bullets: ${bulletPool.availableCount}');
```

**Clearing the pool:**

If you need to free up memory or reset the pool, you can clear all available components:

```dart
bulletPool.clear();
```

```{note}
Clearing only affects components currently in the pool. Components that are in use
(acquired but not yet released) are not affected, and are still returned to the pool once
they are removed.
```


### Best Practices

1. **Mix in `PooledComponent`**: Any `Component` subclass can be pooled once it mixes in
   `PooledComponent`. Then pass a factory function to `ComponentPool` and you're ready to go.

2. **Use `onAcquire` to reset state**: Reset the state left over from the previous use (e.g.
   animation frame, velocity) in `onAcquire()`. It runs before `acquire()` hands the
   component back, so anything you set on it after acquiring it (like its position) is kept.

3. **Just call `removeFromParent()`**: Components are returned to the pool automatically
   when removed. Only call `release()` for acquired components that were never added to the
   component tree.

4. **Don't hold on to released components**: Once a component is returned to the pool it
   can be handed out again, so don't keep using it through an old reference.

5. **Set appropriate pool sizes**: Set `maxSize` based on your game's needs. Too small and
   you'll create new objects frequently; too large and you'll waste memory.

6. **Use `initialSize` for warm-up**: Set `initialSize` to pre-create commonly used
   components, reducing frame drops during gameplay.

7. **Pool behavior is LIFO**: The pool uses a stack (Last In, First Out) internally, meaning
   the most recently returned component will be the next one acquired.
