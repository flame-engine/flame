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
      info: ''
          'Move around with W, A, S, D and notice how the camera follows the white square.\n'
          'If you collide with the blue squares, the camera reference is changed from center to topCenter.\n'
          'The blue squares can also be clicked to show how the coordinate system respects the camera transformation.',
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
      info: ''
          'On web: use scroll to zoom in and out.\n'
          'On mobile: use scale gesture to zoom in and out.',
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
      info: FixedResolutionGame.info,
    )
    ..add(
      'Coordinate Systems',
      (context) => CoordinateSystemsWidget(),
      codeLink: baseLink('camera_and_viewport/coordinate_systems.dart'),
      info: ''
          'Displays event data in all 3 coordinte systems (global, widget and game).\n'
          'Use WASD to move the camera and Q/E to zoom in/out.\n'
          'Trigger events to see the coordinates on each coordinate space.',
    );
}
