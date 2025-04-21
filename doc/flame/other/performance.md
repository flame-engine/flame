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

In games, this is something to be very careful of because games generally have a game loop that updates
as fast as possible, where each update is called a frame. Depending on the hardware, a game can be updating
30, 60, 120 or even higher frames per second. This means if a new object is created in a frame, the game
will end up creating as many number of objects as the frame count per second.

Flame users, generally tend to run into this problem when they override the `update` and `render` method
of a `Component`. For example, in the following innocent looking code, a new `Vector2` and a new `Paint`
object is spawned every frame. But the data inside the objects is essentially the same across all frames.
Now imagine if there are 100 instances of `MyComponent` in a game running at 60 FPS. That would essentially
mean 6000 (100 * 60) new instances of `Vector2` and `Paint` each will be created every second.

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

Flame has a built-in collision detection system which can detect when any two `Hitbox`es intersect with
each other. In an ideal case, this system runs on every frame and checks for collision. It is also smart
enough to filter out only the possible collisions before performing the actual intersection checks.

Despite this, it is safe to assume that the cost of collision detection will increase as the number of
hitboxes increases. But in many games, the developers are not always interested in detecting collision
between every possible pair. For example, consider a simple game where players can fire a `Bullet` component
that has a hitbox. In such a game it is likely that the developers are not interested in detecting collision
between any two bullets, but Flame will still perform those collision checks.

To avoid this, you can set the `collisionType` for bullet component to `CollisionType.passive`. Doing
so will cause Flame to completely skip any kind of collision check between all the passive hitboxes.

```{note}
This does not mean bullet component in all games must always have a passive hitbox.
It is up to the developers to decide which hitboxes can be made passive based on
the rules of the game. For example, the Rogue Shooter game in Flame's examples uses
passive hitbox for enemies instead of the bullets. 
```
