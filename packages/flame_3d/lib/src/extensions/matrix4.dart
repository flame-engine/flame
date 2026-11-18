import 'package:flame_3d/game.dart';
import 'package:flame_3d/src/extensions/clip_space.dart';

export 'package:vector_math/vector_math.dart'
    show
        degrees2Radians,
        setOrthographicMatrix,
        setPerspectiveMatrix,
        setViewMatrix;

/// View and projection matrices for flame_3d's renderer.
///
/// The projections target the clip space of Impeller and WebGPU: x and y in
/// `[-w, w]` with +y up, and the visible depth `0 <= z <= w`, which puts the
/// near plane at depth 0 and the far plane at depth 1. vector_math's
/// `setPerspectiveMatrix` and `setOrthographicMatrix` (re-exported here)
/// follow OpenGL's `-w <= z <= w` instead; under Impeller they clip away
/// everything in the nearer half of the depth range, so do not use them for
/// flame_3d rendering.
///
/// View space is right-handed: the camera looks down -z with +x to the right
/// and +y up.
extension Matrix4Extension on Matrix4 {
  /// Set the matrix to be a right-handed view matrix for an eye at [position]
  /// looking at [target], with [up] pointing up on screen.
  ///
  /// [up] does not need to be unit length. If [position] equals [target] the
  /// view looks down -z, and if [up] is zero or parallel to the view
  /// direction another world axis is used as up, so the result is always a
  /// rigid transform. Allocates nothing.
  void setAsViewMatrix(Vector3 position, Vector3 target, Vector3 up) {
    writeLookAt(
      storage,
      position.x,
      position.y,
      position.z,
      target.x,
      target.y,
      target.z,
      up.x,
      up.y,
      up.z,
    );
  }

  /// Set the matrix to a symmetric perspective projection with a vertical
  /// field of view of [fovY] degrees.
  ///
  /// The depth maps [zNear] to 0 and [zFar] to 1 (`0 < zNear < zFar`).
  void setAsPerspective(
    double fovY,
    double aspectRatio,
    double zNear,
    double zFar,
  ) {
    writePerspective(
      storage,
      fovY * degrees2Radians,
      aspectRatio,
      zNear,
      zFar,
    );
  }

  /// Set the matrix to a symmetric orthographic projection whose view volume
  /// is [height] world units tall and `height * aspectRatio` wide.
  ///
  /// The depth maps [zNear] to 0 and [zFar] to 1 (`zNear < zFar`); [zNear]
  /// may be zero or negative to keep geometry behind the eye.
  void setAsOrthographic(
    double height,
    double aspectRatio,
    double zNear,
    double zFar,
  ) {
    final top = height / 2;
    final right = top * aspectRatio;
    writeOrthographic(storage, -right, right, -top, top, zNear, zFar);
  }

  /// Set the matrix to an orthographic projection of the view-space box
  /// `[left, right] × [bottom, top]` between the distances [zNear] and
  /// [zFar].
  ///
  /// The depth maps [zNear] to 0 and [zFar] to 1 (`zNear < zFar`). An
  /// off-center box shifts the picture without moving the camera, which keeps
  /// the view matrix (and so the lighting and depth order) unchanged.
  void setAsOrthographicOffCenter(
    double left,
    double right,
    double bottom,
    double top,
    double zNear,
    double zFar,
  ) {
    writeOrthographic(storage, left, right, bottom, top, zNear, zFar);
  }
}
