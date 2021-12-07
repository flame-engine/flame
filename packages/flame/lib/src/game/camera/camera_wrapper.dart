import 'dart:ui';

import 'package:meta/meta.dart';

import '../../../components.dart';
import 'camera.dart';

/// This class encapsulates FlameGame's rendering functionality. It will be
/// converted into a proper Component in a future release, but until then
/// using it in any code other than the FlameGame class is unsafe and
/// not recommended.
@internal
class CameraWrapper {
  // TODO(st-pasha): extend from Component
  CameraWrapper(this.camera, this.world);

  final Camera camera;
  final ComponentSet world;

  void update(double dt) {
    camera.update(dt);
  }

  void render(Canvas canvas) {
    camera.viewport.render(canvas, (_canvas) {
      var hasCamera = false; // so we don't apply unnecessary transformations
      world.forEach((component) {
        if (component.respectCamera && !hasCamera) {
          canvas.save();
          camera.apply(canvas);
          hasCamera = true;
        } else if (!component.respectCamera && hasCamera) {
          canvas.restore();
          hasCamera = false;
        }
        canvas.save();
        component.renderTree(canvas);
        canvas.restore();
      });
      if (hasCamera) {
        canvas.restore();
      }
    });
  }
}
