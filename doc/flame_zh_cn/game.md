# FlameGame

`FlameGame` 类实现了一个基于 `Component` 的 `Game`。它有一组组件树，并调用所有已添加到游戏中的组件的 `update` 和 `render` 方法。

我们称这个基于组件的系统为 Flame 组件系统（FCS）。在整个文档中，FCS 用来指代这个系统。

可以通过 `FlameGame` 构造函数中的命名 `children` 参数直接添加组件，或者使用 `add`/`addAll` 方法从任何其他地方添加。然而，大多数情况下，你想要将你的子组件添加到一个 `World` 中，默认的世界存在于 `FlameGame.world` 下，你就像对任何其他组件一样向它添加组件。

一个简单的 `FlameGame` 实现，它在 `onLoad` 中添加了一个组件，另一个直接在构造函数中添加，可以像这样：

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

/// A component that renders the crate sprite, with a 16 x 16 size.
class MyCrate extends SpriteComponent {
  MyCrate() : super(size: Vector2.all(16));

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('crate.png');
  }
}

class MyWorld extends World {
  @override
  Future<void> onLoad() async {
    await add(MyCrate());
  }
}

void main() {
  final myGame = FlameGame(world: MyWorld());
  runApp(
    GameWidget(game: myGame),
  );
}
```

```{note}
如果你在构建方法中实例化你的游戏，你的游戏将会在 Flutter 树每次重建时被重建，这通常比你希望的要频繁得多。
为了避免这种情况，你可以要么先创建一个游戏实例并在你的小部件结构中引用它，要么使用 `GameWidget.controlled` 构造函数。
```

要从 `FlameGame` 的列表中移除组件，可以使用 `remove` 或 `removeAll` 方法。
第一个方法可以用来移除一个组件，第二个方法可以在你想要移除一系列组件时使用。
这些方法存在于所有 `Component` 上，包括世界（world）。


## Game Loop

`GameLoop` 模块是对游戏循环概念的简单抽象。基本上，大多数游戏都建立在两个方法上：

- `render` 方法使用画布来绘制游戏的当前状态。
- `update` 方法接收自上次更新以来的微秒时间差，允许你过渡到下一个状态。

`GameLoop` 被 Flame 的所有 `Game` 实现所使用。


## Resizing

每当游戏需要调整大小时，例如当方向改变时，`FlameGame` 将调用所有 `Component` 的 `onGameResize` 方法，并将此信息传递给相机和视口。

`FlameGame.camera` 控制在坐标空间中哪个点应该作为你的取景器的锚点，默认情况下 [0,0] 位于视口的中心（`Anchor.center`）。


## Lifecycle

`FlameGame` 生命周期回调函数 `onLoad`、`render` 等按照以下顺序被调用：

```{include} diagrams/flame_game_life_cycle.md
```

当 `FlameGame` 第一次被添加到 `GameWidget` 时，生命周期方法 `onGameResize`、`onLoad` 和 `onMount` 将按照这个顺序被调用。
然后 `update` 和 `render` 会按照顺序在每一个游戏刻调用。
如果 `FlameGame` 从 `GameWidget` 中移除，那么 `onRemove` 将被调用。
如果 `FlameGame` 被添加到一个新的 `GameWidget`，那么序列将从 `onGameResize` 开始重复。

```{note}
`onGameResize` 和 `onLoad` 的顺序与其他 `Component` 组件相反。这是为了允许在资源被加载或生成之前计算游戏元素的大小。
```

`onRemove` 回调可以用来清理子组件和缓存的数据：

```dart
  @override
  void onRemove() {
    // Optional based on your game needs.
    removeAll(children);
    processLifecycleEvents();
    Flame.images.clearCache();
    Flame.assets.clearCache();
    // Any other code that you want to run when the game is removed.
  }
```

```{note}
在 `FlameGame` 中，子组件和资源的清理不会自动进行，必须显式地添加到 `onRemove` 调用中。
```


## Debug mode

Flame 的 `FlameGame` 类提供了一个名为 `debugMode` 的变量，默认值为 `false`。

然而，它可以设置为 `true` 以启用游戏组件的调试功能。**请注意**，这个变量的值在组件被添加到游戏时会传递给它们，因此如果你在运行时更改 `debugMode`，默认情况下不会影响已经添加的组件。

要了解更多关于 Flame 中 `debugMode` 的信息，请参考 [调试文档](other/debug.md)。


## Change background color

要改变你的 `FlameGame` 的背景颜色，你需要重写 `backgroundColor()` 方法。

在以下示例中，背景颜色被设置为完全透明，这样你可以看到位于 `GameWidget` 背后的小部件。默认是实心黑色。

```dart
class MyGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0x00000000);
}
```

请注意，游戏运行时背景颜色不能动态改变，但如果你需要背景颜色动态变化，你可以绘制一个覆盖整个画布的背景。


## SingleGameInstance mixin

如果你正在制作一个单游戏应用，可以选择将可选的混入 `SingleGameInstance` 应用到你的游戏中。这是在构建游戏时常见的场景：有一个全屏的 `GameWidget` 托管一个单独的 `Game` 实例。

添加这个混入在某些情况下提供了性能优势。特别是，当一个组件被添加到其父组件时，组件的 `onLoad` 方法会保证开始执行，即使父组件尚未挂载。因此，`await` 调用 `parent.add(component)` 将始终确保完成组件的加载。

使用这个混入很简单：

```dart
class MyGame extends FlameGame with SingleGameInstance {
  // ...
}
```


## Low-level Game API

```{include} diagrams/low_level_game_api.md
```

抽象的 `Game` 类是一个低级 API，可以在你想要实现游戏引擎的结构功能时使用。例如，`Game` 没有实现任何 `update` 或 `render` 函数。

这个类还包含了生命周期方法 `onLoad`、`onMount` 和 `onRemove`，这些方法在游戏被加载 + 挂载或移除时，由 `GameWidget`（或另一个父组件）调用。
`onLoad` 只在该类第一次被添加到父组件时调用，但是 `onMount`（在 `onLoad` 之后调用）每次被添加到新父组件时都会调用。`onRemove` 在该类从父组件移除时调用。

```{note}
`Game` 类允许你更自由地实现功能，但如果你使用它，你也将错过 Flame 中所有内置的特性。
```

举个例子:

```dart
class MyGameSubClass extends Game {
  @override
  void render(Canvas canvas) {
    // ...
  }

  @override
  void update(double dt) {
    // ...
  }
}

void main() {
  final myGame = MyGameSubClass();
  runApp(
    GameWidget(
      game: myGame,
    )
  );
}
```


## Pause/Resuming/Stepping game execution

Flame 的 `Game` 可以通过两种方式暂停和恢复：

- 使用 `pauseEngine` 和 `resumeEngine` 方法。
- 通过改变 `paused` 属性。

当暂停一个 `Game` 时，`GameLoop` 实际上是被暂停的，这意味着在它被恢复之前不会有任何更新或新的渲染发生。

在游戏暂停时，可以使用 `stepEngine` 方法逐帧推进它。
这在最终游戏中可能没有太多用处，但在开发周期中逐步检查游戏状态时可能非常有用。


### Backgrounding

当应用程序退到后台时，游戏会自动暂停，当它回到前台时会恢复。通过设置 `pauseWhenBackgrounded` 为 `false` 可以禁用这种行为。

```dart
class MyGame extends FlameGame {
  MyGame() {
    pauseWhenBackgrounded = false;
  }
}
```

在当前的 Flutter 稳定版本（3.13）中，这个标志在非移动平台（包括 web）上实际上被忽略了。


## HasPerformanceTracker mixin

在优化游戏时，追踪游戏更新和渲染每一帧所需的时间可能很有用。这些数据可以帮助检测代码中运行频繁的区域。它也可以帮助发现游戏中渲染耗时最多的视觉区域。

要获取更新和渲染时间，只需将 `HasPerformanceTracker` 混入（mixin）添加到游戏类中。

```dart
class MyGame extends FlameGame with HasPerformanceTracker {
  // access `updateTime` and `renderTime` getters.
}
```
