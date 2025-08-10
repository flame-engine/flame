import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// Texture formats; values correspond to WebGL enums.
enum TextureFormat {
  alpha('ALPHA', 6406),
  rgb('RGB', 6407),
  rgba('RGBA', 6408),
  luminance('LUMINANCE', 6409),
  luminanceAlpha('LUMINANCE_ALPHA', 6410);

  final String name;
  final int value;

  const TextureFormat(this.name, this.value);

  static TextureFormat valueOf(String name) {
    return values.firstWhere((e) => e.name == name);
  }

  static TextureFormat? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }
}
