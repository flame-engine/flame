import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/src/extensions/clip_space.dart';

/// The projection a [CameraComponent3D] builds when it has no
/// [CameraComponent3D.customProjectionMatrix].
enum CameraProjection() {
  /// A pinhole camera with a vertical field of view of
  /// [CameraComponent3D.fovY] degrees.
  perspective,

  /// A parallel projection of a view volume
  /// [CameraComponent3D.orthographicHeight] world units tall.
  orthographic,
}

/// {@template camera_component_3d}
/// [CameraComponent3D] is a component through which a [World3D] is observed.
///
/// The view is a look-at transform from [position] towards [target] with [up]
/// pointing up on screen, unless a [customViewMatrix] replaces it. The
/// projection is the [projection] mode built from [fovY] or
/// [orthographicHeight], [near], [far] and the viewport's aspect ratio, unless
/// a [customProjectionMatrix] replaces it.
///
/// ## Clip space
///
/// The projections map view space to the clip space of Impeller and WebGPU:
/// x and y in `[-w, w]` with +y up, and the visible depth `0 <= z <= w`, with
/// the near plane at depth 0 and the far plane at depth 1. Everything between
/// [near] and [far] is kept, in both projection modes. View space is
/// right-handed: the camera looks down -z with +x to the right and +y up.
///
/// ## Caching
///
/// [viewMatrix], [projectionMatrix], [viewProjectionMatrix],
/// [inverseViewMatrix], [eyePosition] and [frustum] are computed when first
/// read after one of their inputs changed and cached until the next change;
/// reading them allocates nothing. The camera compares its inputs by value on
/// each read, so changes made in place (`camera.position.x += 1`,
/// `camera.target.setFrom(...)`, editing a custom matrix) are picked up as
/// well as assignments. [version] increases whenever an input changes, so a
/// consumer can keep derived data until the version differs.
///
/// The returned matrices, vector and frustum are the camera's own objects,
/// updated in place: copy them to keep a value. The matrices and the vector
/// are rewritten on every read, so changing them has no lasting effect; the
/// frustum is only rewritten when it changes, so never modify it.
///
/// ## Custom matrices
///
/// A [customViewMatrix] or [customProjectionMatrix] (or both) supports any
/// affine view and any projection into the clip space above: oblique,
/// dimetric, off-center, or mirrored ones that no look-at camera produces.
/// The cached matrices, [frustum], [eyePosition], [version] and the
/// conversions between viewport points and world space all follow them.
///
/// ## Winding
///
/// A mirroring matrix, such as a view that swaps two world axes, reverses the
/// winding of every triangle on screen. For the camera's own matrices the
/// determinant of `projectionMatrix * viewMatrix` is negative, both for its
/// upper-left 3x3 part and for the full 4x4 matrix; when it is positive the
/// picture is mirrored and counter-clockwise front faces appear clockwise.
/// The full 4x4 determinant is the exact test for any projection (its sign is
/// the orientation of the projective map at every point); the 3x3 part agrees
/// with it for affine (orthographic, oblique) projections and for perspective
/// ones with a positive near distance. A custom projection must keep the depth
/// direction (near at depth 0, far at depth 1, `w > 0` in front of the eye)
/// for the test to hold.
/// {@endtemplate}
class CameraComponent3D({
  double fovY = 60,
  double? orthographicHeight,
  double near = distanceNear,
  double far = distanceFar,
  Vector3? position,
  Quaternion? rotation,
  Vector3? target,
  Vector3? up,
  CameraProjection projection = CameraProjection.perspective,
  Matrix4? customViewMatrix,
  Matrix4? customProjectionMatrix,
  var int cameraMask = 0xFFFFFFFF,
  World3D? super.world,
  super.viewport,
  super.viewfinder,
  super.backdrop,
  super.hudComponents,
}) extends CameraComponent {
  /// {@macro camera_component_3d}
  this {
    _readLookAt();
    if (_customViewMatrix case final matrix?) {
      _readMatrix(matrix, _customViewSeen);
    }
    if (_customProjectionMatrix case final matrix?) {
      _readMatrix(matrix, _customProjectionSeen);
    }
    final size = viewport.virtualSize;
    _viewportWidth = size.x;
    _viewportHeight = size.y;
  }

  @override
  World3D? get world => super.world as World3D?;

  @override
  set world(covariant World3D? world) => super.world = world;

  /// The position of the camera in 3D space, often referred to as the "eye",
  /// used by the look-at view.
  ///
  /// Ignored while a [customViewMatrix] is set; [eyePosition] is the eye of
  /// whichever view is in use.
  Vector3 position = position?.clone() ?? Vector3.zero();

  /// The target in 3D space that the camera is looking at.
  ///
  /// Ignored while a [customViewMatrix] is set.
  Vector3 target = target?.clone() ?? Vector3(0, 0, -1);

  /// The vector from [position] to [target] (not normalized).
  ///
  /// Describes the look-at inputs and allocates a new vector on every call.
  Vector3 get forward => target - position;

  /// `forward × up`, pointing to the right of the look-at view (not
  /// normalized).
  ///
  /// Allocates a new vector on every call.
  Vector3 get right => forward.cross(up);

  /// The up direction of the look-at view.
  ///
  /// The setter stores a normalized copy. The returned vector is the camera's
  /// own: changing it in place changes the view, and it does not need to stay
  /// unit length. Ignored while a [customViewMatrix] is set.
  Vector3 get up => _up;
  set up(Vector3 up) => _up
    ..setFrom(up)
    ..normalize();
  final Vector3 _up = (up?.clone() ?? Vector3(0, 1, 0))..normalize();

  /// The rotation of the camera.
  ///
  /// Not an input of the view: subclasses such as [FirstPersonCamera] and
  /// [ThirdPersonCamera] use it to place [position] and [target].
  Quaternion rotation = rotation ?? Quaternion.identity();

  /// The vertical field of view in degrees of the
  /// [CameraProjection.perspective] projection.
  ///
  /// In the [CameraProjection.orthographic] projection it is only used as the
  /// view volume's height while [orthographicHeight] is null, as earlier
  /// versions did; set [orthographicHeight] instead, that fallback will be
  /// removed.
  double get fovY => _fovY;
  set fovY(double value) {
    if (value == _fovY) {
      return;
    }
    _fovY = value;
    if (_projection == CameraProjection.perspective ||
        _orthographicHeight == null) {
      _builtInProjectionChanged();
    }
  }

  double _fovY = fovY;

  /// The full vertical extent, in world units, of the view volume of the
  /// [CameraProjection.orthographic] projection; its width is this times the
  /// viewport's aspect ratio.
  ///
  /// One world unit covers `viewport.virtualSize.y / orthographicHeight`
  /// logical pixels. When null, [fovY] is used instead (deprecated).
  double? get orthographicHeight => _orthographicHeight;
  set orthographicHeight(double? value) {
    if (value == _orthographicHeight) {
      return;
    }
    final changesHeight = (value ?? _fovY) != (_orthographicHeight ?? _fovY);
    _orthographicHeight = value;
    if (changesHeight && _projection == CameraProjection.orthographic) {
      _builtInProjectionChanged();
    }
  }

  double? _orthographicHeight = orthographicHeight;

  /// The distance from the eye to the near clipping plane, along the view
  /// direction. Defaults to [distanceNear].
  ///
  /// Must be positive for the [CameraProjection.perspective] projection. The
  /// [CameraProjection.orthographic] projection also accepts zero or negative
  /// values, which keep geometry behind the eye.
  double get near => _near;
  set near(double value) {
    if (value == _near) {
      return;
    }
    _near = value;
    _builtInProjectionChanged();
  }

  double _near = near;

  /// The distance from the eye to the far clipping plane, along the view
  /// direction; greater than [near]. Defaults to [distanceFar].
  double get far => _far;
  set far(double value) {
    if (value == _far) {
      return;
    }
    _far = value;
    _builtInProjectionChanged();
  }

  double _far = far;

  /// The current camera projection.
  ///
  /// Ignored while a [customProjectionMatrix] is set.
  CameraProjection get projection => _projection;
  set projection(CameraProjection value) {
    if (value == _projection) {
      return;
    }
    _projection = value;
    _builtInProjectionChanged();
  }

  CameraProjection _projection = projection;

  /// A view matrix (world to view space) used instead of the look-at view of
  /// [position], [target] and [up], or null for the look-at view.
  ///
  /// Any invertible affine matrix works, including mirrored ones. The camera
  /// keeps a reference and follows changes made to the matrix in place.
  Matrix4? get customViewMatrix => _customViewMatrix;
  set customViewMatrix(Matrix4? value) {
    if (identical(value, _customViewMatrix) &&
        (value == null || !_matrixChanged(value, _customViewSeen))) {
      return;
    }
    _customViewMatrix = value;
    if (value == null) {
      _readLookAt();
    } else {
      _readMatrix(value, _customViewSeen);
    }
    _invalidateView();
  }

  Matrix4? _customViewMatrix = customViewMatrix;

  /// A projection matrix (view to clip space) used instead of the built-in
  /// [projection], or null for the built-in one.
  ///
  /// It must target the clip space described on [CameraComponent3D]: x and y
  /// in `[-w, w]` with +y up, depth `0 <= z <= w` from near to far. [fovY],
  /// [orthographicHeight], [near], [far] and the viewport's aspect ratio do
  /// not apply to it. The camera keeps a reference and follows changes made
  /// to the matrix in place.
  Matrix4? get customProjectionMatrix => _customProjectionMatrix;
  set customProjectionMatrix(Matrix4? value) {
    if (identical(value, _customProjectionMatrix) &&
        (value == null || !_matrixChanged(value, _customProjectionSeen))) {
      return;
    }
    _customProjectionMatrix = value;
    if (value != null) {
      _readMatrix(value, _customProjectionSeen);
    }
    _invalidateProjection();
  }

  Matrix4? _customProjectionMatrix = customProjectionMatrix;

  /// Increases whenever an input of the view or the projection changes: the
  /// look-at inputs, the projection settings, the custom matrices or the
  /// viewport size. Inputs that the current matrices do not use (for example
  /// [position] while a [customViewMatrix] is set) do not count.
  ///
  /// Starts at 0. Compare it with a value read earlier to know whether
  /// anything derived from the camera is stale.
  int get version {
    _sync();
    return _version;
  }

  int _version = 0;

  /// How many times a cached matrix, the eye position or the frustum was
  /// recomputed, for profiling and tests.
  int get matrixUpdateCount => _matrixUpdateCount;
  int _matrixUpdateCount = 0;

  /// The view matrix of the camera (world to view space), without any
  /// projection applied on it.
  Matrix4 get viewMatrix {
    _sync();
    _ensureView();
    return _copyToMatrix(_view, _viewMatrix);
  }

  final Matrix4 _viewMatrix = Matrix4.zero();

  /// The projection matrix of the camera (view to clip space).
  Matrix4 get projectionMatrix {
    _sync();
    _ensureProjection();
    return _copyToMatrix(_projectionValues, _projectionMatrix);
  }

  final Matrix4 _projectionMatrix = Matrix4.zero();

  /// The view projection matrix used for rendering:
  /// `projectionMatrix * viewMatrix`.
  Matrix4 get viewProjectionMatrix {
    _sync();
    _ensureViewProjection();
    return _copyToMatrix(_viewProjection, _viewProjectionMatrix);
  }

  final Matrix4 _viewProjectionMatrix = Matrix4.zero();

  /// The inverse of the [viewMatrix] (view to world space): its columns are
  /// the camera's right, up and backward axes and the [eyePosition].
  Matrix4 get inverseViewMatrix {
    _sync();
    _ensureInverseView();
    return _copyToMatrix(_inverseView, _inverseViewMatrix);
  }

  final Matrix4 _inverseViewMatrix = Matrix4.zero();

  /// The world-space position of the view-space origin: [position] for the
  /// look-at view, or derived from the [customViewMatrix].
  ///
  /// It is the center of projection of a perspective projection; [near] and
  /// [far] are measured from it along the view direction.
  Vector3 get eyePosition {
    _sync();
    _ensureInverseView();
    return _eyePosition..setValues(
      _inverseView[12],
      _inverseView[13],
      _inverseView[14],
    );
  }

  final Vector3 _eyePosition = Vector3.zero();

  /// The frustum of the [viewProjectionMatrix], with the near plane at depth
  /// 0 and the far plane at depth 1.
  Frustum get frustum {
    _sync();
    _ensureFrustum();
    return _frustum;
  }

  final Frustum _frustum = Frustum();

  /// Converts a point of the viewport into the world-space ray through it.
  ///
  /// [viewportPoint] is in the viewport's own coordinates (logical pixels
  /// unless the viewport scales its content), with (0, 0) at its top-left
  /// corner and `viewport.virtualSize` at its bottom-right corner. [World3D]
  /// draws the scene over exactly that area while the [viewfinder] keeps its
  /// default framing (center anchor at the origin, zoom 1, no rotation). For
  /// a viewport that fills the game this is the `canvasPosition` of a Flame
  /// pointer event; otherwise convert it with
  /// `viewport.globalToLocal(event.canvasPosition)`.
  ///
  /// The ray starts on the near plane and its direction is unit length and
  /// points away from the eye. Works for both projections and for custom
  /// matrices, as long as `projectionMatrix * viewMatrix` is invertible and
  /// the viewport has a size. The result is written into [output] when given.
  Ray viewportPointToRay(Vector2 viewportPoint, {Ray? output}) {
    _sync();
    _ensureInverseViewProjection();
    final ndcX = 2 * viewportPoint.x / _viewportWidth - 1;
    final ndcY = 1 - 2 * viewportPoint.y / _viewportHeight;

    // Unproject (ndcX, ndcY, 0, 1) and (ndcX, ndcY, 1, 1).
    final m = _inverseViewProjection;
    final nx = m[0] * ndcX + m[4] * ndcY + m[12];
    final ny = m[1] * ndcX + m[5] * ndcY + m[13];
    final nz = m[2] * ndcX + m[6] * ndcY + m[14];
    final nw = m[3] * ndcX + m[7] * ndcY + m[15];
    final fw = nw + m[11];
    final originX = nx / nw;
    final originY = ny / nw;
    final originZ = nz / nw;
    var dx = (nx + m[8]) / fw - originX;
    var dy = (ny + m[9]) / fw - originY;
    var dz = (nz + m[10]) / fw - originZ;
    final length = math.sqrt(dx * dx + dy * dy + dz * dz);
    dx /= length;
    dy /= length;
    dz /= length;

    final ray = output ?? Ray();
    ray.origin.setValues(originX, originY, originZ);
    ray.direction.setValues(dx, dy, dz);
    return ray;
  }

  /// Projects a world-space point to the viewport point it is drawn at, in
  /// the coordinates [viewportPointToRay] takes.
  ///
  /// The point does not need to be inside the [frustum]; a point behind the
  /// eye of a perspective projection yields a meaningless (mirrored) result,
  /// and one on the eye plane an infinite one. The result is written into
  /// [output] when given.
  Vector2 worldToViewportPoint(Vector3 worldPoint, {Vector2? output}) {
    _sync();
    _ensureViewProjection();
    final m = _viewProjection;
    final x = worldPoint.x;
    final y = worldPoint.y;
    final z = worldPoint.z;
    final w = m[3] * x + m[7] * y + m[11] * z + m[15];
    final ndcX = (m[0] * x + m[4] * y + m[8] * z + m[12]) / w;
    final ndcY = (m[1] * x + m[5] * y + m[9] * z + m[13]) / w;
    return (output ?? Vector2.zero())..setValues(
      (ndcX + 1) * 0.5 * _viewportWidth,
      (1 - ndcY) * 0.5 * _viewportHeight,
    );
  }

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

  /// The default [near] distance.
  static const distanceNear = 0.01;

  /// The default [far] distance.
  static const distanceFar = 1000.0;

  // Double-precision working copies, column-major like Matrix4.storage. The
  // public Matrix4s are refreshed from them on every read, so a caller that
  // modifies a returned matrix cannot corrupt the cache.
  final Float64List _view = Float64List(16);
  final Float64List _projectionValues = Float64List(16);
  final Float64List _viewProjection = Float64List(16);
  final Float64List _inverseView = Float64List(16);
  final Float64List _inverseViewProjection = Float64List(16);

  bool _viewDirty = true;
  bool _projectionDirty = true;
  bool _viewProjectionDirty = true;
  bool _inverseViewDirty = true;
  bool _inverseViewProjectionDirty = true;
  bool _frustumDirty = true;

  // The input values the cached matrices were built from.
  final Float64List _lookAtSeen = Float64List(9);
  final Float64List _customViewSeen = Float64List(16);
  final Float64List _customProjectionSeen = Float64List(16);
  double _viewportWidth = 0;
  double _viewportHeight = 0;

  /// Compares the inputs that are read by value with the values the cache was
  /// built from, and invalidates what they feed.
  void _sync() {
    if (_customViewMatrix case final matrix?) {
      if (_matrixChanged(matrix, _customViewSeen)) {
        _invalidateView();
      }
    } else if (_lookAtChanged()) {
      _invalidateView();
    }
    if (_customProjectionMatrix case final matrix?) {
      if (_matrixChanged(matrix, _customProjectionSeen)) {
        _invalidateProjection();
      }
    }
    final size = viewport.virtualSize;
    if (size.x != _viewportWidth || size.y != _viewportHeight) {
      _viewportWidth = size.x;
      _viewportHeight = size.y;
      _invalidateProjection();
    }
  }

  bool _lookAtChanged() {
    final seen = _lookAtSeen;
    final p = position;
    final t = target;
    final u = _up;
    if (p.x == seen[0] &&
        p.y == seen[1] &&
        p.z == seen[2] &&
        t.x == seen[3] &&
        t.y == seen[4] &&
        t.z == seen[5] &&
        u.x == seen[6] &&
        u.y == seen[7] &&
        u.z == seen[8]) {
      return false;
    }
    _readLookAt();
    return true;
  }

  void _readLookAt() {
    _lookAtSeen
      ..[0] = position.x
      ..[1] = position.y
      ..[2] = position.z
      ..[3] = target.x
      ..[4] = target.y
      ..[5] = target.z
      ..[6] = _up.x
      ..[7] = _up.y
      ..[8] = _up.z;
  }

  static bool _matrixChanged(Matrix4 matrix, Float64List seen) {
    final values = matrix.storage;
    for (var i = 0; i < 16; i++) {
      if (values[i] != seen[i]) {
        _readMatrix(matrix, seen);
        return true;
      }
    }
    return false;
  }

  static void _readMatrix(Matrix4 matrix, Float64List seen) {
    final values = matrix.storage;
    for (var i = 0; i < 16; i++) {
      seen[i] = values[i];
    }
  }

  void _invalidateView() {
    _viewDirty = true;
    _inverseViewDirty = true;
    _invalidateCombined();
  }

  void _invalidateProjection() {
    _projectionDirty = true;
    _invalidateCombined();
  }

  void _invalidateCombined() {
    _viewProjectionDirty = true;
    _inverseViewProjectionDirty = true;
    _frustumDirty = true;
    _version++;
  }

  void _builtInProjectionChanged() {
    if (_customProjectionMatrix == null) {
      _invalidateProjection();
    }
  }

  void _ensureView() {
    if (!_viewDirty) {
      return;
    }
    _viewDirty = false;
    _matrixUpdateCount++;
    if (_customViewMatrix == null) {
      final seen = _lookAtSeen;
      writeLookAt(
        _view,
        seen[0],
        seen[1],
        seen[2],
        seen[3],
        seen[4],
        seen[5],
        seen[6],
        seen[7],
        seen[8],
      );
    } else {
      _copy(_customViewSeen, _view);
    }
  }

  void _ensureProjection() {
    if (!_projectionDirty) {
      return;
    }
    _projectionDirty = false;
    _matrixUpdateCount++;
    if (_customProjectionMatrix != null) {
      _copy(_customProjectionSeen, _projectionValues);
      return;
    }
    final aspectRatio = _viewportWidth > 0 && _viewportHeight > 0
        ? _viewportWidth / _viewportHeight
        : 1.0;
    switch (_projection) {
      case CameraProjection.perspective:
        assert(
          0 < _near && _near < _far,
          'A perspective projection needs 0 < near < far '
          '(near: $_near, far: $_far).',
        );
        writePerspective(
          _projectionValues,
          _fovY * degrees2Radians,
          aspectRatio,
          _near,
          _far,
        );
      case CameraProjection.orthographic:
        assert(
          _near < _far,
          'An orthographic projection needs near < far '
          '(near: $_near, far: $_far).',
        );
        final top = (_orthographicHeight ?? _fovY) / 2;
        final right = top * aspectRatio;
        writeOrthographic(
          _projectionValues,
          -right,
          right,
          -top,
          top,
          _near,
          _far,
        );
    }
  }

  void _ensureViewProjection() {
    _ensureView();
    _ensureProjection();
    if (!_viewProjectionDirty) {
      return;
    }
    _viewProjectionDirty = false;
    _matrixUpdateCount++;
    multiplyMatrices(_projectionValues, _view, _viewProjection);
  }

  void _ensureInverseView() {
    _ensureView();
    if (!_inverseViewDirty) {
      return;
    }
    _inverseViewDirty = false;
    _matrixUpdateCount++;
    if (_customViewMatrix == null) {
      final seen = _lookAtSeen;
      writeRigidInverse(_view, seen[0], seen[1], seen[2], _inverseView);
    } else {
      invertMatrix(_view, _inverseView);
    }
  }

  void _ensureInverseViewProjection() {
    _ensureViewProjection();
    if (!_inverseViewProjectionDirty) {
      return;
    }
    _inverseViewProjectionDirty = false;
    _matrixUpdateCount++;
    invertMatrix(_viewProjection, _inverseViewProjection);
  }

  void _ensureFrustum() {
    _ensureViewProjection();
    if (!_frustumDirty) {
      return;
    }
    _frustumDirty = false;
    _matrixUpdateCount++;
    writeFrustumPlanes(_frustum, _viewProjection);
  }

  static Matrix4 _copyToMatrix(Float64List values, Matrix4 matrix) {
    final storage = matrix.storage;
    for (var i = 0; i < 16; i++) {
      storage[i] = values[i];
    }
    return matrix;
  }

  static void _copy(Float64List from, Float64List to) {
    for (var i = 0; i < 16; i++) {
      to[i] = from[i];
    }
  }
}
