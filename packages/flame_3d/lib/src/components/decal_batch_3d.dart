import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color, Rect;

import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template decal_batch_3d}
/// Draws many flat 3D surface decals in a single instanced draw call using
/// [DecalMaterial].
///
/// Each decal sits on a unit quad in its local XY plane (`[-0.5, 0.5]^2`),
/// oriented and scaled by its 3D transform (or placed with [addFlatDecal] for
/// ground/floor decals aligned to an arbitrary plane), with its own color and
/// optional normalized UV sub-rectangle (`0..1`) into an atlas texture.
/// {@endtemplate}
class DecalBatch3D({
  DecalMaterial? material,
  int initialCapacity = 16,
  super.position,
  super.scale,
  super.rotation,
  super.children,
}) extends Object3D {
  /// {@macro decal_batch_3d}
  this : super(castsShadows: false) {
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

  /// The material shared by all decals in this batch.
  final DecalMaterial material = material ?? DecalMaterial();

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

  int _capacity = 16;
  int _length = 0;
  late Float32List _instances;
  Float32List? _worldInstances;
  final Matrix4 _lastWorldMatrix = Matrix4.zero();
  int _localVersion = 0;
  int _transformedVersion = -1;

  final Aabb3 _localAabb = Aabb3();
  bool _localBoundsDirty = true;

  /// Number of decals currently in the batch.
  int get length => _length;

  /// Whether the batch has no decals.
  bool get isEmpty => _length == 0;

  /// Appends a decal with an arbitrary 3D [transform] (mapping the unit XY quad
  /// `[-0.5, 0.5]^2` into the batch's local space) and returns its index.
  int addDecal({
    required Matrix4 transform,
    Color color = const Color(0xFFFFFFFF),
    Rect? uvRect,
  }) {
    final index = _length;
    if (index == _capacity) {
      _grow(_capacity * 2);
    }
    _length++;
    _writeDecal(index, transform, color, uvRect);
    _invalidate();
    return index;
  }

  /// Convenience helper that places a decal at [center] oriented by [normal]
  /// (defaults to `(0, 1, 0)` Y-up; pass `(0, 0, 1)` for Z-up boards), rotated
  /// in-plane by [angle] radians and sized `(width, height)`.
  int addFlatDecal({
    required Vector3 center,
    double width = 1.0,
    double height = 1.0,
    double angle = 0.0,
    Vector3? normal,
    Color color = const Color(0xFFFFFFFF),
    Rect? uvRect,
  }) {
    _composeFlatMatrix(_scratch, center, width, height, angle, normal);
    return addDecal(transform: _scratch, color: color, uvRect: uvRect);
  }

  /// Updates the decal at [index] in place.
  void setDecal(
    int index, {
    Matrix4? transform,
    Color? color,
    Rect? uvRect,
  }) {
    RangeError.checkValidIndex(index, this, 'index', _length);
    final base = index * _stride;
    if (transform != null) {
      final s = transform.storage;
      for (var i = 0; i < 16; i++) {
        _instances[base + i] = s[i];
      }
      _localBoundsDirty = true;
      markAabbDirty();
    }
    if (color != null) {
      _instances
        ..[base + 16] = color.r
        ..[base + 17] = color.g
        ..[base + 18] = color.b
        ..[base + 19] = color.a;
    }
    if (uvRect != null) {
      _instances
        ..[base + 20] = uvRect.left
        ..[base + 21] = uvRect.top
        ..[base + 22] = uvRect.width
        ..[base + 23] = uvRect.height;
    }
    _localVersion++;
    worldOrNull?.markSceneDirty(shadows: false);
  }

  /// Places a height-attenuated circular mobile drop-shadow decal at
  /// [groundPoint] for an object floating [elevation] world units above it:
  /// expands slightly and fades out smoothly up to [maxElevation].
  int? addBlobShadow({
    required Vector3 groundPoint,
    required double radius,
    double elevation = 0.0,
    double maxElevation = 4.0,
    double baseOpacity = 0.55,
    Color shadowColor = const Color(0xFF0A0F1E),
    Vector3? normal,
  }) {
    final h = math.max(0.0, elevation);
    if (maxElevation > 0 && h >= maxElevation) {
      return null;
    }
    final t = maxElevation > 0 ? (h / maxElevation).clamp(0.0, 1.0) : 0.0;
    final fade = (1.0 - t) * (1.0 - t);
    final alpha = (baseOpacity * fade).clamp(0.0, 1.0);
    if (alpha <= 0.005) {
      return null;
    }
    final diameter = radius * 2.0 * (1.0 + 0.45 * t);
    final c = Color.fromARGB(
      (alpha * 255).round(),
      (shadowColor.r * 255).round(),
      (shadowColor.g * 255).round(),
      (shadowColor.b * 255).round(),
    );
    return addFlatDecal(
      center: groundPoint,
      width: diameter,
      height: diameter,
      normal: normal,
      color: c,
    );
  }

  /// Removes the decal at [index] in `O(1)` by swapping with the last entry.
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

  /// Removes all decals without freeing capacity.
  void clear() {
    if (_length == 0) {
      return;
    }
    _length = 0;
    _invalidate();
  }

  @override
  Aabb3? computeLocalAabb() {
    if (_length == 0) {
      return null;
    }
    if (_localBoundsDirty) {
      _localBoundsDirty = false;
      var minX = double.infinity;
      var minY = double.infinity;
      var minZ = double.infinity;
      var maxX = double.negativeInfinity;
      var maxY = double.negativeInfinity;
      var maxZ = double.negativeInfinity;
      for (var idx = 0; idx < _length; idx++) {
        final b = idx * _stride;
        for (var corner = 0; corner < 4; corner++) {
          final cx = (corner & 1) == 0 ? -0.5 : 0.5;
          final cy = (corner & 2) == 0 ? -0.5 : 0.5;
          final wx =
              _instances[b] * cx + _instances[b + 4] * cy + _instances[b + 12];
          final wy =
              _instances[b + 1] * cx +
              _instances[b + 5] * cy +
              _instances[b + 13];
          final wz =
              _instances[b + 2] * cx +
              _instances[b + 6] * cy +
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
        ..min.setValues(minX - 1e-3, minY - 1e-3, minZ - 1e-3)
        ..max.setValues(maxX + 1e-3, maxY + 1e-3, maxZ + 1e-3);
    }
    return _localAabb;
  }

  @override
  void draw(covariant RenderContext3D context) {
    if (_length == 0 || context.isShadowPass) {
      return;
    }
    context.drawInstances(
      _unitQuad,
      instances: _resolvedBuffer(),
      count: _length,
      material: material,
    );
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

  void _writeDecal(int index, Matrix4 transform, Color color, Rect? uvRect) {
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
      ..[base + 20] = uvRect?.left ?? 0
      ..[base + 21] = uvRect?.top ?? 0
      ..[base + 22] = uvRect?.width ?? 0
      ..[base + 23] = uvRect?.height ?? 0;
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
    worldOrNull?.markSceneDirty(shadows: false);
  }

  static void _composeFlatMatrix(
    Matrix4 out,
    Vector3 center,
    double width,
    double height,
    double angle,
    Vector3? normal,
  ) {
    var nx = normal?.x ?? 0.0;
    var ny = normal?.y ?? 1.0;
    var nz = normal?.z ?? 0.0;
    final nLen = math.sqrt(nx * nx + ny * ny + nz * nz);
    if (nLen > 1e-12) {
      nx /= nLen;
      ny /= nLen;
      nz /= nLen;
    } else {
      nx = 0.0;
      ny = 1.0;
      nz = 0.0;
    }

    // Build an orthonormal tangent basis `(tx, ty, tz)` x `(bx, by, bz)` in
    // the decal plane perpendicular to `n`.
    final refX = nx.abs() < 0.9 ? 1.0 : 0.0;
    final refY = nx.abs() < 0.9 ? 0.0 : 1.0;
    var tx = refY * nz;
    var ty = -refX * nz;
    var tz = refX * ny - refY * nx;
    final tLen = math.sqrt(tx * tx + ty * ty + tz * tz);
    tx /= tLen;
    ty /= tLen;
    tz /= tLen;

    final bx = ny * tz - nz * ty;
    final by = nz * tx - nx * tz;
    final bz = nx * ty - ny * tx;

    final c = math.cos(angle);
    final s = math.sin(angle);
    final ux = (c * tx + s * bx) * width;
    final uy = (c * ty + s * by) * width;
    final uz = (c * tz + s * bz) * width;
    final vx = (-s * tx + c * bx) * height;
    final vy = (-s * ty + c * by) * height;
    final vz = (-s * tz + c * bz) * height;

    out.storage
      ..[0] = ux
      ..[1] = uy
      ..[2] = uz
      ..[3] = 0.0
      ..[4] = vx
      ..[5] = vy
      ..[6] = vz
      ..[7] = 0.0
      ..[8] = nx
      ..[9] = ny
      ..[10] = nz
      ..[11] = 0.0
      ..[12] = center.x
      ..[13] = center.y
      ..[14] = center.z
      ..[15] = 1.0;
  }

  static final Matrix4 _scratch = Matrix4.identity();
}
