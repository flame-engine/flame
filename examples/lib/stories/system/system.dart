import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'overlay.dart';
import 'pause_resume_game.dart';
import 'without_flamegame.dart';

void addSystemStories(Dashbook dashbook) {
  dashbook.storiesOf('System')
    ..add(
      'Pause/resume engine',
      (_) => GameWidget(game: PauseResumeExample()),
      codeLink: baseLink('system/pause_resume_game.dart'),
      info: PauseResumeExample.description,
    )
    ..add(
      'Overlay',
      overlayBuilder,
      codeLink: baseLink('widgets/overlay.dart'),
      info: OverlaysExample.description,
    )
    ..add(
      'Without FlameGame',
      (_) => GameWidget(game: NoFlameGameExample()),
      codeLink: baseLink('utils/without_flamegame.dart'),
      info: NoFlameGameExample.description,
    );
}
