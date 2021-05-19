import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'advanced_joystick.dart';
import 'draggables.dart';
import 'hoverables.dart';
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
      codeLink: baseLink('controls/keyboard.dart'),
    )
    ..add(
      'Mouse Movement',
      (_) => GameWidget(game: MouseMovementGame()),
      codeLink: baseLink('controls/mouse_movement.dart'),
    )
    ..add(
      'Scroll',
      (_) => GameWidget(game: ScrollGame()),
      codeLink: baseLink('controls/scroll.dart'),
    )
    ..add(
      'Multitap',
      (_) => GameWidget(game: MultitapGame()),
      codeLink: baseLink('controls/multitap.dart'),
    )
    ..add(
      'Multitap Advanced',
      (_) => GameWidget(game: MultitapAdvancedGame()),
      codeLink: baseLink('controls/multitap_advanced.dart'),
    )
    ..add(
      'Tapables',
      (_) => GameWidget(game: TapablesGame()),
      codeLink: baseLink('controls/tapables.dart'),
    )
    ..add(
      'Overlaping Tappables',
      (_) => GameWidget(game: OverlappingTapablesGame()),
      codeLink: baseLink('controls/overlaping_tappables.dart'),
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
      codeLink: baseLink('controls/draggables.dart'),
    )
    ..add(
      'Hoverables',
      (_) => GameWidget(game: HoverablesGame()),
      codeLink: baseLink('controls/hoverables.dart'),
      info: 'Add more squares by clicking. Hover squares to change colors.',
    )
    ..add(
      'Joystick',
      (_) => GameWidget(game: JoystickGame()),
      codeLink: baseLink('controls/joystick.dart'),
    )
    ..add(
      'Joystick Advanced',
      (_) => GameWidget(game: AdvancedJoystickGame()),
      codeLink: baseLink('controls/advanced_joystick.dart'),
    );
}
