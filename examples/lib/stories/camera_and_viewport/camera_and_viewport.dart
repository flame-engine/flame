import 'package:dashbook/dashbook.dart';
import 'package:flame/game.dart';

import '../../commons/commons.dart';
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
      /*
         Text for instructions:

         Move around with W, A, S, D and notice how the camera follows the white square
         The blue squares can also be clicked to show how the coordinate system respect
         The camera transformation
      */
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
      /*
         Text for instructions:

         On web: use scroll to zoom in and out
         On mobile: use scale gesture to zoom in and out
      */
    );
}
