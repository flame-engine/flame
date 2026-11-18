import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/src/extensions/clip_space.dart';

/// {@template directional_shadow_projection}
/// The orthographic projection a directional light renders its shadow map
/// with, fitted to the region that receives shadows.
///
/// [update] fits it: the map covers the part of the receiving region that a
/// camera sees (or the whole region without a camera) as seen from the
/// light, and its depth range reaches from the farthest receiver back
/// towards the light over every caster, so that every object between the
/// light and the receivers casts its shadow.
///
/// The light's [view] is a rotation that looks along the light's direction
/// from the world origin; it does not follow the camera. With `stabilize`,
/// the width and height of the map only take values on a ladder of sizes
/// (about 9 % apart, kept while they still fit) and its edges are snapped to
/// whole texels of the light's view, so that as the camera moves, a point of
/// the world keeps landing on the same spot of a texel and the edges of the
/// shadows do not shimmer.
///
/// It keeps the size of the last fit, so use one per scene.
/// {@endtemplate}
class DirectionalShadowProjection() {
  /// The light's view matrix: from world space to the light's view space,
  /// which looks down its -z axis along the light's direction.
  final Matrix4 view = Matrix4.identity();

  /// The orthographic projection of the light's view-space box [left] to
  /// [right], [bottom] to [top], and [near] to [far] along the light, onto
  /// clip space (depth 0 at [near], 1 at [far]).
  final Matrix4 projection = Matrix4.identity();

  /// `projection * view`.
  final Matrix4 viewProjection = Matrix4.identity();

  /// The left edge of the map in the light's view space.
  double get left => _left;
  double _left = -1;

  /// The right edge of the map in the light's view space.
  double get right => _left + _width;

  /// The bottom edge of the map in the light's view space.
  double get bottom => _bottom;
  double _bottom = -1;

  /// The top edge of the map in the light's view space.
  double get top => _bottom + _height;

  /// The distance along the light, from the light's view origin, of depth 0.
  double get near => _near;
  double _near = 0;

  /// The distance along the light, from the light's view origin, of depth 1.
  double get far => _far;
  double _far = 1;

  /// The width of a texel of the map in world units.
  double get texelWidth => _width / _resolution;

  /// The height of a texel of the map in world units.
  double get texelHeight => _height / _resolution;

  double _width = 2;
  double _height = 2;
  int _resolution = 1;

  /// The ratio between two consecutive sizes of the ladder the width and the
  /// height of a stabilized map take.
  static final double sizeStep = math.pow(2, 1 / 8).toDouble();

  /// How much larger than needed a stabilized map may stay before it shrinks
  /// to a smaller size of the ladder.
  static const double sizeSlack = 1.3;

  /// Fits the projection and returns whether anything receives shadows.
  ///
  /// [direction] is the direction the light travels in (it need not be
  /// normalized). [casters] bounds every object that casts shadows (the
  /// bounds of the scene) and [receivers] the region that receives them
  /// (the same bounds by default). With a [cameraViewProjection] (a
  /// view-projection matrix whose clip space has the visible depth
  /// `0 <= z <= w`), only the part of the receivers it sees is covered,
  /// up to [maxDistance] from the camera along the direction it looks in
  /// when that is given, which needs the [cameraView] as well. [resolution]
  /// is the width and height of the map in texels.
  ///
  /// When nothing receives shadows (the camera sees none of the receivers),
  /// it returns `false` and leaves the projection unchanged.
  bool update({
    required Vector3 direction,
    required Aabb3 casters,
    required int resolution,
    Aabb3? receivers,
    Matrix4? cameraViewProjection,
    Matrix4? cameraView,
    double? maxDistance,
    bool stabilize = true,
  }) {
    writeLookAt(
      _view,
      0,
      0,
      0,
      direction.x,
      direction.y,
      direction.z,
      0,
      1,
      0,
    );

    _resetBounds();
    final region = receivers ?? casters;
    if (cameraViewProjection == null) {
      _addBoxCorners(region);
    } else if (!_addVisiblePart(
      region,
      cameraViewProjection,
      cameraView,
      maxDistance,
    )) {
      return false;
    }
    if (!(_maxX >= _minX && _maxY >= _minY)) {
      return false;
    }

    // Every caster between the light and the receivers: the depth range
    // starts at the nearest corner of the casters towards the light.
    var nearest = _minDepth;
    final cMin = casters.min;
    final cMax = casters.max;
    for (var corner = 0; corner < 8; corner++) {
      final depth = -_viewZ(
        corner & 1 == 0 ? cMin.x : cMax.x,
        corner & 2 == 0 ? cMin.y : cMax.y,
        corner & 4 == 0 ? cMin.z : cMax.z,
      );
      nearest = math.min(nearest, depth);
    }
    final depthRange = _maxDepth - nearest;
    final scale = math.max(
      depthRange,
      math.max(_maxX - _minX, _maxY - _minY),
    );
    final depthPad = scale * 1e-3 + 1e-6;
    _near = nearest - depthPad;
    _far = _maxDepth + depthPad;

    _resolution = resolution;
    final minimum = scale * 1e-6 + 1e-9;
    // The map must still cover the region once its edges are snapped down to
    // whole texels: one texel more than the region.
    final grow = resolution / (resolution - 1);
    final neededWidth = math.max(_maxX - _minX, minimum) * grow;
    final neededHeight = math.max(_maxY - _minY, minimum) * grow;
    if (stabilize) {
      _width = _ladderSize(neededWidth, _width);
      _height = _ladderSize(neededHeight, _height);
      final texelX = _width / resolution;
      final texelY = _height / resolution;
      _left = (_minX / texelX).floorToDouble() * texelX;
      _bottom = (_minY / texelY).floorToDouble() * texelY;
    } else {
      _width = neededWidth;
      _height = neededHeight;
      _left = _minX - (neededWidth - (_maxX - _minX)) / 2;
      _bottom = _minY - (neededHeight - (_maxY - _minY)) / 2;
    }

    writeOrthographic(
      _projection,
      _left,
      _left + _width,
      _bottom,
      _bottom + _height,
      _near,
      _far,
    );
    multiplyMatrices(_projection, _view, _viewProjection);
    view.storage.setAll(0, _view);
    projection.storage.setAll(0, _projection);
    viewProjection.storage.setAll(0, _viewProjection);
    return true;
  }

  /// The size of the ladder for a map that needs [needed], keeping
  /// [previous] while it fits and is at most [sizeSlack] times too large.
  static double _ladderSize(double needed, double previous) {
    if (previous >= needed && previous <= needed * sizeSlack) {
      return previous;
    }
    final steps = (math.log(needed) / math.log(sizeStep)).ceil();
    var size = math.pow(sizeStep, steps).toDouble();
    // Guard against rounding in the logarithm.
    while (size < needed) {
      size *= sizeStep;
    }
    return size;
  }

  // Working copies in double precision.
  final Float64List _view = Float64List(16);
  final Float64List _projection = Float64List(16);
  final Float64List _viewProjection = Float64List(16);
  final Float64List _camera = Float64List(16);
  final Float64List _inverseCamera = Float64List(16);
  final Float64List _cameraView = Float64List(16);

  // The bounds, in the light's view space, of the points that receive
  // shadows: x, y, and the depth along the light (-z).
  double _minX = 0;
  double _maxX = 0;
  double _minY = 0;
  double _maxY = 0;
  double _minDepth = 0;
  double _maxDepth = 0;

  void _resetBounds() {
    _minX = double.infinity;
    _minY = double.infinity;
    _minDepth = double.infinity;
    _maxX = double.negativeInfinity;
    _maxY = double.negativeInfinity;
    _maxDepth = double.negativeInfinity;
  }

  double _viewZ(double x, double y, double z) {
    final v = _view;
    return v[2] * x + v[6] * y + v[10] * z + v[14];
  }

  void _addPoint(double x, double y, double z) {
    final v = _view;
    final lx = v[0] * x + v[4] * y + v[8] * z + v[12];
    final ly = v[1] * x + v[5] * y + v[9] * z + v[13];
    final depth = -(v[2] * x + v[6] * y + v[10] * z + v[14]);
    _minX = math.min(_minX, lx);
    _maxX = math.max(_maxX, lx);
    _minY = math.min(_minY, ly);
    _maxY = math.max(_maxY, ly);
    _minDepth = math.min(_minDepth, depth);
    _maxDepth = math.max(_maxDepth, depth);
  }

  void _addBoxCorners(Aabb3 box) {
    final min = box.min;
    final max = box.max;
    for (var corner = 0; corner < 8; corner++) {
      _addPoint(
        corner & 1 == 0 ? min.x : max.x,
        corner & 2 == 0 ? min.y : max.y,
        corner & 4 == 0 ? min.z : max.z,
      );
    }
  }

  // The corners of the camera's frustum (x, y, z per corner, corner bits:
  // 1 right, 2 top, 4 far), and its planes (inside where
  // `a x + b y + c z + d >= 0`): left, right, bottom, top, near, far, and the
  // plane of the maximum distance.
  final Float64List _corners = Float64List(24);
  final Float64List _planes = Float64List(28);
  int _planeCount = 6;

  // The corners of the receiving box.
  final Float64List _boxCorners = Float64List(24);

  /// Adds the vertices of the intersection of [box] with the camera's
  /// frustum, and returns whether it is not empty.
  ///
  /// The vertices of the intersection of two convex polyhedra are the
  /// vertices of either that are inside the other, and the points where the
  /// edges of either cross the faces of the other: they are the ends of the
  /// edges of each clipped by the other.
  bool _addVisiblePart(
    Aabb3 box,
    Matrix4 cameraViewProjection,
    Matrix4? cameraView,
    double? maxDistance,
  ) {
    final m = _camera..setAll(0, cameraViewProjection.storage);
    if (!invertMatrix(m, _inverseCamera)) {
      _addBoxCorners(box);
      return true;
    }
    final inverse = _inverseCamera;
    final corners = _corners;
    for (var corner = 0; corner < 8; corner++) {
      final x = corner & 1 == 0 ? -1.0 : 1.0;
      final y = corner & 2 == 0 ? -1.0 : 1.0;
      final z = corner & 4 == 0 ? 0.0 : 1.0;
      final w = inverse[3] * x + inverse[7] * y + inverse[11] * z + inverse[15];
      corners[corner * 3] =
          (inverse[0] * x + inverse[4] * y + inverse[8] * z + inverse[12]) / w;
      corners[corner * 3 + 1] =
          (inverse[1] * x + inverse[5] * y + inverse[9] * z + inverse[13]) / w;
      corners[corner * 3 + 2] =
          (inverse[2] * x + inverse[6] * y + inverse[10] * z + inverse[14]) / w;
    }

    // Planes from the rows of the view-projection matrix: -w <= x <= w,
    // -w <= y <= w and 0 <= z <= w.
    final planes = _planes;
    for (var c = 0; c < 4; c++) {
      final x = m[c * 4];
      final y = m[c * 4 + 1];
      final z = m[c * 4 + 2];
      final w = m[c * 4 + 3];
      planes[c] = w + x;
      planes[4 + c] = w - x;
      planes[8 + c] = w + y;
      planes[12 + c] = w - y;
      planes[16 + c] = z;
      planes[20 + c] = w - z;
    }
    _planeCount = 6;

    if (maxDistance != null && cameraView != null && maxDistance.isFinite) {
      final v = _cameraView..setAll(0, cameraView.storage);
      // The camera looks down -z of its view: forward is minus the third row
      // of the rotation, and depth along it is -(view * p).z.
      planes[24] = v[2];
      planes[25] = v[6];
      planes[26] = v[10];
      planes[27] = v[14] + maxDistance;
      _planeCount = 7;
      // Cut the frustum's edges from near to far at that distance.
      for (var corner = 0; corner < 4; corner++) {
        final nearIndex = corner * 3;
        final farIndex = (corner + 4) * 3;
        final nx = corners[nearIndex];
        final ny = corners[nearIndex + 1];
        final nz = corners[nearIndex + 2];
        final fx = corners[farIndex];
        final fy = corners[farIndex + 1];
        final fz = corners[farIndex + 2];
        final nearValue = v[2] * nx + v[6] * ny + v[10] * nz + planes[27];
        final farValue = v[2] * fx + v[6] * fy + v[10] * fz + planes[27];
        if (farValue < 0 && nearValue > farValue) {
          final t = nearValue <= 0 ? 0.0 : nearValue / (nearValue - farValue);
          corners[farIndex] = nx + (fx - nx) * t;
          corners[farIndex + 1] = ny + (fy - ny) * t;
          corners[farIndex + 2] = nz + (fz - nz) * t;
        }
      }
    }

    final min = box.min;
    final max = box.max;
    final boxCorners = _boxCorners;
    for (var corner = 0; corner < 8; corner++) {
      boxCorners[corner * 3] = corner & 1 == 0 ? min.x : max.x;
      boxCorners[corner * 3 + 1] = corner & 2 == 0 ? min.y : max.y;
      boxCorners[corner * 3 + 2] = corner & 4 == 0 ? min.z : max.z;
    }

    var any = false;
    for (var a = 0; a < 8; a++) {
      for (var bit = 1; bit < 8; bit <<= 1) {
        if (a & bit != 0) {
          continue;
        }
        final b = a | bit;
        any = _clipToBox(corners, a, b, box) | any;
        any = _clipToFrustum(boxCorners, a, b) | any;
      }
    }
    return any;
  }

  /// Clips the segment between the points [a] and [b] of [points] to [box]
  /// and adds the ends of what is left; returns whether anything is left.
  bool _clipToBox(Float64List points, int a, int b, Aabb3 box) {
    final ax = points[a * 3];
    final ay = points[a * 3 + 1];
    final az = points[a * 3 + 2];
    final dx = points[b * 3] - ax;
    final dy = points[b * 3 + 1] - ay;
    final dz = points[b * 3 + 2] - az;
    _t0 = 0;
    _t1 = 1;
    final min = box.min;
    final max = box.max;
    if (!_clipSlab(ax, dx, min.x, max.x) ||
        !_clipSlab(ay, dy, min.y, max.y) ||
        !_clipSlab(az, dz, min.z, max.z)) {
      return false;
    }
    final t0 = _t0;
    final t1 = _t1;
    _addPoint(ax + dx * t0, ay + dy * t0, az + dz * t0);
    _addPoint(ax + dx * t1, ay + dy * t1, az + dz * t1);
    return true;
  }

  // The part of the segment being clipped that is left.
  double _t0 = 0;
  double _t1 = 1;

  /// Clips the segment `start + t * delta` (along one axis) to the slab from
  /// [low] to [high]; returns whether anything is left.
  bool _clipSlab(double start, double delta, double low, double high) {
    if (delta.abs() < 1e-300) {
      return start >= low && start <= high;
    }
    var tLow = (low - start) / delta;
    var tHigh = (high - start) / delta;
    if (tLow > tHigh) {
      final swap = tLow;
      tLow = tHigh;
      tHigh = swap;
    }
    _t0 = math.max(_t0, tLow);
    _t1 = math.min(_t1, tHigh);
    return _t0 <= _t1;
  }

  /// Clips the segment between the points [a] and [b] of [points] to the
  /// camera's frustum and adds the ends of what is left; returns whether
  /// anything is left.
  bool _clipToFrustum(Float64List points, int a, int b) {
    final ax = points[a * 3];
    final ay = points[a * 3 + 1];
    final az = points[a * 3 + 2];
    final dx = points[b * 3] - ax;
    final dy = points[b * 3 + 1] - ay;
    final dz = points[b * 3 + 2] - az;
    var t0 = 0.0;
    var t1 = 1.0;
    final planes = _planes;
    for (var i = 0; i < _planeCount; i++) {
      final p = i * 4;
      final start =
          planes[p] * ax +
          planes[p + 1] * ay +
          planes[p + 2] * az +
          planes[p + 3];
      final delta = planes[p] * dx + planes[p + 1] * dy + planes[p + 2] * dz;
      if (delta.abs() < 1e-300) {
        if (start < 0) {
          return false;
        }
        continue;
      }
      final t = -start / delta;
      if (delta > 0) {
        t0 = math.max(t0, t);
      } else {
        t1 = math.min(t1, t);
      }
      if (t0 > t1) {
        return false;
      }
    }
    _addPoint(ax + dx * t0, ay + dy * t0, az + dz * t0);
    _addPoint(ax + dx * t1, ay + dy * t1, az + dz * t1);
    return true;
  }
}
