# Effects

```markdown
效果（Effect）是一个特殊的组件，可以附加到另一个组件上以修改其属性或外观。

例如，假设你正在制作一个有可收集增强物品的游戏。你希望这些增强物品在地图上随机生成，然后在一段时间后消失。

显然，你可以为增强物品制作一个精灵组件，然后将该组件放置在地图上，但我们可以做的更好！

让我们添加一个 `ScaleEffect`，使物品在首次出现时从0%增长到100%。

再添加一个无限重复的交替 `MoveEffect`，使物品轻微地上下移动。

然后添加一个 `OpacityEffect`，使物品“闪烁”3次，这个效果将内置30秒的延迟，或者你希望增强物品停留在原地的任何时长。

最后，添加一个 `RemoveEffect`，在指定的时间后自动将物品从游戏树中移除（你可能希望在 `OpacityEffect` 结束后立即进行计时）。

正如你所见，通过一些简单效果，我们将一个简单的无生命精灵变成了一个更有趣的物品。更重要的是，它并没有导致代码复杂性的增加：效果一旦添加，将自动工作，然后在完成后自动从游戏树中移除。
```



## Overview

`Effect` 的功能是在一段时间内改变某个组件的属性。为了实现这一点，`Effect` 必须知道属性的初始值、最终值以及它应该如何随时间变化。初始值通常由效果自动确定，最终值由用户明确提供，而随时间的变化则由 `EffectController` 处理。

Flame 提供了多种效果，你还可以[创建你自己的效果](#creating-new-effects)。以下是包括的效果：

- [`MoveByEffect`](#movebyeffect)
- [`MoveToEffect`](#movetoeffect)
- [`MoveAlongPathEffect`](#movealongpatheffect)
- [`RotateEffect.by`](#rotateeffectby)
- [`RotateEffect.to`](#rotateeffectto)
- [`ScaleEffect.by`](#scaleeffectby)
- [`ScaleEffect.to`](#scaleeffectto)
- [`SizeEffect.by`](#sizeeffectby)
- [`SizeEffect.to`](#sizeeffectto)
- [`AnchorByEffect`](#anchorbyeffect)
- [`AnchorToEffect`](#anchortoeffect)
- [`OpacityToEffect`](#opacitytoeffect)
- [`OpacityByEffect`](#opacitybyeffect)
- [`ColorEffect`](#coloreffect)
- [`SequenceEffect`](#sequenceeffect)
- [`RemoveEffect`](#removeeffect)

`EffectController` 是一个描述效果应如何随时间演变的对象。如果你将效果的初始值视为0%进度，最终值视为100%进度，那么效果控制器的工作就是将“物理”时间（以秒为单位）映射到“逻辑”时间，后者从0变化到1。

Flame框架也提供了多种效果控制器：

- [`EffectController`](#effectcontroller)
- [`LinearEffectController`](#lineareffectcontroller)
- [`ReverseLinearEffectController`](#reverselineareffectcontroller)
- [`CurvedEffectController`](#curvedeffectcontroller)
- [`ReverseCurvedEffectController`](#reversecurvedeffectcontroller)
- [`PauseEffectController`](#pauseeffectcontroller)
- [`RepeatedEffectController`](#repeatedeffectcontroller)
- [`InfiniteEffectController`](#infiniteeffectcontroller)
- [`SequenceEffectController`](#sequenceeffectcontroller)
- [`SpeedEffectController`](#speedeffectcontroller)
- [`DelayedEffectController`](#delayedeffectcontroller)
- [`NoiseEffectController`](#noiseeffectcontroller)
- [`RandomEffectController`](#randomeffectcontroller)
- [`SineEffectController`](#sineeffectcontroller)
- [`ZigzagEffectController`](#zigzageffectcontroller)


## Built-in effects


### `Effect`

基 `Effect` 类本身不可用（它是抽象的），但它提供了所有其他效果所继承的一些共同功能。这包括：

- 使用 `effect.pause()` 和 `effect.resume()` 暂停/恢复效果的能力。你可以使用 `effect.isPaused` 检查效果当前是否已暂停。

- 属性 `removeOnFinish`（默认为 true）会在效果完成后将效果组件从游戏树中移除并进行垃圾回收。如果你计划在效果完成后重用该效果，请将其设置为 false。

- 可选的用户提供的 `onComplete`，在效果完成执行但尚未从游戏树中移除之前调用。

- 当效果完成时，`completed` 未来（future）将完成。

- `reset()` 方法将效果恢复到原始状态，允许它再次运行。


### `MoveByEffect`

这个效果应用于 `PositionComponent`，并将其按照指定的 `offset` 数量进行移动。这个偏移量是相对于目标当前位置的：

```{flutter-app}
:sources: ../flame/examples
:page: move_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = MoveByEffect(
  Vector2(0, -10),
  EffectController(duration: 0.5),
);
```

如果组件当前位于 `Vector2(250, 200)`，那么在效果结束时，它的位置将变为 `Vector2(250, 190)`。

可以同时对一个组件应用多个移动效果。结果将是所有个别效果的叠加。


### `MoveToEffect`

这个效果使 `PositionComponent` 从当前位置沿直线移动到指定的目的地点。

```{flutter-app}
:sources: ../flame/examples
:page: move_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = MoveToEffect(
  Vector2(100, 500),
  EffectController(duration: 3),
);
```

可以，但不建议在同一组件上附加多个这样的效果。

### `MoveAlongPathEffect`

这个效果使 `PositionComponent` 沿着相对于组件当前位置的指定路径移动。路径可以有非直线段，但必须是单连通的。建议从 `Vector2.zero()` 开始路径，以避免组件位置的突然跳跃。

```{flutter-app}
:sources: ../flame/examples
:page: move_along_path_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = MoveAlongPathEffect(
  Path()..quadraticBezierTo(100, 0, 50, -50),
  EffectController(duration: 1.5),
);
```

可选标志 `absolute: true` 会将效果内定义的路径视为绝对路径。也就是说，目标会在开始时“跳跃”到路径的起点，然后沿着这条路径移动，就好像它是画布上的一条曲线一样。

另一个标志 `oriented: true` 指示目标不仅要沿着曲线移动，而且在每个点也要朝着曲线面向的方向旋转。有了这个标志，效果同时成为了移动和旋转效果。


### `RotateEffect.by`

将目标顺时针旋转指定角度，相对于其当前方向。角度以弧度为单位。例如，以下效果将使目标顺时针旋转90º（即 $\frac{\tau}{4}$ 弧度）：

```{flutter-app}
:sources: ../flame/examples
:page: rotate_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = RotateEffect.by(
  tau/4,
  EffectController(duration: 2),
);
```


### `RotateEffect.to`

将目标顺时针旋转到指定角度。例如，以下代码将使目标朝向东方（0º 是北，90º 是东，180º 是南，270º 是西）：

```{flutter-app}
:sources: ../flame/examples
:page: rotate_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = RotateEffect.to(
  tau/4,
  EffectController(duration: 2),
);
```


### `ScaleEffect.by`

这个效果会通过指定的数量改变目标的缩放比例。例如，这将使组件的尺寸增大50%：

 ```{flutter-app}
 :sources: ../flame/examples
 :page: scale_by_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = ScaleEffect.by(
  Vector2.all(1.5),
  EffectController(duration: 0.3),
);
```


### `ScaleEffect.to`

这个效果的工作方式类似于 `ScaleEffect.by`，但它设置目标缩放的绝对值。

 ```{flutter-app}
 :sources: ../flame/examples
 :page: scale_to_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = ScaleEffect.to(
  Vector2.all(0.5),
  EffectController(duration: 0.5),
);
```


### `SizeEffect.by`

这个效果会相对于目标组件的当前大小改变其尺寸。例如，如果目标的大小为 `Vector2(100, 100)`，那么在应用了以下效果并运行完毕后，新的大小将变为 `Vector2(120, 50)`：

 ```{flutter-app}
 :sources: ../flame/examples
 :page: size_by_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = SizeEffect.by(
   Vector2(-15, 30),
   EffectController(duration: 1),
);
```

```markdown
`PositionComponent` 的大小不能为负数。如果一个效果试图将大小设置为负值，那么大小将被限制在零。

请注意，为了让这个效果起作用，目标组件必须实现 `SizeProvider` 接口，并在渲染时考虑其 `size`。只有少数内置组件实现了这个 API，但你可以通过在类声明中添加 `implements SizeEffect` 来让你自己的组件与大小效果一起工作。

`SizeEffect` 的一个替代方案是 `ScaleEffect`，它的工作方式更通用，可以缩放目标组件及其子组件。
```



### `SizeEffect.to`

将目标组件的大小更改为指定的大小。目标大小不能为负数：


 ```{flutter-app}
 :sources: ../flame/examples
 :page: size_to_effect
 :show: widget code infobox
 :width: 180
 :height: 160
 ```

```dart
final effect = SizeEffect.to(
  Vector2(90, 80),
  EffectController(duration: 1),
);
```


### `AnchorByEffect`

通过指定的偏移量改变目标的锚点位置。这个效果也可以使用 `AnchorEffect.by()` 创建。

```{flutter-app}
:sources: ../flame/examples
:page: anchor_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = AnchorByEffect(
  Vector2(0.1, 0.1),
  EffectController(speed: 1),
);
```


### `AnchorToEffect`

改变目标的锚点位置。这个效果也可以使用 `AnchorEffect.to()` 创建。

```{flutter-app}
:sources: ../flame/examples
:page: anchor_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = AnchorToEffect(
  Anchor.center,
  EffectController(speed: 1),
);
```


### `OpacityToEffect`

这个效果会随时间改变目标的透明度至指定的 alpha 值。它只能应用于实现了 `OpacityProvider` 的组件。

```{flutter-app}
:sources: ../flame/examples
:page: opacity_to_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = OpacityEffect.to(
  0.2,
  EffectController(duration: 0.75),
);
```

如果组件使用了多个画笔，效果可以通过 `target` 参数来定位一个或多个画笔。`HasPaint` 混入实现了 `OpacityProvider` 并提供了 API，可以轻松地为所需的 paintIds 创建提供者。
对于单个 paintId，可以使用 `opacityProviderOf`，对于多个 paintIds，可以使用 `opacityProviderOfList`。


```{flutter-app}
:sources: ../flame/examples
:page: opacity_effect_with_target
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = OpacityEffect.to(
  0.2,
  EffectController(duration: 0.75),
  target: component.opacityProviderOfList(
    paintIds: const [paintId1, paintId2],
  ),
);
```

透明度值为 0 对应于完全透明的组件，而透明度值为 1 则表示完全不透明。便利构造函数 `OpacityEffect.fadeOut()` 和 `OpacityEffect.fadeIn()` 将分别使目标动画过渡到完全透明和完全可见。


### `OpacityByEffect`

这个效果将相对于指定的 alpha 值改变目标的透明度。例如，以下效果将使目标的透明度改变 `90%`：

```{flutter-app}
:sources: ../flame/examples
:page: opacity_by_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = OpacityEffect.by(
  0.9,
  EffectController(duration: 0.75),
);
```

目前，这个效果只能应用于具有 `HasPaint` 混入的组件。如果目标组件使用了多个画笔，效果可以通过 `paintId` 参数针对任何单一颜色进行操作。


### GlowEffect

```{note}
This effect is currently experimental, and its API may change in the future.
```

这个效果将在目标周围应用发光效果，相对于指定的 `glow-strength`。阴影的颜色将是目标的绘画颜色。例如，以下效果将通过强度为 `10` 的方式在目标周围应用发光效果：

```{flutter-app}
:sources: ../flame/examples
:page: glow_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = GlowEffect(
  10.0,
  EffectController(duration: 3),
);
```

目前，这个效果只能应用于包含 `HasPaint` 混入的组件。


### `SequenceEffect`

这个效果可以用来连续运行多个其他效果。这些组成效果可以有不同的类型。

序列效果也可以是交替的（序列首先向前运行，然后向后运行）；并且可以重复一定次数，或者无限重复。

```{flutter-app}
:sources: ../flame/examples
:page: sequence_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = SequenceEffect([
  ScaleEffect.by(
    Vector2.all(1.5),
    EffectController(
      duration: 0.2,
      alternate: true,
    ),
  ),
  MoveEffect.by(
    Vector2(30, -50),
    EffectController(
      duration: 0.5,
    ),
  ),
  OpacityEffect.to(
    0,
    EffectController(
      duration: 0.3,
    ),
  ),
  RemoveEffect(),
]);
```


### `RemoveEffect`

这是一个简单的效果，可以附加到一个组件上，使其在指定的延迟过后从游戏树中移除：

```{flutter-app}
:sources: ../flame/examples
:page: remove_effect
:show: widget code infobox
:width: 180
:height: 160
```


```dart
final effect = RemoveEffect(delay: 3.0);
```


## ColorEffect

这个效果将改变画笔的基础颜色，使得渲染的组件在指定范围内被提供的颜色染色。

使用示例：

```{flutter-app}
:sources: ../flame/examples
:page: color_effect
:show: widget code infobox
:width: 180
:height: 160
```

```dart
final effect = ColorEffect(
  const Color(0xFF00FF00),
  EffectController(duration: 1.5),
  opacityFrom = 0.2,
  opacityTo: 0.8,
);
```

`opacityFrom` 和 `opacityTo` 参数将决定将多少颜色应用到组件上。在这个例子中，效果将从20%开始，上升到80%。

**注意：** 由于这个效果的实现方式以及 Flutter 的 `ColorFilter` 类的工作原理，这个效果不能与其他 `ColorEffect` 混用，当有多个效果被添加到组件时，只有最后一个会起作用。


## Creating new effects

尽管 Flame 提供了丰富的内置效果，但最终你可能会发现它们不够用。幸运的是，创建新效果非常简单。

每个效果都扩展了基 `Effect` 类，可能是通过更专业的抽象子类之一，如 `ComponentEffect<T>` 或 `Transform2DEffect`。

`Effect` 类的构造函数需要一个 `EffectController` 实例作为参数。在大多数情况下，你可能希望从你自己的构造函数中传递该控制器。幸运的是，效果控制器封装了效果实现的复杂性，所以你不需要担心重新创建该功能。

最后，你需要实现一个单一的方法 `apply(double progress)`，该方法将在效果激活时的每个更新刻被调用。在这个方法中，你应该对效果的目标进行更改。

此外，如果你想在效果开始或结束时执行任何操作，可能需要实现回调 `onStart()` 和 `onFinish()`。

在实现 `apply()` 方法时，我们建议只使用相对更新。也就是说，通过增加/减少其当前值来改变目标属性，而不是直接将该属性设置为固定值。这样，多个效果就能在同一组件上作用，而不会相互干扰。


## Effect controllers


### `EffectController`

基 `EffectController` 类提供了一个工厂构造函数，能够创建多种常见的控制器。该构造函数的语法如下：

```dart
EffectController({
    required double duration,
    Curve curve = Curves.linear,
    double? reverseDuration,
    Curve? reverseCurve,
    bool alternate = false,
    double atMaxDuration = 0.0,
    double atMinDuration = 0.0,
    int? repeatCount,
    bool infinite = false,
    double startDelay = 0.0,
    VoidCallback? onMax,
    VoidCallback? onMin,
});
```

- `duration` -- 效果主要部分的持续时间，即从0%发展到100%所需的时间。这个参数不能为负，但可以为零。如果这是唯一指定的参数，那么效果将在 `duration` 秒内线性增长。

- `curve` -- 如果提供，根据提供的[曲线](https://api.flutter.dev/flutter/animation/Curves-class.html)创建一个非线性效果，从0%发展到100%。

- `reverseDuration` -- 如果提供，在控制器中添加一个额外的步骤：在效果在 `duration` 秒内从0%增长到100%之后，它将然后在 `reverseDuration` 秒内从100%倒退到0%。此外，效果将在进度级别0完成（通常效果在进度1完成）。

- `reverseCurve` -- 在效果的“倒退”步骤中使用的曲线。如果没有提供，这将默认为 `curve.flipped`。

- `alternate` -- 设置为 true 相当于指定 `reverseDuration` 等于 `duration`。如果已经设置了 `reverseDuration`，则此标志无效果。

- `atMaxDuration` -- 如果非零，这在效果达到最大进度后和倒退阶段之前插入一个暂停。在这段时间内，效果保持在100%进度。如果没有倒退阶段，那么这将简单地在效果被标记为完成之前暂停。

- `atMinDuration` -- 如果非零，这在倒退阶段结束时效果达到最低进度（0）后插入一个暂停。在这段时间内，效果的进度为0%。如果没有倒退阶段，那么如果存在“at-max”暂停，这个暂停仍将在其后插入，或者在其他情况下在向前阶段之后插入。此外，效果现在将在进度级别0完成。

- `repeatCount` -- 如果大于一，它将导致效果重复自身指定的次数。每次迭代将包括向前阶段、在最大值处暂停、倒退阶段，然后是最小值处暂停（跳过未指定的）。

- `infinite` -- 如果为 true，效果将无限重复，永不完成。这相当于将 `repeatCount` 设置为无限大。

- `startDelay` -- 在效果开始之前插入的额外等待时间。


### `LinearEffectController`

这是最简单的效果控制器，它在指定的 `duration` 时间内从 0 线性增长到 1：

```dart
final ec = LinearEffectController(3);
```


### `ReverseLinearEffectController`

与 `LinearEffectController` 类似，但它的方向相反，并且在指定的持续时间内从 1 线性减少到 0：

```dart
final ec = ReverseLinearEffectController(1);
```


### `CurvedEffectController`

这个效果控制器在指定的 `duration` 时间内非线性地从 0 增长到 1，并遵循提供的 `curve`：

```dart
final ec = CurvedEffectController(0.5, Curves.easeOut);
```


### `ReverseCurvedEffectController`

与 `CurvedEffectController` 类似，但是控制器按照提供的 `curve` 从 1 减少到 0：

```dart
final ec = ReverseCurvedEffectController(0.5, Curves.bounceInOut);
```


### `PauseEffectController`

这个效果控制器在指定的时间持续内保持进度在恒定值。通常，`progress` 会是 0 或者 1：

```dart
final ec = PauseEffectController(1.5, progress: 0);
```


### `RepeatedEffectController`

这是一个复合效果控制器。它将另一个效果控制器作为子控制器，并多次重复它，在每个下一个周期开始前重置。

```dart
final ec = RepeatedEffectController(LinearEffectController(1), 10);
```

子效果控制器不能是无限的。如果子控制器是随机的，那么它将在每次迭代时用新的随机值重新初始化。


### `InfiniteEffectController`

与 `RepeatedEffectController` 类似，但它会无限期地重复其子控制器。

```dart
final ec = InfiniteEffectController(LinearEffectController(1));
```


### `SequenceEffectController`

按顺序一个接一个地执行一系列效果控制器。控制器列表不能为空。

```dart
final ec = SequenceEffectController([
  LinearEffectController(1),
  PauseEffectController(0.2),
  ReverseLinearEffectController(1),
]);
```


### `SpeedEffectController`

改变其子效果控制器的持续时间，以便效果以预定义的速度进行。子 `EffectController` 的初始持续时间是不相关的。子控制器必须是 `DurationEffectController` 的子类。

`SpeedEffectController` 只能应用于速度概念已明确定义的效果。这样的效果必须实现 `MeasurableEffect` 接口。
例如，以下效果符合条件：[`MoveByEffect`](#movebyeffect)、[`MoveToEffect`](#movetoeffect)、[`MoveAlongPathEffect`](#movealongpatheffect)、[`RotateEffect.by`](#rotateeffectby)、[`RotateEffect.to`](#rotateeffectto)。

参数 `speed` 以单位每秒表示，其中“单位”的概念取决于目标效果。例如，对于移动效果，它们指的是旅行的距离；对于旋转效果，单位是弧度。

```dart
final ec1 = SpeedEffectController(LinearEffectController(0), speed: 1);
final ec2 = EffectController(speed: 1); // same as ec1
```


### `DelayedEffectController`

效果控制器在指定的 `delay` 之后执行其子控制器。在控制器执行“延迟”阶段时，效果将被视为“未开始”，即其 `.started` 属性将返回 `false`。

```dart
final ec = DelayedEffectController(LinearEffectController(1), delay: 5);
```


### `NoiseEffectController`

这个效果控制器表现出嘈杂的行为，即它在零点左右随机振荡。这种效果控制器可以用来实现各种震动效果。

```dart
final ec = NoiseEffectController(duration: 0.6, frequency: 10);
```


### `RandomEffectController`

此控制器包装了另一个控制器，使其持续时间变为随机。每次重置时，持续时间的实际值将被重新生成，这使得该控制器在重复上下文中特别有用，例如在 [](#repeatedeffectcontroller) 或 [](#infiniteeffectcontroller) 中。

```dart
final ec = RandomEffectController.uniform(
  LinearEffectController(0),  // duration here is irrelevant
  min: 0.5,
  max: 1.5,
);
```

用户有能力控制使用哪个 `Random` 源，以及控制生成的随机持续时间的确切分布。包括了两种分布——`.uniform` 和 `.exponential`，用户可以自己实现任何其他分布。


### `SineEffectController`

一个代表正弦函数单个周期的效果控制器。使用这个来创建看起来自然的谐波振荡。
两个由具有不同周期的 `SineEffectControllers` 控制的垂直移动效果，将创建一个[Lissajous curve](https://en.wikipedia.org/wiki/Lissajous_curve)。

```dart
final ec = SineEffectController(period: 1);
```


### `ZigzagEffectController`

简单的交替效果控制器。在一个 `period` 的过程中，此控制器将从 0 线性进展到 1，然后到 -1，再回到 0。当起始位置应该是振荡的中心，而不是极端值时（如标准交替 `EffectController` 提供的），使用这种振荡效果。

```dart
final ec = ZigzagEffectController(period: 2);
```


## 其他的

- [Examples of various effects](https://examples.flame-engine.org/).


[tau]: https://en.wikipedia.org/wiki/Tau_(mathematical_constant)
[Lissajous curve]: https://en.wikipedia.org/wiki/Lissajous_curve
