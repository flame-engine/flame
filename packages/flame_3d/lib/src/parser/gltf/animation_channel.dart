import 'package:flame_3d/src/parser/gltf/animation_target.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

class AnimationChannel extends GltfNode {
  /// The ID of a sampler in this animation used to compute the value for the
  /// target, e.g., a node's translation, rotation, or scale (TRS).
  final int sampler;

  /// The descriptor of the animated property.
  final AnimationTarget target;

  AnimationChannel({
    required super.root,
    required this.sampler,
    required this.target,
  });

  AnimationChannel.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        sampler: Parser.integer(map, 'sampler')!,
        target: Parser.object(root, map, 'target', AnimationTarget.parse)!,
      );
}
