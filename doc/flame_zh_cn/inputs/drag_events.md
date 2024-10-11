# Drag Events

**拖动事件**发生在用户在设备屏幕上移动手指，或在按住鼠标按钮时移动鼠标。

如果用户使用多个手指，则可以同时发生多个拖动事件。在这种情况下，Flame 将正确处理这些事件，你甚至可以通过使用它们的 `pointerId` 属性来跟踪事件。

对于那些希望响应拖动的组件，请添加 `DragCallbacks` 混入。”


- “这个混入为你的组件添加了四个可重写的方法：`onDragStart`、`onDragUpdate`、`onDragEnd` 和 `onDragCancel`。默认情况下，这些方法不执行任何操作——你需要重写它们才能实现任何功能。”
- 此外，该组件必须实现 `containsLocalPoint()` 方法（已经在 `PositionComponent` 中实现，因此大多数情况下你不需要在这里做任何事情）——这个方法允许 Flame 知道事件是否发生在组件内部。

```dart
class MyComponent extends PositionComponent with DragCallbacks {
  MyComponent() : super(size: Vector2(180, 120));

   @override
   void onDragStart(DragStartEvent event) {
     // Do something in response to a drag event
   }
}
```


## Demo

“在这个示例中，你可以使用拖动手势将星形图形拖动到屏幕上，或者在洋红色矩形内绘制曲线。”

```{flutter-app}
:sources: ../flame/examples
:page: drag_events
:show: widget code
```


## Drag anatomy


### onDragStart

这是拖动序列中发生的第一个事件。通常，此事件将被发送到接触点上带有 `DragCallbacks` 混入的最上层组件。然而，通过将标志 `event.continuePropagation` 设置为 true，你可以允许事件传播到下面的组件。

与此事件关联的 `DragStartEvent` 对象将包含事件起始点的坐标。这个点在多个坐标系统中可用：`devicePosition` 是在整个设备的坐标系统中给出的，`canvasPosition` 是在游戏小部件的坐标系统中，而 `localPosition` 提供了组件的局部坐标系统中的位置。

任何接收到 `onDragStart` 的组件将随后接收到 `onDragUpdate` 和 `onDragEnd` 事件。


### onDragUpdate

此事件在用户拖动手指穿过屏幕时持续触发。如果用户保持手指静止，则不会触发此事件。

默认实现将此事件发送给所有接收到之前 `onDragStart` 的组件，并且使用相同的指针 ID。如果触摸点仍在组件内，则 `event.localPosition` 将提供该点在局部坐标系统中的位置。然而，如果用户将手指移开组件，`event.localPosition` 属性将返回一个坐标为 NaN 的点。同样，此情况下的 `event.renderingTrace` 将为空。然而，事件的 `canvasPosition` 和 `devicePosition` 属性将是有效的。

此外，`DragUpdateEvent` 将包含 `delta` —— 自上一个 `onDragUpdate` 以来，或者如果这是拖动开始后的第一次拖动更新，则为 `onDragStart` 以来，手指移动的距离。

`event.timestamp` 属性测量自拖动开始以来经过的时间。例如，它可以用来计算移动的速度。


### onDragEnd

当用户抬起手指并因此停止拖动手势时，将触发此事件。此事件没有与之相关联的位置。


### onDragCancel

此事件发生时的确切语义尚不清楚，因此我们提供了一个默认实现，简单地将此事件转换为 `onDragEnd`。​⬤


## Mixins


### DragCallbacks

`DragCallbacks` 混入可以添加到任何 `Component`，使该组件开始接收拖动事件。

此混入为组件添加了 `onDragStart`、`onDragUpdate`、`onDragEnd` 和 `onDragCancel` 方法，默认情况下这些方法不执行任何操作，但可以被重写以实现实际功能。

另一个重要的细节是，组件只会接收到源自 *该组件内部* 的拖动事件，这由 `containsLocalPoint()` 函数判断。常用的 `PositionComponent` 类提供了基于其 `size` 属性的实现。因此，如果你的组件派生自 `PositionComponent`，请确保正确设置其大小。然而，如果你的组件派生自基本的 `Component`，则必须手动实现 `containsLocalPoint()` 方法。

如果你的组件是较大层次结构的一部分，则只有在其祖先都正确实现 `containsLocalPoint` 的情况下，它才会接收拖动事件。

```dart
class MyComponent extends PositionComponent with DragCallbacks {
  MyComponent({super.size});

  final _paint = Paint();
  bool _isDragged = false;

  @override
  void onDragStart(DragStartEvent event) => _isDragged = true;

  @override
  void onDragUpdate(DragUpdateEvent event) => position += event.delta;

  @override
  void onDragEnd(DragEndEvent event) => _isDragged = false;

  @override
  void render(Canvas canvas) {
    _paint.color = _isDragged? Colors.red : Colors.white;
    canvas.drawRect(size.toRect(), _paint);
  }
}
```
