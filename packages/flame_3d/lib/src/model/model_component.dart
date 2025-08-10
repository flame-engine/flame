import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/src/model/animation_state.dart';
import 'package:flame_3d/src/model/model.dart';

/// A component wrapper over a 3D [Model], using the [AnimationState] to keep
/// track and manage its animations.
class ModelComponent extends Object3D {
  final Model model;

  final Set<int> _hiddenNodes = {};
  final AnimationState _animation = AnimationState();

  ModelComponent({
    required this.model,
    super.position,
    super.rotation,
    super.scale,
  });

  Aabb3 get aabb => _aabb
    ..setFrom(model.aabb)
    ..transform(transformMatrix);
  final Aabb3 _aabb = Aabb3();

  @override
  void bind(GraphicsDevice device) {
    final nodes = model.processNodes(_animation);
    for (final MapEntry(key: index, value: node) in nodes.entries) {
      if (_hiddenNodes.contains(index)) {
        continue;
      }

      final mesh = node.node.mesh;
      if (mesh != null) {
        device.jointsInfo.jointTransformsPerSurface = node.jointTransforms;
        world.device
          ..model.setFrom(transformMatrix.multiplied(node.combinedTransform))
          ..bindMesh(mesh);
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    _animation.update(dt);
  }

  Set<String> get animationNames => model.animations
      .map((e) => e.name)
      .whereType<String>() // filter not null
      .toSet();

  void playAnimationByName(String name, {bool resetClock = true}) {
    final animation = model.animations.where((e) => e.name == name).firstOrNull;
    if (animation == null) {
      throw ArgumentError('No animation with name $name');
    }
    _animation.startAnimation(animation, resetClock: resetClock);
  }

  void playAnimationByIndex(int index, {bool resetClock = true}) {
    final animation = model.animations[index];
    _animation.startAnimation(animation, resetClock: resetClock);
  }

  void stopAnimation() {
    _animation.startAnimation(null);
  }

  void hideNodeByName(String name, {bool hidden = true}) {
    final node = model.nodes.entries.firstWhere((e) => e.value.name == name);
    if (hidden) {
      _hiddenNodes.add(node.key);
    } else {
      _hiddenNodes.remove(node.key);
    }
  }

  @override
  bool shouldCull(CameraComponent3D camera) {
    // TODO(luan): this actually does not work because of animations
    // it might end up culling something that is actually visible
    return camera.frustum.intersectsWithAabb3(aabb);
  }
}
