# Gesture Input

这是直接附加在游戏类上的手势输入文档，但大多数情况下，你可能希望在组件上检测输入，例如，请参见以下内容： [TapCallbacks](tap_events.md)
和 [DragCallbacks](drag_events.md) .

有关其他输入文档，请参见：

- [Keyboard Input](keyboard_input.md): 用于按键输入的文档：
- [Other Inputs](other_inputs.md): 用于摇杆、游戏手柄等的文档：


## Intro

在 `package:flame/gestures.dart` 中，你可以找到一整套可以包含在你的游戏类实例中的 `mixin`，以便接收触摸输入事件。下面是这些 `mixin` 及其方法的完整列表：


## Touch and mouse detectors

```text
- TapDetector
  - onTap
  - onTapCancel
  - onTapDown
  - onLongTapDown
  - onTapUp

- SecondaryTapDetector
  - onSecondaryTapDown
  - onSecondaryTapUp
  - onSecondaryTapCancel

- TertiaryTapDetector
  - onTertiaryTapDown
  - onTertiaryTapUp
  - onTertiaryTapCancel

- DoubleTapDetector
  - onDoubleTap

- LongPressDetector
  - onLongPress
  - onLongPressStart
  - onLongPressMoveUpdate
  - onLongPressUp
  - onLongPressEnd

- VerticalDragDetector
  - onVerticalDragDown
  - onVerticalDragStart
  - onVerticalDragUpdate
  - onVerticalDragEnd
  - onVerticalDragCancel

- HorizontalDragDetector
  - onHorizontalDragDown
  - onHorizontalDragStart
  - onHorizontalDragUpdate
  - onHorizontalDragEnd
  - onHorizontalDragCancel

- ForcePressDetector
  - onForcePressStart
  - onForcePressPeak
  - onForcePressUpdate
  - onForcePressEnd

- PanDetector
  - onPanDown
  - onPanStart
  - onPanUpdate
  - onPanEnd
  - onPanCancel

- ScaleDetector
  - onScaleStart
  - onScaleUpdate
  - onScaleEnd

- MultiTouchTapDetector
  - onTap
  - onTapCancel
  - onTapDown
  - onTapUp

- MultiTouchDragDetector
  - onReceiveDrag
```

仅限鼠标事件。


```text
 - MouseMovementDetector
  - onMouseMove
 - ScrollDetector
  - onScroll
```


无法将高级检测器（`MultiTouch*`）与同类的基本检测器混合使用，因为高级检测器将 **始终赢得手势竞技场**，而基本检测器将永远不会被触发。
例如，你不能同时使用 `MultiTouchTapDetector` 和 `PanDetector`，因为后者将不会触发任何事件（这里还有一个断言）。

Flame的GestureApi由Flutter的Gesture Widgets提供，包括
[GestureDetector widget](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html),
[RawGestureDetector widget](https://api.flutter.dev/flutter/widgets/RawGestureDetector-class.html)
and [MouseRegion widget](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html), you can
also read more about Flutter's gestures
[here](https://api.flutter.dev/flutter/gestures/gestures-library.html).


## PanDetector and ScaleDetector

如果你同时添加了 `PanDetector` 和 `ScaleDetector`，Flutter 会提示一个相当难以理解的断言：

```{note}
Having both a pan gesture recognizer and a scale gesture recognizer is
redundant; scale is a superset of pan.

Just use the scale gesture recognizer.
```

这可能看起来有些奇怪，但 `onScaleUpdate` 不仅在需要改变缩放时被触发，还会在所有的平移/拖动事件中触发。
所以如果你需要同时使用这两种检测器，你将不得不在 `onScaleUpdate`（以及 `onScaleStart` 和 `onScaleEnd`）中处理它们的逻辑。

例如，如果你想在平移事件中移动相机，在缩放事件中进行缩放，你可以这样做：

```dart
  late double startZoom;

  @override
  void onScaleStart(_) {
    startZoom = camera.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateInfo info) {
    final currentScale = info.scale.global;
    if (!currentScale.isIdentity()) {
      camera.zoom = startZoom * currentScale.y;
    } else {
      camera.translateBy(-info.delta.global);
      camera.snap();
    }
  }
```

在上述示例中，平移事件通过 `info.delta` 处理，而缩放事件通过 `info.scale` 处理，尽管它们理论上都来自底层的缩放事件。

这也可以在
[zoom example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/camera_and_viewport/zoom_example.dart).


## Mouse cursor

也可以更改在 `GameWidget` 区域显示的当前鼠标光标。要实现这一点，可以在 `Game` 类中使用以下代码

```dart
mouseCursor.value = SystemMouseCursors.move;
```

要使用自定义光标初始化 `GameWidget`，可以使用 `mouseCursor` 属性

```dart
GameWidget(
  game: MouseCursorGame(),
  mouseCursor: SystemMouseCursors.move,
);
```


## Event coordinate system

在具有位置信息的事件上，比如 `Tap*` 或 `Drag`，你会注意到 `eventPosition` 属性包含两个字段：`global` 和 `widget`。下面你将找到关于它们的简要解释。


### global

事件发生时考虑整个屏幕的位置，与 Flutter 原生事件中的 `globalPosition` 相同。



### widget

事件发生时相对于 `GameWidget` 的位置和大小的位置，与 Flutter 原生事件中的 `localPosition` 相同。


## Example

```dart
class MyGame extends FlameGame with TapDetector {
  // Other methods omitted

  @override
  bool onTapDown(TapDownInfo info) {
    print("Player tap down on ${info.eventPosition.widget}");
    return true;
  }

  @override
  bool onTapUp(TapUpInfo info) {
    print("Player tap up on ${info.eventPosition.widget}");
    return true;
  }
}
```

你也可以查看更完整的例子。

[here](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/input/).


### GestureHitboxes

`GestureHitboxes` 混入用于更准确地识别位于你的 `Component`s 之上的手势。假设你有一个相当圆的石头作为 `SpriteComponent`，那么你就不想注册在图片角落的输入，因为石头并没有显示在那里，而 `PositionComponent` 默认是矩形的。然后你可以使用 `GestureHitboxes` 混入来定义一个更准确的圆形或多边形（或其他形状），输入应该在这个范围内，以便事件能在你的组件上注册。

你可以像下面 `Collidable` 示例中添加新的命中框一样，向具有 `GestureHitboxes` 混入的组件添加新的命中框。

更多关于如何定义命中框的信息可以在命中框部分找到。
[collision detection](../collision_detection.md#shapehitbox) docs.

如何使用的一些例子
[here](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/gesture_hitboxes_example.dart).
