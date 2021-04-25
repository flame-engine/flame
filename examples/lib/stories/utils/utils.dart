import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'nine_tile_box.dart';
import 'particles.dart';
import 'timer.dart';
import 'timer_component.dart';

void addUtilsStories(Dashbook dashbook) {
  dashbook.storiesOf('Utils')
    ..add(
      'Nine Tile Box',
      (_) => GameWidget(game: NineTileBoxGame()),
      codeLink: baseLink('utils/nine_tile_box.dart'),
    )
    ..add(
      'Timer',
      (_) => GameWidget(game: TimerGame()),
      codeLink: baseLink('utils/timer.dart'),
    )
    ..add(
      'Timer Component',
      (_) => GameWidget(game: TimerComponentGame()),
      codeLink: baseLink('utils/timer_component.dart'),
    )
    ..add(
      'Particles',
      (_) => GameWidget(game: ParticlesGame()),
      codeLink: baseLink('utils/particles.dart'),
    );
}
