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
      (_) => GameWidget(game: KeyboardGame()),
      codeLink: baseLink('input/keyboard.dart'),
      info: keyboardInfo,
    )
    ..add(
      'Mouse Movement',
      (_) => GameWidget(game: MouseMovementGame()),
      codeLink: baseLink('input/mouse_movement.dart'),
    )
    ..add(
      'Mouse Cursor',
      (_) => GameWidget(
        game: MouseCursorGame(),
        mouseCursor: SystemMouseCursors.move,
      ),
      codeLink: baseLink('input/mouse_cursor.dart'),
      info: '''
      Example showcasing the ability to change the game cursor in runtime
      hover the little square to see the cursor changing
      ''',
    )
    ..add(
      'Scroll',
      (_) => GameWidget(game: ScrollGame()),
      codeLink: baseLink('input/scroll.dart'),
    )
    ..add(
      'Multitap',
      (_) => GameWidget(game: MultitapGame()),
      codeLink: baseLink('input/multitap.dart'),
    )
    ..add(
      'Multitap Advanced',
      (_) => GameWidget(game: MultitapAdvancedGame()),
      codeLink: baseLink('input/multitap_advanced.dart'),
    )
    ..add(
      'Tappables',
      (_) => GameWidget(game: TappablesGame()),
      codeLink: baseLink('input/tappables.dart'),
    )
    ..add(
      'Overlaping Tappables',
      (_) => GameWidget(game: OverlappingTappablesGame()),
      codeLink: baseLink('input/overlaping_tappables.dart'),
    )
    ..add(
      'Draggables',
      (context) {
        return GameWidget(
          game: DraggablesGame(
            zoom: context.listProperty('zoom', 1, [0.5, 1, 1.5]),
          ),
        );
      },
      codeLink: baseLink('input/draggables.dart'),
    )
    ..add(
      'Hoverables',
      (_) => GameWidget(game: HoverablesGame()),
      codeLink: baseLink('input/hoverables.dart'),
      info: 'Add more squares by clicking. Hover squares to change colors.',
    )
    ..add(
      'Joystick',
      (_) => GameWidget(game: JoystickGame()),
      codeLink: baseLink('input/joystick.dart'),
    )
    ..add(
      'Joystick Advanced',
      (_) => GameWidget(game: JoystickAdvancedGame()),
      codeLink: baseLink('input/joystick_advanced.dart'),
    );
}
