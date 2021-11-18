import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../commons/commons.dart';
import 'draggables.dart';
import 'hoverables.dart';
import 'joystick.dart';
import 'joystick_advanced.dart';
import 'keyboard_example.dart';
import 'mouse_cursor.dart';
import 'mouse_movement.dart';
import 'multitap.dart';
import 'multitap_advanced.dart';
import 'overlapping_tappables.dart';
import 'scroll.dart';
import 'tappables.dart';

void addInputStories(Dashbook dashbook) {
  dashbook.storiesOf('Input')
    ..add(
      'Keyboard',
      (_) => GameWidget(game: KeyboardExample()),
      codeLink: baseLink('input/keyboard_example.dart'),
      info: KeyboardExample.description,
    )
    ..add(
      'Mouse Movement',
      (_) => GameWidget(game: MouseMovementExample()),
      codeLink: baseLink('input/mouse_movement.dart'),
      info: MouseMovementExample.description,
    )
    ..add(
      'Mouse Cursor',
      (_) => GameWidget(
        game: MouseCursorExample(),
        mouseCursor: SystemMouseCursors.move,
      ),
      codeLink: baseLink('input/mouse_cursor.dart'),
      info: MouseCursorExample.description,
    )
    ..add(
      'Scroll',
      (_) => GameWidget(game: ScrollExample()),
      codeLink: baseLink('input/scroll.dart'),
      info: ScrollExample.description,
    )
    ..add(
      'Multitap',
      (_) => GameWidget(game: MultitapExample()),
      codeLink: baseLink('input/multitap.dart'),
      info: MultitapExample.description,
    )
    ..add(
      'Multitap Advanced',
      (_) => GameWidget(game: MultitapAdvancedExample()),
      codeLink: baseLink('input/multitap_advanced.dart'),
      info: MultitapAdvancedExample.description,
    )
    ..add(
      'Tappables',
      (_) => GameWidget(game: TappablesExample()),
      codeLink: baseLink('input/tappables.dart'),
      info: TappablesExample.description,
    )
    ..add(
      'Overlapping Tappables',
      (_) => GameWidget(game: OverlappingTappablesExample()),
      codeLink: baseLink('input/overlapping_tappables.dart'),
      info: OverlappingTappablesExample.description,
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
      codeLink: baseLink('input/draggables.dart'),
      info: DraggablesExample.description,
    )
    ..add(
      'Hoverables',
      (_) => GameWidget(game: HoverablesExample()),
      codeLink: baseLink('input/hoverables.dart'),
      info: HoverablesExample.description,
    )
    ..add(
      'Joystick',
      (_) => GameWidget(game: JoystickExample()),
      codeLink: baseLink('input/joystick.dart'),
      info: JoystickExample.description,
    )
    ..add(
      'Joystick Advanced',
      (_) => GameWidget(game: JoystickAdvancedExample()),
      codeLink: baseLink('input/joystick_advanced.dart'),
      info: JoystickAdvancedExample.description,
    );
}
