import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/extensions/clip_space.dart';
import 'package:meta/meta.dart';

/// {@template scene_3d_projection}
/// How a [Scene3DComponent] maps the points of its 3D scene to its local 2D
/// coordinates.
///
/// A projection is a 4x4 matrix, [sceneToLocalMatrix], taking a scene point
/// `(x, y, z, 1)` to `(X, Y, Z, W)`: the point lands on the local 2D point
/// `(X / W, Y / W)` (in the coordinates of the component, y pointing down),
/// at the depth `Z / W`, which runs from 0 on the near plane to 1 on the far
/// plane; what lies outside that range is not drawn. Nearer points hide
/// farther ones.
///
/// - [Scene3DProjection.affine] is a parallel projection given by the 2D
///   images of the scene's axes, like the projection of isometric or dimetric
///   2D art. `W` is 1.
/// - [Scene3DProjection.camera] and [Scene3DProjection.perspective] map the
///   picture of a camera (a view matrix and a clip-space projection, as a
///   [CameraComponent3D] builds them) onto a rectangle of the component, for
///   a perspective look inside the layer.
/// - [Scene3DProjection.matrix] takes any such matrix.
///
/// The projection may mirror the scene (for example when the 2D images of the
/// x, y and z axes are in clockwise order, seen from the viewer); the winding
/// of front faces then flips automatically, so back-face culling keeps
/// working.
///
/// A projection is immutable: to change it, give the component a new one.
/// Creating one is cheap.
///
/// Besides the matrix, a projection has a [viewMatrix], a rigid transform
/// whose origin is the viewer's eye. Lit materials read the eye position from
/// it, and shaders that read the `view` and `projection` matrices of the pass
/// get this view and the matching projection. For a parallel projection the
/// eye is placed far away on the side of the viewer.
/// {@endtemplate}
class Scene3DProjection._(
  final Float64List _view,
  final Float64List _viewToLocal,
) {
  /// A parallel projection that maps the scene point `(x, y, z)` to the local
  /// point `origin + x * xAxis + y * yAxis + z * zAxis`.
  ///
  /// [xAxis], [yAxis] and [zAxis] are the local 2D images of the scene's unit
  /// vectors, [origin] (default `(0, 0)`) the image of the scene's origin.
  /// The scene points that map to one local point lie on a line, the line of
  /// sight; [towardsViewer] tells on which side of the scene the viewer is:
  /// it must point roughly along the line of sight, towards the viewer.
  ///
  /// The depth is the distance along the line of sight, away from the viewer,
  /// measured from the plane through the scene's origin; [near] and [far]
  /// (with `near < far`, in scene units) bound the depths that are drawn.
  ///
  /// For example, a scene measured in cells, with z up, drawn as 2D art where
  /// a cell is 88 by 44 pixels and a unit of height 53.889 pixels:
  ///
  /// ```dart
  /// final projection = Scene3DProjection.affine(
  ///   xAxis: Vector2(44, 22),
  ///   yAxis: Vector2(-44, 22),
  ///   zAxis: Vector2(0, -53.889),
  ///   towardsViewer: Vector3(1, 1, 1),
  ///   near: -100,
  ///   far: 100,
  /// );
  /// ```
  factory Scene3DProjection.affine({
    required Vector2 xAxis,
    required Vector2 yAxis,
    required Vector2 zAxis,
    required Vector3 towardsViewer,
    required double near,
    required double far,
    Vector2? origin,
  }) {
    if (!(near < far) || near.isInfinite || far.isInfinite) {
      throw ArgumentError('near ($near) must be less than far ($far)');
    }
    final (kx, ky, kz) = _lineOfSight(
      xAxis.x,
      yAxis.x,
      zAxis.x,
      xAxis.y,
      yAxis.y,
      zAxis.y,
    );
    final side =
        kx * towardsViewer.x + ky * towardsViewer.y + kz * towardsViewer.z;
    if (!(side.abs() > 1e-9 * towardsViewer.length)) {
      throw ArgumentError.value(
        towardsViewer,
        'towardsViewer',
        'Must point along the line of sight, towards the viewer',
      );
    }
    final sign = side > 0 ? 1.0 : -1.0;
    final range = far - near;
    final m = Float64List(16)
      // Column-major: element (row, column) is at `column * 4 + row`.
      ..[0] = xAxis.x
      ..[4] = yAxis.x
      ..[8] = zAxis.x
      ..[12] = origin?.x ?? 0
      ..[1] = xAxis.y
      ..[5] = yAxis.y
      ..[9] = zAxis.y
      ..[13] = origin?.y ?? 0
      ..[2] = -sign * kx / range
      ..[6] = -sign * ky / range
      ..[10] = -sign * kz / range
      ..[14] = -near / range
      ..[15] = 1;
    return Scene3DProjection._fromSceneToLocal(m, null);
  }

  /// The picture of a camera, mapped onto the local rectangle [rect].
  ///
  /// [viewMatrix] (world to view space, rigid) and [projectionMatrix] (view to
  /// clip space) follow the conventions of [CameraComponent3D]: x and y in
  /// `[-w, w]` with +y up, depth from 0 on the near plane to 1 on the far
  /// plane. The square `[-1, 1]²` of normalized device coordinates becomes
  /// [rect], so the projection's aspect ratio should be the one of [rect].
  factory Scene3DProjection.camera({
    required Matrix4 viewMatrix,
    required Matrix4 projectionMatrix,
    required Rect rect,
  }) {
    final view = Float64List.fromList(viewMatrix.storage);
    return Scene3DProjection._fromCamera(
      view,
      Float64List.fromList(projectionMatrix.storage),
      rect,
    );
  }

  /// A pinhole camera at [eye] looking at [target], with [up] (default +z)
  /// pointing up in the picture and a vertical field of view of [fovY]
  /// degrees, whose picture covers the local rectangle [rect].
  ///
  /// The depth runs from the [near] distance to the [far] distance from the
  /// eye (`0 < near < far`).
  factory Scene3DProjection.perspective({
    required Vector3 eye,
    required Vector3 target,
    required Rect rect,
    Vector3? up,
    double fovY = 60,
    double near = 0.1,
    double far = 1000,
  }) {
    if (!(0 < near && near < far)) {
      throw ArgumentError('A perspective needs 0 < near < far ($near, $far)');
    }
    if (rect.isEmpty) {
      throw ArgumentError.value(rect, 'rect', 'Must not be empty');
    }
    final upVector = up ?? Vector3(0, 0, 1);
    final view = Float64List(16);
    writeLookAt(
      view,
      eye.x,
      eye.y,
      eye.z,
      target.x,
      target.y,
      target.z,
      upVector.x,
      upVector.y,
      upVector.z,
    );
    final projection = Float64List(16);
    writePerspective(
      projection,
      fovY * degrees2Radians,
      rect.width / rect.height,
      near,
      far,
    );
    return Scene3DProjection._fromCamera(view, projection, rect);
  }

  /// A projection given by its [sceneToLocal] matrix, see
  /// [Scene3DProjection].
  ///
  /// [viewMatrix] is the rigid transform whose origin is the eye. When
  /// omitted it is derived from the matrix: the center of projection of a
  /// perspective matrix, or a point far away on the viewer's side (where the
  /// depth decreases) of an affine one.
  factory Scene3DProjection.matrix(
    Matrix4 sceneToLocal, {
    Matrix4? viewMatrix,
  }) {
    return Scene3DProjection._fromSceneToLocal(
      Float64List.fromList(sceneToLocal.storage),
      viewMatrix == null ? null : Float64List.fromList(viewMatrix.storage),
    );
  }

  factory Scene3DProjection._fromCamera(
    Float64List view,
    Float64List projection,
    Rect rect,
  ) {
    // Normalized device coordinates to local coordinates, y flipped.
    final halfWidth = rect.width / 2;
    final halfHeight = rect.height / 2;
    final centerX = rect.left + halfWidth;
    final centerY = rect.top + halfHeight;
    final viewToLocal = Float64List(16);
    for (var column = 0; column < 4; column++) {
      final i = column * 4;
      final x = projection[i];
      final y = projection[i + 1];
      final w = projection[i + 3];
      viewToLocal
        ..[i] = halfWidth * x + centerX * w
        ..[i + 1] = -halfHeight * y + centerY * w
        ..[i + 2] = projection[i + 2]
        ..[i + 3] = w;
    }
    final result = Scene3DProjection._(view, viewToLocal);
    result._checkInvertible();
    return result;
  }

  factory Scene3DProjection._fromSceneToLocal(
    Float64List sceneToLocal,
    Float64List? view,
  ) {
    final viewValues = view ?? _deriveView(sceneToLocal);
    final inverseView = Float64List(16);
    if (!invertMatrix(viewValues, inverseView)) {
      throw ArgumentError('The view matrix must be invertible');
    }
    final viewToLocal = Float64List(16);
    multiplyMatrices(sceneToLocal, inverseView, viewToLocal);
    final result = Scene3DProjection._(viewValues, viewToLocal);
    result._checkInvertible();
    return result;
  }

  /// `viewToLocal * view`, see [sceneToLocalMatrix].
  late final Float64List _sceneToLocal = () {
    final values = Float64List(16);
    multiplyMatrices(_viewToLocal, _view, values);
    return values;
  }();

  final Float64List _localToScene = Float64List(16);

  void _checkInvertible() {
    if (!invertMatrix(_sceneToLocal, _localToScene)) {
      throw ArgumentError(
        'The projection must be invertible: the depth must vary along the '
        'line of sight',
      );
    }
  }

  /// The matrix taking scene points to local homogeneous coordinates, see
  /// [Scene3DProjection].
  ///
  /// Returns a new matrix on every call.
  Matrix4 get sceneToLocalMatrix => Matrix4.fromList(_sceneToLocal);

  /// The rigid transform from the scene to the viewer's eye space, see
  /// [Scene3DProjection].
  ///
  /// Returns a new matrix on every call.
  Matrix4 get viewMatrix => Matrix4.fromList(_view);

  /// Whether the projection is affine (a parallel projection): `W` does not
  /// depend on the scene point.
  late final bool isAffine =
      _sceneToLocal[3] == 0 && _sceneToLocal[7] == 0 && _sceneToLocal[11] == 0;

  /// The scene-to-local matrix, column-major, see [sceneToLocalMatrix].
  @internal
  Float64List get sceneToLocalValues => _sceneToLocal;

  /// The scene-to-view matrix, column-major, see [viewMatrix].
  @internal
  Float64List get viewValues => _view;

  /// The view-to-local matrix, column-major: `sceneToLocal * view⁻¹`.
  @internal
  Float64List get viewToLocalValues => _viewToLocal;

  /// The local 2D point that the scene point [scenePoint] lands on.
  ///
  /// The result is written into [output] when given. A point on the eye
  /// plane of a perspective projection lands at infinity.
  Vector2 scenePointToLocal(Vector3 scenePoint, {Vector2? output}) {
    final m = _sceneToLocal;
    final x = scenePoint.x;
    final y = scenePoint.y;
    final z = scenePoint.z;
    final w = m[3] * x + m[7] * y + m[11] * z + m[15];
    return (output ?? Vector2.zero())..setValues(
      (m[0] * x + m[4] * y + m[8] * z + m[12]) / w,
      (m[1] * x + m[5] * y + m[9] * z + m[13]) / w,
    );
  }

  /// The depth of [scenePoint], from 0 on the near plane to 1 on the far
  /// plane.
  double depthOf(Vector3 scenePoint) {
    final m = _sceneToLocal;
    final x = scenePoint.x;
    final y = scenePoint.y;
    final z = scenePoint.z;
    final w = m[3] * x + m[7] * y + m[11] * z + m[15];
    return (m[2] * x + m[6] * y + m[10] * z + m[14]) / w;
  }

  /// The scene point that lands on the local point [localPoint] at [depth]
  /// (0 on the near plane, 1 on the far plane).
  ///
  /// The result is written into [output] when given.
  Vector3 localPointToScene(
    Vector2 localPoint, {
    double depth = 0,
    Vector3? output,
  }) {
    final m = _localToScene;
    final x = localPoint.x;
    final y = localPoint.y;
    final w = m[3] * x + m[7] * y + m[11] * depth + m[15];
    return (output ?? Vector3.zero())..setValues(
      (m[0] * x + m[4] * y + m[8] * depth + m[12]) / w,
      (m[1] * x + m[5] * y + m[9] * depth + m[13]) / w,
      (m[2] * x + m[6] * y + m[10] * depth + m[14]) / w,
    );
  }

  /// The ray of the scene points that land on the local point [localPoint].
  ///
  /// The ray starts on the near plane and its direction is unit length and
  /// points away from the viewer, so `ray.at(t)` lands on [localPoint] for
  /// every `t`. For an affine projection it is the line of sight through
  /// [localPoint]. The result is written into [output] when given.
  Ray localPointToRay(Vector2 localPoint, {Ray? output}) {
    final ray = output ?? Ray();
    final origin = localPointToScene(localPoint, output: ray.origin);
    final far = localPointToScene(localPoint, depth: 1, output: ray.direction);
    far
      ..sub(origin)
      ..normalize();
    return ray;
  }

  /// The unit direction of the lines that the linear part with rows
  /// `(x0, x1, x2)` and `(y0, y1, y2)` maps to single points.
  static (double, double, double) _lineOfSight(
    double x0,
    double x1,
    double x2,
    double y0,
    double y1,
    double y2,
  ) {
    final kx = x1 * y2 - x2 * y1;
    final ky = x2 * y0 - x0 * y2;
    final kz = x0 * y1 - x1 * y0;
    final length = math.sqrt(kx * kx + ky * ky + kz * kz);
    if (!(length > 0)) {
      throw ArgumentError(
        'The x and y rows of the projection must not be parallel',
      );
    }
    return (kx / length, ky / length, kz / length);
  }

  /// A view matrix whose eye suits the projection [m] (column-major).
  static Float64List _deriveView(Float64List m) {
    final view = Float64List(16);
    final affine = m[3] == 0 && m[7] == 0 && m[11] == 0;
    if (!affine) {
      // The eye is where X, Y and W all vanish.
      final eye = _solve3(
        m[0],
        m[4],
        m[8],
        m[1],
        m[5],
        m[9],
        m[3],
        m[7],
        m[11],
        -m[12],
        -m[13],
        -m[15],
      );
      view
        ..[0] = 1
        ..[5] = 1
        ..[10] = 1
        ..[15] = 1;
      if (eye != null) {
        view
          ..[12] = -eye.$1
          ..[13] = -eye.$2
          ..[14] = -eye.$3;
      }
      return view;
    }

    final w = m[15];
    var (kx, ky, kz) = _lineOfSight(m[0], m[4], m[8], m[1], m[5], m[9]);
    // Depth gradient along the line of sight: make it point to the viewer,
    // where the depth decreases.
    var slope = (m[2] * kx + m[6] * ky + m[10] * kz) / w;
    if (slope == 0) {
      throw ArgumentError('The depth must vary along the line of sight');
    }
    if (slope > 0) {
      kx = -kx;
      ky = -ky;
      kz = -kz;
      slope = -slope;
    }
    // The eye is on the line of sight through the scene's origin, where the
    // depth is -4: in front of the near plane by four depth ranges, far
    // enough for the lighting to look parallel. Its view axes put the line
    // of sight on the z axis, so that the large distance does not cost
    // precision in x and y.
    final distance = (4 + m[14] / w) / -slope;
    // Up: perpendicular to the line of sight and to the x row, pointing up
    // on screen (the y row decreases along it).
    var ux = ky * m[8] - kz * m[4];
    var uy = kz * m[0] - kx * m[8];
    var uz = kx * m[4] - ky * m[0];
    if (ux * m[1] + uy * m[5] + uz * m[9] > 0) {
      ux = -ux;
      uy = -uy;
      uz = -uz;
    }
    writeLookAt(
      view,
      kx * distance,
      ky * distance,
      kz * distance,
      kx * (distance - 1),
      ky * (distance - 1),
      kz * (distance - 1),
      ux,
      uy,
      uz,
    );
    return view;
  }

  /// Solves the 3x3 system with rows `(a, b, c)`, `(d, e, f)`, `(g, h, i)`
  /// and right-hand side `(r0, r1, r2)`, or returns null when it is singular.
  static (double, double, double)? _solve3(
    double a,
    double b,
    double c,
    double d,
    double e,
    double f,
    double g,
    double h,
    double i,
    double r0,
    double r1,
    double r2,
  ) {
    final det = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
    if (det.abs() < 1e-12) {
      return null;
    }
    final x =
        (r0 * (e * i - f * h) - b * (r1 * i - f * r2) + c * (r1 * h - e * r2)) /
        det;
    final y =
        (a * (r1 * i - f * r2) - r0 * (d * i - f * g) + c * (d * r2 - r1 * g)) /
        det;
    final z =
        (a * (e * r2 - r1 * h) - b * (d * r2 - r1 * g) + r0 * (d * h - e * g)) /
        det;
    return (x, y, z);
  }
}
