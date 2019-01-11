import 'package:flutter/services.dart';

typedef void KeyListener(RawKeyEvent event);
typedef void GamepadListener(String evtType, String key);

const GAMEPAD_BUTTON_UP = "UP";
const GAMEPAD_BUTTON_DOWN = "DOWN";

const GAMEPAD_DPAD_UP = "UP";
const GAMEPAD_DPAD_DOWN = "DOWN";
const GAMEPAD_DPAD_LEFT = "LEFT";
const GAMEPAD_DPAD_RIGHT = "RIGHT";

const GAMEPAD_BUTTON_A = "A";
const GAMEPAD_BUTTON_B = "B";
const GAMEPAD_BUTTON_X = "X";
const GAMEPAD_BUTTON_Y = "Y";

const GAMEPAD_BUTTON_L1 = "L1";
const GAMEPAD_BUTTON_L2 = "L2";

const GAMEPAD_BUTTON_R1 = "R1";
const GAMEPAD_BUTTON_R2 = "R2";

const GAMEPAD_BUTTON_START = "START";
const GAMEPAD_BUTTON_SELECT = "SELECT";

const ANDROID_MAPPING = {
  19: GAMEPAD_DPAD_UP,
  20: GAMEPAD_DPAD_DOWN,
  21: GAMEPAD_DPAD_LEFT,
  22: GAMEPAD_DPAD_RIGHT,
  96: GAMEPAD_BUTTON_A,
  97: GAMEPAD_BUTTON_B,
  99: GAMEPAD_BUTTON_X,
  100: GAMEPAD_BUTTON_Y,
  102: GAMEPAD_BUTTON_L1,
  103: GAMEPAD_BUTTON_R1,
  104: GAMEPAD_BUTTON_L2,
  105: GAMEPAD_BUTTON_R2,
  108: GAMEPAD_BUTTON_START,
  109: GAMEPAD_BUTTON_SELECT
};

/// Gamepad functionalities
///
/// To use this class, access it via [Flame.gamepad].
class Gamepad {
  KeyListener listener;

  void addListener(GamepadListener gamepadListener) {
    this.listener = (RawKeyEvent e) {
      String evtType =
          e is RawKeyDownEvent ? GAMEPAD_BUTTON_DOWN : GAMEPAD_BUTTON_UP;

      if (e.data is RawKeyEventDataAndroid) {
        RawKeyEventDataAndroid androidEvent = e.data as RawKeyEventDataAndroid;

        String key = ANDROID_MAPPING[androidEvent.keyCode];
        if (key != null) {
          gamepadListener(evtType, key);
        }
      }
    };

    RawKeyboard.instance.addListener(this.listener);
  }

  void removeListener() {
    RawKeyboard.instance.removeListener(this.listener);
  }
}
