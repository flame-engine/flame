import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

enum PrimitiveType() {
  triangles,
}

/// Displacement deltas for one blend-shape / morph target of a [Surface].
class MorphTargetData({
  required final Float32List positionDeltas,
  final String? name,
  final Float32List? normalDeltas,
});

/// {@template surface}
/// Base surface [Resource], it describes a single surface to be rendered: an
/// interleaved vertex buffer laid out as described by [layout], triangle
/// indices, and the [material] it is drawn with.
///
/// Indices are 16-bit, or 32-bit when the surface has more than 65,535
/// vertices (or when built from a [Uint32List]).
/// {@endtemplate}
class Surface extends Resource<GpuBuffer> {
  /// {@macro surface}
  ///
  /// Builds the surface from [Vertex] objects, packed with the
  /// [VertexLayout.standard] layout. If [calculateNormals] is `true`, the
  /// normals are calculated when a vertex does not provide one.
  Surface({
    required List<Vertex> vertices,
    required List<int> indices,
    Material? material,
    this.jointMap,
    List<MorphTargetData> morphTargets = const [],
    bool calculateNormals = true,
  }) : material = material ?? Material.defaultMaterial,
       layout = VertexLayout.standard,
       morphTargets = List.unmodifiable(morphTargets) {
    final normalizedVertices = _normalize(
      vertices: vertices,
      indices: indices,
      calculateNormals: calculateNormals,
    );
    vertexData = _packVertices(normalizedVertices);
    vertexCount = normalizedVertices.length;
    if (this.morphTargets.isNotEmpty) {
      _baseVertexData = Float32List.fromList(vertexData);
    }
    _setIndices(_indexList(indices, vertexCount));
    _aabb = _computeAabb(vertexData, layout, vertexCount);
  }

  /// {@macro surface}
  ///
  /// Builds the surface straight from typed arrays, without creating [Vertex]
  /// objects: [vertices] holds the interleaved floats of every vertex as
  /// described by [layout] (the [VertexLayout.standard] layout by default),
  /// and [indices] is a [Uint16List] or a [Uint32List].
  ///
  /// The arrays are used as given, not copied. The bounds are computed from
  /// the [VertexLayout.positionAttribute] unless [aabb] is given.
  Surface.fromBuffers({
    required Float32List vertices,
    required List<int> indices,
    VertexLayout? layout,
    Material? material,
    this.jointMap,
    List<MorphTargetData> morphTargets = const [],
    Aabb3? aabb,
  }) : material = material ?? Material.defaultMaterial,
       layout = layout ?? VertexLayout.standard,
       morphTargets = List.unmodifiable(morphTargets) {
    final stride = this.layout.strideInFloats;
    if (vertices.length % stride != 0) {
      throw ArgumentError.value(
        vertices.length,
        'vertices',
        'Must hold whole vertices of ${this.layout.strideInFloats} floats',
      );
    }
    if (indices is! Uint16List && indices is! Uint32List) {
      throw ArgumentError.value(
        indices.runtimeType,
        'indices',
        'Must be a Uint16List or a Uint32List',
      );
    }
    vertexData = vertices;
    vertexCount = vertices.length ~/ stride;
    if (this.morphTargets.isNotEmpty) {
      _baseVertexData = Float32List.fromList(vertexData);
    }
    _setIndices(indices);
    _aabb = aabb ?? _computeAabb(vertexData, this.layout, vertexCount);
  }

  static int _nextId = 0;

  /// A number identifying this surface, used to group draws by surface.
  final int id = _nextId++;

  /// The material the surface is drawn with.
  Material material;

  /// Maps the joint indices of the model to the joint indices used by this
  /// surface's vertices, for skinned surfaces.
  Map<int, int>? jointMap;

  /// Optional blend-shape / morph targets displacing [vertexData].
  final List<MorphTargetData> morphTargets;

  Float32List? _baseVertexData;

  /// The layout of [vertexData].
  final VertexLayout layout;

  /// The interleaved vertex data, [VertexLayout.strideInFloats] floats per
  /// vertex.
  late Float32List vertexData;

  /// The bounds of the surface's vertices.
  Aabb3 get aabb => _aabb;
  late final Aabb3 _aabb;

  /// The number of vertices.
  late final int vertexCount;

  /// The triangle indices: a [Uint16List] or a [Uint32List], see [indexType].
  List<int> get indices => _indices;
  late final List<int> _indices;

  /// The type of [indices].
  GpuIndexType get indexType => _indexType;
  late final GpuIndexType _indexType;

  /// The number of indices.
  int get indexCount => _indices.length;

  /// The size of the vertex data in bytes.
  int get verticesBytes => vertexData.lengthInBytes;

  /// The size of the index data in bytes.
  int get indicesBytes => indexCount * _indexType.bytesPerIndex;

  /// The offset of the index data in the surface's GPU buffer.
  int get indicesOffsetInBytes => verticesBytes;

  Float32List? _positions;
  SurfaceBvh? _bvh;

  /// The (x, y, z) positions of this surface's vertices, packed contiguously
  /// as `[x0, y0, z0, x1, y1, z1, ...]`. Computed on first access and updated
  /// automatically by [updateVertices].
  Float32List get positions => _positions ??= _extractPositions();

  /// Lazy flat Bounding Volume Hierarchy (`O(log T)` narrowphase ray queries)
  /// over this surface's triangles, built on first access and invalidated when
  /// [updateVertices] mutates vertex positions.
  SurfaceBvh get bvh => _bvh ??= SurfaceBvh.build(this);

  int? _resourceSizeInBytes;

  int get _sizeInBytes => verticesBytes + _align4(indicesBytes);

  @override
  bool get recreateResource =>
      super.recreateResource || _resourceSizeInBytes != _sizeInBytes;

  @override
  GpuBuffer createResource() {
    _resourceSizeInBytes = _sizeInBytes;
    final indices = _indices as TypedData;
    return GpuBackend.instance.createBuffer(
        storageMode: GpuStorageMode.hostVisible,
        sizeInBytes: _sizeInBytes,
      )
      ..write(ByteData.sublistView(vertexData))
      ..write(
        ByteData.sublistView(indices),
        destinationOffsetInBytes: indicesOffsetInBytes,
      );
  }

  /// Updates the interleaved vertex buffer in place on the GPU (when already
  /// uploaded), refreshes [aabb], and invalidates any cached [bvh].
  void updateVertices(Float32List newVertices, {Aabb3? aabb}) {
    if (newVertices.length != vertexData.length) {
      throw ArgumentError.value(
        newVertices.length,
        'newVertices',
        'Must match existing length ${vertexData.length}',
      );
    }
    if (!identical(newVertices, vertexData)) {
      vertexData.setAll(0, newVertices);
    }
    if (aabb != null) {
      _aabb.setFrom(aabb);
    } else {
      final recomputed = _computeAabb(vertexData, layout, vertexCount);
      _aabb.setFrom(recomputed);
    }
    if (_positions != null) {
      _fillPositions(_positions!);
    }
    _bvh = null;
    if (hasResource && _resourceSizeInBytes == _sizeInBytes) {
      resource.write(ByteData.sublistView(vertexData));
    }
  }

  /// Blends [morphTargets] using [weights] onto the rest vertices of this
  /// surface with zero heap allocations and uploads the morphed vertex buffer.
  void applyMorphWeights(List<double> weights) {
    if (morphTargets.isEmpty) {
      return;
    }
    final base = _baseVertexData ??= Float32List.fromList(vertexData);
    vertexData.setAll(0, base);

    final posOffset = layout.offsetOf(VertexLayout.positionAttribute);
    final nrmOffset = layout.offsetOf('vertexNormal');
    final stride = layout.strideInFloats;
    final targetCount = math.min(weights.length, morphTargets.length);

    for (var t = 0; t < targetCount; t++) {
      final w = weights[t];
      if (w.abs() <= 1e-6) {
        continue;
      }
      final target = morphTargets[t];
      final pDeltas = target.positionDeltas;
      if (posOffset != null && pDeltas.length >= vertexCount * 3) {
        for (var v = 0; v < vertexCount; v++) {
          final vo = v * stride + posOffset;
          final po = v * 3;
          vertexData[vo] += pDeltas[po] * w;
          vertexData[vo + 1] += pDeltas[po + 1] * w;
          vertexData[vo + 2] += pDeltas[po + 2] * w;
        }
      }
      final nDeltas = target.normalDeltas;
      if (nrmOffset != null &&
          nDeltas != null &&
          nDeltas.length >= vertexCount * 3) {
        for (var v = 0; v < vertexCount; v++) {
          final vo = v * stride + nrmOffset;
          final no = v * 3;
          vertexData[vo] += nDeltas[no] * w;
          vertexData[vo + 1] += nDeltas[no + 1] * w;
          vertexData[vo + 2] += nDeltas[no + 2] * w;
        }
      }
    }

    if (nrmOffset != null) {
      for (var v = 0; v < vertexCount; v++) {
        final vo = v * stride + nrmOffset;
        final nx = vertexData[vo];
        final ny = vertexData[vo + 1];
        final nz = vertexData[vo + 2];
        final len2 = nx * nx + ny * ny + nz * nz;
        if (len2 > 1e-12) {
          final inv = 1.0 / math.sqrt(len2);
          vertexData[vo] = nx * inv;
          vertexData[vo + 1] = ny * inv;
          vertexData[vo + 2] = nz * inv;
        }
      }
    }

    updateVertices(vertexData);
  }

  @override
  void dispose() {
    _resourceSizeInBytes = null;
    super.dispose();
  }

  void _setIndices(List<int> indices) {
    _indices = indices;
    _indexType = indices is Uint32List
        ? GpuIndexType.uint32
        : GpuIndexType.uint16;
  }

  Float32List _extractPositions() {
    final out = Float32List(vertexCount * 3);
    _fillPositions(out);
    return out;
  }

  void _fillPositions(Float32List out) {
    final offset = layout.offsetOf(VertexLayout.positionAttribute);
    if (offset == null) {
      return;
    }
    final stride = layout.strideInFloats;
    for (var i = 0; i < vertexCount; i++) {
      final base = i * stride + offset;
      out[i * 3] = vertexData[base];
      out[i * 3 + 1] = vertexData[base + 1];
      out[i * 3 + 2] = vertexData[base + 2];
    }
  }

  static int _align4(int value) => (value + 3) & ~3;

  static List<int> _indexList(List<int> indices, int vertexCount) {
    var wide = vertexCount > 0xFFFF;
    for (var i = 0; !wide && i < indices.length; i++) {
      wide = indices[i] >= 0xFFFF;
    }
    return wide ? Uint32List.fromList(indices) : Uint32ListOrUint16.of(indices);
  }

  static Aabb3 _computeAabb(
    Float32List data,
    VertexLayout layout,
    int vertexCount,
  ) {
    final offset = layout.offsetOf(VertexLayout.positionAttribute);
    if (offset == null || vertexCount == 0) {
      return Aabb3();
    }
    final stride = layout.strideInFloats;
    var minX = double.infinity;
    var minY = double.infinity;
    var minZ = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    var maxZ = double.negativeInfinity;
    for (var i = offset; i < data.length; i += stride) {
      final x = data[i];
      final y = data[i + 1];
      final z = data[i + 2];
      if (x < minX) {
        minX = x;
      }
      if (x > maxX) {
        maxX = x;
      }
      if (y < minY) {
        minY = y;
      }
      if (y > maxY) {
        maxY = y;
      }
      if (z < minZ) {
        minZ = z;
      }
      if (z > maxZ) {
        maxZ = z;
      }
    }
    return Aabb3.minMax(
      Vector3(minX, minY, minZ),
      Vector3(maxX, maxY, maxZ),
    );
  }

  static Float32List _packVertices(List<Vertex> vertices) {
    final stride = VertexLayout.standard.strideInFloats;
    final packed = Float32List(vertices.length * stride);
    for (var i = 0; i < vertices.length; i++) {
      packed.setRange(i * stride, (i + 1) * stride, vertices[i].storage);
    }
    return packed;
  }

  static List<Vertex> _normalize({
    required List<Vertex> vertices,
    required List<int> indices,
    required bool calculateNormals,
  }) {
    final recalculate =
        calculateNormals && vertices.any((e) => e.normal == null);
    if (!recalculate) {
      return vertices;
    }

    final normals = Vertex.calculateVertexNormals(
      vertices.map((e) => e.position.mutable).toList(),
      indices,
    );
    return [
      for (final (i, v) in vertices.indexed)
        v.copyWith(normal: v.normal?.mutable ?? normals[i]),
    ];
  }
}

extension Uint32ListOrUint16 on Uint16List {
  static Uint16List of(List<int> indices) => Uint16List.fromList(indices);
}
