import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'circles.dart';
import 'multiple_shapes.dart';
import 'only_shapes.dart';

void addCollisionDetectionStories(Dashbook dashbook) {
  dashbook.storiesOf('Collision Detection')
    ..add(
      'Circles',
      (_) => GameWidget(game: Circles()),
      codeLink: baseLink('collision_detection/circles.dart'),
      info: circlesInfo,
    )
    ..add(
      'Multiple shapes',
      (_) => GameWidget(game: MultipleShapes()),
      codeLink: baseLink('collision_detection/multiple_shapes.dart'),
      info: multipleShapesInfo,
    )
    ..add(
      'Simple Shapes',
      (_) => GameWidget(game: OnlyShapes()),
      codeLink: baseLink('collision_detection/only_shapes.dart'),
      info: onlyShapesInfo,
    );
}
