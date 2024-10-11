# Collision Detection

在大多数游戏中，需要碰撞检测来检测和响应两个组件相互交叉。例如，箭矢击中敌人或玩家捡起硬币。

在大多数碰撞检测系统中，你使用所谓的命中框来创建组件的更精确的边界框。

在 Flame 中，命中框是组件的区域，可以对碰撞做出反应（并使[手势输入](inputs/gesture_input.md#gesturehitboxes))更准确。

碰撞检测系统支持三种不同类型的形状，你可以用它们构建命中框，这些形状是多边形、矩形和圆形。可以向组件添加多个命中框来形成区域，该区域可以用来检测碰撞或判断它是否包含一个点，后者对于精确的手势检测非常有用。碰撞检测不处理当两个命中框碰撞时应该发生什么，因此用户需要自己实现，例如当两个 `PositionComponent`s 的命中框相交时会发生什么。

请注意，内置的碰撞检测系统不考虑两个相互超车的命中框之间的碰撞，这可能发生在它们移动得非常快或 `update` 被调用时有一个大的时间差（例如，如果你的应用不在前台）。这种行为被称为隧道效应，如果你想了解更多，可以阅读更多关于它的信息。

还请注意，碰撞检测系统有一个限制，如果你有某些类型的祖先的翻转和缩放组合的命中框，它可能无法正常工作。


## Mixins


### HasCollisionDetection

如果你想在游戏中使用碰撞检测，你必须给你的游戏添加 `HasCollisionDetection` 混入，这样它就能追踪可能发生碰撞的组件。

示例：

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  // ...
}
```

现在当你向游戏中添加了 `ShapeHitbox` 的组件时，它们将自动被检查是否发生碰撞。

你也可以直接将 `HasCollisionDetection` 混入到另一个 `Component` 中，而不是 `FlameGame`，例如，用于 `CameraComponent` 的 `World`。如果这样做，添加到该组件树中的命中框将只与该子树中的其他命中框进行比较，这使得在一个 `FlameGame` 中可以有多个具有碰撞检测的世界。

示例：

```dart
class CollisionDetectionWorld extends World with HasCollisionDetection {}
```

```{note}
命中框只会连接到一个碰撞检测系统，那就是具有 `HasCollisionDetection` 混入的最近的父组件。
```


### CollisionCallbacks

要响应碰撞，你应该向你的组件添加 `CollisionCallbacks` 混入。
示例：


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

在这个示例中，我们使用 Dart 的 `is` 关键字来检查我们碰撞的组件类型。点集是命中框边缘相交的位置。

请注意，如果两个 `PositionComponent` 都实现了 `onCollision` 方法，`onCollision` 方法将被调用，同时对两个命中框也是如此。同样适用于 `onCollisionStart` 和 `onCollisionEnd` 方法，当两个组件和命中框开始或停止相互碰撞时会被调用。

当一个 `PositionComponent`（和命中框）开始与另一个 `PositionComponent` 碰撞时，会调用 `onCollisionStart` 和 `onCollision`，所以如果你不需要在碰撞开始时做特定的事情，你只需要覆盖 `onCollision`，反之亦然。

如果你想检查与屏幕边缘的碰撞，就像我们在上面的示例中所做的，你可以使用预定义的 [ScreenHitbox](#screenhitbox) 类。

默认情况下，所有命中框都是空心的，这意味着一个命中框可以完全被另一个命中框包围而不触发碰撞。如果你想将你的命中框设置为实心，可以设置 `isSolid = true`。实心命中框内的空心命中框将触发碰撞，但反之则不会。如果实心命中框的边缘没有交集，将返回中心位置。


### Collision order

如果一个 `Hitbox` 在给定的时间步内与多个其他 `Hitbox` 发生碰撞，那么 `onCollision` 回调将以本质上随机的顺序被调用。在某些情况下，这可能会成为问题，例如在弹跳球游戏中，球的轨迹可能会因为首先击中哪个其他对象而有所不同。为了帮助解决这个问题，可以使用 `collisionsCompletedNotifier` 监听器——这会在碰撞检测过程结束时触发。

一个可能的使用示例是在你的 `PositionComponent` 中添加一个局部变量来保存与之碰撞的其他组件：

`List<PositionComponent> collisionComponents = [];`。
然后 `onCollision` 回调被用来将所有其他的 `PositionComponent` 保存到这个列表中：

```dart
@override
void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  collisionComponents.add(other);
  super.onCollision(intersectionPoints, other);
}

```

最后，在 `PositionComponent` 的 `onLoad` 方法中添加一个监听器，调用一个函数，该函数将决定如何处理碰撞：

```dart
(game as HasCollisionDetection)
    .collisionDetection
    .collisionsCompletedNotifier
    .addListener(() {
  resolveCollisions();
});
```

每次调用 `update` 时，都需要清空 `collisionComponents` 列表。


## ShapeHitbox

`ShapeHitbox` 是正常的组件，因此你只需像添加其他任何组件一样，将它们添加到你想要添加命中框的组件中：

```dart
class MyComponent extends PositionComponent {
  @override
  void onLoad() {
    add(RectangleHitbox());
  }
}
```

如果你没有给命中框添加任何参数，像上面那样，命中框会尽量填充其父组件。除了让命中框尽量填充其父组件之外，还有两种方式来初始化命中框，一种是常规构造函数，你可以通过它自己定义命中框，包括大小、位置等。另一种是使用 `relative` 构造函数，它根据其预期父组件的大小来定义命中框。

在某些特定情况下，你可能只想在命中框之间处理碰撞，而不将 `onCollision*` 事件传播到命中框的父组件。例如，一个车辆可以有一个主体命中框来控制碰撞，以及侧面命中框来检查向左转或向右转的可能性。
因此，与主体命中框的碰撞意味着与组件本身的碰撞，而与侧面命中框的碰撞则不意味着真正的碰撞，并且不应该传播到命中框的父组件。
对于这种情况，你可以将 `triggersParentCollision` 变量设置为 `false`：

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

你可以在[ShapeComponents](components.md#shapecomponents)部分阅读更多关于不同形状是如何定义的。

请记住，你可以根据自己的需要向 `PositionComponent` 添加尽可能多的 `ShapeHitbox`，以构成更复杂的区域。例如，一个戴着帽子的雪人可以用三个 `CircleHitbox` 和两个 `RectangleHitbox` 来表示帽子。

命中框可以用于碰撞检测，或者用于使组件上方的手势检测更准确，有关后者的更多信息，请参阅关于[GestureHitboxes](inputs/gesture_input.md#gesturehitboxes)混入的章节。


### CollisionType

命中框有一个名为 `collisionType` 的字段，它定义了何时一个命中框应该与另一个命中框发生碰撞。通常，你希望尽可能多地将命中框设置为 `CollisionType.passive`，以提高碰撞检测的性能。默认情况下，`CollisionType` 是 `active`。

`CollisionType` 枚举包含以下值：

- `active` 与类型为 active 或 passive 的其他 `Hitbox` 发生碰撞
- `passive` 与类型为 active 的其他 `Hitbox` 发生碰撞
- `inactive` 不与任何其他 `Hitbox` 发生碰撞

所以，如果你有不需要相互检查碰撞的命中框，你可以通过在构造函数中设置 `collisionType: CollisionType.passive` 将它们标记为被动，例如地面组件，或者也许你的敌人之间不需要检查碰撞，那么它们也可以被标记为 `passive`。

想象一个游戏中有很多子弹，它们不能相互碰撞，向玩家飞去，那么玩家可以被设置为 `CollisionType.active`，而子弹被设置为 `CollisionType.passive`。

然后我们有 `inactive` 类型，它在碰撞检测中根本不会被检查。这可以用于例如，如果你有组件在屏幕外，你目前不关心它们，但它们可能后来会重新回到视野中，所以它们没有完全从游戏中移除。

这些只是你如何使用这些类型的示例，它们的用例会更多，所以即使你的用例没有在这里列出，也不要犹豫使用它们。


### PolygonHitbox

需要注意的是，如果你想在 `Polygon` 上使用碰撞检测或 `containsPoint`，那么这个多边形必须是凸的。因此，始终使用凸多边形，否则如果你不太了解你在做什么，很可能会碰到问题。还需要注意的是，你应该总是以逆时针顺序定义多边形的顶点。

其他命中框形状没有任何强制性的构造函数，这是因为它们可以有一个默认值，这个默认值可以从它们所附加的可碰撞对象的大小中计算得出，但是由于多边形可以在边界框内以无限多种方式制作，所以你必须在构造函数中为这个形状添加定义。

`PolygonHitbox` 具有与 [](components.md#polygoncomponent) 相同的构造函数，请参阅相关文档以了解更多信息。


### RectangleHitbox

`RectangleHitbox` 具有与 [](components.md#rectanglecomponent) 相同的构造函数，请参阅相关文档以了解更多信息。


### CircleHitbox

`CircleHitbox` 具有与 [](components.md#circlecomponent) 相同的构造函数，请参阅相关文档以了解更多信息。


## ScreenHitbox

`ScreenHitbox` 是一个组件，代表你的视口/屏幕边缘。
如果你将 `ScreenHitbox` 添加到游戏中，其他带有命中框的组件在与边缘碰撞时将收到通知。
它不需要任何参数，它只依赖于它被添加到的游戏的 `size`。
要添加它，你只需在游戏的 `add(ScreenHitbox())` 中进行，如果你不希望 `ScreenHitbox` 本身在有东西与它碰撞时收到通知。
由于 `ScreenHitbox` 具有 `CollisionCallbacks` 混入，如果需要，你可以向该对象添加自己的 `onCollisionCallback`、`onStartCollisionCallback` 和 `onEndCollisionCallback` 函数。

## CompositeHitbox

在 `CompositeHitbox` 中，你可以添加多个命中框，使它们模拟成为一个合并的命中框。

如果你想制作一个帽子，例如，你可能想使用两个 [](#rectanglehitbox) 来恰当地跟随帽子的边缘，然后你可以将这些命中框添加到这个类的实例中，并对整个帽子的碰撞做出反应，而不是仅对每个单独的命中框做出反应。


## Broad phase

如果你的游戏场地不是很大，并且没有很多可碰撞的组件——你不必担心所使用的广度阶段系统，所以如果标准实现对你来说已经足够高效，你可能不需要阅读本节。

广度阶段是碰撞检测的第一步，在这里计算潜在的碰撞。计算这些潜在碰撞比精确检查交集要快，并且它消除了需要检查所有命中框之间的相互关系，因此避免了 O(n²) 的复杂度。

广度阶段产生一组潜在的碰撞（一组 `CollisionProspect`）。然后使用这组潜在碰撞来检查命中框之间的确切交集（有时称为“深度阶段”）。

默认情况下，Flame 的碰撞检测使用扫描和修剪广度阶段。如果你的游戏需要另一种类型的广度阶段，你可以通过扩展 `Broadphase` 并手动设置应该使用的碰撞检测系统来编写自己的广度阶段。

例如，如果你实现了一个基于神奇算法而不是标准扫描和修剪的广度阶段，那么你会做以下操作：

```dart
class MyGame extends FlameGame with HasCollisionDetection {
  MyGame() : super() {
    collisionDetection =
        StandardCollisionDetection(broadphase: MagicAlgorithmBroadphase());
  }
}
```


## Quad Tree broad phase

如果你的游戏场地很大，并且游戏包含很多可碰撞的组件（超过一百个），标准的扫描和修剪可能会变得效率低下。如果是这样，你可以尝试使用四叉树广度阶段。

要做到这一点，在你的游戏中添加 `HasQuadTreeCollisionDetection` 混入，而不是 `HasCollisionDetection` 并在游戏加载时调用 `initializeCollisionDetection` 函数：

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

在调用 `initializeCollisionDetection` 时，你应该传递正确的地图尺寸，以使四叉树算法正常工作。还有一些额外的参数可以使系统更高效：

- `minimumDistance`：对象之间考虑它们可能发生碰撞的最小距离。如果为 `null`，则检查被禁用，这是默认行为。
- `maxObjects`：一个象限中的最大对象数。默认为 25。
- `maxDepth`：象限内的最大嵌套级别。默认为 10。

如果你使用四叉树系统，可以通过在组件中实现 `CollisionCallbacks` 混入的 `onComponentTypeCheck` 函数使其更加高效。
如果你需要防止不同类型项目之间的碰撞，这会很有用。计算结果是缓存的，所以这里不应该检查任何动态参数，该函数打算用作纯粹的类型检查器：

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

经过激烈的游戏玩法后，地图可能会变得过度聚集，有很多空的象限。运行 `QuadTree.optimize()` 来进行空象限的清理：

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
总是尝试不同的碰撞检测方法，并检查它们在你的游戏中的表现如何。
并不是没有听说过 `QuadTreeBroadphase` 明显 _比默认的慢_。
不要想当然地认为更复杂的方法总是更快。
```


## Ray casting and Ray tracing

射线投射和射线追踪是在游戏中从一个点发出射线的方法，能够看到这些射线与什么发生碰撞以及在撞击某物后如何反射。

对于所有以下方法，如果你有任何想要忽略的命中框，你可以添加 `ignoreHitboxes` 参数，这是一个你希望在调用中忽略的命中框的列表。
这在某些情况下非常有用，例如，如果你从命中框内发出射线，这可能是在你的玩家或NPC上；或者如果你不希望射线从 `ScreenHitbox` 反弹。


### Ray casting

射线投射是从一点发出一个或多个射线并查看它们是否击中任何物体的操作，在 Flame 的情况下，是命中框。

我们提供了两种方法来进行射线投射，`raycast` 和 `raycastAll`。第一个方法只发出一个单一的射线并返回一个结果，其中包含有关射线击中了什么以及击中位置的信息，以及一些额外的信息，如距离、法线和反射射线。
第二个方法，`raycastAll`，工作方式类似，但是从原点向外均匀发出多个射线，或者在一个以原点为中心的角度内发出。

默认情况下，`raycast` 和 `raycastAll` 扫描最近的命中，而不考虑它距离射线原点有多远。
但在某些用例中，可能只希望在某个特定范围内找到命中。对于这些情况，可以提供可选的 `maxDistance`。

要使用射线投射功能，你必须在你的游戏中有 `HasCollisionDetection` 混入。添加后，你可以在游戏类上调用 `collisionDetection.raycast(...)`。

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

在这个例子中，我们可以看到 `Ray2` 类被使用，这个类定义了一个从原点位置和方向（都由 `Vector2` 定义）的射线。这个特定的射线从 `0, 100` 开始，并向右侧直线发射。

这个操作的结果要么是 `null`（如果射线没有击中任何东西），或者是一个 `RaycastResult`，其中包含：

- 射线击中的命中框
- 碰撞的交点
- 反射射线，即射线在它击中的命中框上的反射方式
- 碰撞的法线，即一个垂直于它击中的命中框表面的向量

如果你关心性能，你可以预先创建一个 `RaycastResult` 对象，你可以通过 `out` 参数将其传递给方法，这将允许方法重用这个对象而不是为每次迭代创建一个新的。

如果你在 `update` 方法中进行大量的射线投射，这可能很有帮助。


#### raycastAll

有时你希望从一个原点向所有方向或有限范围的方向发射射线。这可以有很多应用，例如，你可以计算玩家或敌人的视野，或者它也可以用来创建光源。

示例：

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

在这个例子中，我们将从 (200, 200) 向所有方向均匀发射 100 条射线。

如果你想限制方向，你可以使用 `startAngle` 和 `sweepAngle` 参数。其中 `startAngle`（从正上方开始计数）是射线开始的位置，然后射线将在 `startAngle + sweepAngle` 结束。

如果你关心性能，你可以通过将它们作为列表用 `out` 参数发送，来重用函数创建的 `RaycastResult` 对象。


### Ray tracing

射线追踪与射线投射类似，但不是只检查射线击中了什么，而是可以继续追踪射线，看看它的反射射线（从命中框反弹的射线）将击中什么，然后看看那个投射的反射射线的反射射线将击中什么，以此类推，直到你决定已经足够长时间地追踪了射线。如果你想象一下台球在台球桌上的反弹方式，那么这些信息就可以通过射线追踪来获取。

示例：

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

在上述示例中，我们从 (0, 100) 处发出一条射线，斜向下向右发射，并声明我们希望它最多在 100 个命中框上反弹，它不一定能得到 100 个结果，因为在某个时刻，其中一个反射射线可能没有击中命中框，然后该方法就完成了。

该方法是惰性的，这意味着它只会执行你要求的计算，所以你必须遍历它返回的可迭代对象来获取结果，或者使用 `toList()` 直接计算所有结果。

在 for 循环中，可以看到如何使用它，在该循环中，我们检查当前反射射线的交点（前一个射线击中命中框的位置）是否比起始射线的原点更远超过 300 像素，如果是，我们就不需要关心其余的结果（然后它们也不需要被计算）。

如果你关心性能，你可以通过将它们作为列表用 `out` 参数发送，来重用函数创建的 `RaycastResult` 对象。


## Comparison to Forge2D

如果你想在游戏中拥有一个完整的物理引擎，我们推荐你使用 Forge2D，通过添加 [flame_forge2d](https://github.com/flame-engine/flame_forge2d) 作为依赖来实现。
但如果你的用例更简单，只需要检查组件的碰撞并提高手势的准确性，Flame 内置的碰撞检测将非常适用。

如果你有以下需求，至少应该考虑使用 [Forge2D](https://github.com/flame-engine/forge2d)：

- 相互作用的真实力
- 可以与其他物体互动的粒子系统
- 物体之间的连接件

如果你只需要以下功能（因为不涉及 Forge2D 会更简单）：

- 能够对一些组件的碰撞做出响应
- 能够对组件与屏幕边界的碰撞做出响应
- 复杂形状作为组件的命中框，以便手势更准确
- 能够指明组件的哪一部分与某物发生碰撞的命中框

只是一个好主意，如果上述情况符合你的需求，只需使用 Flame 碰撞检测系统即可。


## Examples

- [Collidable AnimationComponent](https://examples.flame-engine.org/#/Collision_Detection_Collidable_AnimationComponent)
- [Circles](https://examples.flame-engine.org/#/Collision_Detection_Circles)
- [Multiple shapes](https://examples.flame-engine.org/#/Collision_Detection_Multiple_shapes)
- [More Examples](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/collision_detection)
