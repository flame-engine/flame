import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'advanced_joystick.dart';
import 'draggables.dart';
import 'joystick.dart';
import 'keyboard.dart';
import 'mouse_movement.dart';
import 'multitap.dart';
import 'multitap_advanced.dart';
import 'overlapping_tapables.dart';
import 'scroll.dart';
import 'tapables.dart';

void addControlsStories(Dashbook dashbook) {
  dashbook.storiesOf('Controls')
    ..add(
      'Keyboard',
      (_) => GameWidget(game: KeyboardGame()),
      codeLink: baseLink('gestures/keyboard.dart'),
    )
    ..add(
      'Mouse Movement',
      (_) => GameWidget(game: MouseMovementGame()),
      codeLink: baseLink('gestures/mouse_movement.dart'),
    )
    ..add(
      'Scroll',
      (_) => GameWidget(game: ScrollGame()),
      codeLink: baseLink('gestures/scroll.dart'),
    )
    ..add(
      'Multitap',
      (_) => GameWidget(game: MultitapGame()),
      codeLink: baseLink('gestures/multitap.dart'),
    )
    ..add(
      'Multitap Advanced',
      (_) => GameWidget(game: MultitapAdvancedGame()),
      codeLink: baseLink('gestures/multitap_advanced.dart'),
    )
    ..add(
      'Tapables',
      (_) => GameWidget(game: TapablesGame()),
      codeLink: baseLink('gestures/tappables.dart'),
    )
    ..add(
      'Overlaping Tappables',
      (_) => GameWidget(game: OverlappingTapablesGame()),
      codeLink: baseLink('gestures/overlaping_tappables.dart'),
    )
    ..add(
      'Draggables',
      (_) => GameWidget(game: DraggablesGame()),
      codeLink: baseLink('gestures/draggables.dart'),
    )
    ..add(
      'Joystick',
      (_) => GameWidget(game: JoystickGame()),
      codeLink: baseLink('gestures/joystick.dart'),
    )
    ..add(
      'Joystick Advanced',
      (_) => GameWidget(game: AdvancedJoystickGame()),
      codeLink: baseLink('gestures/advanced_joystick.dart'),
    );
}
