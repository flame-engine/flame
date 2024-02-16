import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/input/advanced_button_example.dart';
import 'package:examples/stories/input/double_tap_callbacks_example.dart';
import 'package:examples/stories/input/drag_callbacks_example.dart';
import 'package:examples/stories/input/gesture_hitboxes_example.dart';
import 'package:examples/stories/input/hardware_keyboard_example.dart';
import 'package:examples/stories/input/hover_callbacks_example.dart';
import 'package:examples/stories/input/joystick_advanced_example.dart';
import 'package:examples/stories/input/joystick_example.dart';
import 'package:examples/stories/input/keyboard_example.dart';
import 'package:examples/stories/input/keyboard_listener_component_example.dart';
import 'package:examples/stories/input/mouse_cursor_example.dart';
import 'package:examples/stories/input/mouse_movement_example.dart';
import 'package:examples/stories/input/multitap_advanced_example.dart';
import 'package:examples/stories/input/multitap_example.dart';
import 'package:examples/stories/input/overlapping_tap_callbacks_example.dart';
import 'package:examples/stories/input/scroll_example.dart';
import 'package:examples/stories/input/tap_callbacks_example.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void addInputStories(Dashbook dashbook) {
  dashbook.storiesOf('Input')
    ..add(
      'TapCallbacks',
      (_) => GameWidget(game: TapCallbacksExample()),
      codeLink: baseLink('input/tap_callbacks_example.dart'),
      info: TapCallbacksExample.description,
    )
    ..add(
      'DragCallbacks',
      (context) {
        return GameWidget(
          game: DragCallbacksExample(
            zoom: context.listProperty('zoom', 1, [0.5, 1, 1.5]),
          ),
        );
      },
      codeLink: baseLink('input/drag_callbacks_example.dart'),
      info: DragCallbacksExample.description,
    )
    ..add(
      'Double Tap (Component)',
      (context) {
        return GameWidget(
          game: DoubleTapCallbacksExample(),
        );
      },
      codeLink: baseLink('input/double_tap_callbacks_example.dart'),
      info: DoubleTapCallbacksExample.description,
    )
    ..add(
      'HoverCallbacks',
      (_) => GameWidget(game: HoverCallbacksExample()),
      codeLink: baseLink('input/hover_callbacks_example.dart'),
      info: HoverCallbacksExample.description,
    )
    ..add(
      'Keyboard',
      (_) => GameWidget(game: KeyboardExample()),
      codeLink: baseLink('input/keyboard_example.dart'),
      info: KeyboardExample.description,
    )
    ..add(
      'Keyboard (Component)',
      (_) => GameWidget(game: KeyboardListenerComponentExample()),
      codeLink: baseLink('input/keyboard_listener_component_example.dart'),
      info: KeyboardListenerComponentExample.description,
    )
    ..add(
      'Hardware Keyboard',
      (_) => GameWidget(game: HardwareKeyboardExample()),
      codeLink: baseLink('input/hardware_keyboard_example.dart'),
      info: HardwareKeyboardExample.description,
    )
    ..add(
      'Mouse Movement',
      (_) => GameWidget(game: MouseMovementExample()),
      codeLink: baseLink('input/mouse_movement_example.dart'),
      info: MouseMovementExample.description,
    )
    ..add(
      'Mouse Cursor',
      (_) => GameWidget(
        game: MouseCursorExample(),
        mouseCursor: SystemMouseCursors.move,
      ),
      codeLink: baseLink('input/mouse_cursor_example.dart'),
      info: MouseCursorExample.description,
    )
    ..add(
      'Scroll',
      (_) => GameWidget(game: ScrollExample()),
      codeLink: baseLink('input/scroll_example.dart'),
      info: ScrollExample.description,
    )
    ..add(
      'Multitap',
      (_) => GameWidget(game: MultitapExample()),
      codeLink: baseLink('input/multitap_example.dart'),
      info: MultitapExample.description,
    )
    ..add(
      'Multitap Advanced',
      (_) => GameWidget(game: MultitapAdvancedExample()),
      codeLink: baseLink('input/multitap_advanced_example.dart'),
      info: MultitapAdvancedExample.description,
    )
    ..add(
      'Overlapping TapCallbacks',
      (_) => GameWidget(game: OverlappingTapCallbacksExample()),
      codeLink: baseLink('input/overlapping_tap_callbacks_example.dart'),
      info: OverlappingTapCallbacksExample.description,
    )
    ..add(
      'Gesture Hitboxes',
      (_) => GameWidget(game: GestureHitboxesExample()),
      codeLink: baseLink('input/gesture_hitboxes_example.dart'),
      info: GestureHitboxesExample.description,
    )
    ..add(
      'Joystick',
      (_) => GameWidget(game: JoystickExample()),
      codeLink: baseLink('input/joystick_example.dart'),
      info: JoystickExample.description,
    )
    ..add(
      'Joystick Advanced',
      (_) => GameWidget(game: JoystickAdvancedExample()),
      codeLink: baseLink('input/joystick_advanced_example.dart'),
      info: JoystickAdvancedExample.description,
    )
    ..add(
      'Advanced Button',
      (_) => GameWidget(game: AdvancedButtonExample()),
      codeLink: baseLink('input/advanced_button_example.dart'),
      info: AdvancedButtonExample.description,
    );
}
