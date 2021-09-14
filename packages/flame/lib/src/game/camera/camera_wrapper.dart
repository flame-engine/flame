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
      // First render regular world objects
      canvas.save();
      camera.apply(canvas);
      world.forEach((component) {
        if (!component.isHud) {
          // TODO(st-pasha): refactor [ParallaxComponent] so that it
          // wouldn't require any camera hacks.
          if (component is ParallaxComponent) {
            canvas.restore();
          }
          canvas.save();
          component.renderTree(canvas);
          canvas.restore();
          if (component is ParallaxComponent) {
            camera.apply(canvas);
          }
        }
      });
      canvas.restore();
      // Then render the HUD
      world.forEach((component) {
        if (component.isHud) {
          canvas.save();
          component.renderTree(canvas);
          canvas.restore();
        }
      });
    });
  }
}
