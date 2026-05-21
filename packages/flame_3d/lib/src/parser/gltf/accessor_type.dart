import 'package:flame_3d/src/parser/gltf/gltf_node.dart';

/// Specifies if the accessor's elements are scalars, vectors, or matrices.
enum AccessorType {
  scalar('SCALAR', 1),
  vec2('VEC2', 2),
  vec3('VEC3', 3),
  vec4('VEC4', 4),
  mat2('MAT2', 4),
  mat3('MAT3', 9),
  mat4('MAT4', 16);

  final String name;
  final int size;

  const AccessorType(this.name, this.size);

  static AccessorType valueOf(String name) {
    return values.firstWhere((e) => e.name == name);
  }

  static AccessorType? parse(Map<String, Object?> map, String key) {
    return Parser.stringEnum(map, key, valueOf);
  }
}
