# Gesture Input

This is documentation for gesture inputs attached directly on the game class, most of the time you
want to detect input on your components instead, see for example the [TapCallbacks](tap_events.md)
and [DragCallbacks](drag_events.md) for that.

For other input documents, see also:

- [Keyboard Input](keyboard_input.md): for keystrokes
- [Other Inputs](other_inputs.md): For joysticks, game pads, etc.


## Intro

Inside `package:flame/gestures.dart` you can find a whole set of `mixin`s which can be included on
your game class instance to be able to receive touch input events. Below you can see the full list
of these `mixin`s and its methods:


## Touch and mouse detectors

```{warning}
Detectors will be deprecated in the future. Prefer `Callbacks` instead.
```

```text
- PanDetector
  - onPanDown
  - onPanStart
  - onPanUpdate
  - onPanEnd
  - onPanCancel

- MultiTouchTapDetector
  - onTap
  - onTapCancel
  - onTapDown
  - onTapUp

- MultiTouchDragDetector
  - onReceiveDrag
```

Mouse only events

```text
 - MouseMovementDetector
  - onMouseMove
 - ScrollDetector
  - onScroll
```


It is not possible to mix advanced detectors (`MultiTouch*`) with basic detectors of the same
kind, since the advanced detectors will *always win the gesture arena* and the basic detectors will
never be triggered. So for example, you can't use both `MultiTouchTapDetector` and `PanDetector`
together, since no events will be triggered for the latter (there is also an assertion for this).

Flame's GestureApi is provided by Flutter's Gesture Widgets, including
[GestureDetector widget](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html),
[RawGestureDetector widget](https://api.flutter.dev/flutter/widgets/RawGestureDetector-class.html)
and [MouseRegion widget](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html), you can
also read more about
[Flutter's gesture system](https://api.flutter.dev/flutter/gestures/gestures-library.html).


## Panning and zooming

To handle panning and pinch-to-zoom at the same time, use the
[`DragCallbacks`](drag_events.md) and [`ScaleCallbacks`](scale_events.md) mixins together. Both are
driven by the same recognizer, so they can be combined freely: drag events are reported per pointer,
while scale events only start once two or more pointers are down.

```dart
class MyGame extends FlameGame with DragCallbacks, ScaleCallbacks {
  late double startZoom;

  void clampZoom() {
    camera.viewfinder.zoom = camera.viewfinder.zoom.clamp(0.05, 3.0);
  }

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    startZoom = camera.viewfinder.zoom;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    camera.viewfinder.zoom = startZoom * event.verticalScale;
    clampZoom();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Two-finger pinches emit both drag and scale; skip pan while zooming
    if (isScaling) {
      return;
    }
    final zoom = camera.viewfinder.zoom;
    camera.moveBy((event.localDelta..negate()) / zoom);
  }
}
```

This can also be seen in the
[zoom example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/camera_and_viewport/zoom_example.dart).


## Mouse cursor

It is also possible to change the current mouse cursor displayed on the `GameWidget` region. To do
so the following code can be used inside the `Game` class

```dart
mouseCursor.value = SystemMouseCursors.move;
```

To already initialize the `GameWidget` with a custom cursor, the `mouseCursor` property can be used

```dart
GameWidget(
  game: MouseCursorGame(),
  mouseCursor: SystemMouseCursors.move,
);
```


## Event coordinate system

On events that have positions, like for example `Tap*` or `Drag`, you will notice that the
`eventPosition` attribute includes 2 fields: `global` and `widget`. Below you will find a brief
explanation about each of them.


### global

The position where the event occurred considering the entire screen, same as
`globalPosition` in Flutter's native events.


### widget

The position where the event occurred relative to the `GameWidget` position and size, same as
`localPosition` in Flutter's native events.


## Example

```dart
class MyGame extends FlameGame with MultiTouchTapDetector {
  // Other methods omitted

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    print('Player tap down on ${info.eventPosition.widget}');
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    print('Player tap up on ${info.eventPosition.widget}');
  }
}
```

Note that there is no single-pointer tap detector at the game level; for that, use the component
level [`TapCallbacks`](tap_events.md) instead, which `FlameGame` can mix in directly since it is
itself a `Component`.

You can also check more complete examples in the
[input examples directory](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/input/).


### GestureHitboxes

The `GestureHitboxes` mixin is used to more accurately recognize gestures on top of your
`Component`s. Say that you have a fairly round rock as a `SpriteComponent` for example, then you
don't want to register input that is in the corner of the image where the rock is not displayed,
since a `PositionComponent` is rectangular by default. Then you can use the `GestureHitboxes` mixin
to define a more accurate circle or polygon (or another shape) for which the input should be within
for the event to be registered on your component.

You can add new hitboxes to the component that has the `GestureHitboxes` mixin just like they are
added in the below `Collidable` example.

More information about how to define hitboxes can be found in the hitbox section of the
[collision detection](../collision_detection.md#shapehitbox) docs.

An example of how to use it can be seen in the
[gesture hitboxes example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/gesture_hitboxes_example.dart).
