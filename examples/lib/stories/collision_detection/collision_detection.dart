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
      (_) => GameWidget(game: CollidableAnimationExample()),
      codeLink: baseLink('collision_detection/collidable_animation.dart'),
      info: CollidableAnimationExample.description,
    )
    ..add(
      'Circles',
      (_) => GameWidget(game: CirclesExample()),
      codeLink: baseLink('collision_detection/circles.dart'),
      info: CirclesExample.description,
    )
    ..add(
      'Multiple shapes',
      (_) => GameWidget(game: MultipleShapesExample()),
      codeLink: baseLink('collision_detection/multiple_shapes.dart'),
      info: MultipleShapesExample.description,
    )
    ..add(
      'Simple Shapes',
      (_) => GameWidget(game: SimpleShapesExample()),
      codeLink: baseLink('collision_detection/simple_shapes.dart'),
      info: SimpleShapesExample.description,
    );
}
