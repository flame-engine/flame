import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'circles_example.dart';
import 'collidable_animation_example.dart';
import 'multiple_shapes_example.dart';

void addCollisionDetectionStories(Dashbook dashbook) {
  dashbook.storiesOf('Collision Detection')
    ..add(
      'Collidable AnimationComponent',
      (_) => GameWidget(game: CollidableAnimationExample()),
      codeLink:
          baseLink('collision_detection/collidable_animation_example.dart'),
      info: CollidableAnimationExample.description,
    )
    ..add(
      'Circles',
      (_) => GameWidget(game: CirclesExample()),
      codeLink: baseLink('collision_detection/circles_example.dart'),
      info: CirclesExample.description,
    )
    ..add(
      'Multiple shapes',
      (_) => GameWidget(game: MultipleShapesExample()),
      codeLink: baseLink('collision_detection/multiple_shapes_example.dart'),
      info: MultipleShapesExample.description,
    );
}
