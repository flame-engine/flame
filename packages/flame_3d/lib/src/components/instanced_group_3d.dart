import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template instanced_group_3d}
/// Draws many instances of one [Mesh] in a single `O(1)` submission per
/// [Surface] without creating a child component per instance.
///
/// Transforms, per-instance colors, and per-instance `Vector4` data live in a
/// contiguous `Float32List` (`24` floats per instance) handed straight to
/// [RenderContext3D.drawInstances] (including during shadow passes).
/// {@endtemplate}
class InstancedGroup3D({
  required final Mesh mesh,
  int initialCapacity = 16,
  super.position,
  super.scale,
  super.rotation,
  super.children,
  super.castsShadows,
}) extends Object3D {
  /// {@macro instanced_group_3d}
  this {
    if (initialCapacity < 1) {
      throw ArgumentError.value(
        initialCapacity,
        'initialCapacity',
        'Must be at least 1',
      );
    }
    _capacity = initialCapacity;
    _instances = Float32List(_capacity * _stride);
  }

  static const int _stride = VertexLayout.instanceStrideInFloats;

  int _capacity = 16;
  int _length = 0;
  late Float32List _instances;
  Float32List? _worldInstances;
  final Matrix4 _lastWorldMatrix = Matrix4.zero();
  int _localVersion = 0;
  int _transformedVersion = -1;

  final Aabb3 _localAabb = Aabb3();
  bool _localBoundsDirty = true;

  /// Number of active instances in the group.
  int get length => _length;

  /// Whether the group holds no instances.
  bool get isEmpty => _length == 0;

  /// Whether the group holds at least one instance.
  bool get isNotEmpty => _length > 0;

  /// Appends an instance and returns its index.
  int addInstance({
    required Matrix4 transform,
    Color color = const Color(0xFFFFFFFF),
    Vector4? instanceData,
  }) {
    final index = _length;
    if (index == _capacity) {
      _grow(_capacity * 2);
    }
    _length++;
    _writeInstance(index, transform, color, instanceData);
    _invalidate();
    return index;
  }

  /// Updates fields of the instance at [index] in place.
  void setInstance(
    int index, {
    Matrix4? transform,
    Color? color,
    Vector4? instanceData,
  }) {
    RangeError.checkValidIndex(index, this, 'index', _length);
    final base = index * _stride;
    if (transform != null) {
      final s = transform.storage;
      for (var i = 0; i < 16; i++) {
        _instances[base + i] = s[i];
      }
      _localBoundsDirty = true;
    }
    if (color != null) {
      _instances
        ..[base + 16] = color.r
        ..[base + 17] = color.g
        ..[base + 18] = color.b
        ..[base + 19] = color.a;
    }
    if (instanceData != null) {
      _instances
        ..[base + 20] = instanceData.x
        ..[base + 21] = instanceData.y
        ..[base + 22] = instanceData.z
        ..[base + 23] = instanceData.w;
    }
    _localVersion++;
    if (transform != null) {
      markAabbDirty();
    }
    _notifyWorldDirty(shadows: transform != null);
  }

  /// Removes the instance at [index] in `O(1)` by moving the last instance into
  /// its slot.
  void removeAtSwapLast(int index) {
    RangeError.checkValidIndex(index, this, 'index', _length);
    final last = --_length;
    if (index != last) {
      _instances.setRange(
        index * _stride,
        (index + 1) * _stride,
        _instances,
        last * _stride,
      );
    }
    _invalidate();
  }

  /// Removes all instances without releasing the backing buffer.
  void clear() {
    if (_length == 0) {
      return;
    }
    _length = 0;
    _invalidate();
  }

  /// Reads the local transform of [index] into [out] (or a new [Matrix4]).
  Matrix4 instanceTransform(int index, {Matrix4? out}) {
    RangeError.checkValidIndex(index, this, 'index', _length);
    final result = out ?? Matrix4.zero();
    final base = index * _stride;
    for (var i = 0; i < 16; i++) {
      result.storage[i] = _instances[base + i];
    }
    return result;
  }

  @override
  Aabb3? computeLocalAabb() {
    if (_length == 0) {
      return null;
    }
    if (_localBoundsDirty) {
      _localBoundsDirty = false;
      final meshBox = mesh.aabb;
      var minX = double.infinity;
      var minY = double.infinity;
      var minZ = double.infinity;
      var maxX = double.negativeInfinity;
      var maxY = double.negativeInfinity;
      var maxZ = double.negativeInfinity;
      for (var idx = 0; idx < _length; idx++) {
        final b = idx * _stride;
        for (var corner = 0; corner < 8; corner++) {
          final cx = (corner & 1) == 0 ? meshBox.min.x : meshBox.max.x;
          final cy = (corner & 2) == 0 ? meshBox.min.y : meshBox.max.y;
          final cz = (corner & 4) == 0 ? meshBox.min.z : meshBox.max.z;
          final wx =
              _instances[b] * cx +
              _instances[b + 4] * cy +
              _instances[b + 8] * cz +
              _instances[b + 12];
          final wy =
              _instances[b + 1] * cx +
              _instances[b + 5] * cy +
              _instances[b + 9] * cz +
              _instances[b + 13];
          final wz =
              _instances[b + 2] * cx +
              _instances[b + 6] * cy +
              _instances[b + 10] * cz +
              _instances[b + 14];
          minX = math.min(minX, wx);
          minY = math.min(minY, wy);
          minZ = math.min(minZ, wz);
          maxX = math.max(maxX, wx);
          maxY = math.max(maxY, wy);
          maxZ = math.max(maxZ, wz);
        }
      }
      _localAabb
        ..min.setValues(minX, minY, minZ)
        ..max.setValues(maxX, maxY, maxZ);
    }
    return _localAabb;
  }

  @override
  void draw(covariant RenderContext3D context) {
    if (_length == 0) {
      return;
    }
    final buffer = _resolvedBuffer();
    for (final surface in mesh.surfaces) {
      context.drawInstances(
        surface,
        instances: buffer,
        count: _length,
      );
    }
  }

  @override
  RayHit3D? raycast(
    Ray worldRay, {
    double maxDistance = double.infinity,
    CullMode? cullMode,
  }) {
    if (_length == 0) {
      return null;
    }
    final buffer = _resolvedBuffer();
    RayHit3D? best;
    var limit = maxDistance;
    for (var i = 0; i < _length; i++) {
      final base = i * _stride;
      for (var k = 0; k < 16; k++) {
        _scratchMatrix.storage[k] = buffer[base + k];
      }
      final hit = RayHit3D.intersectMesh(
        owner: this,
        mesh: mesh,
        modelMatrix: _scratchMatrix,
        worldRay: worldRay,
        maxDistance: limit,
        cullMode: cullMode,
      );
      if (hit != null && hit.distance < limit) {
        limit = hit.distance;
        best = RayHit3D(
          object: this,
          surface: hit.surface,
          surfaceIndex: i,
          distance: hit.distance,
          worldPoint: hit.worldPoint,
          worldNormal: hit.worldNormal,
          localPoint: hit.localPoint,
          localNormal: hit.localNormal,
          triangleIndex: hit.triangleIndex,
        );
      }
    }
    return best;
  }

  Float32List _resolvedBuffer() {
    final world = worldTransformMatrix;
    if (world.isIdentity()) {
      return _instances;
    }
    var out = _worldInstances;
    if (out == null || out.length < _length * _stride) {
      out = _worldInstances = Float32List(_capacity * _stride);
      _transformedVersion = -1;
    }
    if (_transformedVersion != _localVersion || _lastWorldMatrix != world) {
      _transformedVersion = _localVersion;
      _lastWorldMatrix.setFrom(world);
      final w = world.storage;
      for (var i = 0; i < _length; i++) {
        final b = i * _stride;
        for (var col = 0; col < 4; col++) {
          final c = b + col * 4;
          final x = _instances[c];
          final y = _instances[c + 1];
          final z = _instances[c + 2];
          final mw = _instances[c + 3];
          out
            ..[c] = w[0] * x + w[4] * y + w[8] * z + w[12] * mw
            ..[c + 1] = w[1] * x + w[5] * y + w[9] * z + w[13] * mw
            ..[c + 2] = w[2] * x + w[6] * y + w[10] * z + w[14] * mw
            ..[c + 3] = w[3] * x + w[7] * y + w[11] * z + w[15] * mw;
        }
        for (var k = 16; k < 24; k++) {
          out[b + k] = _instances[b + k];
        }
      }
    }
    return out;
  }

  void _writeInstance(
    int index,
    Matrix4 transform,
    Color color,
    Vector4? instanceData,
  ) {
    final base = index * _stride;
    final s = transform.storage;
    for (var i = 0; i < 16; i++) {
      _instances[base + i] = s[i];
    }
    _instances
      ..[base + 16] = color.r
      ..[base + 17] = color.g
      ..[base + 18] = color.b
      ..[base + 19] = color.a
      ..[base + 20] = instanceData?.x ?? 0
      ..[base + 21] = instanceData?.y ?? 0
      ..[base + 22] = instanceData?.z ?? 0
      ..[base + 23] = instanceData?.w ?? 0;
  }

  void _grow(int newCapacity) {
    final next = Float32List(newCapacity * _stride)
      ..setRange(0, _length * _stride, _instances);
    _instances = next;
    _capacity = newCapacity;
    _worldInstances = null;
  }

  void _invalidate() {
    _localVersion++;
    _localBoundsDirty = true;
    markAabbDirty();
    _notifyWorldDirty(shadows: true);
  }

  void _notifyWorldDirty({required bool shadows}) {
    worldOrNull?.markSceneDirty(shadows: shadows && castsShadows);
  }

  static final Matrix4 _scratchMatrix = Matrix4.identity();
}
