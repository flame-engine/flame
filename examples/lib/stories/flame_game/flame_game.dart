import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/flame_game/levels.dart';
import 'package:flame/game.dart';

void addFlameGameStories(Dashbook dashbook) {
  dashbook.storiesOf('FlameGame').add(
        'Levels',
        (_) => GameWidget(game: LevelsExample()),
        info: LevelsExample.description,
        codeLink: baseLink('flame_game/levels.dart'),
      );
}
