# Touch Controls


## Keyboard WASD / Arrows

Please reference the [Keyboard example](https://examples.flame-engine.org/) for a complete example.


## Joystick

Please reference the [Joystick documents](../../doc/flame/inputs/other_inputs.md#joystick) for a
complete example.


## Touch Controls within the HUD

```{flutter-app}
:sources: ../flame/examples
:page: snippet_hud_controls
:show: widget code infobox
:width: 180
:height: 160
```

```dart
// A simple button that sets a direction for x direction.
final leftButton = HudButtonComponent(
  button: RectangleComponent.square(size: 30),
  margin: const EdgeInsets.only(bottom: offset, left: offset),
  onPressed: () {
    _xAxisInput = -1;
  },
  onReleased: () {
    _xAxisInput = 0;
  },
);
add(leftButton);

```
