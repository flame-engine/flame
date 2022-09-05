import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/input/draggables_example.dart';
import 'package:examples/stories/input/gesture_hitboxes_example.dart';
import 'package:examples/stories/input/hoverables_example.dart';
import 'package:examples/stories/input/joystick_advanced_example.dart';
import 'package:examples/stories/input/joystick_example.dart';
import 'package:examples/stories/input/keyboard_example.dart';
import 'package:examples/stories/input/keyboard_listener_component_example.dart';
import 'package:examples/stories/input/mouse_cursor_example.dart';
import 'package:examples/stories/input/mouse_movement_example.dart';
import 'package:examples/stories/input/multitap_advanced_example.dart';
import 'package:examples/stories/input/multitap_example.dart';
import 'package:examples/stories/input/overlapping_tappables_example.dart';
import 'package:examples/stories/input/scroll_example.dart';
import 'package:examples/stories/input/tappables_example.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void addInputStories(Dashbook dashbook) {
  dashbook.storiesOf('Input')
    ..add(
      'Tappables',
      (_) => GameWidget(game: TappablesExample()),
      codeLink: baseLink('input/tappables_example.dart'),
      info: TappablesExample.description,
    )
    ..add(
      'Draggables',
      (context) {
        return GameWidget(
          game: DraggablesExample(
            zoom: context.listProperty('zoom', 1, [0.5, 1, 1.5]),
          ),
        );
      },
      codeLink: baseLink('input/draggables_example.dart'),
      info: DraggablesExample.description,
    )
    ..add(
      'Hoverables',
      (_) => GameWidget(game: HoverablesExample()),
      codeLink: baseLink('input/hoverables_example.dart'),
      info: HoverablesExample.description,
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
      'Overlapping Tappables',
      (_) => GameWidget(game: OverlappingTappablesExample()),
      codeLink: baseLink('input/overlapping_tappables_example.dart'),
      info: OverlappingTappablesExample.description,
    )
    ..add(
      'Gesture Hitboxes',
      (_) => GameWidget(game: GestureHitboxesExample()),
      codeLink: baseLink('collision_detection/simple_shapes_example.dart'),
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
    );
}
