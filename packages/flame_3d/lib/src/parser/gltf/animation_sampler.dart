import 'package:flame_3d/src/parser/gltf/accessor.dart';
import 'package:flame_3d/src/parser/gltf/animation_interpolation.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// An animation sampler combines timestamps with a sequence of output values
/// and defines an interpolation algorithm.
class AnimationSampler extends GltfNode {
  /// The index of an accessor containing keyframe timestamps.
  /// The accessor **MUST** be of scalar type with floating-point components.
  /// The values represent time in seconds with `time[0] >= 0.0`, and strictly
  /// increasing values, i.e., `time[n + 1] > time[n]`.
  final GltfRef<FloatAccessor> input;

  /// Interpolation algorithm.
  final AnimationInterpolation interpolation;

  /// The index of an accessor, containing keyframe output values.
  final GltfRef<RawAccessor> output;

  AnimationSampler({
    required super.root,
    required this.input,
    required this.interpolation,
    required this.output,
  });

  AnimationSampler.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        input: Parser.ref(root, map, 'input')!,
        interpolation:
            AnimationInterpolation.parse(map, 'interpolation') ??
            AnimationInterpolation.linear,
        output: Parser.ref(root, map, 'output')!,
      );
}
