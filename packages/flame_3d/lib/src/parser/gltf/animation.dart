import 'package:flame_3d/src/model/model_animation.dart';
import 'package:flame_3d/src/parser/gltf/animation_channel.dart';
import 'package:flame_3d/src/parser/gltf/animation_path.dart';
import 'package:flame_3d/src/parser/gltf/animation_sampler.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// A keyframe animation.
class Animation extends GltfNode {
  final String? name;

  /// An array of animation channels.
  /// An animation channel combines an animation sampler with a target property
  /// being animated.
  /// Different channels of the same animation **MUST NOT** have the same
  /// targets.
  final List<AnimationChannel> channels;

  /// An array of animation samplers.
  /// An animation sampler combines timestamps with a sequence of output values
  /// and defines an interpolation algorithm.
  final List<AnimationSampler> samplers;

  Animation({
    required super.root,
    required this.name,
    required this.channels,
    required this.samplers,
  });

  Animation.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        name: Parser.string(map, 'name'),
        channels: Parser.objectList(
          root,
          map,
          'channels',
          AnimationChannel.parse,
        )!,
        samplers: Parser.objectList(
          root,
          map,
          'samplers',
          AnimationSampler.parse,
        )!,
      );

  ModelAnimation toFlameAnimation() {
    final controllers = <int, List<AnimationController>>{};
    for (final channel in channels) {
      final path = channel.target.path;
      final sampler = samplers[channel.sampler];

      final times = sampler.input.get().typedData();
      final values = sampler.output.get();

      final spline =
          switch (path) {
                AnimationPath.translation => TranslationAnimationSpline.from(
                  interpolation: sampler.interpolation,
                  times: times,
                  values: values.asVector3().typedData(),
                ),
                AnimationPath.scale => ScaleAnimationSpline.from(
                  interpolation: sampler.interpolation,
                  times: times,
                  values: values.asVector3().typedData(),
                ),
                AnimationPath.rotation => RotationAnimationSpline.from(
                  interpolation: sampler.interpolation,
                  times: times,
                  values: values.asQuaternion().typedData(),
                ),
                AnimationPath.weights => throw UnimplementedError(),
              }
              as AnimationSpline;

      final nodeIndex = channel.target.node.index;
      (controllers[nodeIndex] ??= []).add(
        AnimationController(
          animation: spline,
        ),
      );
    }
    final nodes = controllers.map(
      (key, value) => MapEntry(
        key,
        NodeAnimation(
          channels: value,
        ),
      ),
    );
    return ModelAnimation(
      name: name,
      nodes: nodes,
    );
  }
}
