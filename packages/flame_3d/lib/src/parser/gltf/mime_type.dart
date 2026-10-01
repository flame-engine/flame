import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

enum MimeType(final String value) {
  jpeg('image/jpeg'),
  png('image/png'),
  string('string');

  static MimeType valueOf(String value) {
    return values.firstWhere((e) => e.value == value);
  }

  static MimeType? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }
}
