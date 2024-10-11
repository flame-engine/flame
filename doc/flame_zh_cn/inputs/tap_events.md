# Tap Events

```{note}
此文档描述了新的事件API。旧的（遗留）方法，仍然得到支持，详见 [](gesture_input.md)。
```

**轻触事件** 是与 Flame 游戏互动的最基本方法之一。当用户用手指触摸屏幕、用鼠标点击或用触控笔轻敲时，就会发生轻触事件。轻触可以是“长按”，但在手势过程中手指不应移动。因此，触摸屏幕、移动手指然后释放——这不是轻触而是拖动。同样，当鼠标移动时点击鼠标按钮也会被注册为拖动。

可以同时发生多个轻触事件，特别是如果用户有多个手指。Flame 会正确处理此类情况，你甚至可以使用它们的 `pointerId` 属性来跟踪事件。

对于你想要响应轻触的组件，添加 `TapCallbacks` 混入。

- 这个混入为你的组件添加了四个可覆盖的方法：`onTapDown`、`onTapUp`、`onTapCancel` 和 `onLongTapDown`。默认情况下，这些方法什么也不做，需要被覆盖以便执行任何功能。

- 此外，组件必须实现 `containsLocalPoint()` 方法（在 `PositionComponent` 中已经实现，所以大多数情况下你不需要在这里做任何事情）——这个方法让 Flame 知道事件是否发生在组件内。

```dart
class MyComponent extends PositionComponent with TapCallbacks {
  MyComponent() : super(size: Vector2(80, 60));

  @override
  void onTapUp(TapUpEvent event) {
    // Do something in response to a tap event
  }
}
```


## Tap anatomy


### onTapDown

每一次轻触都以一个“轻触按下”事件开始，你可以通过 `void onTapDown(TapDownEvent)` 处理器接收到这个事件。事件会传递给位于触摸点的第一个拥有 `TapCallbacks` 混入的组件。通常，事件随后会停止传播。然而，你可以通过设置 `event.continuePropagation` 为 true 来强制事件也被传递给下面的组件。

传递给事件处理器的 `TapDownEvent` 对象包含了关于事件的可用信息。例如，`event.localPosition` 将包含事件在当前组件的局部坐标系中的坐标，而 `event.canvasPosition` 是在整个游戏画布的坐标系中。

每一个接收到 `onTapDown` 事件的组件最终都会接收到带有相同 `pointerId` 的 `onTapUp` 或 `onTapCancel` 事件。


### onLongTapDown

如果用户按住手指一段时间（由 `MultiTapDispatcher` 中的 `.longTapDelay` 属性配置），就会触发“长按”事件。这个事件会调用之前接收到 `onTapDown` 事件的组件上的 `void onLongTapDown(TapDownEvent)` 处理器。

默认情况下，`.longTapDelay` 设置为 300 毫秒，这可能与系统默认值不同。你可以通过设置 `TapConfig.longTapDelay` 值来改变这个值。对于特定的辅助功能需求，这也可能很有用。


### onTapUp

这个事件表示轻触序列成功完成。它保证只被传递给那些之前接收到相同指针 ID 的 `onTapDown` 事件的组件。

传递给事件处理器的 `TapUpEvent` 对象包含了事件的信息，其中包括事件的坐标（即用户在抬起手指前触摸屏幕的位置），以及事件的 `pointerId`。

请注意，轻触结束事件的设备坐标将与相应的轻触开始事件的设备坐标相同（或非常接近）。然而，局部坐标则不一定。如果你正在轻触的组件正在移动（在游戏当中它们经常这样做），那么你会发现局部的轻触结束坐标与轻触开始坐标相当不同。

在极端情况下，当组件从触摸点移开时，`onTapUp` 事件将根本不会被生成：它将被 `onTapCancel` 替换。不过，请注意，在这种情况下，`onTapCancel` 将在用户抬起或移动他们的手指的那一刻生成，而不是在组件从触摸点移开的那一刻生成。


### onTapCancel

当轻触未能实现时，会发生这个事件。最常见的情况是用户移动了他们的手指，这将手势从“轻触”转变为“拖动”。

较少见的情况是，正在被轻触的组件从用户的手指下移开。更罕见的情况是，当另一个小部件覆盖在游戏小部件上，或者设备关闭，或类似的情况时，会发生 `onTapCancel`。

`TapCancelEvent` 对象只包含当前被取消的前一个 `TapDownEvent` 的 `pointerId`。与轻触取消相关的没有位置信息。


### Demo

尝试下面的演示，查看轻触事件的实际效果。

中间的蓝色矩形是拥有 `TapCallbacks` 混入的组件。

轻触这个组件会在触摸点创建圆形。

具体来说，`onTapDown` 事件开始绘制圆形。圆形的厚度将与轻触的持续时间成比例：在 `onTapUp` 之后，圆形的描边宽度将不再增加。在 `onLongTapDown` 触发的时刻，会有一条细白条纹。

最后，如果你通过移动手指引发 `onTapCancel` 事件，圆形将会内爆并消失。

```{flutter-app}
:sources: ../flame/examples
:page: tap_events
:show: widget code
```


## Mixins

这一节更详细地描述了几个用于处理轻触事件所需的混入。


### TapCallbacks

`TapCallbacks` 混入可以被添加到任何 `Component` 中，以便该组件开始接收轻触事件。

这个混入向组件添加了 `onTapDown`、`onLongTapDown`、`onTapUp` 和 `onTapCancel` 方法，这些方法默认不做任何事情，但可以被覆盖以实现任何实际功能。你也不需要覆盖所有这些方法：例如，如果你只想响应“真正的”轻触，你只需覆盖 `onTapUp`。

另一个关键细节是，一个组件只会接收发生在该组件 *内部* 的轻触事件，这是由 `containsLocalPoint()` 函数判断的。常用的 `PositionComponent` 类根据其 `size` 属性提供了这样的实现。因此，如果你的组件是从 `PositionComponent` 派生的，那么请确保你正确设置了其大小。然而，如果你的组件是从裸 `Component` 派生的，那么必须手动实现 `containsLocalPoint()` 方法。

如果你的组件是一个更大层级结构的一部分，那么它只会在其父组件正确实现了 `containsLocalPoint` 的情况下接收轻触事件。

```dart
class MyComponent extends Component with TapCallbacks {
  final _rect = const Rect.fromLTWH(0, 0, 100, 100);
  final _paint = Paint();
  bool _isPressed = false;

  @override
  bool containsLocalPoint(Vector2 point) => _rect.contains(point.toOffset());

  @override
  void onTapDown(TapDownEvent event) => _isPressed = true;

  @override
  void onTapUp(TapUpEvent event) => _isPressed = false;

  @override
  void onTapCancel(TapCancelEvent event) => _isPressed = false;

  @override
  void render(Canvas canvas) {
    _paint.color = _isPressed? Colors.red : Colors.white;
    canvas.drawRect(_rect, _paint);
  }
}
```


### DoubleTapCallbacks

Flame 还提供了一个名为 `DoubleTapCallbacks` 的混入，用于从组件接收双击事件。要在组件中开始接收双击事件，请将 `DoubleTapCallbacks` 混入添加到你的 `PositionComponent` 中。

```dart
class MyComponent extends PositionComponent with DoubleTapCallbacks {
  @override
  void onDoubleTapUp(DoubleTapEvent event) {
    /// Do something
  }

  @override
  void onDoubleTapCancel(DoubleTapCancelEvent event) {
    /// Do something
  }

  @override
  void onDoubleTapDown(DoubleTapDownEvent event) {
    /// Do something
  }
```


## Migration

如果你有一个已经使用 `Tappable`/`Draggable` 混入的游戏，那么这一节将描述如何过渡到本文档中描述的新API。以下是你需要做的：

将所有使用这些混入的组件替换为 `TapCallbacks`/`DragCallbacks`。
需要对新API进行调整的方法有 `onTapDown`、`onTapUp`、`onTapCancel` 和 `onLongTapDown`：

- 像 `(int pointerId, TapDownDetails details)` 这样的参数对被单个事件对象 `TapDownEvent event` 替换。
- 不再有返回值，但如果你需要让组件将轻触传递给下面的组件，那么设置 `event.continuePropagation` 为 true。这只对 `onTapDown` 事件需要——所有其他事件将自动传递。
- 如果你的组件需要知道触摸点的坐标，请使用 `event.localPosition` 而不是手动计算。也提供了 `event.canvasPosition` 和 `event.devicePosition` 属性。
- 如果组件附加到自定义的祖先，则确保该祖先也有正确的大小或实现 `containsLocalPoint()`。
