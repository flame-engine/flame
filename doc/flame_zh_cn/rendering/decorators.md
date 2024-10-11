# Decorators

**装饰器（Decorators）** 是一类可以封装特定视觉效果的类，然后将这些视觉效果应用到一系列的画布绘制操作上。装饰器不是 [Component]s，但它们可以手动或通过 [HasDecorator] 混入应用到组件上。同样，装饰器不是 [Effect]s，尽管它们可以用来实现某些 `Effect`s。

在 Flame 中有相当数量的装饰器可用，如果需要，也很简单添加自己的装饰器。一旦 Flutter 在 web 上完全支持，我们计划添加基于着色器的装饰器。


## Flame built-in decorators


### PaintDecorator.blur

```{flutter-app}
:sources: ../flame/examples
:page: decorator_blur
:show: widget code infobox
:width: 180
:height: 160
```

这个装饰器对底层组件应用高斯模糊。在 X 和 Y 方向上的模糊量可以不同，尽管这并不很常见。

```dart
final decorator = PaintDecorator.blur(3.0);
```

可能的用途包括：

- 柔和阴影；
- 远处或非常靠近相机的“失焦”物体；
- 运动模糊效果；
- 在显示弹出对话框时降低/隐藏内容；
- 当角色醉酒时的模糊视觉。


### PaintDecorator.grayscale

```{flutter-app}
:sources: ../flame/examples
:page: decorator_grayscale
:show: widget code infobox
:width: 180
:height: 160
```

这个装饰器将底层图像转换成灰度色阶，就像它是一张黑白照片。此外，你可以根据需要将图像设置为半透明至 `opacity` 指定的程度。

```dart
final decorator = PaintDecorator.grayscale(opacity: 0.5);
```

可能的用途包括：

- 应用于一个NPC，将它们变成石头，或者变成幽灵！
- 应用于一个场景，以表明它是过去的记忆；
- 黑白照片。


### PaintDecorator.tint

```{flutter-app}
:sources: ../flame/examples
:page: decorator_tint
:show: widget code infobox
:width: 180
:height: 160
```

这个装饰器用指定的颜色为底层图像上色，就像透过有色玻璃观看一样。建议这个装饰器使用的 `color` 是半透明的，这样你可以看到下面图像的细节。

```dart
final decorator = PaintDecorator.tint(const Color(0xAAFF0000);
```

可能的用途包括：

- 受到特定类型魔法影响的NPC；
- 阴影中的物品/角色可以被染成黑色；
- 将场景染成红色以显示杀戮欲或角色生命值低；
- 将角色染成绿色以显示角色中毒或生病；
- 在夜晚将场景染成深蓝色。


### Rotate3DDecorator

```{flutter-app}
:sources: ../flame/examples
:page: decorator_rotate3d
:show: widget code infobox
:width: 180
:height: 160
```

这个装饰器对底层组件应用了3D旋转。你可以指定旋转的角度，以及旋转的支点和要应用的透视失真程度。

装饰器还提供了 `isFlipped` 属性，允许你确定组件当前是从正面还是从背面查看。如果你想绘制一个在正面和背面看起来不同的组件，这非常有用。

```dart
final decorator = Rotate3DDecorator(
  center: component.center,
  angleX: rotationAngle,
  perspective: 0.002,
);
```

可能的用途包括：

- 可以翻转的卡片；
- 书中的页面；
- 应用路由之间的过渡；
- 如雪花或树叶等3D下落粒子。


### Shadow3DDecorator

```{flutter-app}
:sources: ../flame/examples
:page: decorator_shadow3d
:show: widget code infobox
:width: 180
:height: 160
```

这个装饰器在组件下方渲染一个阴影，就好像组件是一个站在平面上的3D对象。这种效果最适合使用等角投影相机的游戏。

这个生成器产生的阴影非常灵活：你可以控制它的角度、长度、不透明度、模糊度等。有关这个装饰器具有的属性及其含义的完整描述，请参见类文档。

```dart
final decorator = Shadow3DDecorator(
  base: Vector2(100, 150),
  angle: -1.4,
  xShift: 200,
  yScale: 1.5,
  opacity: 0.5,
  blur: 1.5,
);
```

这个装饰器的主要目的是为你的组件添加地面上的阴影。主要的限制是阴影是平面的，不能与环境互动。例如，这个装饰器无法处理落在墙壁或其他垂直结构上的阴影。


## Using decorators


### HasDecorator mixin

这个 `Component` mixin 添加了 `decorator` 属性，该属性最初是 `null`。如果你将这个属性设置为一个实际的 `Decorator` 对象，那么在组件渲染过程中，该装饰器将应用其视觉效果。为了移除这个视觉效果，只需将 `decorator` 属性重新设置为 `null`。


### PositionComponent

`PositionComponent`（以及所有派生类）已经拥有一个 `decorator` 属性，因此对于这些组件来说，不需要 `HasDecorator` mixin。

实际上，`PositionComponent` 使用其装饰器来正确地在屏幕上定位组件。因此，任何你想要应用到 `PositionComponent` 的新装饰器都需要被链接起来（见下文的[多个装饰器](#multiple-decorators)部分）。

如果你想要为 `PositionComponent` 创建一个替代的逻辑，以决定组件如何在屏幕上定位，也可以替换 `PositionComponent` 的根装饰器。


### Multiple decorators

可以同时对同一个组件应用多个装饰器：`Decorator` 类支持链式操作。也就是说，如果你在组件上已经有一个装饰器，并且你想要添加另一个装饰器，那么你可以调用 `component.decorator.addLast(newDecorator)` —— 这将在现有链的末尾添加新的装饰器。稍后可以使用 `removeLast()` 方法来移除该装饰器。

可以这样链接多个装饰器。例如，如果 `A` 是一个初始装饰器，那么 `A.addLast(B)` 可以接着是 `A.addLast(C)` 或者 `B.addLast(C)` —— 在这两种情况下都会创建 `A -> B -> C` 的链。在实践中，这意味着整个链可以从其根开始操作，这通常是 `component.decorator`。


[Component]: ../../flame/components.md#component
[Effect]: ../../flame/effects.md
[HasDecorator]: #hasdecorator-mixin
