# Performance

和其他游戏引擎一样，Flame 尽量在保持 API 简洁的前提下提高效率。但由于其通用特性，Flame 无法对正在制作的游戏类型做出任何假设。这意味着游戏开发者始终有一些基于游戏功能的性能优化空间。

另一方面，根据底层硬件的不同，Flame 在性能上总会有一些硬性限制。但除了硬件限制外，Flame 用户还可能会遇到一些常见的性能陷阱，不过通过遵循一些简单的步骤，可以轻松避免这些问题。

本节将介绍一些优化技巧以及避免常见性能陷阱的方法。

```{note}
免责声明：每个 Flame 项目都各不相同。因此，这里描述的解决方案无法保证始终能显著提升性能。
```


## Object creation per frame

在任何类型的项目或游戏中，创建类对象是非常常见的操作。然而，对象的创建是一种相对复杂的操作。根据对象创建的频率和数量，应用程序可能会出现性能下降的情况。

在游戏中，这一点需要特别注意，因为游戏通常都有一个尽可能快速更新的游戏循环，每次更新被称为一个帧（frame）。根据硬件的不同，游戏每秒可能更新 30、60、120 或更高的帧数。

这意味着如果在每个帧中创建一个新对象，游戏将会根据每秒帧数创建相应数量的新对象。

Flame 用户通常会在重写 `Component` 的 `update` 和 `render` 方法时遇到这个问题。例如，在以下看似无害的代码中，每个帧都会创建一个新的 `Vector2` 和一个新的 `Paint` 对象。

但实际上，这些对象中的数据在所有帧中都是相同的。现在，想象一下，如果在一个以 60 FPS 运行的游戏中有 100 个 `MyComponent` 实例。每秒就会创建 6000（100 * 60）个新的 `Vector2` 和 `Paint` 实例。

```{note}
这就像每次想发送邮件时都买一台新电脑，或者每次想写点什么时都买一支新笔。虽然确实可以完成任务，但这并不是一种经济明智的做法。
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

更好的做法如下所示。此代码将所需的 `Vector2` 和 `Paint` 对象存储为类成员，并在所有 `update` 和 `render` 调用中复用它们。

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
总而言之，避免在每个帧中创建不必要的对象。即使是看似很小的对象，如果大量创建，也会影响性能。
```


## Unwanted collision checks

Flame 内置了一个碰撞检测系统，可以检测任意两个 `Hitbox` 何时相交。在理想情况下，该系统会在每个帧中运行，并检查碰撞情况。同时，它足够智能，可以在执行实际相交检查之前，仅过滤出可能发生碰撞的对象。

尽管如此，可以假设碰撞检测的成本会随着 `Hitbox` 数量的增加而增加。但在许多游戏中，开发者并不总是希望检测所有可能的碰撞组合。例如，考虑一个简单的游戏，其中玩家可以发射带有 `Hitbox` 的 `Bullet` 组件。在这样的游戏中，开发者可能不希望检测任意两个子弹之间的碰撞，但 Flame 仍然会执行这些碰撞检查。

为避免这种情况，可以将子弹组件的 `collisionType` 设置为 `CollisionType.passive`。这样做会使 Flame 完全跳过所有被标记为 `passive` 的 `Hitbox` 之间的任何碰撞检查。

```{note}
这并不意味着所有游戏中的子弹组件都必须使用被动 `Hitbox`。
是否将某些 `Hitbox` 设置为被动状态取决于开发者基于游戏规则的决定。例如，Flame 示例中的 Rogue Shooter 游戏使用了敌人的被动 `Hitbox`，而不是子弹的。
```
