# Inputs

Games are interactive by nature, so handling player input is essential. Flame provides input
handling that works on all platforms Flutter supports: touch on mobile, mouse and keyboard on
desktop, and pointer events on the web. These APIs are designed as mixins that you add to your
components, so each component can independently decide which input events it cares about. This is
similar to how
Flutter's [GestureDetector](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html)
works, but adapted for Flame's component tree.

Since `FlameGame` is itself a `Component`, adding one of these mixins to your game class works
exactly as well as adding it to a component; no wrapper component required.

- [Tap Events](tap_events.md): `TapCallbacks`, `SecondaryTapCallbacks`, `TertiaryTapCallbacks`,
  `DoubleTapCallbacks`
- [Drag Events](drag_events.md): `DragCallbacks`
- [Scale Events](scale_events.md): `ScaleCallbacks`
- [Long Press Events](long_press_events.md): `LongPressCallbacks`
- [Pointer Events](pointer_events.md): `MouseMoveCallbacks`, `HoverCallbacks`, `ScrollCallbacks`
- [Keyboard Input](keyboard_input.md): for keystrokes
- [Hardware Keyboard Detector](hardware_keyboard_detector.md)
- [Other Inputs and Helpers](other_inputs.md): for joysticks, game pads, etc.

Under the hood, these are all built on Flutter's own gesture widgets, including the
[GestureDetector widget](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html),
[RawGestureDetector widget](https://api.flutter.dev/flutter/widgets/RawGestureDetector-class.html)
and [MouseRegion widget](https://api.flutter.dev/flutter/widgets/MouseRegion-class.html); you can
also read more about
[Flutter's gesture system](https://api.flutter.dev/flutter/gestures/gestures-library.html).


## Event coordinate system

Every event that carries a position reports it in three coordinate systems:

- `devicePosition`: relative to the entire screen, the same as `globalPosition` in Flutter's native
  events.
- `canvasPosition`: relative to the `GameWidget` position and size, the same as `localPosition` in
  Flutter's native events. This is Flame's "global" position.
- `localPosition`: relative to the component currently receiving the event, with the whole chain of
  parent transforms (camera included) already applied.

Events that represent a movement, such as `DragUpdateEvent`, additionally expose start and end
positions (`canvasStartPosition` / `canvasEndPosition`, and so on) plus the corresponding deltas:
`deviceDelta`, `canvasDelta` and `localDelta`.

`localPosition` and `localDelta` are relative to whichever component is currently receiving the
event, so only read them inside the callback. Do not hold on to the event and read them afterwards:
once delivery is over they are no longer maintained, and depending on the event you will either get
a leftover value or an error. If you need the position later, copy it during the callback with
`event.localPosition.clone()`.

When you mix a callback into your `FlameGame` directly, the game is that component; and since it has
no transform of its own, the local values there are equivalent to the canvas coordinates.


## GestureHitboxes

Every mixin whose events carry a position implements `PointerInputCallbacks` (taps, drags, scales,
long presses and pointer events - but not the keyboard ones) and they all decide whether an event
belongs to a component by asking its `containsLocalPoint()`, which for a `PositionComponent` is its
rectangular bounds.

The `GestureHitboxes` mixin is used to recognize input on top of your `Component`s more accurately.
Say that you have a round rock as a `SpriteComponent` for example, then you don't want to register
input that is in the corner of the image where the rock is not displayed; you can use the
`GestureHitboxes` mixin to define a more accurate boundary (circle, polygon, any shape) for the
event to check when propagating to your component.

You can add new hitboxes to the component that has the `GestureHitboxes` mixin just like they are
added in the `Collidable` example.

More information about how to define hitboxes can be found in the hitbox section of the
[collision detection](../collision_detection.md#shapehitbox) docs.

An example of how to use it can be seen in the
[gesture hitboxes example](https://github.com/flame-engine/flame/blob/main/examples/lib/stories/input/gesture_hitboxes_example.dart).

```{toctree}
:hidden:

Tap Events                <tap_events.md>
Drag Events               <drag_events.md>
Scale Events              <scale_events.md>
Long Press Events         <long_press_events.md>
Pointer Events            <pointer_events.md>
Keyboard Input            <keyboard_input.md>
HardwareKeyboardDetector  <hardware_keyboard_detector.md>
Other Inputs              <other_inputs.md>
```
