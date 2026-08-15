# Gesture Input

This is documentation for the legacy detector mixins, which are added directly to your game class.
New code should prefer the `Callbacks` mixins instead (e.g. [TapCallbacks](tap_events.md) and
[DragCallbacks](drag_events.md)) which can be added to any `Component`, including the `FlameGame`
itself.

For other input documents, see also:

- [Keyboard Input](keyboard_input.md): for keystrokes
- [Other Inputs](other_inputs.md): For joysticks, game pads, etc.


## Intro

Inside `package:flame/input.dart` you can find a set of legacy `mixin`s which can be included on
your game class instance to be able to receive touch input events. Below you can see the full
list of these `mixin`s and its methods:


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
```

Mouse only events

```text
 - MouseMovementDetector
  - onMouseMove
 - ScrollDetector
  - onScroll
```


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
class MyGame extends FlameGame with PanDetector {
  // Other methods omitted

  @override
  void onPanStart(DragStartInfo info) {
    print('Player started panning on ${info.eventPosition.widget}');
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    print('Player panned to ${info.eventPosition.widget}');
  }
}
```


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
