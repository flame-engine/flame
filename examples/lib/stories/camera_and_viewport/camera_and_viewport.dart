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
          game: CameraAndViewportGame(
            viewportResolution: Vector2(
              context.numberProperty('viewport width', 500),
              context.numberProperty('viewport height', 500),
            ),
          ),
        );
      },
      codeLink: baseLink('camera_and_viewport/follow_object.dart'),
      info: CameraAndViewportGame.description,
    )
    ..add(
      'Zoom',
      (context) {
        return GameWidget(
          game: ZoomGame(
            viewportResolution: Vector2(
              context.numberProperty('viewport width', 500),
              context.numberProperty('viewport height', 500),
            ),
          ),
        );
      },
      codeLink: baseLink('camera_and_viewport/zoom.dart'),
      info: ZoomGame.description,
    )
    ..add(
      'Fixed Resolution viewport',
      (context) {
        return GameWidget(
          game: FixedResolutionGame(
            viewportResolution: Vector2(
              context.numberProperty('viewport width', 600),
              context.numberProperty('viewport height', 1024),
            ),
          ),
        );
      },
      codeLink: baseLink('camera_and_viewport/fixed_resolution.dart'),
      info: FixedResolutionGame.description,
    )
    ..add(
      'Coordinate Systems',
      (context) => CoordinateSystemsWidget(),
      codeLink: baseLink('camera_and_viewport/coordinate_systems.dart'),
      info: CoordinateSystemsGame.description,
    );
}
