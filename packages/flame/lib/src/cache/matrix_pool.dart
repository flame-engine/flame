import 'dart:typed_data' show Float64List, Float32List;
import 'dart:ui';

class MatrixPool {
  static final List<Float64List> _pool = [];
  static const int _bufferSize = 16;

  static Float64List getBuffer() {
    if (_pool.isEmpty) {
      return Float64List(_bufferSize);
    }
    return _pool.removeLast();
  }

  static void releaseBuffer(Float64List buffer) {
    _pool.add(buffer);
  }
}

/// Applies Canvas.transform to a Float64List buffer,
/// allowing the Matrix4 and Lists to be 32 bit.
void canvasTransform(Canvas canvas, Float32List matrix4) {
  final buffer = MatrixPool.getBuffer();
  for (var i = 0; i < 16; i++) {
    buffer[i] = matrix4[i];
  }
  canvas.transform(buffer);
  MatrixPool.releaseBuffer(buffer);
}

/// Applies Path.transform to a Float64List buffer,
/// allowing the Matrix4 and Lists to be 32 bit.
Path pathTransform(Path path, Float32List matrix4) {
  final buffer = MatrixPool.getBuffer();
  for (var i = 0; i < 16; i++) {
    buffer[i] = matrix4[i];
  }
  final transformed = path.transform(buffer);
  MatrixPool.releaseBuffer(buffer);

  return transformed;
}
