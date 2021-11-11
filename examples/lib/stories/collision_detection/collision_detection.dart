import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'circles.dart';
import 'collidable_animation.dart';
import 'multiple_shapes.dart';
import 'simple_shapes.dart';

void addCollisionDetectionStories(Dashbook dashbook) {
  dashbook.storiesOf('Collision Detection')
    ..add(
      'Collidable AnimationComponent',
      (_) => GameWidget(game: CollidableAnimationGame()),
      codeLink: baseLink('collision_detection/collidable_animation.dart'),
      info: CollidableAnimationGame.description,
    )
    ..add(
      'Circles',
      (_) => GameWidget(game: Circles()),
      codeLink: baseLink('collision_detection/circles.dart'),
      info: Circles.description,
    )
    ..add(
      'Multiple shapes',
      (_) => GameWidget(game: MultipleShapes()),
      codeLink: baseLink('collision_detection/multiple_shapes.dart'),
      info: MultipleShapes.description,
    )
    ..add(
      'Simple Shapes',
      (_) => GameWidget(game: SimpleShapes()),
      codeLink: baseLink('collision_detection/simple_shapes.dart'),
      info: SimpleShapes.description,
    );
}
