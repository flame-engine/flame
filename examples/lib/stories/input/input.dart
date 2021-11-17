import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../../commons/commons.dart';
import 'draggables.dart';
import 'hoverables.dart';
import 'joystick.dart';
import 'joystick_advanced.dart';
import 'keyboard.dart';
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
      codeLink: baseLink('input/keyboard.dart'),
      info: KeyboardExample.description,
    )
    ..add(
      'Mouse Movement',
      (_) => GameWidget(game: MouseMovementExample()),
      codeLink: baseLink('input/mouse_movement.dart'),
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
    )
    ..add(
      'Multitap',
      (_) => GameWidget(game: MultitapExample()),
      codeLink: baseLink('input/multitap.dart'),
    )
    ..add(
      'Multitap Advanced',
      (_) => GameWidget(game: MultitapAdvancedExample()),
      codeLink: baseLink('input/multitap_advanced.dart'),
    )
    ..add(
      'Tappables',
      (_) => GameWidget(game: TappablesExample()),
      codeLink: baseLink('input/tappables.dart'),
    )
    ..add(
      'Overlaping Tappables',
      (_) => GameWidget(game: OverlappingTappablesExample()),
      codeLink: baseLink('input/overlaping_tappables.dart'),
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
    )
    ..add(
      'Joystick Advanced',
      (_) => GameWidget(game: JoystickAdvancedExample()),
      codeLink: baseLink('input/joystick_advanced.dart'),
    );
}
