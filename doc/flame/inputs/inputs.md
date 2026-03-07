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
- [Gesture Input](gesture_input.md)
- [Keyboard Input](keyboard_input.md)
- [Other Inputs and Helpers](other_inputs.md)
- [Pointer Events](pointer_events.md)
- [Hardware Keyboard Detector](hardware_keyboard_detector.md)

```{toctree}
:hidden:

Tap Events                <tap_events.md>
Drag Events               <drag_events.md>
Scale Events              <scale_events.md>
Gesture Input             <gesture_input.md>
Keyboard Input            <keyboard_input.md>
Other Inputs              <other_inputs.md>
Pointer Events            <pointer_events.md>
HardwareKeyboardDetector  <hardware_keyboard_detector.md>
```
