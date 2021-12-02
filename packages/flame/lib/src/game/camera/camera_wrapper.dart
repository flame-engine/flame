import 'dart:ui';

import '../../../components.dart';
import 'camera.dart';

/// This class encapsulates FlameGame's rendering functionality. It will be
/// converted into a proper Component in a future release, but until then
/// using it in any code other than the FlameGame class is unsafe and
/// not recommended.
class CameraWrapper {
  // TODO(st-pasha): extend from Component
  CameraWrapper(this.camera, this.world);

  final Camera camera;
  final ComponentSet world;

  void update(double dt) {
    camera.update(dt);
  }

  void render(Canvas canvas) {
    // TODO(st-pasha): it would be easier to keep the world and the
    // HUD as two separate component trees.
    camera.viewport.render(canvas, (_canvas) {
      var hasCamera = false; // so we don't apply unecessary transformations
      world.forEach((component) {
        if (!component.isHud && !hasCamera) {
          canvas.save();
          camera.apply(canvas);
          hasCamera = true;
        } else if (component.isHud && hasCamera) {
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
