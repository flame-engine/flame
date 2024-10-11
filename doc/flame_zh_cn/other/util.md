# Util

在此页面中，你可以找到一些实用类和方法的文档。


## Device Class

该类可以通过 `Flame.device` 访问，并提供了一些用于控制设备状态的方法，例如，可以更改屏幕方向以及设置应用是否全屏显示。


### `Flame.device.fullScreen()`

调用此方法时，将禁用所有 `SystemUiOverlay`，使应用全屏显示。当在主方法中调用时，它会使你的应用全屏（没有顶部或底部的工具栏）。

**注意：** 在 Web 上调用此方法没有效果。


### `Flame.device.setLandscape()`

此方法将整个应用（实际上也包括游戏）的方向设置为横屏，并根据操作系统和设备设置，应该允许左右横屏方向。如果要将应用方向设置为特定方向的横屏，请使用 `Flame.device.setLandscapeLeftOnly` 或 `Flame.device.setLandscapeRightOnly`。

**注意：** 在 Web 上调用此方法没有效果。


### `Flame.device.setPortrait()`

此方法将整个应用（实际上也包括游戏）的方向设置为竖屏，并根据操作系统和设备设置，应该允许上下竖屏方向。

如果要将应用方向设置为特定方向的竖屏，请使用 `Flame.device.setPortraitUpOnly` 或 `Flame.device.setPortraitDownOnly`。

**注意：** 在 Web 上调用此方法没有效果。


### `Flame.device.setOrientation()` and `Flame.device.setOrientations()`

如果需要更细致地控制允许的方向（而不必直接处理 `SystemChrome`），可以使用 `setOrientation`（接受一个 `DeviceOrientation` 作为参数）和 `setOrientations`（接受一个 `List<DeviceOrientation>` 作为可能的方向）。

**注意：** 在 Web 上调用此方法没有效果。


## Timer

Flame 提供了一个简单的实用类，帮助你处理倒计时和计时器状态变化，例如事件。

倒计时示例：

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class MyGame extends Game {
  final TextPaint textPaint = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 20),
  );

  final countdown = Timer(2);

  @override
  void update(double dt) {
    countdown.update(dt);
    if (countdown.finished) {
      // Prefer the timer callback, but this is better in some cases
    }
  }

  @override
  void render(Canvas canvas) {
    textPaint.render(
      canvas,
      "Countdown: ${countdown.current.toString()}",
      Vector2(10, 100),
    );
  }
}

```

间隔示例：

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class MyGame extends Game {
  final TextPaint textPaint = TextPaint(
    style: const TextStyle(color: Colors.white, fontSize: 20),
  );
  Timer interval;

  int elapsedSecs = 0;

  MyGame() {
    interval = Timer(
      1,
      onTick: () => elapsedSecs += 1,
      repeat: true,
    );
  }

  @override
  void update(double dt) {
    interval.update(dt);
  }

  @override
  void render(Canvas canvas) {
    textPaint.render(canvas, "Elapsed time: $elapsedSecs", Vector2(10, 150));
  }
}

```

`Timer` 实例也可以通过使用 `TimerComponent` 类在 `FlameGame` 中使用。

`TimerComponent` 示例：

```dart
import 'package:flame/timer.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class MyFlameGame extends FlameGame {
  MyFlameGame() {
    add(
      TimerComponent(
        period: 10,
        repeat: true,
        onTick: () => print('10 seconds elapsed'),
      )
    );
  }
}
```


## Time Scale

在许多游戏中，基于某些游戏事件创建慢动作或快进效果通常是很有必要的。实现这些效果的一个非常常见的方法是操控游戏内的时间或滴答率（tick rate）。

为了简化这种操控，Flame 提供了一个 `HasTimeScale` 混入（mixin）。该混入可以附加到任何 Flame `Component`，并暴露一个简单的 `timeScale` 的获取/设置 API。

`timeScale` 的默认值为 `1`，这意味着组件的游戏时间与现实生活中的时间以相同速度运行。

将其设置为 `2` 将使组件的时间快两倍，而设置为 `0.5` 则使其以现实生活时间的一半速度运行。该混入还提供 `pause` 和 `resume` 方法，可以用来替代手动将 `timeScale` 设置为 `0` 和 `1`。

由于 `FlameGame` 也是一个 `Component`，因此该混入也可以附加到 `FlameGame` 上。这样做将允许从一个地方控制游戏中所有组件的时间缩放。

```{note}
`HasTimeScale` 无法单独控制来自 `flame_forge2d` 的 `BodyComponent` 的移动。只有在整个游戏或 `Forge2DWorld` 需要进行时间缩放时，它才会有用。
```

```{flutter-app}
:sources: ../flame/examples
:page: time_scale
:show: widget code infobox
:width: 180
:height: 160
```

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';

class MyFlameGame extends FlameGame with HasTimeScale {
  void speedUp(){
    timeScale = 2.0;
  }

  void slowDown(){
    timeScale = 1.0;
  }
}
```


## Extensions

Flame 包含了一组实用的扩展，这些扩展旨在帮助开发者提供快捷方式和转换方法，以下是这些扩展的总结。

它们都可以从 `package:flame/extensions.dart` 导入。


### Canvas

方法：

- `scaleVector`：与 `canvas scale` 方法类似，但接受 `Vector2` 作为参数。
- `translateVector`：与 `canvas translate` 方法类似，但接受 `Vector2` 作为参数。
- `renderPoint`：在画布上渲染一个点（主要用于调试）。
- `renderAt` 和 `renderRotated`：如果你直接渲染到 `Canvas`，可以使用这些函数轻松操作坐标，以便在正确的位置渲染内容。它们会更改 `Canvas` 的变换矩阵，但在之后会重置。


### Color

方法：

- `darken`：将颜色的阴影变暗，范围在 0 到 1 之间。
- `brighten`：将颜色的阴影变亮，范围在 0 到 1 之间。

工厂：

- `ColorExtension.fromRGBHexString`：从有效的十六进制字符串解析 RGB 颜色（例如 #1C1C1C）。
- `ColorExtension.fromARGBHexString`：从有效的十六进制字符串解析 ARGB 颜色（例如 #FF1C1C1C）。


### Image

方法：

- `pixelsInUint8`：以 `Uint8List` 的形式检索图像的像素数据，格式为 `ImageByteFormat.rawRgba`。
- `getBoundingRect`：获取 `Image` 的边界矩形，返回 `Rect`。
- `size`：返回 `Image` 的大小，类型为 `Vector2`。
- `darken`：将图像的每个像素变暗，范围在 0 到 1 之间。
- `brighten`：将图像的每个像素变亮，范围在 0 到 1 之间。

### Offset

方法：

- `toVector2`：从 `Offset` 创建一个 `Vector2`。
- `toSize`：从 `Offset` 创建一个 `Size`。
- `toPoint`：从 `Offset` 创建一个 `Point`。
- `toRect`：创建一个以 (0,0) 为起点的 `Rect`，其右下角为给定的 `Offset`。


### Rect

方法：

- `toOffset`：从 `Rect` 创建一个 `Offset`。
- `toVector2`：创建一个从 (0,0) 开始并延伸到 `Rect` 大小的 `Vector2`。
- `containsPoint`：判断该 `Rect` 是否包含一个 `Vector2` 点。
- `intersectsSegment`：判断由两个 `Vector2` 形成的线段是否与该 `Rect` 相交。
- `intersectsLineSegment`：判断 `LineSegment` 是否与该 `Rect` 相交。
- `toVertices`：将 `Rect` 的四个角转化为 `Vector2` 列表。
- `toFlameRectangle`：将该 `Rect` 转换为 Flame 的 `Rectangle`。
- `toMathRectangle`：将该 `Rect` 转换为 `math.Rectangle`。
- `toGeometryRectangle`：将该 `Rect` 转换为来自 flame-geom 的 `Rectangle`。
- `transform`：使用 `Matrix4` 转换 `Rect`。

Factories:

- `RectExtension.getBounds`：构造一个 `Rect`，表示一组 `Vector2` 的边界。
- `RectExtension.fromCenter`：从中心点（使用 `Vector2`）构造一个 `Rect`。


### math.Rectangle

Methods:

- `toRect`：将此数学 `Rectangle` 转换为 UI `Rect`。


### Size

Methods:

- `toVector2`：从 `Size` 创建一个 `Vector2`。
- `toOffset`：从 `Size` 创建一个 `Offset`。
- `toPoint`：从 `Size` 创建一个 `Point`。
- `toRect`：创建一个以 (0,0) 为起点，大小为 `Size` 的 `Rect`。


### Vector2

该类来自 `vector_math` 包，我们在该包提供的基础上添加了一些有用的扩展方法。

Methods:

- `toOffset`：从 `Vector2` 创建一个 `Offset`。
- `toPoint`：从 `Vector2` 创建一个 `Point`。
- `toRect`：创建一个以 (0,0) 为起点，大小为 `Vector2` 的 `Rect`。
- `toPositionedRect`：创建一个以 `Vector2` 中的 [x, y] 为起点，大小为 `Vector2` 参数的 `Rect`。
- `lerp`：将 `Vector2` 线性插值到另一个 `Vector2`。
- `rotate`：按弧度指定的角度旋转 `Vector2`，可选择围绕定义的 `Vector2` 旋转，否则围绕中心旋转。
- `scaleTo`：将 `Vector2` 的长度更改为提供的长度，而不改变方向。
- `moveToTarget`：以给定距离平滑移动 `Vector2` 朝目标方向。

Factories:

- `Vector2Extension.fromInts`：使用整数作为输入创建一个 `Vector2`。

Operators:

- `&`：将两个 `Vector2` 组合成一个 `Rect`，左侧为原点，右侧为大小。
- `%`：对两个 `Vector2` 的 x 和 y 分别进行取模/余数运算。


### Matrix4

该类来自 `vector_math` 包。我们在 `vector_math` 提供的基础上创建了一些扩展方法。

方法：

- `translate2`：通过给定的 `Vector2` 平移 `Matrix4`。
- `transform2`：通过使用 `Matrix4` 变换给定的 `Vector2` 创建一个新的 `Vector2`。
- `transformed2`：将输入的 `Vector2` 转换为输出的 `Vector2`。

获取器：

- `m11`：第一行第一列。
- `m12`：第一行第二列。
- `m13`：第一行第三列。
- `m14`：第一行第四列。
- `m21`：第二行第一列。
- `m22`：第二行第二列。
- `m23`：第二行第三列。
- `m24`：第二行第四列。
- `m31`：第三行第一列。
- `m32`：第三行第二列。
- `m33`：第三行第三列。
- `m34`：第三行第四列。
- `m41`：第四行第一列。
- `m42`：第四行第二列。
- `m43`：第四行第三列。
- `m44`：第四行第四列。

工厂：

- `Matrix4Extension.scale`：创建一个缩放的 `Matrix4`。可以通过将 `Vector4` 或 `Vector2` 作为第一个参数传递，或者通过传递 x、y、z 的 `double` 值来实现。
