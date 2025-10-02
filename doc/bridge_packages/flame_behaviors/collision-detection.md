# Collision Detection 💥

Flame comes with a powerful built-in [collision detection system](https://docs.flame-engine.org/1.10.0/flame/collision_detection.html),
but this API is not strongly typed. Components always get the colliding component as a
`PositionComponent` and developers need to manually check what type of class it is.

`flame_behaviors` is all about enforcing a strongly typed API. It provides a special behavior
called `CollisionBehavior` that describes the type of entity being targeted for collision. It
does not, however, do any real collision detection. That is done by the
`PropagatingCollisionBehavior`.

The `PropagatingCollisionBehavior` handles the collision detection by registering a hitbox on the
parent entity. When that hitbox has a collision, the `PropagatingCollisionBehavior` checks if the
component that the parent entity is colliding with contains the target entity type specified in
`CollisionBehavior`.

There are two main benefits of letting the `PropagatingCollisionBehavior` handle the collision detection,
the first and most important one is performance. By only registering collision callbacks on the
entities themselves, the collision detection system does not have to go through any "collidable"
behaviors, for which there could be many per entity. We only do that now if we confirm a collision
has happened.

The second benefit is that it allows for [separation of concerns][separation_of_concerns].
Each `CollisionBehavior` handles a specific collision use case and ensures that the developer does
not have to write a bunch of if statements in one big method to figure out what it is colliding
with.

A good use case of this collisional behavior pattern can be seen in the `flame_behaviors`
[example](https://github.com/flame-engine/flame/tree/main/packages/flame_behaviors/example)

```dart
class MyEntityCollisionBehavior
    extends CollisionBehavior<MyCollidingEntity, MyParentEntity> {
  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    MyCollidingEntity other,
  ) {
    // We are starting colliding with MyCollidingEntity
  }

  @override
  void onCollisionEnd(MyCollidingEntity other) {
    // We stopped colliding with MyCollidingEntity
  }
}

class MyParentEntity extends Entity {
  MyParentEntity() : super(
          behaviors: [
            PropagatingCollisionBehavior(RectangleHitbox()),
            MyEntityCollisionBehavior(),
          ],
        );
  
  ...
}
```

[separation_of_concerns]: https://en.wikipedia.org/wiki/Separation_of_concerns
