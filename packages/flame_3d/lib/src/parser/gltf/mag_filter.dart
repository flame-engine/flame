import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// Magnification filter. Valid values correspond to WebGL enums.
enum MagFilter {
  nearest('NEAREST', 9728),
  linear('LINEAR', 9729);

  final String name;
  final int value;

  const MagFilter(this.name, this.value);

  static MagFilter valueOf(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  static MagFilter? parse(Map<String, Object?> map, String key) {
    return Parser.integerEnum(map, key, valueOf);
  }
}
