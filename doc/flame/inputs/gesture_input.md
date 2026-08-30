# Gesture Input

Gesture input in Flame is handled by the `Callbacks` mixins. They can be added to any `Component`,
and since `FlameGame` is itself a `Component`, adding one to your game class works exactly as well —
no wrapper component required. Each family has its own page:

- [Tap Events](tap_events.md): `TapCallbacks`, `DoubleTapCallbacks`, and the secondary/tertiary
  button variants
- [Drag Events](drag_events.md): `DragCallbacks`
- [Scale Events](scale_events.md): `ScaleCallbacks`
- [Long Press Events](long_press_events.md): `LongPressCallbacks`
- [Pointer Events](pointer_events.md): `MouseMoveCallbacks`, `HoverCallbacks`, `ScrollCallbacks`

For other input documents, see also:

- [Keyboard Input](keyboard_input.md): for keystrokes
- [Other Inputs](other_inputs.md): For joysticks, game pads, etc.


## PanDetector

`PanDetector` is the last remaining detector mixin — the older style of input handling, added
directly to the game class instead of to a component. Everything else on that side has already been
replaced by the `Callbacks` mixins above.

```{warning}
`PanDetector` will be removed. Prefer [`DragCallbacks`](drag_events.md), which
can be added to your `FlameGame` directly and additionally reports a
`pointerId` so that simultaneous drags can be told apart.
```

```text
- PanDetector
  - onPanDown
  - onPanStart
  - onPanUpdate
  - onPanEnd
  - onPanCancel
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
