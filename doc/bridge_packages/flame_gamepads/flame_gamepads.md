# flame_gamepads

**flame_gamepads** provides helping bridge functionality to use the `gamepads` package in your flame
game.


## GamepadEvents mixin

Add `GamepadCallbacks` mixin to your component with the `with` keyword and override the
`onGamepadEvent` method to receive callbacks when a gamepad event occurs.

```dart
class PlayerComponent extends PositionComponent with GamepadCallbacks {
  @override
  void onGamepadEvent(NormalizedGamepadEvent event) {
    if (event.button == GamepadButton.a && event.value != 0) {
        // 'a' button pressed.
    }
  }
}
```

An example of how to use the API can be found
[here](https://github.com/flame-engine/flame/tree/main/packages/flame_gamepads/example).

See the lib [gamepads](https://github.com/flame-engine/gamepads.dart) for more info on how to
process the NormalizedGamepadEvent data.
