import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

class Surface extends Resource<gpu.DeviceBuffer?> {
  Surface(
    List<Vertex> vertices,
    List<int> indices, [
    this.material,
  ]) : super(null) {
    // `TODO`(bdero): This should have an attribute map instead and be fully SoA
    // but vertex attributes in Impeller aren't flexible enough yet.
    // See also https://github.com/flutter/flutter/issues/116168.
    _vertices = Float32List.fromList(
      vertices.fold([], (p, v) => p..addAll(v.storage)),
    ).buffer;
    _vertexCount = _vertices.lengthInBytes ~/ (vertices.length * 9);

    _indices = Uint16List.fromList(indices).buffer;
    _indexCount = _indices.lengthInBytes ~/ 2;

    _calculateAabb(vertices);
  }

  Material? material;

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

  @override
  gpu.DeviceBuffer? get resource {
    var resource = super.resource;
    final sizeInBytes = _vertices.lengthInBytes + _indices.lengthInBytes;
    if (resource?.sizeInBytes != sizeInBytes) {
      // Store the device buffer in the resource parent.
      resource = super.resource = gpu.gpuContext.createDeviceBuffer(
        gpu.StorageMode.hostVisible,
        sizeInBytes,
      );

      resource
        ?..overwrite(_vertices.asByteData())
        ..overwrite(
          _indices.asByteData(),
          destinationOffsetInBytes: _vertices.lengthInBytes,
        );
    }
    return resource;
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
}
