import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:material_ui/material_ui.dart';

/// Where the bone is, if there is one.
const _bonePosition = BlackboardKey<Vector2>('bonePosition');

class BasicExample() extends BehaviorTreeGame {
  this : super(height: 340);

  static const String description = '''
    This is a small behavior tree for a dog. Tap anywhere to throw a bone, and
    the dog fetches it and eats it. When there is no bone, the dog just pulses
    yellow.

    The tree is shown below the dog, and you can see which of its nodes is
    running at any moment. A selector tries its children in order until one
    does not fail, and a sequence runs its children in order until one does not
    succeed. So the tree reads: "if there is a bone, run to it and eat it,
    otherwise pulse".

    The tap puts the position of the bone on the blackboard, which is how the
    game talks to the tree. The nodes of the tree read it from there.
  ''';

  @override
  void onLoad() {
    final dog = _Dog();
    world.addAll([
      TapArea(size: Vector2(exampleWidth, 230), onTap: dog.throwBone),
      caption('Tap anywhere to throw a bone.', position: Vector2(12, 12)),
      dog,
      TreeView(dog, position: Vector2(12, 240)),
    ]);
  }
}

class _Dog() extends CircleComponent with HasBehaviorTree {
  this
    : super(
        radius: 12,
        position: Vector2(exampleWidth / 2, 130),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.cyan,
      );

  Component? _bone;

  void throwBone(Vector2 position) {
    _bone?.removeFromParent();
    _bone = RectangleComponent(
      position: position,
      size: Vector2(16, 7),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white,
    );
    parent!.add(_bone!);
    blackboard.set(_bonePosition, position);
    // The dog might be running to an older bone. Aborting the tree makes it
    // start over, so the `MoveTo` reads the position of the new bone.
    behaviorTree.abort();
  }

  void eatBone() {
    _bone?.removeFromParent();
    _bone = null;
    blackboard.remove(_bonePosition);
  }

  @override
  void onLoad() {
    behaviorTree = BehaviorTree(
      // This selector is reactive, so it checks its first child on every tick.
      // That makes the dog stop pulsing as soon as a bone appears.
      Selector(reactive: true, [
        named(
          'fetch the bone',
          Sequence([
            named(
              'is there a bone?',
              Condition((context) => context.blackboard.has(_bonePosition)),
            ),
            named(
              'run to it',
              MoveTo((context) => context.get(_bonePosition), speed: 140),
            ),
            named(
              'eat it',
              Task((context) {
                context.owner<_Dog>().eatBone();
                return Status.success;
              }),
            ),
          ]),
        ),
        named(
          'nothing to do, pulse',
          PlayEffect(
            (context) => ColorEffect(
              Colors.yellow,
              EffectController(duration: 0.5, alternate: true),
            ),
          ),
        ),
      ]),
      owner: this,
    );
  }
}
