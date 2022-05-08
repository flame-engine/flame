import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'camera_follow_and_world_bounds.dart';
import 'shapes.dart';

void addExperimentalStories(Dashbook dashbook) {
  dashbook.storiesOf('Experimental')
    ..add(
      'Shapes',
      (_) => GameWidget(game: ShapesExample()),
      codeLink: baseLink('experimental/shapes.dart'),
      info: ShapesExample.description,
    )
    ..add(
      'Follow and World bounds',
      (_) => GameWidget(game: CameraFollowAndWorldBoundsExample()),
      codeLink: baseLink('experimental/camera_follow_and_world_bounds.dart'),
      info: CameraFollowAndWorldBoundsExample.description,
    );
}
