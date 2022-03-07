import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../commons/commons.dart';
import 'draggables_example.dart';
import 'gesture_hitboxes_example.dart';
import 'hoverables_example.dart';
import 'joystick_advanced_example.dart';
import 'joystick_example.dart';
import 'keyboard_example.dart';
import 'mouse_cursor_example.dart';
import 'mouse_movement_example.dart';
import 'multitap_advanced_example.dart';
import 'multitap_example.dart';
import 'overlapping_tappables_example.dart';
import 'scroll_example.dart';
import 'tappables_example.dart';

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
