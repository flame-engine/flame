# Components

```{include} diagrams/component.md
```

这个图表可能看起来很复杂，但别担心，它并没有看起来那么复杂。


## Component

所有组件都继承自 Component 类，并且可以包含其他 Component 作为子组件。这就是我们所谓的 Flame 组件系统（Flame Component System），简称 FCS。

可以使用 add(Component c) 方法或者直接在构造函数中添加子组件。

示例：

```dart
void main() {
  final component1 = Component(children: [Component(), Component()]);
  final component2 = Component();
  component2.add(Component());
  component2.addAll([Component(), Component()]);
}
```

这里的 Component() 当然可以是 Component 的任何子类。

每个 Component 都有几个可选实现的方法，这些方法会被 FlameGame 类调用。


### Component lifecycle

```{include} diagrams/component_life_cycle.md
```

onGameResize 方法在屏幕大小改变时调用，也会在该组件被添加到组件树中时，在 onMount 之前调用。

onParentResize 方法类似：它也会在组件被挂载到组件树中时调用，并且每当当前组件的父级尺寸发生变化时也会调用。

onRemove 方法可以重写以在组件被从游戏中移除之前执行代码，即使组件同时被父组件的 remove 方法和 Component remove 方法移除，该方法也只会执行一次。

onLoad 方法可以重写以异步初始化组件，比如加载图像。此方法在 onGameResize 和 onMount 之前执行。在组件的生命周期中，该方法保证只会执行一次，因此可以将其视为“异步构造函数”。

onMount 方法在组件每次挂载到游戏树中时都会运行。这意味着不应该在这里初始化 late final 变量，因为在组件生命周期中，此方法可能会运行多次。此方法只有在父组件已经挂载时才会运行。如果父组件尚未挂载，则该方法将排队等待（这不会对游戏引擎的其他部分产生影响）。

onChildrenChanged 方法可以重写以检测父组件的子组件更改。此方法会在父组件的子组件发生添加或移除（包括子组件更改父组件）时调用。它的参数包含目标子组件和发生的更改类型（added 或 removed）。


可以通过一系列 getter 检查组件生命周期状态：

- `isLoaded`: 返回当前加载状态的布尔值。
- `loaded`: 返回一个 Future，该 Future 会在组件加载完成后完成。
- `isMounted`: 返回当前挂载状态的布尔值。
- `mounted`: 返回一个 Future，该 Future 会在组件挂载完成后完成。
- `isRemoved`: 返回当前移除状态的布尔值。
- `removed`: 返回一个 Future，该 Future 会在组件被移除后完成。


### Priority（优先级）

在 Flame 中，每个 Component 都有 int priority 属性，用于确定该组件在父级子组件中的排序顺序。这有时在其他语言和框架中被称为 z-index。设置的 priority 越高，组件将显示得越靠前，因为它会覆盖之前渲染的优先级较低的组件。

如果添加了两个组件，并将其中一个的优先级设置为 1，那么该组件将显示在另一个组件的上方（如果它们重叠），因为默认优先级是 0。

所有组件在构造函数中都接受 priority 作为命名参数，因此如果在编译时就知道组件的优先级，则可以将其传递给构造函数。

示例：

```dart
class MyGame extends FlameGame {
  @override
  void onLoad() {
    final myComponent = PositionComponent(priority: 5);
    add(myComponent);
  }
}
```

要更新组件的优先级，可以将其设置为新值，例如 component.priority = 2，它将在当前帧的渲染阶段之前更新。

在以下示例中，我们首先以优先级 1 初始化组件，然后当用户点击组件时，我们将其优先级更改为 2：

```dart
class MyComponent extends PositionComponent with TapCallbacks {

  MyComponent() : super(priority: 1);

  @override
  void onTapDown(TapDownEvent event) {
    priority = 2;
  }
}
```


### Composability of components

有时将其他组件包装在你的组件内部是很有用的。例如，通过层次结构对视觉组件进行分组。可以通过向任意组件（例如 PositionComponent）添加子组件来实现这一点。

当组件有子组件时，每次父组件更新和渲染时，所有子组件都会在相同条件下更新和渲染。

以下是一个用法示例，其中通过一个包装器管理两个组件的可见性：

```dart
class GameOverPanel extends PositionComponent {
  bool visible = false;
  final Image spriteImage;

  GameOverPanel(this.spriteImage);

  @override
  void onLoad() {
    final gameOverText = GameOverText(spriteImage); // GameOverText is a Component
    final gameOverButton = GameOverButton(spriteImage); // GameOverRestart is a SpriteComponent

    add(gameOverText);
    add(gameOverButton);
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
    } // If not visible none of the children will be rendered
  }
}
```

添加子组件到你的组件有两种方法。首先，可以使用 add()、addAll() 和 addToParent() 方法，它们可以在游戏的任何时候使用。

通常，子组件将在组件的 onLoad() 方法中创建和添加，但在游戏过程中添加新的子组件也是很常见的。

第二种方法是在组件的构造函数中使用 children: 参数。这种方法更类似于标准的 Flutter API：

```dart
class MyGame extends FlameGame {
  @override
  void onLoad() {
    add(
      PositionComponent(
        position: Vector2(30, 0),
        children: [
          HighScoreDisplay(),
          HitPointsDisplay(),
          FpsComponent(),
        ],
      ),
    );
  }
}
```

两种方法可以自由组合：在构造函数中指定的子组件将首先被添加，然后再添加任何额外的子组件。

请注意，通过任一方法添加的子组件只能在它们加载和挂载之后才能保证可用。我们只能确保它们会按照调度的顺序出现在子组件列表中。


### Access to the World from a Component（从组件访问 World）

如果组件有一个 `World` 作为其祖先并且需要访问该 `World` 对象，则可以使用 `HasWorldReference mixin`。

栗子:

```dart
class MyComponent extends Component with HasWorldReference<MyWorld>,
    TapCallbacks {
  @override
  void onTapDown(TapDownEvent info) {
    // world is of type MyWorld
    world.add(AnotherComponent());
  }
}
```

如果尝试从没有 `World` 祖先的组件中访问 `world`，则会抛出断言错误。


### Ensuring a component has a given parent(确保组件具有特定父组件)

当组件需要被添加到特定类型的父组件时，可以使用 `ParentIsA mixin` 来强制执行类型化的父组件。


栗子:

```dart
class MyComponent extends Component with ParentIsA<MyParentComponent> {
  @override
  void onLoad() {
    // parent is of type MyParentComponent
    print(parent.myValue);
  }
}
```

如果你尝试将 `MyComponent` 添加到不是 `MyParentComponent` 的父组件中，将会抛出一个断言错误。


### Ensuring a component has a given ancestor

当一个组件需要在组件树中某处有特定类型的祖先时，可以使用 `HasAncestor` 混入（mixin）来强制这种关系。

该混入暴露了 `ancestor` 字段，该字段将是给定的类型。

Example:

```dart
class MyComponent extends Component with HasAncestor<MyAncestorComponent> {
  @override
  void onLoad() {
    // ancestor is of type MyAncestorComponent.
    print(ancestor.myValue);
  }
}
```

如果你尝试将 `MyComponent` 添加到不包含 `MyAncestorComponent` 的树中，将会抛出一个断言错误。


### Component Keys

组件可以有一个识别键，允许从组件树的任何点检索它们。

要使用键注册组件，只需在组件的构造函数的 `key` 参数中传递一个键：

```dart
final myComponent = Component(
  key: ComponentKey.named('player'),
);
```

Then, to retrieve it in a different point of the component tree:

```dart
flameGame.findByKey(ComponentKey.named('player'));
```

有两种类型的键：`unique` 和 `named`。唯一键（unique keys）基于键实例的相等性，这意味着：

```dart
final key = ComponentKey.unique();
final key2 = key;
print(key == key2); // true
print(key == ComponentKey.unique()); // false
```

命名键（named keys）基于它接收到的名称，因此：

```dart
final key1 = ComponentKey.named('player');
final key2 = ComponentKey.named('player');
print(key1 == key2); // true
```

当使用命名键时，也可以使用 `findByKeyName` 辅助函数来检索组件。

```dart
flameGame.findByKeyName('player');
```


### Querying child components

添加到组件的子组件生活在一个名为 `children` 的 `QueryableOrderedSet` 中。

要查询集合中特定类型的组件，可以使用 `query<T>()` 函数。

默认情况下，子组件集合中的 `strictMode` 设置为 `false`，但如果将其设置为 `true`，则必须先使用 `children.register` 注册查询，然后才能使用查询。

如果你在编译时就知道稍后将运行特定类型的查询，无论 `strictMode` 是否设置为 `true` 或 `false`，都建议注册查询，因为这样可以获得一些性能优势。`register` 调用通常在 `onLoad` 中完成。

🌰:

```dart
@override
void onLoad() {
  children.register<PositionComponent>();
}
```

在上述示例中，为 `PositionComponent` 注册了一个查询，下面可以看到如何查询已注册的组件类型的例子。

```dart
@override
void update(double dt) {
  final allPositionComponents = children.query<PositionComponent>();
}
```


### Querying components at a specific point on the screen（在屏幕上的特定点查询组件）

`componentsAtPoint()` 方法允许你检查哪些组件在屏幕上的某个点被渲染。返回值是一个可迭代的组件集合，你还可以通过提供一个可写的 `List<Vector2>` 作为第二个参数来获取每个组件局部坐标空间中初始点的坐标。

这个可迭代的集合按照从前到后的顺序检索组件，即首先是前面的组件，然后是后面的组件。

此方法只能返回实现了 `containsLocalPoint()` 方法的组件。`PositionComponent`（Flame 中许多组件的基类）提供了这样的实现。然而，如果你定义了一个从 `Component` 派生的自定义类，你需要自己实现 `containsLocalPoint()` 方法。

以下是如何使用 `componentsAtPoint()` 的示例：

```dart
void onDragUpdate(DragUpdateInfo info) {
  game.componentsAtPoint(info.widget).forEach((component) {
    if (component is DropTarget) {
      component.highlight();
    }
  });
}
```


### Visibility of components

通常推荐使用 `add` 和 `remove` 方法将组件添加或从树中移除来隐藏或显示组件。

然而，从树中添加和移除组件将触发该组件的生命周期步骤（例如调用 `onRemove` 和 `onMount`）。这还是一个异步过程，如果在短时间内快速连续移除和添加组件，需要小心确保组件在再次添加之前已经完成移除。

```dart
/// Example of handling the removal and adding of a child component
/// in quick succession
void show() async {
  // Need to await the [removed] future first, just in case the
  // component is still in the process of being removed.
  await myChildComponent.removed;
  add(myChildComponent);
}

void hide() {
  remove(myChildComponent);
}
```
这些行为并不总是理想的。

另一种显示和隐藏组件的方法是使用 `HasVisibility` 混入（mixin），它可以用于任何从 `Component` 继承的类。
这个混入引入了 `isVisible` 属性。
只需将 `isVisible` 设置为 `false` 即可隐藏组件，设置为 `true` 即可再次显示它，而无需将其从树中移除。这会影响组件及其所有后代（子组件）的可见性。

```dart
/// Example that implements HasVisibility
class MyComponent extends PositionComponent with HasVisibility {}

/// Usage of the isVisible property
final myComponent = MyComponent();
add(myComponent);

myComponent.isVisible = false;
```

该混入只影响组件是否被渲染，并且不会影响其他行为。

```{note}
重要！即使组件不可见，它仍然在树中，并且会继续接收到 'update' 以及其他所有生命周期事件的调用。它仍然会响应输入事件，并且仍然会与其他组件交互，例如碰撞检测。
```

该混入通过阻止 `renderTree` 方法工作，因此如果 `renderTree` 被重写，应该手动检查 `isVisible` 以保留此功能。

```dart
class MyComponent extends PositionComponent with HasVisibility {

  @override
  void renderTree(Canvas canvas) {
    // Check for visibility
    if (isVisible) {
      // Custom code here

      // Continue rendering the tree
      super.renderTree(canvas);
    }
  }
}
```


## PositionComponent

这个类代表屏幕上的一个定位对象，可以是浮动矩形、旋转精灵或任何具有位置和大小的其他对象。如果向其中添加子组件，它还可以代表一组定位组件。

`PositionComponent` 的基础是它具有 `position`（位置）、`size`（大小）、`scale`（缩放）、`angle`（角度）和 `anchor`（锚点），这些属性改变了组件的渲染方式。


### Position

`position` 只是一个 `Vector2`，它表示组件的锚点相对于其父组件的位置；如果父组件是一个 `FlameGame`，那么它是相对于视口的位置。


### Size

当相机的缩放级别为 1.0（无缩放，默认值）时，组件的 `size`（大小）。
`size` *not* 是相对于组件的父组件的。


### Scale

`scale` 表示组件及其子组件应该缩放的程度。由于它由 `Vector2` 表示，你可以通过以相同的量改变 `x` 和 `y` 来均匀缩放，或者通过以不同的量改变 `x` 或 `y` 来非均匀缩放。


### Angle角度

`angle` 是围绕锚点的旋转角度，以弧度为单位表示。它是相对于父组件的角度。

### Native Angle本地角度

`nativeAngle` 是一个以弧度为单位的顺时针角度，代表组件的默认方向。当 [angle](#angle) 为零时，它可以用来定义组件面向的方向。

在制作基于精灵的组件时，如果原始图像不是面向上/北方向，计算使组件面向目标的角度将需要一些偏移量以使其看起来正确。在这种情况下，`nativeAngle` 可以用来让组件知道原始图像面向的方向。

例如，如果一个子弹图像指向东方，那么可以将 `nativeAngle` 设置为 π/2 弧度。以下是一些常见方向及其对应的本地角度值。

Direction | Native Angle | In degrees
----------|--------------|-------------
Up/North  | 0            | 0
Down/South| pi or -pi    | 180 or -180
Left/West | -pi/2        | -90
Right/East| pi/2         | 90


### Anchor

```{flutter-app}
:sources: ../flame/examples
:page: anchor
:show: widget code infobox
This example shows effect of changing `anchor` point of parent (red) and child (blue)
components. Tap on them to cycle through the anchor points. Note that the local
position of the child component is (0, 0) at all times.
```

`anchor` 定义了组件上的位置和旋转的基准点（默认为 `Anchor.topLeft`）。因此，如果你将锚点设置为 `Anchor.center`，组件在屏幕上的位置将是组件的中心，如果应用了 `angle`，则围绕锚点旋转，所以在这种情况下是围绕组件的中心。你可以将其想象为Flame "抓取"组件的点。

当查询组件的 `position` 或 `absolutePosition` 时，返回的坐标是组件的 `anchor` 点的坐标。如果你想找到组件的特定锚点的位置，而这个锚点实际上并不是组件的 `anchor`，你可以使用 `positionOfAnchor` 和 `absolutePositionOfAnchor` 方法。

```dart
final comp = PositionComponent(
  size: Vector2.all(20),
  anchor: Anchor.center,
);

// Returns (0,0)
final p1 = component.position;

// Returns (10, 10)
final p2 = component.positionOfAnchor(Anchor.bottomRight);
```

使用 `anchor` 时一个常见的陷阱是将其与子组件的附着点混淆。例如，将父组件的 `anchor` 设置为 `Anchor.center` 并不意味着子组件会相对于父组件的中心放置。

```{note}
子组件的局部原点始终是其父组件的左上角，无论它们的 `anchor` 值如何。
```


### PositionComponent children

`PositionComponent` 的所有子组件都将相对于父组件进行变换，这意味着 `position`（位置）、`angle`（角度）和 `scale`（缩放）将是相对于父组件的状态。

因此，如果你想将一个子组件定位在父组件的中心，你会这样做：

```dart
@override
void onLoad() {
  final parent = PositionComponent(
    position: Vector2(100, 100),
    size: Vector2(100, 100),
  );
  final child = PositionComponent(
    position: parent.size / 2,
    anchor: Anchor.center,
  );
  parent.add(child);
}
```

记住，大多数在屏幕上渲染的组件都是 `PositionComponent`s，所以这个模式也可以用于例如 `SpriteComponent` 和 `SpriteAnimationComponent` 等。


### Render PositionComponent

在为扩展了 `PositionComponent` 的组件实现 `render` 方法时，请记住从左上角（0.0）开始渲染。你的渲染方法不应该处理组件应该在屏幕上的哪个位置渲染。要处理组件应该在哪里以及如何渲染，请使用 `position`、`angle` 和 `anchor` 属性，Flame 将自动为你处理其余部分。

如果你想要知道组件的边界框在屏幕上的位置，可以使用 `toRect` 方法。

如果你想要改变组件渲染的方向，你也可以使用 `flipHorizontally()` 和 `flipVertically()` 在 `render(Canvas canvas)` 期间围绕锚点翻转画布上绘制的任何内容。这些方法在所有 `PositionComponent` 对象上都可用，并且在 `SpriteComponent` 和 `SpriteAnimationComponent` 上特别有用。

如果你想要围绕组件的中心翻转组件，而不必将锚点更改为 `Anchor.center`，你可以使用 `flipHorizontallyAroundCenter()` 和 `flipVerticallyAroundCenter()`。


## SpriteComponent

`PositionComponent` 最常用的实现是 `SpriteComponent`，它可以通过一个 `Sprite` 来创建：

```dart
import 'package:flame/components/component.dart';

class MyGame extends FlameGame {
  late final SpriteComponent player;

  @override
  Future<void> onLoad() async {
    final sprite = await Sprite.load('player.png');
    final size = Vector2.all(128.0);
    final player = SpriteComponent(size: size, sprite: sprite);

    // Vector2(0.0, 0.0) by default, can also be set in the constructor
    player.position = Vector2(10, 20);

    // 0 by default, can also be set in the constructor
    player.angle = 0;

    // Adds the component
    add(player);
  }
}
```


## SpriteAnimationComponent

这个类用于表示一个拥有在单一循环动画中运行的精灵的组件。

这将使用3个不同的图像创建一个简单的三帧动画：

```dart
@override
Future<void> onLoad() async {
  final sprites = [0, 1, 2]
      .map((i) => Sprite.load('player_$i.png'));
  final animation = SpriteAnimation.spriteList(
    await Future.wait(sprites),
    stepTime: 0.01,
  );
  this.player = SpriteAnimationComponent(
    animation: animation,
    size: Vector2.all(64.0),
  );
}
```
如果你有一个精灵表（sprite sheet），你可以使用 `SpriteAnimationData` 类的 `sequenced` 构造函数来创建一个循环动画（[Images &gt; Animation](rendering/images.md#animation)）：


```dart
@override
Future<void> onLoad() async {
  final size = Vector2.all(64.0);
  final data = SpriteAnimationData.sequenced(
    textureSize: size,
    amount: 2,
    stepTime: 0.1,
  );
  this.player = SpriteAnimationComponent.fromFrameData(
    await images.load('player.png'),
    data,
  );
}
```

所有动画组件内部都维护了一个 `SpriteAnimationTicker`，它负责触发 `SpriteAnimation` 的更新。
这允许多个组件共享同一个动画对象。

示例：

```dart
final sprites = [/*You sprite list here*/];
final animation = SpriteAnimation.spriteList(sprites, stepTime: 0.01);

final animationTicker = SpriteAnimationTicker(animation);

// or alternatively, you can ask the animation object to create one for you.

final animationTicker = animation.createTicker(); // creates a new ticker

animationTicker.update(dt);
```

要监听动画完成（当它到达最后一帧并且不是循环的）时，你可以使用 `animationTicker.completed`。

示例：

```dart
await animationTicker.completed;

doSomething();

// or alternatively

animationTicker.completed.whenComplete(doSomething);
```

此外，`SpriteAnimationTicker` 还有以下可选的事件回调：`onStart`、`onFrame` 和 `onComplete`。要监听这些事件，你可以这样做：

```dart
final animationTicker = SpriteAnimationTicker(animation)
  ..onStart = () {
    // Do something on start.
  };

final animationTicker = SpriteAnimationTicker(animation)
  ..onComplete = () {
    // Do something on completion.
  };

final animationTicker = SpriteAnimationTicker(animation)
  ..onFrame = (index) {
    if (index == 1) {
      // Do something for the second frame.
    }
  };
```


## SpriteAnimationGroupComponent

`SpriteAnimationGroupComponent` 是 `SpriteAnimationComponent` 的一个简单包装器，它使你的组件能够持有多个动画，并在运行时更改当前播放的动画。由于这个组件只是一个包装器，事件监听器可以按照在 `SpriteAnimationComponent` 中描述的方式实现。

它的使用与 `SpriteAnimationComponent` 非常相似，但不是用单个动画进行初始化，而是这个组件接收一个映射，其键是泛型类型 `T`，值是 `SpriteAnimation`，以及当前动画。

示例：

```dart
enum RobotState {
  idle,
  running,
}

final running = await loadSpriteAnimation(/* omitted */);
final idle = await loadSpriteAnimation(/* omitted */);

final robot = SpriteAnimationGroupComponent<RobotState>(
  animations: {
    RobotState.running: running,
    RobotState.idle: idle,
  },
  current: RobotState.idle,
);

// Changes current animation to "running"
robot.current = RobotState.running;
```

由于这个组件使用多个 `SpriteAnimation`，自然它需要相同数量的动画滴答器来使所有这些动画进行滴答。
使用 `animationsTickers` 获取器可以访问包含每个动画状态滴答器的映射。如果你想为 `onStart`、`onComplete` 和 `onFrame` 注册回调，这可能会很有用。

示例：

```dart
enum RobotState { idle, running, jump }

final running = await loadSpriteAnimation(/* omitted */);
final idle = await loadSpriteAnimation(/* omitted */);

final robot = SpriteAnimationGroupComponent<RobotState>(
  animations: {
    RobotState.running: running,
    RobotState.idle: idle,
  },
  current: RobotState.idle,
);

robot.animationTickers?[RobotState.running]?.onStart = () {
  // Do something on start of running animation.
};

robot.animationTickers?[RobotState.jump]?.onStart = () {
  // Do something on start of jump animation.
};

robot.animationTickers?[RobotState.jump]?.onComplete = () {
  // Do something on complete of jump animation.
};

robot.animationTickers?[RobotState.idle]?.onFrame = (currentIndex) {
  // Do something based on current frame index of idle animation.
};
```


## SpriteGroupComponent

`SpriteGroupComponent` 与它的动画对应物非常相似，但特别是用于精灵。

示例：

```dart
class PlayerComponent extends SpriteGroupComponent<ButtonState>
    with HasGameReference<SpriteGroupExample>, TapCallbacks {
  @override
  Future<void>? onLoad() async {
    final pressedSprite = await gameRef.loadSprite(/* omitted */);
    final unpressedSprite = await gameRef.loadSprite(/* omitted */);

    sprites = {
      ButtonState.pressed: pressedSprite,
      ButtonState.unpressed: unpressedSprite,
    };

    current = ButtonState.unpressed;
  }

  // tap methods handler omitted...
}
```


## SpawnComponent

这个组件是一个非可视组件，它在 `SpawnComponent` 的父组件内生成其他组件。如果你想要在一个区域内随机生成敌人或增强道具，这个组件非常有用。

`SpawnComponent` 接受一个工厂函数，它用这个函数来创建新组件，以及一个区域，组件应该在这个区域内生成（或者沿着这个区域的边缘生成）。

对于区域，你可以使用 `Circle`、`Rectangle` 或 `Polygon` 类，如果你想要在形状的边缘生成组件，将 `within` 参数设置为 false（默认为 true）。

例如，以下代码每 0.5 秒在定义的圆内随机生成一个新的 `MyComponent` 类型的组件：

工厂函数 `factory` 接受一个 `int` 类型的参数，这是正在生成的组件的索引，所以如果已经有 4 个组件被生成，那么第 5 个组件的索引将是 4，因为索引从 0 开始。

```dart
SpawnComponent(
  factory: (i) => MyComponent(size: Vector2(10, 20)),
  period: 0.5,
  area: Circle(Vector2(100, 200), 150),
);
```

如果你不希望生成速率是静态的，你可以使用 `SpawnComponent.periodRange` 构造函数，并用 `minPeriod` 和 `maxPeriod` 参数来代替。
在以下示例中，组件将在圆内随机生成，每个新生成组件之间的时间在 0.5 到 10 秒之间。

```dart
SpawnComponent.periodRange(
  factory: (i) => MyComponent(size: Vector2(10, 20)),
  minPeriod: 0.5,
  maxPeriod: 10,
  area: Circle(Vector2(100, 200), 150),
);
```

如果你想在 `factory` 函数内自己设置位置，你可以在构造函数中使用 `selfPositioning = true`，你将能够自己设置位置并忽略 `area` 参数。

```dart
SpawnComponent(
  factory: (i) =>
    MyComponent(position: Vector2(100, 200), size: Vector2(10, 20)),
  selfPositioning: true,
  period: 0.5,
);
```


## SvgComponent

注意：要在使用 Flame 的同时使用 SVG，使用 [`flame_svg`](https://github.com/flame-engine/flame_svg) 包。

这个组件使用 `Svg` 类的一个实例来表示一个在游戏内渲染的 SVG 文件的组件：

```dart
@override
Future<void> onLoad() async {
  final svg = await Svg.load('android.svg');
  final android = SvgComponent.fromSvg(
    svg,
    position: Vector2.all(100),
    size: Vector2.all(100),
  );
}
```


## ParallaxComponent

这个 `Component` 可以用来通过在彼此上方绘制几个透明图像来渲染具有深度感的背景，每个图像或动画（`ParallaxRenderer`）以不同的速度移动。

其理念是，当你看着地平线并移动时，较近的物体似乎比远处的物体移动得更快。

这个组件模拟了这种效果，制作出更真实的背景效果。

最简单的 `ParallaxComponent` 是这样创建的：

```dart
@override
Future<void> onLoad() async {
  final parallaxComponent = await loadParallaxComponent([
    ParallaxImageData('bg.png'),
    ParallaxImageData('trees.png'),
  ]);
  add(parallaxComponent);
}
```

`ParallaxComponent` 也可以通过实现 `onLoad` 方法来“自己加载”：

```dart
class MyParallaxComponent extends ParallaxComponent<MyGame> {
  @override
  Future<void> onLoad() async {
    parallax = await gameRef.loadParallax([
      ParallaxImageData('bg.png'),
      ParallaxImageData('trees.png'),
    ]);
  }
}

class MyGame extends FlameGame {
  @override
  void onLoad() {
    add(MyParallaxComponent());
  }
}
```

这会创建一个静态背景。如果你想要一个移动的视差背景（这才是视差背景的真正意义所在），你可以根据你想要为每一层设置的精细程度，以几种不同的方式进行。

最简单的方法是在 `load` 辅助函数中设置命名可选参数 `baseVelocity` 和 `velocityMultiplierDelta`。例如，如果你想要在 X 轴上移动你的背景图像，并且“越近”的图像速度越快：

```dart
@override
Future<void> onLoad() async {
  final parallaxComponent = await loadParallaxComponent(
    _dataList,
    baseVelocity: Vector2(20, 0),
    velocityMultiplierDelta: Vector2(1.8, 1.0),
  );
}
```

你可以随时设置基础速度 `baseSpeed` 和层速度差 `layerDelta`，例如，如果你的角色跳跃或者你的游戏加速。

```dart
@override
void onLoad() {
  final parallax = parallaxComponent.parallax;
  parallax.baseSpeed = Vector2(100, 0);
  parallax.velocityMultiplierDelta = Vector2(2.0, 1.0);
}
```

默认情况下，图像会相对于左下角对齐，沿 X 轴重复，并且按比例缩放，以便图像覆盖屏幕的高度。如果你想改变这种行为，例如，如果你不是在制作一个侧滚游戏，你可以为每个 `ParallaxRenderer` 设置 `repeat`、`alignment` 和 `fill` 参数，并将它们添加到 `ParallaxLayer` 中，然后传递到 `ParallaxComponent` 的构造函数中。

高级示例：

```dart
final images = [
  loadParallaxImage(
    'stars.jpg',
    repeat: ImageRepeat.repeat,
    alignment: Alignment.center,
    fill: LayerFill.width,
  ),
  loadParallaxImage(
    'planets.jpg',
    repeat: ImageRepeat.repeatY,
    alignment: Alignment.bottomLeft,
    fill: LayerFill.none,
  ),
  loadParallaxImage(
    'dust.jpg',
    repeat: ImageRepeat.repeatX,
    alignment: Alignment.topRight,
    fill: LayerFill.height,
  ),
];

final layers = images.map(
  (image) => ParallaxLayer(
    await image,
    velocityMultiplier: images.indexOf(image) * 2.0,
  )
);

final parallaxComponent = ParallaxComponent.fromParallax(
  Parallax(
    await Future.wait(layers),
    baseVelocity: Vector2(50, 0),
  ),
);
```

- 在本例中，星星图像将在两个轴向上重复绘制，居中对齐，并缩放以填充屏幕宽度。
- 行星图像将在 Y 轴向上重复，屏幕左下角对齐，并且不进行缩放。
- 尘埃图像将在 X 轴向上重复，右上角对齐，并缩放以填充屏幕高度。

一旦你完成了 `ParallaxComponent` 的设置，就像添加其他任何组件一样将其添加到游戏中（`game.add(parallaxComponent)`）。
同时，不要忘记将你的图像添加到 `pubspec.yaml` 文件中作为资源，否则它们将无法被找到。

`Parallax` 文件包含了一个游戏的扩展，它添加了 `loadParallax`、`loadParallaxLayer`、`loadParallaxImage` 和 `loadParallaxAnimation`，以便它自动使用你的游戏图像缓存而不是全局缓存。`ParallaxComponent` 文件也提供了 `loadParallaxComponent`，但情况相同。

如果你想让 `ParallaxComponent` 充满整个屏幕，只需省略 `size` 参数，它就会占据游戏的大小，当游戏大小或方向改变时，它也会调整为全屏。

Flame 提供了两种类型的 `ParallaxRenderer`：`ParallaxImage` 和 `ParallaxAnimation`，`ParallaxImage` 是一个静态图像渲染器，而 `ParallaxAnimation` 正如其名，是一个基于动画和帧的渲染器。
也可以通过扩展 `ParallaxRenderer` 类来创建自定义渲染器。

三个示例实现可以在
[examples directory](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/parallax).


## ShapeComponents

`ShapeComponent` 是表示可缩放的几何形状的基类。这些形状有不同的方式来定义它们的外观，但它们都有一个可以修改的尺寸和角度，形状定义将相应地缩放或旋转形状。

这些形状旨在作为一种工具，用于以一种比与碰撞检测系统结合使用更通用的方式来使用几何形状，在那里你想使用这些形状来定义物体的轮廓。

[ShapeHitbox](collision_detection.md#shapehitbox)es.


### PolygonComponent

`PolygonComponent` 是通过在构造函数中给出一组点（称为顶点）来创建的。这些点将被转换成一个具有大小的多边形，该大小仍然可以进行缩放和旋转。

例如，以下代码将创建一个从 (50, 50) 到 (100, 100) 的正方形，其中心位于 (75, 75)：

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

`PolygonComponent` 也可以通过使用一组相对顶点来创建，这些顶点是相对于给定大小定义的点，通常是为了适应父组件的大小。

例如，你可以这样创建一个菱形的多边形：

```dart
void main() {
  PolygonComponent.relative(
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

示例中的顶点定义了从屏幕中心到边缘在 x 轴和 y 轴上的百分比长度，因此在我们的列表中的第一项 (`Vector2(0.0, 1.0)`) 指向了边界框最顶部中间的位置，因为这里的坐标系统是从多边形的中心定义的。

![An example of how to define a polygon shape](../images/polygon_shape.png)

在图片中你可以看到，由紫色箭头形成的多边形形状是如何由红色箭头定义的。

记住要以逆时针方向定义列表（如果你在屏幕坐标系统中思考，其中 y 轴是翻转的，否则是顺时针）。


### RectangleComponent

`RectangleComponent` 的创建方式与 `PositionComponent` 非常相似，因为它也有一个边界矩形。

例如，可以这样创建：

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

Dart 还有一个非常好的方式来创建矩形，那个类叫做 `Rect`。你可以通过使用 `Rectangle.fromRect` 工厂方法从 `Rect` 创建一个 Flame 的 `RectangleComponent`，并且就像设置 `PolygonComponent` 的顶点一样，如果你使用这个构造函数，你的矩形将根据 `Rect` 来设置大小。

以下代码将创建一个左上角在 `(10, 10)` 且大小为 `(100, 50)` 的 `RectangleComponent`。

```dart
void main() {
  RectangleComponent.fromRect(
    Rect.fromLTWH(10, 10, 100, 50),
  );
}
```

你也可以通过定义与预期父组件大小的关系来创建一个 `RectangleComponent`，你可以使用默认构造函数根据位置、大小和角度来构建你的矩形。`relation` 是一个相对于父组件大小的向量，例如，一个 `relation` 为 `Vector2(0.5, 0.8)` 将创建一个矩形，其宽度是父组件大小的 50%，高度是其 80%。

在下面的示例中，将创建一个大小为 `(25.0, 30.0)` 且位置在 `(100, 100)` 的 `RectangleComponent`。

```dart
void main() {
  RectangleComponent.relative(
    Vector2(0.5, 1.0),
    position: Vector2.all(100),
    size: Vector2(50, 30),
  );
}
```

由于正方形是矩形的简化版本，还有一个构造函数用于创建正方形的 `RectangleComponent`，唯一的区别是 `size` 参数是一个 `double` 类型而不是 `Vector2` 类型。

```dart
void main() {
  RectangleComponent.square(
    position: Vector2.all(100),
    size: 200,
  );
}
```


### CircleComponent

如果你从一开始就知道圆的位置和/或半径的长度，你可以使用可选参数 `radius` 和 `position` 来设置这些值。

以下代码将创建一个中心在 `(100, 100)`、半径为 5 的 `CircleComponent`，因此其大小为 `Vector2(10, 10)`。

```dart
void main() {
  CircleComponent(radius: 5, position: Vector2.all(100), anchor: Anchor.center);
}
```

在创建一个 `CircleComponent` 时，如果使用 `relative` 构造函数，你可以定义半径与由 `size` 定义的边界框最短边的比较长度。

以下示例将创建一个半径为 40（直径为 80）的 `CircleComponent`。

```dart
void main() {
  CircleComponent.relative(0.8, size: Vector2.all(100));
}
```


## IsometricTileMapComponent

这个组件允许你根据笛卡尔矩阵的块和一个等距贴图集来渲染一个等距地图。

一个简单的使用示例：

```dart
// Creates a tileset, the block ids are automatically assigned sequentially
// starting at 0, from left to right and then top to bottom.
final tilesetImage = await images.load('tileset.png');
final tileset = SpriteSheet(image: tilesetImage, srcSize: Vector2.all(32));
// Each element is a block id, -1 means nothing
final matrix = [[0, 1, 0], [1, 0, 0], [1, 1, 1]];
add(IsometricTileMapComponent(tileset, matrix));
```

它还提供了用于坐标转换的方法，因此你可以处理点击、悬停、在瓷砖上方渲染实体、添加选择器等。

你还可以指定 `tileHeight`，这是每个立方体底部和顶部平面之间的垂直距离。基本上，它是你立方体最前沿的高度；通常它是瓷砖大小的一半（默认）或四分之一。在下面的图片中，你可以看到用较深的色调表示的高度：

![An example of how to determine the tileHeight](../images/tile-height-example.png)

这是一个四分之一长度地图的样子的例子：

![An example of a isometric map with selector](../images/isometric.png)

Flame 的示例应用程序中包含了一个更深入的示例，展示了如何解析坐标来制作一个选择器。代码可以在这里找到[这里](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/isometric_tile_map_example.dart)，同时你还可以在这里查看实时版本[这里](https://examples.flame-engine.org/#/Rendering_Isometric_Tile_Map)。


## NineTileBoxComponent

九宫格盒子是一个使用网格精灵绘制的矩形。

网格精灵是一个 3x3 网格，包含 9 个区块，分别代表 4 个角、4 条边和中间部分。

角上的区块以相同大小绘制，边上的区块在边的方向上拉伸，中间部分则在两个方向上扩展。

使用这个功能，你可以得到一个能够很好地扩展到任何大小的盒子/矩形。这在制作面板、对话框、边框时非常有用。

查看示例应用程序了解更多。
[nine_tile_box](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/rendering/nine_tile_box_example.dart)
for details on how to use it.


## CustomPainterComponent

`CustomPainter` 是一个 Flutter 类，与 `CustomPaint` 组件一起在 Flutter 应用程序中用于渲染自定义形状。

Flame 提供了一个名为 `CustomPainterComponent` 的组件，它可以接收一个自定义绘制器并在游戏画布上渲染它。

这可以用于在 Flame 游戏和 Flutter 组件之间共享自定义渲染逻辑。

🌰
[custom_painter_component](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/widgets/custom_painter_example.dart)
详细使用


## ComponentsNotifier

大多数时候，只需访问子组件及其属性就足以构建游戏的逻辑。

但有时，响应性可以帮助开发者简化并编写更好的代码，为了帮助实现这一点，Flame 提供了 `ComponentsNotifier`，这是 `ChangeNotifier` 的一个实现，它在每次组件被添加、移除或手动更改时都会通知监听器。

例如，假设我们想要在玩家生命值达到零时显示游戏结束的文本。

要使组件在添加或移除新实例时自动报告，可以对组件类应用 `Notifier` 混入：

```dart
class Player extends SpriteComponent with Notifier {}
```

然后，要监听该组件的变化，可以使用 `FlameGame` 中的 `componentsNotifier` 方法：

```dart
class MyGame extends FlameGame {
  int lives = 2;

  @override
  void onLoad() {
    final playerNotifier = componentsNotifier<Player>()
        ..addListener(() {
          final player = playerNotifier.single;
          if (player == null) {
            lives--;
            if (lives == 0) {
              add(GameOverComponent());
            } else {
              add(Player());
            }
          }
        });
  }
}
```

一个 `Notifier` 组件也可以手动通知其监听器发生了变化。让我们扩展上面的例子，制作一个当玩家生命值减半时闪烁的 hud 组件。为此，我们需要 `Player` 组件手动通知变化，示例：

```dart
class Player extends SpriteComponent with Notifier {
  double health = 1;

  void takeHit() {
    health -= .1;
    if (health == 0) {
      removeFromParent();
    } else if (health <= .5) {
      notifyListeners();
    }
  }
}
```

然后，我们的 hud 组件可以是这样的：

```dart
class Hud extends PositionComponent with HasGameRef {

  @override
  void onLoad() {
    final playerNotifier = gameRef.componentsNotifier<Player>()
        ..addListener(() {
          final player = playerNotifier.single;
          if (player != null) {
            if (player.health <= .5) {
              add(BlinkEffect());
            }
          }
        });
  }
}
```

`ComponentsNotifier` 在 `FlameGame` 中状态变化时重新构建组件也非常有用，为了帮助实现这一点，Flame 提供了一个 `ComponentsNotifierBuilder` 组件。

要查看其使用示例，请查看运行中的示例。
[here](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/components/components_notifier_example.dart).


## ClipComponent

`ClipComponent` 是一个组件，它将画布剪切为其大小和形状。这意味着如果组件本身或 `ClipComponent` 的任何子组件在 `ClipComponent` 的边界外进行渲染，那么不在区域内的部分将不会被显示。

`ClipComponent` 接收一个构建器函数，该函数应该返回定义剪切区域的 `Shape`，基于其大小。

为了更容易使用该组件，有三个工厂提供了常见的形状：

- `ClipComponent.rectangle`：根据其大小以矩形的形式剪切区域。
- `ClipComponent.circle`：根据其大小以圆形的形式剪切区域。
- `ClipComponent.polygon`：根据构造函数中接收的点以多边形的形式剪切区域。

Check the example app
[clip_component](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/components/clip_component_example.dart)
for details on how to use it.


## Effects

Flame 提供了一系列可以应用于特定类型组件的特效，这些特效可以用来动画化你组件的某些属性，比如位置或尺寸。你可以在[这里](effects.md)查看这些特效的列表。

特效的运行示例可以在[这里](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/effects)找到；


## When not using `FlameGame`

如果你没有使用 `FlameGame`，不要忘记在游戏每次更新时都需要更新所有组件。这允许组件执行它们的内部处理和更新它们的状态。

例如，所有基于 `SpriteAnimation` 的组件内部的 `SpriteAnimationTicker` 需要触发动画对象，以决定接下来显示哪帧动画。

如果不使用 `FlameGame`，可以通过手动调用 `component.update()` 来完成。

这也意味着，如果你正在实现你自己的基于精灵动画的组件，你可以直接使用 `SpriteAnimationTicker` 来更新 `SpriteAnimation`。
