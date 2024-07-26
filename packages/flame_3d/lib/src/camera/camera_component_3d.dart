import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';

enum CameraProjection { perspective, orthographic }

enum CameraMode { custom, free, orbital, firstPerson, thirdPerson }

/// {@template camera_component_3d}
/// [CameraComponent3D] is a component through which a [World3D] is observed.
/// {@endtemplate}
class CameraComponent3D extends CameraComponent {
  /// {@macro camera_component_3d}
  CameraComponent3D({
    this.fovY = 60,
    Vector3? position,
    Vector3? target,
    Vector3? up,
    this.projection = CameraProjection.perspective,
    this.mode = CameraMode.free,
    World3D? super.world,
    super.viewport,
    super.viewfinder,
    super.backdrop,
    super.hudComponents,
  })  : position = position?.clone() ?? Vector3.zero(),
        target = target?.clone() ?? Vector3(0, 0, -1),
        _up = up?.clone() ?? Vector3(0, 1, 0);

  @override
  World3D? get world => super.world as World3D?;

  @override
  set world(covariant World3D? world) => super.world = world;

  /// The [fovY] is the field of view in Y (degrees) when the [projection] is
  /// [CameraProjection.perspective] otherwise it is used as the near plane when
  /// the [projection] is [CameraProjection.orthographic].
  double fovY;

  /// The position of the camera in 3D space.
  ///
  /// Often also referred to as the "eye".
  Vector3 position;

  /// The target in 3D space that the camera is looking at.
  Vector3 target;

  /// The forward direction relative to the camera.
  Vector3 get forward => target - position;

  /// The right direction relative to the camera.
  Vector3 get right => forward.cross(up);

  /// The up direction relative to the camera.
  Vector3 get up => _up.normalized();
  set up(Vector3 up) => _up.setFrom(up);
  final Vector3 _up;

  /// The current camera projection.
  CameraProjection projection;

  /// The current camera mode.
  CameraMode mode;

  /// The view matrix of the camera, this is without any projection applied on
  /// it.
  Matrix4 get viewMatrix => _viewMatrix..setAsViewMatrix(position, target, up);
  final Matrix4 _viewMatrix = Matrix4.zero();

  /// The projection matrix of the camera.
  Matrix4 get projectionMatrix {
    final aspectRatio = viewport.virtualSize.x / viewport.virtualSize.y;
    return switch (projection) {
      CameraProjection.perspective => _projectionMatrix
        ..setAsPerspective(fovY, aspectRatio, distanceNear, distanceFar),
      CameraProjection.orthographic => _projectionMatrix
        ..setAsOrthographic(fovY, aspectRatio, distanceNear, distanceFar)
    };
  }

  final Matrix4 _projectionMatrix = Matrix4.zero();

  Matrix4 get viewProjectionMatrix => _viewProjectionMatrix
    ..setFrom(projectionMatrix)
    ..multiply(viewMatrix);
  final Matrix4 _viewProjectionMatrix = Matrix4.zero();

  final Frustum _frustum = Frustum();

  Frustum get frustum => _frustum..setFromMatrix(viewProjectionMatrix);

  void moveForward(double distance, {bool moveInWorldPlane = false}) {
    final forward = this.forward..scale(distance);

    if (moveInWorldPlane) {
      forward.y = 0;
      forward.normalize();
    }

    position.add(forward);
    target.add(forward);
  }

  void moveUp(double distance) {
    final up = this.up..scale(distance);
    position.add(up);
    target.add(up);
  }

  void moveRight(double distance, {bool moveInWorldPlane = false}) {
    final right = this.right..scale(distance);

    if (moveInWorldPlane) {
      right.y = 0;
      right.normalize();
    }

    position.add(right);
    target.add(right);
  }

  void moveToTarget(double delta) {
    var distance = position.distanceTo(target);
    distance += delta;

    if (distance <= 0) {
      distance = 0.001;
    }

    final forward = this.forward;
    position.setValues(
      target.x + (forward.x * -distance),
      target.y + (forward.y * -distance),
      target.z + (forward.z * -distance),
    );
  }

  void yaw(double angle, {bool rotateAroundTarget = false}) {
    final targetPosition = (target - position)..applyAxisAngle(up, angle);

    if (rotateAroundTarget) {
      position.setValues(
        target.x - targetPosition.x,
        target.y - targetPosition.y,
        target.z - targetPosition.z,
      );
    } else {
      target.setValues(
        position.x + targetPosition.x,
        position.y + targetPosition.y,
        position.z + targetPosition.z,
      );
    }
  }

  void pitch(
    double angle, {
    bool lockView = false,
    bool rotateAroundTarget = false,
    bool rotateUp = false,
  }) {
    var localAngle = angle;
    final up = this.up;
    final targetPosition = target - position;

    if (lockView) {
      final maxAngleUp = up.angleTo(targetPosition);
      if (localAngle > maxAngleUp) {
        localAngle = maxAngleUp;
      }

      var maxAngleDown = (-up).angleTo(targetPosition);
      maxAngleDown *= -1.0;

      if (localAngle < maxAngleDown) {
        localAngle = maxAngleDown;
      }
    }

    final right = this.right;
    targetPosition.applyAxisAngle(right, localAngle);

    if (rotateAroundTarget) {
      position.setValues(
        target.x - targetPosition.x,
        target.y - targetPosition.y,
        target.z - targetPosition.z,
      );
    } else {
      target.setValues(
        position.x + targetPosition.x,
        position.y + targetPosition.y,
        position.z + targetPosition.z,
      );
    }

    if (rotateUp) {
      _up.applyAxisAngle(right, angle);
    }
  }

  void roll(double angle) {
    _up.applyAxisAngle(forward, angle);
  }

  static CameraComponent3D? get currentCamera =>
      CameraComponent.currentCamera as CameraComponent3D?;

  static const distanceNear = 0.01;
  static const distanceFar = 1000.0;
}
