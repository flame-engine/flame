import 'package:flame_3d/src/parser/gltf/animation_path.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/node.dart';

/// The descriptor of the animated property.
class AnimationTarget extends GltfNode {
  /// The reference to the node to animate. When undefined, the animated object
  /// **MAY** be defined by an extension.
  final GltfRef<Node> node;

  /// The name of the node's TRS property to animate, or the `weights` of the
  /// Morph Targets it instantiates.
  /// For the `translation` property, the values that are provided by the
  /// sampler are the translation along the X, Y, and Z axes.
  /// For the `rotation` property, the values are a quaternion in the order
  /// (x, y, z, w), where w is the scalar.
  /// For the `scale` property, the values are the scaling factors along the
  /// X, Y, and Z axes.
  final AnimationPath path;

  AnimationTarget({
    required super.root,
    required this.node,
    required this.path,
  });

  AnimationTarget.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        node: Parser.ref(root, map, 'node')!,
        path: AnimationPath.parse(map, 'path')!,
      );
}
