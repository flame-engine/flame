import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'pursue_example.dart';

void addBehaviorStories(Dashbook dashbook) {
  dashbook.storiesOf('Behaviors').add(
        'Pursue',
        (_) => GameWidget(game: PursueExample()),
        codeLink: baseLink('behaviors/pursue_example.dart'),
        info: PursueExample.description,
      );
}
