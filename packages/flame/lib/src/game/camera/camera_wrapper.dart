import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/game/camera/camera.dart';
import 'package:meta/meta.dart';

/// This class encapsulates FlameGame's rendering functionality. It will be
/// converted into a proper Component in a future release, but until then
/// using it in any code other than the FlameGame class is unsafe and
/// not recommended.
@internal
@Deprecated('Will be removed in Flame v1.10')
class CameraWrapper {
  @Deprecated('Will be removed in Flame v1.10')
  CameraWrapper(this.camera, this.world);

  final Camera camera;
  final ComponentSet world;

  void update(double dt) {
    camera.update(dt);
  }

  void render(Canvas canvas) {
    PositionType? previousType;
    canvas.save();
    world.forEach((component) {
      final sameType = component.positionType == previousType;
      if (!sameType) {
        if (previousType != null && previousType != PositionType.widget) {
          canvas.restore();
          canvas.save();
        }
        switch (component.positionType) {
          case PositionType.game:
            camera.viewport.apply(canvas);
            camera.apply(canvas);
            break;
          case PositionType.viewport:
            camera.viewport.apply(canvas);
            break;
          case PositionType.widget:
        }
      }
      component.renderTree(canvas);
      previousType = component.positionType;
    });

    if (previousType != PositionType.widget) {
      canvas.restore();
    }
  }
}
