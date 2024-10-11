# Pointer Events

```{note}
本文档描述了新的事件API。旧的（遗留）方法仍然得到支持，详见 [](gesture_input.md).
```

**指针事件** 是 Flutter 中通用的“鼠标移动”类型事件（适用于桌面或网络）。

如果你想在组件或游戏中与鼠标移动事件交互，可以使用 `PointerMoveCallbacks` 混入。

🌰:

```dart
class MyComponent extends PositionComponent with PointerMoveCallbacks {
  MyComponent() : super(size: Vector2(80, 60));

  @override
  void onPointerMove(PointerMoveEvent event) {
    // Do something in response to the mouse move (e.g. update coordinates)
  }
}
```

这个混入为你的组件添加了两个可覆盖的方法：

- `onPointerMove`：当鼠标在组件内移动时调用
- `onPointerMoveStop`：如果组件正在被悬停，并且鼠标离开时，会调用一次

默认情况下，这些方法什么也不做，需要被覆盖以便执行任何功能。

此外，组件必须实现 `containsLocalPoint()` 方法（在 `PositionComponent` 中已经实现，所以大多数情况下你不需要在这里做任何事情）——这个方法让 Flame 知道事件是否发生在组件内。

请注意，只有在你的组件内发生的鼠标事件才会被代理。然而，`onPointerMoveStop` 会在第一次鼠标移动离开你的组件时触发一次，所以你可以在其中处理任何退出条件。


## HoverCallbacks

如果你想特别知道组件是否正在被悬停，或者如果你想挂钩悬停进入和退出事件，你可以使用一个更专门的混入，叫做 `HoverCallbacks`。

例如：

```dart
class MyComponent extends PositionComponent with HoverCallbacks {

  MyComponent() : super(size: Vector2(80, 60));

  @override
  void update(double dt) {
    // use `isHovered` to know if the component is being hovered
  }

  @override
  void onHoverEnter() {
    // Do something in response to the mouse entering the component
  }

  @override
  void onHoverExit() {
    // Do something in response to the mouse leaving the component
  }
}
```

请注意，你仍然可以监听“原始”的 `onPointerMove` 方法以获得额外的功能，只是确保调用 `super` 版本以启用 `HoverCallbacks` 行为。


### Demo

尝试下面的演示，查看指针悬停事件的实际效果。

```{flutter-app}
:sources: ../flame/examples
:page: pointer_events
:show: widget code
```
