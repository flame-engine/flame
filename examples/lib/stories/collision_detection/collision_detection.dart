import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'circles.dart';
import 'multiple_shapes.dart';
import 'only_shapes.dart';

const basicInfo = '''
An example with many hitboxes that move around on the screen and during
collisions they change color depending on what it is that they have collided
with. 

The snowman, the component built with three circles on top of each other, works
a little bit differently than the other components to show that you can have
multiple hitboxes within one component.

On this example, you can "throw" the components by dragging them quickly in any
direction.
''';

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
      info: basicInfo,
    )
    ..add(
      'Shapes without components',
      (_) => GameWidget(game: OnlyShapes()),
      codeLink: baseLink('collision_detection/only_shapes.dart'),
    );
}
