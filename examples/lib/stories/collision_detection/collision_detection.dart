import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'circles.dart';
import 'multiple_shapes.dart';

void addCollisionDetectionStories(Dashbook dashbook) {
  dashbook.storiesOf('Collision Detection')
    ..add(
      'Circles',
      (_) => GameWidget(game: Circles()),
      codeLink: baseLink('collision_detection/circles.dart'),
    )
    ..add(
      'Multiple shapes',
      (_) => GameWidget(game: MultipleShapes()),
      codeLink: baseLink('collision_detection/multiple_shapes.dart'),
    );
}
