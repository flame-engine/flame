import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// Specifies if the camera uses a perspective or orthographic projection.
enum CameraType {
  perspective,
  orthographic;

  static CameraType valueOf(String value) {
    return values.firstWhere((e) => e.name == value);
  }

  static CameraType? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }
}
