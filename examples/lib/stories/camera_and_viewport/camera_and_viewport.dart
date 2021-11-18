import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
import 'coordinate_systems.dart';
import 'fixed_resolution.dart';
import 'follow_object.dart';
import 'zoom.dart';

void addCameraAndViewportStories(Dashbook dashbook) {
  dashbook.storiesOf('Camera & Viewport')
    ..add(
      'Follow Object',
      (context) {
        return GameWidget(
          game: CameraAndViewportExample(
            viewportResolution: Vector2(
              context.numberProperty('viewport width', 500),
              context.numberProperty('viewport height', 500),
            ),
          ),
        );
      },
      codeLink: baseLink('camera_and_viewport/follow_object.dart'),
      info: CameraAndViewportExample.description,
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
      codeLink: baseLink('camera_and_viewport/zoom.dart'),
      info: ZoomExample.description,
    )
    ..add(
      'Fixed Resolution viewport',
      (context) {
        return GameWidget(
          game: FixedResolutionExample(
            viewportResolution: Vector2(
              context.numberProperty('viewport width', 600),
              context.numberProperty('viewport height', 1024),
            ),
          ),
        );
      },
      codeLink: baseLink('camera_and_viewport/fixed_resolution.dart'),
      info: FixedResolutionExample.description,
    )
    ..add(
      'Coordinate Systems',
      (context) => CoordinateSystemsWidget(),
      codeLink: baseLink('camera_and_viewport/coordinate_systems.dart'),
      info: CoordinateSystemsExample.description,
    );
}
