import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color, Rect;

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// Draws `N` depth-buffered HD-2D sprites, standees, foliage cards, or world
/// icons in a single instanced GPU draw call using [BillboardMaterial3D].
class BillboardBatch3D({
  BillboardMaterial3D? material,
  int initialCapacity = 32,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Object3D {
  this : super(castsShadows: false) {
    _capacity = math.max(1, initialCapacity);
    _instances = Float32List(_capacity * _stride);
  }

  final BillboardMaterial3D material = material ?? BillboardMaterial3D();

  static const int _stride = VertexLayout.instanceStrideInFloats;

  static final Surface _unitQuad = Surface.fromBuffers(
    vertices: Float32List.fromList(const [
      -0.5, -0.5, 0.0, 0.0, 1.0, //
      0.5, -0.5, 0.0, 1.0, 1.0, //
      0.5, 0.5, 0.0, 1.0, 0.0, //
      -0.5, 0.5, 0.0, 0.0, 0.0, //
    ]),
    indices: Uint16List.fromList(const [0, 1, 2, 0, 2, 3]),
    layout: VertexLayout(const [
      VertexAttribute(VertexLayout.positionAttribute, 3),
      VertexAttribute('vertexTexCoord', 2),
    ]),
  );

  int _capacity = 32;
  int _length = 0;
  late Float32List _instances;
  final Aabb3 _localAabb = Aabb3();
  bool _boundsDirty = true;

  int get length => _length;
  bool get isEmpty => _length == 0;

  void clear() {
    if (_length == 0) {
      return;
    }
    _length = 0;
    _boundsDirty = true;
    markAabbDirty();
    worldOrNull?.markSceneDirty(shadows: false);
  }

  /// Appends a billboard / standee and returns its slot index.
  ///
  /// [anchorY] controls the vertical pivot (`0.0` = centered, `-0.5` = grounded
  /// at the bottom edge of the sprite).
  int addBillboard({
    required Vector3 position,
    required double width,
    required double height,
    BillboardOrientation3D orientation = BillboardOrientation3D.cylindrical,
    Vector3? upAxis,
    double anchorY = -0.5,
    double tiltRadians = 0.0,
    double rollRadians = 0.0,
    Rect uvRect = const Rect.fromLTWH(0, 0, 1, 1),
    Color color = const Color(0xFFFFFFFF),
    double emissiveBoost = 0.0,
    double unlit = 0.0,
    double fade = 0.0,
  }) {
    final idx = _length;
    if (idx == _capacity) {
      final next = _capacity * 2;
      _instances = Float32List(next * _stride)..setAll(0, _instances);
      _capacity = next;
    }
    _length++;
    _writeSlot(
      idx,
      position: position,
      width: width,
      height: height,
      orientation: orientation,
      upAxis: upAxis ?? Vector3(0, 1, 0),
      anchorY: anchorY,
      tiltRadians: tiltRadians,
      rollRadians: rollRadians,
      uvRect: uvRect,
      color: color,
      emissiveBoost: emissiveBoost,
      unlit: unlit,
      fade: fade,
    );
    _boundsDirty = true;
    markAabbDirty();
    worldOrNull?.markSceneDirty(shadows: false);
    return idx;
  }

  /// Updates an existing billboard at [index] in place.
  void setBillboard(
    int index, {
    required Vector3 position,
    required double width,
    required double height,
    BillboardOrientation3D orientation = BillboardOrientation3D.cylindrical,
    Vector3? upAxis,
    double anchorY = -0.5,
    double tiltRadians = 0.0,
    double rollRadians = 0.0,
    Rect uvRect = const Rect.fromLTWH(0, 0, 1, 1),
    Color color = const Color(0xFFFFFFFF),
    double emissiveBoost = 0.0,
    double unlit = 0.0,
    double fade = 0.0,
  }) {
    RangeError.checkValidIndex(index, this, 'index', _length);
    _writeSlot(
      index,
      position: position,
      width: width,
      height: height,
      orientation: orientation,
      upAxis: upAxis ?? Vector3(0, 1, 0),
      anchorY: anchorY,
      tiltRadians: tiltRadians,
      rollRadians: rollRadians,
      uvRect: uvRect,
      color: color,
      emissiveBoost: emissiveBoost,
      unlit: unlit,
      fade: fade,
    );
    _boundsDirty = true;
    markAabbDirty();
    worldOrNull?.markSceneDirty(shadows: false);
  }

  void _writeSlot(
    int index, {
    required Vector3 position,
    required double width,
    required double height,
    required BillboardOrientation3D orientation,
    required Vector3 upAxis,
    required double anchorY,
    required double tiltRadians,
    required double rollRadians,
    required Rect uvRect,
    required Color color,
    required double emissiveBoost,
    required double unlit,
    required double fade,
  }) {
    final b = index * _stride;
    _instances
      ..[b] = position.x
      ..[b + 1] = position.y
      ..[b + 2] = position.z
      ..[b + 3] = width
      ..[b + 4] = upAxis.x
      ..[b + 5] = upAxis.y
      ..[b + 6] = upAxis.z
      ..[b + 7] = height
      ..[b + 8] = uvRect.left
      ..[b + 9] = uvRect.top
      ..[b + 10] = uvRect.width
      ..[b + 11] = uvRect.height
      ..[b + 12] = anchorY
      ..[b + 13] = tiltRadians
      ..[b + 14] = rollRadians
      ..[b + 15] = orientation.index.toDouble()
      ..[b + 16] = color.r
      ..[b + 17] = color.g
      ..[b + 18] = color.b
      ..[b + 19] = color.a
      ..[b + 20] = emissiveBoost
      ..[b + 21] = unlit
      ..[b + 22] = fade
      ..[b + 23] = 0.0;
  }

  @override
  Aabb3? computeLocalAabb() {
    if (_length == 0) {
      return null;
    }
    if (_boundsDirty) {
      _boundsDirty = false;
      var minX = double.infinity;
      var minY = double.infinity;
      var minZ = double.infinity;
      var maxX = double.negativeInfinity;
      var maxY = double.negativeInfinity;
      var maxZ = double.negativeInfinity;
      for (var i = 0; i < _length; i++) {
        final b = i * _stride;
        final cx = _instances[b];
        final cy = _instances[b + 1];
        final cz = _instances[b + 2];
        final r = math.max(_instances[b + 3], _instances[b + 7]);
        if (cx - r < minX) {
          minX = cx - r;
        }
        if (cy - r < minY) {
          minY = cy - r;
        }
        if (cz - r < minZ) {
          minZ = cz - r;
        }
        if (cx + r > maxX) {
          maxX = cx + r;
        }
        if (cy + r > maxY) {
          maxY = cy + r;
        }
        if (cz + r > maxZ) {
          maxZ = cz + r;
        }
      }
      _localAabb.min.setValues(minX, minY, minZ);
      _localAabb.max.setValues(maxX, maxY, maxZ);
    }
    return _localAabb;
  }

  final Vector3 _sortCenter = Vector3.zero();

  @override
  void draw(covariant RenderContext3D context) {
    if (_length == 0 || context.isShadowPass) {
      return;
    }
    final box = computeLocalAabb()!;
    _sortCenter
      ..setFrom(box.min)
      ..add(box.max)
      ..scale(0.5);
    context.drawInstances(
      _unitQuad,
      instances: _instances,
      count: _length,
      material: material,
      center: _sortCenter,
    );
  }
}
