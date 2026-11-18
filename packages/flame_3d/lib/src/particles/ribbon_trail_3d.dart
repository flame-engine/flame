import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';

/// {@template stroke_batch_3d}
/// Collects one or more 3D polylines (motion ribbons, laser beams, trajectory
/// arcs, liquid streaks) and draws all of their segments in **one instanced GPU
/// draw call** with smooth shared join tangents.
/// {@endtemplate}
class StrokeBatch3D({
  RibbonMaterial3D? material,
  int initialSegmentCapacity = 64,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Object3D {
  /// {@macro stroke_batch_3d}
  this : super(castsShadows: false) {
    if (initialSegmentCapacity < 1) {
      throw ArgumentError.value(
        initialSegmentCapacity,
        'initialSegmentCapacity',
        'Must be at least 1',
      );
    }
    _capacity = initialSegmentCapacity;
    _segments = Float32List(_capacity * _stride);
  }

  /// Material used to draw all segments of this batch.
  final RibbonMaterial3D material = material ?? RibbonMaterial3D();

  static const int _stride = VertexLayout.instanceStrideInFloats;

  static final Surface _segmentQuad = Surface.fromBuffers(
    vertices: Float32List.fromList(const [
      0.0, -1.0, 0.0, //
      1.0, -1.0, 0.0, //
      1.0, 1.0, 0.0, //
      0.0, 1.0, 0.0, //
    ]),
    indices: Uint16List.fromList(const [0, 1, 2, 0, 2, 3]),
    layout: VertexLayout(const [
      VertexAttribute(VertexLayout.positionAttribute, 3),
    ]),
  );

  int _capacity = 64;
  int _segmentCount = 0;
  late Float32List _segments;
  Float32List? _worldSegments;
  final Matrix4 _lastWorldMatrix = Matrix4.zero();
  int _localVersion = 0;
  int _transformedVersion = -1;

  final Aabb3 _bounds = Aabb3();
  final Vector3 _worldCenter = Vector3.zero();
  bool _hasBounds = false;

  Float64List _strokePoints = Float64List(64 * 5);
  int _strokePointCount = 0;
  Color _strokeColor = const Color(0xFFFFFFFF);

  /// Number of segments queued in this batch.
  int get segmentCount => _segmentCount;

  /// Whether no segments are queued.
  bool get isEmpty => _segmentCount == 0;

  /// Clears all queued segments without releasing memory.
  void clear() {
    if (_segmentCount == 0 && !_hasBounds) {
      return;
    }
    _segmentCount = 0;
    _hasBounds = false;
    _localVersion++;
    markAabbDirty();
    worldOrNull?.markSceneDirty(shadows: false);
  }

  /// Starts building a polyline of [color]; add vertices with [addPoint] and
  /// finalize with [endStroke].
  void beginStroke({Color color = const Color(0xFFFFFFFF)}) {
    _strokePointCount = 0;
    _strokeColor = color;
  }

  /// Appends a vertex at `(x, y, z)` with [halfWidth] and [opacity].
  void addPoint(
    double x,
    double y,
    double z, {
    required double halfWidth,
    double opacity = 1.0,
  }) {
    if ((_strokePointCount + 1) * 5 > _strokePoints.length) {
      final grown = Float64List(_strokePoints.length * 2)
        ..setRange(0, _strokePointCount * 5, _strokePoints);
      _strokePoints = grown;
    }
    final o = _strokePointCount * 5;
    _strokePoints
      ..[o] = x
      ..[o + 1] = y
      ..[o + 2] = z
      ..[o + 3] = halfWidth
      ..[o + 4] = opacity.clamp(0.0, 1.0);
    _strokePointCount++;
  }

  /// Finalizes the stroke started with [beginStroke], emitting `n - 1` joined
  /// segments.
  void endStroke() {
    final n = _strokePointCount;
    if (n < 2) {
      _strokePointCount = 0;
      return;
    }
    _emitPackedStroke(_strokePoints, n, _strokeColor);
    _strokePointCount = 0;
  }

  /// Appends a complete polyline of [points] in one call.
  void addPolyline(
    List<Vector3> points, {
    double width = 0.1,
    double endWidth = 0.0,
    Color color = const Color(0xFFFFFFFF),
    double startOpacity = 1.0,
    double endOpacity = 0.0,
  }) {
    if (points.length < 2) {
      return;
    }
    beginStroke(color: color);
    final last = points.length - 1;
    for (var i = 0; i <= last; i++) {
      final t = i / last;
      final p = points[i];
      addPoint(
        p.x,
        p.y,
        p.z,
        halfWidth: 0.5 * (width + (endWidth - width) * t),
        opacity: startOpacity + (endOpacity - startOpacity) * t,
      );
    }
    endStroke();
  }

  void _emitPackedStroke(Float64List pts, int n, Color color) {
    final segs = n - 1;
    if (_segmentCount + segs > _capacity) {
      var cap = _capacity;
      while (cap < _segmentCount + segs) {
        cap *= 2;
      }
      final next = Float32List(cap * _stride)
        ..setRange(0, _segmentCount * _stride, _segments);
      _segments = next;
      _capacity = cap;
      _worldSegments = null;
    }

    for (var i = 0; i < segs; i++) {
      final o0 = i * 5;
      final o1 = (i + 1) * 5;
      final x0 = pts[o0];
      final y0 = pts[o0 + 1];
      final z0 = pts[o0 + 2];
      final w0 = pts[o0 + 3];
      final a0 = pts[o0 + 4];

      final x1 = pts[o1];
      final y1 = pts[o1 + 1];
      final z1 = pts[o1 + 2];
      final w1 = pts[o1 + 3];
      final a1 = pts[o1 + 4];

      final pPrev = i > 0 ? (i - 1) * 5 : o0;
      final pNext = i + 2 < n ? (i + 2) * 5 : o1;
      var t0x = x1 - pts[pPrev];
      var t0y = y1 - pts[pPrev + 1];
      var t0z = z1 - pts[pPrev + 2];
      final l0 = math.sqrt(t0x * t0x + t0y * t0y + t0z * t0z);
      if (l0 > 1e-9) {
        t0x /= l0;
        t0y /= l0;
        t0z /= l0;
      }

      var t1x = pts[pNext] - x0;
      var t1y = pts[pNext + 1] - y0;
      var t1z = pts[pNext + 2] - z0;
      final l1 = math.sqrt(t1x * t1x + t1y * t1y + t1z * t1z);
      if (l1 > 1e-9) {
        t1x /= l1;
        t1y /= l1;
        t1z /= l1;
      }

      final pad = math.max(w0, w1);
      _expandBounds(x0, y0, z0, pad);
      _expandBounds(x1, y1, z1, pad);

      final b = (_segmentCount++) * _stride;
      _segments
        ..[b] = x0
        ..[b + 1] = y0
        ..[b + 2] = z0
        ..[b + 3] = w0
        ..[b + 4] = x1
        ..[b + 5] = y1
        ..[b + 6] = z1
        ..[b + 7] = w1
        ..[b + 8] = t0x
        ..[b + 9] = t0y
        ..[b + 10] = t0z
        ..[b + 11] = a0
        ..[b + 12] = t1x
        ..[b + 13] = t1y
        ..[b + 14] = t1z
        ..[b + 15] = a1
        ..[b + 16] = color.r
        ..[b + 17] = color.g
        ..[b + 18] = color.b
        ..[b + 19] = color.a
        ..[b + 20] = i / segs
        ..[b + 21] = (i + 1) / segs
        ..[b + 22] = 0.0
        ..[b + 23] = 0.0;
    }

    _localVersion++;
    markAabbDirty();
    worldOrNull?.markSceneDirty(shadows: false);
  }

  void _expandBounds(double x, double y, double z, double r) {
    if (!_hasBounds) {
      _hasBounds = true;
      _bounds
        ..min.setValues(x - r, y - r, z - r)
        ..max.setValues(x + r, y + r, z + r);
      return;
    }
    _bounds
      ..min.setValues(
        math.min(_bounds.min.x, x - r),
        math.min(_bounds.min.y, y - r),
        math.min(_bounds.min.z, z - r),
      )
      ..max.setValues(
        math.max(_bounds.max.x, x + r),
        math.max(_bounds.max.y, y + r),
        math.max(_bounds.max.z, z + r),
      );
  }

  @override
  Aabb3? computeLocalAabb() => _hasBounds ? _bounds : null;

  @override
  void draw(covariant RenderContext3D context) {
    if (_segmentCount == 0 || context.isShadowPass) {
      return;
    }
    final wb = aabb;
    _worldCenter.setValues(
      (wb.min.x + wb.max.x) * 0.5,
      (wb.min.y + wb.max.y) * 0.5,
      (wb.min.z + wb.max.z) * 0.5,
    );
    context.drawInstances(
      _segmentQuad,
      instances: _resolvedBuffer(),
      count: _segmentCount,
      material: material,
      center: _worldCenter,
    );
  }

  Float32List _resolvedBuffer() {
    final world = worldTransformMatrix;
    if (world.isIdentity()) {
      return _segments;
    }
    var out = _worldSegments;
    if (out == null || out.length < _segmentCount * _stride) {
      out = _worldSegments = Float32List(_capacity * _stride);
      _transformedVersion = -1;
    }
    if (_transformedVersion != _localVersion || _lastWorldMatrix != world) {
      _transformedVersion = _localVersion;
      _lastWorldMatrix.setFrom(world);
      final m = world.storage;
      final det =
          m[0] * (m[5] * m[10] - m[6] * m[9]) -
          m[4] * (m[1] * m[10] - m[2] * m[9]) +
          m[8] * (m[1] * m[6] - m[2] * m[5]);
      final vol = det.abs();
      final widthScale = vol == 1
          ? 1.0
          : (vol == 0 ? 0.0 : math.exp(math.log(vol) / 3));

      for (var i = 0; i < _segmentCount; i++) {
        final b = i * _stride;
        final x0 = _segments[b];
        final y0 = _segments[b + 1];
        final z0 = _segments[b + 2];
        out
          ..[b] = m[0] * x0 + m[4] * y0 + m[8] * z0 + m[12]
          ..[b + 1] = m[1] * x0 + m[5] * y0 + m[9] * z0 + m[13]
          ..[b + 2] = m[2] * x0 + m[6] * y0 + m[10] * z0 + m[14]
          ..[b + 3] = _segments[b + 3] * widthScale;

        final x1 = _segments[b + 4];
        final y1 = _segments[b + 5];
        final z1 = _segments[b + 6];
        out
          ..[b + 4] = m[0] * x1 + m[4] * y1 + m[8] * z1 + m[12]
          ..[b + 5] = m[1] * x1 + m[5] * y1 + m[9] * z1 + m[13]
          ..[b + 6] = m[2] * x1 + m[6] * y1 + m[10] * z1 + m[14]
          ..[b + 7] = _segments[b + 7] * widthScale;

        for (var tc = 8; tc <= 12; tc += 4) {
          final tx = _segments[b + tc];
          final ty = _segments[b + tc + 1];
          final tz = _segments[b + tc + 2];
          var wx = m[0] * tx + m[4] * ty + m[8] * tz;
          var wy = m[1] * tx + m[5] * ty + m[9] * tz;
          var wz = m[2] * tx + m[6] * ty + m[10] * tz;
          final wl = math.sqrt(wx * wx + wy * wy + wz * wz);
          if (wl > 1e-9) {
            wx /= wl;
            wy /= wl;
            wz /= wl;
          }
          out
            ..[b + tc] = wx
            ..[b + tc + 1] = wy
            ..[b + tc + 2] = wz
            ..[b + tc + 3] = _segments[b + tc + 3];
        }

        for (var k = 16; k < 24; k++) {
          out[b + k] = _segments[b + k];
        }
      }
    }
    return out;
  }
}

/// {@template ribbon_trail_3d}
/// Zero-allocation 3D motion ribbon that tracks its own world position (or an
/// explicit [target] component) over [lifetime] seconds, tapering width and
/// opacity over age and drawing the trail in one instanced GPU draw call.
/// {@endtemplate}
class RibbonTrail3D({
  RibbonMaterial3D? material,
  var Component3D? target,
  int maxPoints = 64,
  var double lifetime = 0.45,
  var double width = 0.16,
  var double minVertexDistance = 0.04,
  var Color color = const Color(0xFFFFFFFF),
  var bool emitting = true,
  ParticleCurve? widthOverLife,
  ParticleCurve? opacityOverLife,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Object3D {
  /// {@macro ribbon_trail_3d}
  this : super(castsShadows: false) {
    if (maxPoints < 2) {
      throw ArgumentError.value(maxPoints, 'maxPoints', 'Must be at least 2');
    }
    _maxPoints = maxPoints;
    _ring = Float64List(_maxPoints * 4);
  }

  final StrokeBatch3D _batch = StrokeBatch3D(
    material: material,
    initialSegmentCapacity: math.max(1, maxPoints),
  );

  /// Curve scaling [width] from `t = 0` (newest point) to `t = 1` (oldest).
  ParticleCurve widthOverLife = widthOverLife ?? ParticleCurve(1, 0);

  /// Curve scaling `color.a` from `t = 0` (newest point) to `t = 1` (oldest).
  ParticleCurve opacityOverLife = opacityOverLife ?? ParticleCurve(1, 0);

  late final int _maxPoints;
  late final Float64List _ring;
  int _head = 0;
  int _count = 0;

  final Aabb3 _localBounds = Aabb3();
  final Matrix4 _inverse = Matrix4.identity();

  /// Material used to render the ribbon.
  RibbonMaterial3D get material => _batch.material;

  /// Number of active trail samples (`0..maxPoints`).
  int get pointCount => _count;

  /// Clears the trail history immediately (useful when teleporting).
  void reset() {
    if (_count > 0) {
      GraphicsDevice.notifyVisualMutation();
    }
    _head = 0;
    _count = 0;
    _batch.clear();
    markAabbDirty();
    worldOrNull?.markSceneDirty(shadows: false);
  }

  /// Manually appends a world-space sample `(x, y, z)`.
  void addSample(double x, double y, double z) {
    if (_count == _maxPoints) {
      _head = (_head + 1) % _maxPoints;
      _count--;
    }
    final slot = (_head + _count) % _maxPoints;
    final o = slot * 4;
    _ring
      ..[o] = x
      ..[o + 1] = y
      ..[o + 2] = z
      ..[o + 3] = 0.0;
    _count++;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (dt <= 0) {
      return;
    }

    final hadPoints = _count >= 2;
    final maxAge = math.max(lifetime, 1e-4);
    var alive = _count;
    var h = _head;
    for (var i = 0; i < _count; i++) {
      final slot = (_head + i) % _maxPoints;
      final age = _ring[slot * 4 + 3] + dt;
      _ring[slot * 4 + 3] = age;
      if (age >= maxAge && slot == h) {
        h = (h + 1) % _maxPoints;
        alive--;
      }
    }
    _head = h;
    _count = alive;

    if (emitting) {
      final tracked =
          target ?? (parent is Component3D ? parent! as Component3D : this);
      final s = tracked.worldTransformMatrix.storage;
      final wx = s[12];
      final wy = s[13];
      final wz = s[14];

      if (_count == 0) {
        addSample(wx, wy, wz);
      } else {
        final newestSlot = (_head + _count - 1) % _maxPoints;
        final no = newestSlot * 4;
        final dx = wx - _ring[no];
        final dy = wy - _ring[no + 1];
        final dz = wz - _ring[no + 2];
        if (dx * dx + dy * dy + dz * dz >=
            minVertexDistance * minVertexDistance) {
          addSample(wx, wy, wz);
        }
      }
    }

    _rebuildSegments(maxAge);
    if (hadPoints || _count >= 2) {
      GraphicsDevice.notifyVisualMutation();
      worldOrNull?.markSceneDirty(shadows: false);
    }
  }

  void _rebuildSegments(double maxAge) {
    _batch.clear();
    if (_count < 2) {
      markAabbDirty();
      return;
    }

    _batch.beginStroke(color: color);
    for (var i = _count - 1; i >= 0; i--) {
      final slot = (_head + i) % _maxPoints;
      final o = slot * 4;
      final t = (_ring[o + 3] / maxAge).clamp(0.0, 1.0);
      final halfW = 0.5 * width * math.max(0.0, widthOverLife.transform(t));
      final alpha = opacityOverLife.transform(t).clamp(0.0, 1.0);
      _batch.addPoint(
        _ring[o],
        _ring[o + 1],
        _ring[o + 2],
        halfWidth: halfW,
        opacity: alpha,
      );
    }
    _batch.endStroke();
    markAabbDirty();
  }

  @override
  Aabb3? computeLocalAabb() {
    final worldBox = _batch.computeLocalAabb();
    if (worldBox == null) {
      return null;
    }
    final world = worldTransformMatrix;
    if (world.isIdentity()) {
      return worldBox;
    }
    final det = _inverse.copyInverse(world);
    if (det == 0) {
      return null;
    }
    return _localBounds
      ..setFrom(worldBox)
      ..transform(_inverse);
  }

  @override
  void draw(covariant RenderContext3D context) {
    _batch.draw(context);
  }
}
