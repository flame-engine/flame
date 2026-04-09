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
`PositionComponent`, so most of the time you don't need to do anything here). This method allows
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


### Hover Demo

Play with the demo below to see the pointer hover events in action.

```{flutter-app}
:sources: ../flame/examples
:page: pointer_events
:show: widget code
```


## ScrollCallbacks

If you want to handle mouse-wheel or trackpad scroll events at the component level, use the
`ScrollCallbacks` mixin.

```dart
class ScrollableSquare extends RectangleComponent with ScrollCallbacks {
  @override
  void onScroll(ScrollEvent event) {
    final factor = switch (event.scrollDelta.y.sign) {
      1 => 0.9,
      -1 => 1.1,
      _ => 1.0, // ignore horizontal-only scrolls
    };
    scale.scale(factor);
    scale.clampScalar(0.3, 5.0);
    event.continuePropagation = false;
  }
}
```

The mixin adds one overridable method:

- `onScroll`: called when a scroll event hits the component.

The `ScrollEvent` provides:

- `scrollDelta`: a `Vector2` with the scroll offset (typically you only need `scrollDelta.y`).
- `canvasPosition` / `localPosition`: the pointer position in canvas and local coordinates.
- `continuePropagation`: set to `false` to prevent the event from reaching components further
  down the hit-test list (or the game itself).

Scroll events are delivered to **all** components under the pointer (not just the topmost one),
so set `continuePropagation = false` if only one component should handle the event.

You can also mix `ScrollCallbacks` directly into your `FlameGame` to handle scrolls at the
game level.


### Scroll Demo

```{flutter-app}
:sources: ../flame/examples
:page: scroll
:show: widget code
```
