import 'dart:typed_data';

import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

class Geometry extends Resource<gpu.DeviceBuffer?> {
  Geometry({List<Vertex>? vertices, List<int>? indices}) : super(null) {
    if (vertices != null) {
      setVertices(vertices);
    }
    if (indices != null) {
      setIndices(indices);
    }
  }

  ByteBuffer _vertices = ByteData(0).buffer;
  int _vertexCount = 0;

  ByteBuffer _indices = ByteData(0).buffer;
  int _indexCount = 0;

  @override
  gpu.DeviceBuffer? get resource {
    var resource = super.resource;
    final sizeInBytes = _vertices.lengthInBytes + _indices.lengthInBytes;
    if (resource?.sizeInBytes != sizeInBytes) {
      resource = super.resource = gpu.gpuContext.createDeviceBuffer(
        gpu.StorageMode.hostVisible,
        sizeInBytes,
      );

      resource!.overwrite(_vertices.asByteData());

      resource.overwrite(
        _indices.asByteData(),
        destinationOffsetInBytes: _vertices.lengthInBytes,
      );
    }
    return resource;
  }

  // TODO(bdero): This should have an attribute map instead and be fully SoA,
  //              but vertex attributes in Impeller aren't flexible enough yet.
  //              See also https://github.com/flutter/flutter/issues/116168.
  void setVertices(List<Vertex> vertices) {
    _vertices = Float32List.fromList(
      vertices.fold([], (p, v) => p..addAll(v.storage)),
    ).buffer;
    _vertexCount = _vertices.lengthInBytes ~/ (vertices.length * 10);
  }

  void setIndices(List<int> indices) {
    _indices = Uint16List.fromList(indices).buffer;
    _indexCount = _indices.lengthInBytes ~/ 2;
  }

  // TODO(wolfen): preferably this uses the `GraphicsDevice`
  void bind(gpu.RenderPass renderPass) {
    renderPass.bindVertexBuffer(
      gpu.BufferView(
        resource!,
        offsetInBytes: 0,
        lengthInBytes: _vertices.lengthInBytes,
      ),
      _vertexCount,
    );

    renderPass.bindIndexBuffer(
      gpu.BufferView(
        resource!,
        offsetInBytes: _vertices.lengthInBytes,
        lengthInBytes: _indices.lengthInBytes,
      ),
      gpu.IndexType.int16,
      _indexCount,
    );
  }
}
