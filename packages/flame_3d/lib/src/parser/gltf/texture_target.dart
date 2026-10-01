import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// Texture targets; values correspond to WebGL enums.
enum TextureTarget(final String name, final int value) {
  texture2d('TEXTURE_2D', 3553);

  static TextureTarget valueOf(String name) {
    return values.firstWhere((e) => e.name == name);
  }

  static TextureTarget? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }
}
