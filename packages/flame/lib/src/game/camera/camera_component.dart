import 'dart:ui';
import '../../../components.dart';
import 'camera.dart';

class CameraComponent extends Component {
  CameraComponent(this.camera, this.world);

  final Camera camera;
  final ComponentSet world;

  @override
  void update(double dt) {
    super.update(dt);
    camera.update(dt);
  }

  @override
  void render(Canvas canvas) {
    // TODO(st-pasha): it would be easier to keep the world and the
    //   HUD as two separate component trees.
    camera.viewport.render(canvas, (_canvas) {
      // First render regular world objects
      canvas.save();
      camera.apply(canvas);
      world.forEach((component) {
        if (!component.isHud) {
          canvas.save();
          component.renderTree(canvas);
          canvas.restore();
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
