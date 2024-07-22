import 'package:flame_3d/game.dart';

export 'package:vector_math/vector_math.dart'
    show
        degrees2Radians,
        setViewMatrix,
        setPerspectiveMatrix,
        setOrthographicMatrix;

extension Matrix4Extension on Matrix4 {
  /// Set the matrix to be a view matrix.
  void setAsViewMatrix(Vector3 position, Vector3 target, Vector3 up) {
    setViewMatrix(this, position, target, up);
  }

  /// Set the matrix to use a projection view.
  void setAsPerspective(
    double fovY,
    double aspectRatio,
    double zNear,
    double zFar,
  ) {
    final fovYRadians = fovY * degrees2Radians;
    setPerspectiveMatrix(this, fovYRadians, aspectRatio, zNear, zFar);
  }

  /// Set the matrix to use a orthographic view.
  void setAsOrthographic(
    double nearPlaneWidth,
    double aspectRatio,
    double zNear,
    double zFar,
  ) {
    final top = nearPlaneWidth / 2.0;
    final right = top * aspectRatio;
    setOrthographicMatrix(this, -right, right, -top, top, zNear, zFar);
  }
}
