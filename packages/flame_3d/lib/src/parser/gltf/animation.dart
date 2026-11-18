import 'package:flame_3d/src/model/model_animation.dart';
import 'package:flame_3d/src/parser/gltf/animation_channel.dart';
import 'package:flame_3d/src/parser/gltf/animation_interpolation.dart';
import 'package:flame_3d/src/parser/gltf/animation_path.dart';
import 'package:flame_3d/src/parser/gltf/animation_sampler.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';

/// A keyframe animation.
class Animation({
  required super.root,
  required final String? name,
  required final List<AnimationChannel> channels,
  required final List<AnimationSampler> samplers,
}) extends GltfNode {
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
    final morphChannels = <int, MorphWeightsChannel>{};

    for (final channel in channels) {
      final path = channel.target.path;
      final sampler = samplers[channel.sampler];
      final nodeIndex = channel.target.node.index;

      final times = sampler.input.get().typedData();
      final values = sampler.output.get();

      if (path == AnimationPath.weights) {
        final rawWeights = values.asFloat().typedData();
        final divisor =
            sampler.interpolation == AnimationInterpolation.cubicSpline
            ? times.length * 3
            : times.length;
        final targetCount = divisor > 0 ? rawWeights.length ~/ divisor : 0;
        if (targetCount > 0) {
          morphChannels[nodeIndex] = MorphWeightsChannel(
            interpolation: sampler.interpolation,
            times: times,
            weights: rawWeights,
            targetCount: targetCount,
          );
        }
        continue;
      }

      final spline = switch (path) {
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
        AnimationPath.weights => throw StateError('Unreachable'),
      } as AnimationSpline;

      (controllers[nodeIndex] ??= []).add(
        AnimationController(
          animation: spline,
        ),
      );
    }

    final allNodeIndices = <int>{...controllers.keys, ...morphChannels.keys};
    final nodes = <int, NodeAnimation>{
      for (final idx in allNodeIndices)
        idx: NodeAnimation(
          channels: controllers[idx] ?? const [],
          morphWeights: morphChannels[idx],
        ),
    };
    return ModelAnimation(
      name: name,
      nodes: nodes,
    );
  }
}
