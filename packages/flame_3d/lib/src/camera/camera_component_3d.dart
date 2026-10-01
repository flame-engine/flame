import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';

enum CameraProjection() {
  perspective,
  orthographic,
}

/// {@template camera_component_3d}
/// [CameraComponent3D] is a component through which a [World3D] is observed.
/// {@endtemplate}
class CameraComponent3D({
  /// The [fovY] is the field of view in Y (degrees) when the [projection] is
  /// [CameraProjection.perspective] otherwise it is used as the near plane when
  /// the [projection] is [CameraProjection.orthographic].
  var double fovY = 60,
  Vector3? position,
  Quaternion? rotation,
  Vector3? target,
  Vector3? up,

  /// The current camera projection.
  var CameraProjection projection = CameraProjection.perspective,
  World3D? super.world,
  super.viewport,
  super.viewfinder,
  super.backdrop,
  super.hudComponents,
}) extends CameraComponent {
  @override
  World3D? get world => super.world as World3D?;

  @override
  set world(covariant World3D? world) => super.world = world;

  /// The position of the camera in 3D space.
  ///
  /// Often also referred to as the "eye".
  Vector3 position = position?.clone() ?? Vector3.zero();

  /// The target in 3D space that the camera is looking at.
  Vector3 target = target?.clone() ?? Vector3(0, 0, -1);

  /// The forward direction relative to the camera.
  Vector3 get forward => target - position;

  /// The right direction relative to the camera.
  Vector3 get right => forward.cross(up);

  /// The up direction relative to the camera.
  Vector3 get up => _up.normalized();
  set up(Vector3 up) => _up.setFrom(up);
  final Vector3 _up = up?.clone() ?? Vector3(0, 1, 0);

  /// The rotation of the camera.
  Quaternion rotation = rotation ?? Quaternion.identity();

  /// The view matrix of the camera, this is without any projection applied on
  /// it.
  Matrix4 get viewMatrix => _viewMatrix..setAsViewMatrix(position, target, up);
  final Matrix4 _viewMatrix = Matrix4.zero();

  /// The projection matrix of the camera.
  Matrix4 get projectionMatrix => switch (projection) {
    CameraProjection.perspective =>
      _projectionMatrix..setAsPerspective(
        fovY,
        viewport.virtualSize.x / viewport.virtualSize.y,
        distanceNear,
        distanceFar,
      ),
    CameraProjection.orthographic =>
      _projectionMatrix..setAsOrthographic(
        fovY,
        viewport.virtualSize.x / viewport.virtualSize.y,
        distanceNear,
        distanceFar,
      ),
  };
  final Matrix4 _projectionMatrix = Matrix4.zero();

  /// The view projection matrix used for rendering.
  Matrix4 get viewProjectionMatrix => _viewProjectionMatrix
    ..setFrom(projectionMatrix)
    ..multiply(viewMatrix);
  final Matrix4 _viewProjectionMatrix = Matrix4.zero();

  /// The frustum of the [viewProjectionMatrix].
  Frustum get frustum => _frustum..setFromMatrix(viewProjectionMatrix);
  final Frustum _frustum = Frustum();

  /// Rotates the camera's yaw and pitch.
  ///
  /// Both [yawDelta] and [pitchDelta] are in radians.
  void rotate(double yawDelta, double pitchDelta) {
    // Create quaternions for both yaw and pitch rotations.
    final yawRotation = Quaternion.axisAngle(Vector3(0, 1, 0), yawDelta);
    final pitchRotation = Quaternion.axisAngle(Vector3(1, 0, 0), pitchDelta);

    // Multiply the yaw with the current and pitch rotation to get the new
    // camera rotation.
    rotation = (yawRotation * rotation * pitchRotation)..normalize();
  }

  /// Resets the camera's rotation to its default state, making it look forward.
  void resetRotation() => rotation = Quaternion.identity();

  static CameraComponent3D? get currentCamera =>
      CameraComponent.currentCamera as CameraComponent3D?;

  static const distanceNear = 0.01;
  static const distanceFar = 1000.0;
}
