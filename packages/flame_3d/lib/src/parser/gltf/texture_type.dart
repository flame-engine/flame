import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// Texture formats; values correspond to WebGL enums.
enum TextureType {
  unsignedByte('UNSIGNED_BYTE', 5121),
  unsignedShort565('UNSIGNED_SHORT_5_6_5', 33635),
  unsignedShort4444('UNSIGNED_SHORT_4_4_4_4', 32819),
  unsignedShort5551('UNSIGNED_SHORT_5_5_5_1', 32820);

  final String name;
  final int value;

  const TextureType(this.name, this.value);

  static TextureType valueOf(int value) {
    return values.firstWhere((e) => e.value == value);
  }

  static TextureType? parse(Map<String, Object?> map, String key) {
    return Parser.integerEnum(map, key, valueOf);
  }
}
