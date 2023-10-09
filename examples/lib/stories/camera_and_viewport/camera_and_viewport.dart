import 'package:dashbook/dashbook.dart';
import 'package:examples/commons/commons.dart';
import 'package:examples/stories/camera_and_viewport/camera_component_example.dart';
import 'package:examples/stories/camera_and_viewport/camera_component_properties_example.dart';
import 'package:examples/stories/camera_and_viewport/camera_follow_and_world_bounds.dart';
import 'package:examples/stories/camera_and_viewport/coordinate_systems_example.dart';
import 'package:examples/stories/camera_and_viewport/fixed_resolution_example.dart';
import 'package:examples/stories/camera_and_viewport/follow_component_example.dart';
import 'package:examples/stories/camera_and_viewport/static_components_example.dart';
import 'package:examples/stories/camera_and_viewport/zoom_example.dart';
import 'package:flame/game.dart';

void addCameraAndViewportStories(Dashbook dashbook) {
  dashbook.storiesOf('Camera & Viewport')
    ..add(
      'Follow Component',
      (context) {
        return GameWidget(
          game: FollowComponentExample(
            viewportResolution: Vector2(
              context.numberProperty('viewport width', 500),
              context.numberProperty('viewport height', 500),
            ),
          ),
        );
      },
      codeLink: baseLink('camera_and_viewport/follow_component_example.dart'),
      info: FollowComponentExample.description,
    )
    ..add(
      'Zoom',
      (context) {
        return GameWidget(
          game: ZoomExample(
            viewportResolution: Vector2(
              context.numberProperty('viewport width', 500),
              context.numberProperty('viewport height', 500),
            ),
          ),
        );
      },
      codeLink: baseLink('camera_and_viewport/zoom_example.dart'),
      info: ZoomExample.description,
    )
    ..add(
      'Fixed Resolution viewport',
      (context) {
        return const GameWidget.controlled(
          gameFactory: FixedResolutionExample.new,
        );
      },
      codeLink: baseLink('camera_and_viewport/fixed_resolution_example.dart'),
      info: FixedResolutionExample.description,
    )
    ..add(
      'HUDs and static components',
      (context) {
        return GameWidget(
          game: StaticComponentsExample(
            viewportResolution: Vector2(
              context.numberProperty('viewport width', 500),
              context.numberProperty('viewport height', 500),
            ),
          ),
        );
      },
      codeLink: baseLink('camera_and_viewport/static_components_example.dart'),
      info: StaticComponentsExample.description,
    )
    ..add(
      'Coordinate Systems',
      (context) => const CoordinateSystemsWidget(),
      codeLink: baseLink('camera_and_viewport/coordinate_systems_example.dart'),
      info: CoordinateSystemsExample.description,
    )
    ..add(
      'CameraComponent',
      (context) => GameWidget(game: CameraComponentExample()),
      codeLink: baseLink('camera_and_viewport/camera_component_example.dart'),
      info: CameraComponentExample.description,
    )
    ..add(
      'CameraComponent properties',
      (context) => GameWidget(game: CameraComponentPropertiesExample()),
      codeLink: baseLink(
        'camera_and_viewport/camera_component_properties_example.dart',
      ),
      info: CameraComponentPropertiesExample.description,
    )
    ..add(
      'Follow and World bounds',
      (_) => GameWidget(game: CameraFollowAndWorldBoundsExample()),
      codeLink:
          baseLink('camera_and_viewport/camera_follow_and_world_bounds.dart'),
      info: CameraFollowAndWorldBoundsExample.description,
    );
}
