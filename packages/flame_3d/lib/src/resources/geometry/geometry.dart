import 'dart:typed_data';

import 'package:flame_3d/resources.dart';
import 'package:flutter_gpu/gpu.dart' as gpu;

class Geometry {
  ByteBuffer? _vertices;
  int _vertexCount = 0;

  ByteBuffer? _indices;
  gpu.IndexType _indexType = gpu.IndexType.int16;
  int _indexCount = 0;

  gpu.DeviceBuffer? _deviceBuffer;

  // TODO(bdero): This should have an attribute map instead and be fully SoA,
  //              but vertex attributes in Impeller aren't flexible enough yet.
  //              See also https://github.com/flutter/flutter/issues/139560.
  void setVertices(List<Vertex> vertices) {
    _vertices = Float32List.fromList(
      vertices.fold(
        [],
        (p, v) => p
          ..addAll([v.position.x, v.position.y, v.position.z])
          ..addAll([v.texCoords.x, v.texCoords.y])
          ..addAll([v.color.r, v.color.g, v.color.b, v.color.a]),
      ),
    ).buffer;
    _vertexCount = _vertices!.lengthInBytes ~/ vertices.length * 6;
    _deviceBuffer = null;
  }

  void setIndices(List<int> indices) {
    _indices = Uint16List.fromList(indices).buffer;
    _indexType = gpu.IndexType.int16;
    _indexCount = _indices!.lengthInBytes ~/ 2;
  }

  void bind(gpu.RenderPass pass) {
    if (_vertices == null) {
      throw Exception('setVertices must be called before binding geometry.');
    }

    _deviceBuffer ??= gpu.gpuContext.createDeviceBuffer(
      gpu.StorageMode.hostVisible,
      _indices == null
          ? _vertices!.lengthInBytes
          : _vertices!.lengthInBytes + _indices!.lengthInBytes,
    );

    _deviceBuffer?.overwrite(_vertices!.asByteData());
    pass.bindVertexBuffer(
      gpu.BufferView(
        _deviceBuffer!,
        offsetInBytes: 0,
        lengthInBytes: _vertices!.lengthInBytes,
      ),
      _vertexCount,
    );

    if (_indices != null) {
      _deviceBuffer?.overwrite(
        _indices!.asByteData(),
        destinationOffsetInBytes: _vertices!.lengthInBytes,
      );
      pass.bindIndexBuffer(
        gpu.BufferView(
          _deviceBuffer!,
          offsetInBytes: _vertices!.lengthInBytes,
          lengthInBytes: _indices!.lengthInBytes,
        ),
        _indexType,
        _indexCount,
      );
    }
  }
}
