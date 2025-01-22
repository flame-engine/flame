# Pointer Events

```{note}
This document describes the new events API. The old (legacy) approach,
which is still supported, is described in [](gesture_input.md).
```

**Pointer events** are Flutter's generalized "mouse-movement"-type events (for desktop or web).

If you want to interact with mouse movement events within your component or game, you can use the
`PointerMoveCallbacks` mixin.

For example:

```dart
class MyComponent extends PositionComponent with PointerMoveCallbacks {
  MyComponent() : super(size: Vector2(80, 60));

  @override
  void onPointerMove(PointerMoveEvent event) {
    // Do something in response to the mouse move (e.g. update coordinates)
  }
}
```

The mixin adds two overridable methods to your component:

- `onPointerMove`: called when the mouse moves within the component
- `onPointerMoveStop`: called once if the component was being hovered and the mouse leaves

By default, each of these methods does nothing, they need to be overridden in order to perform any
function.

In addition, the component must implement the `containsLocalPoint()` method (already implemented in
`PositionComponent`, so most of the time you don't need to do anything here) -- this method allows
Flame to know whether the event occurred within the component or not.

Note that only mouse events happening within your component will be proxied along. However,
`onPointerMoveStop` will be fired once on the first mouse movement that leaves your component, so
you can handle any exit conditions there.


## HoverCallbacks

If you want to specifically know if your component is being hovered or not, or if you want to hook
into hover enter and exit events, you can use a more dedicated mixin called `HoverCallbacks`.

For example:

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

Note that you can still listen to the "raw" onPointerMove methods for additional functionality, just
make sure to call the `super` version to enable the `HoverCallbacks` behavior.


### Demo

Play with the demo below to see the pointer hover events in action.

```{flutter-app}
:sources: ../flame/examples
:page: pointer_events
:show: widget code
```
