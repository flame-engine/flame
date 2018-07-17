# Gamepad

## Gamepad is only support on Android at the moment.

To listen to gamepad events use the 'Flame.gamepad' instance, to add a listener use following snippet.

```dart
  Flame.gamepad.addListener((String evtType, String key) {
    print(key)
    if (evtType == GAMEPAD_BUTTON_UP) {
      print('is up')
    } else {
      print('is down')
    }
  });
```

To check for specific keys use the following constants avaiable on the package: `flame/game.dart`

```
GAMEPAD_BUTTON_UP
GAMEPAD_BUTTON_DOWN

GAMEPAD_DPAD_UP
GAMEPAD_DPAD_DOWN
GAMEPAD_DPAD_LEFT
GAMEPAD_DPAD_RIGHT

GAMEPAD_BUTTON_A
GAMEPAD_BUTTON_B
GAMEPAD_BUTTON_X
GAMEPAD_BUTTON_Y

GAMEPAD_BUTTON_L1
GAMEPAD_BUTTON_L2

GAMEPAD_BUTTON_R1
GAMEPAD_BUTTON_R2

GAMEPAD_BUTTON_START
GAMEPAD_BUTTON_SELECT
```

A functional example can be found [here](https://github.com/erickzanardo/flame-gamepad-example)
