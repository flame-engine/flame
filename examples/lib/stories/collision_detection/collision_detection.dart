import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/collision_detection/bouncing_ball_example.dart';
import 'package:examples/stories/collision_detection/circles_example.dart';
import 'package:examples/stories/collision_detection/collidable_animation_example.dart';
import 'package:examples/stories/collision_detection/multiple_shapes_example.dart';
import 'package:examples/stories/collision_detection/quadtree_example.dart';
import 'package:examples/stories/collision_detection/raycast_example.dart';
import 'package:examples/stories/collision_detection/raycast_light_example.dart';
import 'package:examples/stories/collision_detection/raycast_max_distance_example.dart';
import 'package:examples/stories/collision_detection/raytrace_example.dart';
import 'package:flame/game.dart';

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
      'Bouncing Ball',
      (_) => GameWidget(game: BouncingBallExample()),
      codeLink: baseLink('collision_detection/bouncing_ball_example.dart'),
      info: BouncingBallExample.description,
    )
    ..add(
      'Multiple shapes',
      (_) => GameWidget(game: MultipleShapesExample()),
      codeLink: baseLink('collision_detection/multiple_shapes_example.dart'),
      info: MultipleShapesExample.description,
    )
    ..add(
      'QuadTree collision',
      (_) => GameWidget(game: QuadTreeExample()),
      codeLink: baseLink('collision_detection/quadtree_example.dart'),
      info: QuadTreeExample.description,
    )
    ..add(
      'Raycasting (light)',
      (_) => GameWidget(game: RaycastLightExample()),
      codeLink: baseLink('collision_detection/raycast_light_example.dart'),
      info: RaycastLightExample.description,
    )
    ..add(
      'Raycasting',
      (_) => GameWidget(game: RaycastExample()),
      codeLink: baseLink('collision_detection/raycast_example.dart'),
      info: RaycastExample.description,
    )
    ..add(
      'Raytracing',
      (_) => GameWidget(game: RaytraceExample()),
      codeLink: baseLink('collision_detection/raytrace_example.dart'),
      info: RaytraceExample.description,
    )
    ..add(
      'Raycasting Max Distance',
      (_) => GameWidget(game: RaycastMaxDistanceExample()),
      codeLink:
          baseLink('collision_detection/raycast_max_distance_example.dart'),
      info: RaycastMaxDistanceExample.description,
    );
}
