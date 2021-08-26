import 'dart:typed_data';
import 'package:vector_math/vector_math_64.dart';
import 'command.dart';

class TransformCommand extends CanvasCommand {
  TransformCommand() : _transform = Matrix4.identity();

  final Matrix4 _transform;

  void transform(Float64List matrix) =>
      _transform.multiply(Matrix4.fromFloat64List(matrix));
  void translate(double dx, double dy) => _transform.translate(dx, dy);
  void rotate(double angle) => _transform.rotateZ(angle);
  void scale(double sx, double sy) => _transform.scale(sx, sy, 1);

  @override
  bool equals(TransformCommand other) =>
      eq(_transform.storage, other._transform.storage);

  @override
  String toString() {
    final content = _transform.storage.map((e) => e.toString()).join(', ');
    return 'transform($content)';
  }
}
