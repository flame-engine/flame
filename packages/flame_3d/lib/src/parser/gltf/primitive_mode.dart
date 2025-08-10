import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// The topology type of primitives to render.
enum PrimitiveMode {
  points(0),
  lines(1),
  lineLoop(2),
  lineStrip(3),
  triangles(4),
  triangleStrip(5),
  triangleFan(6);

  final int value;

  const PrimitiveMode(this.value);

  static PrimitiveMode valueOf(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  static PrimitiveMode? parse(Map<String, Object?> map, String key) {
    return Parser.integerEnum(map, key, valueOf);
  }
}
