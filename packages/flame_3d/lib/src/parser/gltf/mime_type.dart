import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

enum MimeType {
  jpeg('image/jpeg'),
  png('image/png'),
  string('string');

  final String value;

  const MimeType(this.value);

  static MimeType valueOf(String value) {
    return values.firstWhere((e) => e.value == value);
  }

  static MimeType? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }
}
