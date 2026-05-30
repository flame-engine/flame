import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// The target that the WebGL buffer should be bound to.
enum BufferViewTarget {
  arrayBuffer(34962),
  elementArrayBuffer(34963);

  final int value;

  const BufferViewTarget(this.value);

  static BufferViewTarget valueOf(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  static BufferViewTarget? parse(Map<String, Object?> map, String key) {
    return Parser.integerEnum(map, key, valueOf);
  }
}
