import 'package:examples/commons/commons.dart';
import 'package:examples/commons/example_use_case.dart';
import 'package:examples/stories/camera_and_viewport/camera_component_example.dart';
import 'package:examples/stories/camera_and_viewport/camera_component_properties_example.dart';
import 'package:examples/stories/camera_and_viewport/camera_follow_and_world_bounds.dart';
import 'package:examples/stories/camera_and_viewport/coordinate_systems_example.dart';
import 'package:examples/stories/camera_and_viewport/fixed_resolution_example.dart';
import 'package:examples/stories/camera_and_viewport/follow_component_example.dart';
import 'package:examples/stories/camera_and_viewport/static_components_example.dart';
import 'package:examples/stories/camera_and_viewport/zoom_example.dart';
import 'package:flame/game.dart';
import 'package:widgetbook/widgetbook.dart';

WidgetbookComponent cameraAndViewportStories() {
  return WidgetbookComponent(
    name: 'Camera & Viewport',
    useCases: [
      ExampleUseCase(
        name: 'Follow Component',
        builder: (context) {
          return GameWidget(
            game: FollowComponentExample(
              viewportResolution: Vector2(
                context.knobs.double.input(
                  label: 'viewport width',
                  initialValue: 500,
                ),
                context.knobs.double.input(
                  label: 'viewport height',
                  initialValue: 500,
                ),
              ),
            ),
          );
        },
        codeLink: baseLink('camera_and_viewport/follow_component_example.dart'),
        info: FollowComponentExample.description,
      ),
      ExampleUseCase(
        name: 'Zoom',
        builder: (context) {
          return GameWidget(
            game: ZoomExample(),
          );
        },
        codeLink: baseLink('camera_and_viewport/zoom_example.dart'),
        info: ZoomExample.description,
      ),
      ExampleUseCase(
        name: 'Fixed Resolution viewport',
        builder: (context) {
          return const GameWidget.managed(
            gameFactory: FixedResolutionExample.new,
          );
        },
        codeLink: baseLink('camera_and_viewport/fixed_resolution_example.dart'),
        info: FixedResolutionExample.description,
      ),
      ExampleUseCase(
        name: 'HUDs and static components',
        builder: (context) {
          return GameWidget(
            game: StaticComponentsExample(
              viewportResolution: Vector2(
                context.knobs.double.input(
                  label: 'viewport width',
                  initialValue: 500,
                ),
                context.knobs.double.input(
                  label: 'viewport height',
                  initialValue: 500,
                ),
              ),
            ),
          );
        },
        codeLink: baseLink(
          'camera_and_viewport/static_components_example.dart',
        ),
        info: StaticComponentsExample.description,
      ),
      ExampleUseCase(
        name: 'Coordinate Systems',
        builder: (context) => const CoordinateSystemsWidget(),
        codeLink: baseLink(
          'camera_and_viewport/coordinate_systems_example.dart',
        ),
        info: CoordinateSystemsExample.description,
      ),
      ExampleUseCase(
        name: 'CameraComponent',
        builder: (context) => GameWidget(game: CameraComponentExample()),
        codeLink: baseLink('camera_and_viewport/camera_component_example.dart'),
        info: CameraComponentExample.description,
      ),
      ExampleUseCase(
        name: 'CameraComponent properties',
        builder: (context) =>
            GameWidget(game: CameraComponentPropertiesExample()),
        codeLink: baseLink(
          'camera_and_viewport/camera_component_properties_example.dart',
        ),
        info: CameraComponentPropertiesExample.description,
      ),
      ExampleUseCase(
        name: 'Follow and World bounds',
        builder: (_) => GameWidget(game: CameraFollowAndWorldBoundsExample()),
        codeLink: baseLink(
          'camera_and_viewport/camera_follow_and_world_bounds.dart',
        ),
        info: CameraFollowAndWorldBoundsExample.description,
      ),
    ],
  );
}
