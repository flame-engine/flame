# Inputs

Games are interactive by nature, so handling player input is essential. Flame provides input
handling that works on all platforms Flutter supports: touch on mobile, mouse and keyboard on
desktop, and
pointer events on the web. These APIs are designed as mixins that you add to your components, so
each component can independently decide which input events it cares about. This is similar to how
Flutter's [GestureDetector](https://api.flutter.dev/flutter/widgets/GestureDetector-class.html)
works, but adapted for Flame's component tree.

- [Tap Events](tap_events.md)
- [Drag Events](drag_events.md)
- [Scale Events](scale_events.md)
- [Long Press Events](long_press_events.md)
- [Gesture Input](gesture_input.md)
- [Keyboard Input](keyboard_input.md)
- [Other Inputs and Helpers](other_inputs.md)
- [Pointer Events](pointer_events.md)
- [Hardware Keyboard Detector](hardware_keyboard_detector.md)


## GestureHitboxes

Every mixin whose events carry a position implements `PointerInputCallbacks` — that is all of the
above except keyboard — and they all decide whether an event belongs to a component by asking its
`containsLocalPoint()`, which for a `PositionComponent` is its rectangular bounds. The
`GestureHitboxes` mixin is used to recognize input on top of your `Component`s more accurately than
that. Say that you have a fairly round rock as a `SpriteComponent` for example, then you don't want
to register input that is in the corner of the image where the rock is not displayed. Then you can
use the `GestureHitboxes` mixin to define a more accurate circle or polygon (or another shape) for
which the input should be within for the event to be registered on your component.

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
Gesture Input             <gesture_input.md>
Keyboard Input            <keyboard_input.md>
Other Inputs              <other_inputs.md>
Pointer Events            <pointer_events.md>
HardwareKeyboardDetector  <hardware_keyboard_detector.md>
```
