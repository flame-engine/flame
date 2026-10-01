import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// Magnification filter. Valid values correspond to WebGL enums.
enum MagFilter(final String name, final int value) {
  nearest('NEAREST', 9728),
  linear('LINEAR', 9729);

  static MagFilter valueOf(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  static MagFilter? parse(Map<String, Object?> map, String key) {
    return Parser.integerEnum(map, key, valueOf);
  }
}
