import 'package:example/components/player.dart';
import 'package:example/components/simple_hud.dart';
import 'package:example/example_game_3d.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart' as v64 show Vector2;
import 'package:flame_3d/camera.dart';

class ExampleCamera3D extends CameraComponent3D
    with HasGameReference<ExampleGame3D> {
  CameraMode _mode = CameraMode.player;
  double distance = 5.0;
  Vector2 delta = Vector2.zero();

  ExampleCamera3D()
    : super(
        position: Vector3(0, 2, 4),
        projection: CameraProjection.perspective,
        viewport: FixedResolutionViewport(
          resolution: v64.Vector2(800, 600),
        ),
        hudComponents: [SimpleHud()],
      );

  CameraMode get mode => _mode;

  set mode(CameraMode mode) {
    _mode = mode;
    reset();
  }

  void reset() {
    if (_mode == CameraMode.drag) {
      position.setFrom(Vector3(0, 2, 4));
      target.setFrom(Vector3(-1, 0, 0));
    } else {
      position = player.position + _computePositionOffset(player.rotation);
      target = player.position + player.lookAt;
    }
    delta.setZero();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_mode == CameraMode.drag) {
      _dragCameraUpdate(dt);
    } else if (_mode == CameraMode.player) {
      _playerCameraUpdate(dt);
    }
  }

  void _dragCameraUpdate(double dt) {
    rotate(delta.x * dt, delta.y * dt);
    target.setFrom(position + _computePositionOffset(rotation));
  }

  Player get player => game.player;

  void _playerCameraUpdate(double dt) {
    final targetOffset =
        player.position + _computePositionOffset(player.rotation);
    final targetLookAt = player.position + player.lookAt;

    position += (targetOffset - position) * _cameraLinearSpeed * dt;
    target += (targetLookAt - target) * _cameraRotationSpeed * dt;
  }

  Vector3 _computePositionOffset(Quaternion rotation) {
    final forward = Vector3(0, -1, 1)..applyQuaternion(rotation);
    return forward.normalized() * -distance;
  }

  static const double _cameraRotationSpeed = 6.0;
  static const double _cameraLinearSpeed = 12.0;
}

enum CameraMode {
  drag,
  player,
}
