import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/structure/levels.dart';
import 'package:flame/game.dart';

void addStructureStories(Dashbook dashbook) {
  dashbook.storiesOf('Structure').add(
        'Levels',
        (_) => GameWidget(game: LevelsExample()),
        info: LevelsExample.description,
        codeLink: baseLink('structure/levels.dart'),
      );
}
