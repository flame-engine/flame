import 'package:example/simple_hud.dart';
import 'package:flame/extensions.dart' as v64 show Vector2;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/core.dart';

class TouchControlledCamera extends ThirdPersonCamera {
  TouchControlledCamera()
      : super(
          following: Vector3(0, 2, 0),
          followDamping: 1,
          position: Vector3(0, 2, 4),
          projection: CameraProjection.perspective,
          distance: 3,
          viewport: FixedResolutionViewport(
            resolution: v64.Vector2(800, 600),
          ),
          hudComponents: [SimpleHud()],
        );

  Vector2 delta = Vector2.zero();

  @override
  void update(double dt) {
    super.update(dt);
    rotate(delta.x * dt, delta.y * dt);
  }
}
