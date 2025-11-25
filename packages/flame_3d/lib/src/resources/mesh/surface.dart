import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/graphics/gpu_context_wrapper.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

enum PrimitiveType {
  triangles,
}

/// {@template surface}
/// Base surface [Resource], it describes a single surface to be rendered.
/// {@endtemplate}
class Surface extends Resource<gpu.DeviceBuffer?> {
  /// {@macro surface}
  Surface({
    required List<Vertex> vertices,
    required List<int> indices,
    Material? material,
    this.jointMap,
    /**
     * If `true`, the normals will be calculated if they are not provided.
     */
    bool calculateNormals = true,
  }) : material = material ?? Material.defaultMaterial {
    final normalizedVertices = _normalize(
      vertices: vertices,
      indices: indices,
      calculateNormals: calculateNormals,
    );
    // `TODO`(bdero): This should have an attribute map instead and be fully SoA
    // but vertex attributes in Impeller aren't flexible enough yet.
    // See also https://github.com/flutter/flutter/issues/116168.
    _vertices = Float32List.fromList(
      normalizedVertices.fold([], (p, v) => p..addAll(v.storage)),
    ).buffer;
    _vertexCount = normalizedVertices.length;

    _indices = Uint16List.fromList(indices).buffer;
    _indexCount = indices.length;

    _calculateAabb(normalizedVertices);
  }

  Material material;
  Map<int, int>? jointMap;

  Aabb3 get aabb => _aabb;
  late Aabb3 _aabb;

  int get verticesBytes => _vertices.lengthInBytes;
  late ByteBuffer _vertices;

  int get vertexCount => _vertexCount;
  late int _vertexCount;

  int get indicesBytes => _indices.lengthInBytes;
  late ByteBuffer _indices;

  int get indexCount => _indexCount;
  late int _indexCount;

  int? resourceSizeInByes;

  @override
  bool get recreateResource {
    final sizeInBytes = _vertices.lengthInBytes + _indices.lengthInBytes;
    return resourceSizeInByes != sizeInBytes;
  }

  @override
  gpu.DeviceBuffer? createResource() {
    final sizeInBytes = _vertices.lengthInBytes + _indices.lengthInBytes;
    resourceSizeInByes = sizeInBytes;
    return GpuContextWrapper(gpu.gpuContext).createDeviceBuffer(
        gpu.StorageMode.hostVisible,
        sizeInBytes,
      )
      ..overwrite(_vertices.asByteData())
      ..overwrite(
        _indices.asByteData(),
        destinationOffsetInBytes: _vertices.lengthInBytes,
      );
  }

  void _calculateAabb(List<Vertex> vertices) {
    var minX = double.infinity;
    var minY = double.infinity;
    var minZ = double.infinity;
    var maxX = double.negativeInfinity;
    var maxY = double.negativeInfinity;
    var maxZ = double.negativeInfinity;

    for (final vertex in vertices) {
      minX = math.min(minX, vertex.position.x);
      minY = math.min(minY, vertex.position.y);
      minZ = math.min(minZ, vertex.position.z);
      maxX = math.max(maxX, vertex.position.x);
      maxY = math.max(maxY, vertex.position.y);
      maxZ = math.max(maxZ, vertex.position.z);
    }

    _aabb = Aabb3.minMax(
      Vector3(minX, minY, minZ),
      Vector3(maxX, maxY, maxZ),
    );
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
