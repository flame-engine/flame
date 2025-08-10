import 'package:flame_3d/src/parser/gltf/accessor.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/node.dart';

/// Joints and matrices defining a skin.
class Skin extends GltfNode {
  /// The reference to the accessor containing the floating-point 4x4
  /// inverse-bind matrices.
  /// Its `accessor.count` property **MUST** be greater than or equal to the
  /// number of elements of the `joints` array.
  /// When undefined, each matrix is a 4x4 identity matrix.
  final GltfRef<Matrix4Accessor>? inverseBindMatrices;

  /// The reference to the node used as a skeleton root.
  /// The node **MUST** be the closest common root of the joints hierarchy or a
  /// direct or indirect parent node of the closest common root.
  final GltfRef<Node>? skeleton;

  /// Indices of skeleton nodes, used as joints in this skin.
  final List<GltfRef<Node>> joints;

  Skin({
    required super.root,
    required this.inverseBindMatrices,
    required this.skeleton,
    required this.joints,
  });

  Skin.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        inverseBindMatrices: Parser.ref(root, map, 'inverseBindMatrices'),
        skeleton: Parser.ref(root, map, 'skeleton'),
        joints: Parser.refList<Node>(root, map, 'joints') ?? [],
      );
}
