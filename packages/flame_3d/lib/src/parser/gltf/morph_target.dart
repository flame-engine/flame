import 'package:flame_3d/src/parser/gltf/accessor.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// A plain JSON object specifying attributes displacements in a morph target,
/// where:
/// * each key corresponds to one of the three supported attribute semantic
///   (`POSITION`, `NORMAL`, or `TANGENT`); and
/// * each value is the index of the accessor containing the attribute
///   displacements' data.
class MorphTarget extends GltfNode {
  Map<MorphTargetType, GltfRef<RawAccessor>> attributes = {};

  MorphTarget({
    required super.root,
    required this.attributes,
  });

  MorphTarget.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        attributes: map.map(
          (key, value) => MapEntry(
            MorphTargetType.valueOf(key),
            GltfRef<RawAccessor>(root: root, index: value! as int),
          ),
        ),
      );
}

enum MorphTargetType {
  position('POSITION'),
  normal('NORMAL'),
  tangent('TANGENT');

  final String value;

  const MorphTargetType(this.value);

  static MorphTargetType valueOf(String value) {
    return values.firstWhere((e) => e.value == value);
  }
}
