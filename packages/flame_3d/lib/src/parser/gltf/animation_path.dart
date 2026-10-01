import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// The name of the node's TRS property to modify.
enum AnimationPath(final String value) {
  translation('translation'),
  rotation('rotation'),
  scale('scale'),
  weights('weights');

  static AnimationPath valueOf(String value) {
    return values.firstWhere((e) => e.value == value);
  }

  static AnimationPath? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }
}
