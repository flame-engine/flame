import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'pause_resume_game.dart';

void addSystemStories(Dashbook dashbook) {
  dashbook.storiesOf('System')
    ..add(
      'Pause/resume engine',
      (_) => GameWidget(game: PauseResumeGame()),
      codeLink: baseLink('system/pause_resume_game.dart'),
      info: PauseResumeGame.info,
    );
}
