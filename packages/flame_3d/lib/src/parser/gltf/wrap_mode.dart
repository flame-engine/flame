import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// Wrapping mode. Valid values correspond to WebGL enums.
enum WrapMode(final String name, final int value) {
  clampToEdge('CLAMP_TO_EDGE', 33071),
  mirroredRepeat('MIRRORED_REPEAT', 33648),
  repeat('REPEAT', 10497);

  static WrapMode valueOf(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  static WrapMode? parse(Map<String, Object?> map, String key) {
    return Parser.integerEnum(map, key, valueOf);
  }
}
