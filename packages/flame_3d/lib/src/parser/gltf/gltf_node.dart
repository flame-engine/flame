import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// A base class for all data classes representing the GLTF schema.
/// It holds a reference to the [GltfRoot] that contains it, which allows
/// for [GltfRef]s to be resolved.
abstract class GltfNode {
  final GltfRoot root;

  GltfNode({
    required this.root,
  });
}

/// A helper utility class to group different methods for parsing GLTF data
/// into data classes.
class Parser {
  Parser._();

  static GltfRef<T>? ref<T extends GltfNode>(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    final index = map[key];
    if (index == null) {
      return null;
    }
    return GltfRef<T>(
      root: root,
      index: index as int,
    );
  }

  static List<GltfRef<T>>? refList<T extends GltfNode>(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    return (map[key] as List<Object?>?)?.map((e) {
      return GltfRef<T>(
        root: root,
        index: e! as int,
      );
    }).toList();
  }

  static Vector3? vector3(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    final entries = floatList(map, key);
    return entries?.let(Vector3.array);
  }

  static Matrix4? matrix4(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    final entries = floatList(map, key);
    return entries?.let(Matrix4.fromList);
  }

  static Vector4? vector4(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    final entries = floatList(map, key);
    return entries?.let(Vector4.array);
  }

  static Quaternion? quaternion(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
  ) {
    final entries = floatList(map, key);
    return entries?.let((e) => Quaternion(e[0], e[1], e[2], e[3]));
  }

  static int? integer(
    Map<String, Object?> map,
    String key,
  ) {
    return (map[key] as num?)?.toInt();
  }

  static double? float(
    Map<String, Object?> map,
    String key,
  ) {
    return (map[key] as num?)?.toDouble();
  }

  static bool? boolean(
    Map<String, Object?> map,
    String key,
  ) {
    return map[key] as bool?;
  }

  static List<double>? floatList(
    Map<String, Object?> map,
    String key,
  ) {
    return (map[key] as List<Object?>?)?.let(coerceFloatList);
  }

  static List<double> coerceFloatList(
    List<Object?> value,
  ) {
    return value.map((e) => (e! as num).toDouble()).toList();
  }

  static String? string(
    Map<String, Object?> map,
    String key,
  ) {
    return map[key] as String?;
  }

  static T? object<T>(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
    T Function(GltfRoot, Map<String, Object?>) parser,
  ) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    return parser(root, value as Map<String, Object?>);
  }

  static T? integerEnum<T extends Enum>(
    Map<String, Object?> map,
    String key,
    T Function(int) valueOf,
  ) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    return valueOf(value as int);
  }

  static T? stringEnum<T extends Enum>(
    Map<String, Object?> map,
    String key,
    T Function(String) valueOf,
  ) {
    final value = map[key];
    if (value == null) {
      return null;
    }
    return valueOf(value as String);
  }

  static List<T>? objectList<T>(
    GltfRoot root,
    Map<String, Object?> map,
    String key,
    T Function(GltfRoot, Map<String, Object?>) parser,
  ) {
    return (map[key] as List<Object?>?)
        ?.map((e) => parser(root, e! as Map<String, Object?>))
        .toList();
  }

  static Map<String, int>? mapInt(
    Map<String, Object?> map,
    String key,
  ) {
    return (map[key] as Map<String, Object?>?)?.map(
      (key, value) => MapEntry(key, value! as int),
    );
  }
}

extension _Let<T> on T {
  R let<R>(R Function(T) block) {
    if (this == null) {
      return null as R;
    }
    return block(this!);
  }
}
