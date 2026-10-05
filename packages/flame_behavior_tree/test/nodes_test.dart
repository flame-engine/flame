import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PlayEffect', () {
    testWithFlameGame('runs until the effect completes', (game) async {
      final component = await _addAgent(game);
      final node = PlayEffect(
        (_) => MoveEffect.by(Vector2(10, 0), EffectController(duration: 1)),
      );
      final tree = BehaviorTree(node, owner: component);

      expect(tree.tick(0), Status.running);
      game.update(0.5);
      expect(tree.tick(0), Status.running);
      expect(component.position.x, closeTo(5, 0.01));

      game.update(0.6);
      expect(tree.tick(0), Status.success);
      expect(component.position.x, closeTo(10, 0.01));
    });

    testWithFlameGame('creates a new effect for every run', (game) async {
      final component = await _addAgent(game);
      var built = 0;
      final tree = BehaviorTree(
        PlayEffect((_) {
          built++;
          return MoveEffect.by(Vector2(1, 0), EffectController(duration: 0.1));
        }),
        owner: component,
      );

      tree.tick(0);
      game.update(0.2);
      expect(tree.tick(0), Status.success);

      tree.tick(0);
      expect(built, 2);
    });

    testWithFlameGame('adds the effect to the target if given', (game) async {
      final owner = await _addAgent(game);
      final target = await _addAgent(game);
      final tree = BehaviorTree(
        PlayEffect(
          (_) => MoveEffect.by(Vector2(10, 0), EffectController(duration: 1)),
          target: target,
        ),
        owner: owner,
      );

      tree.tick(0);
      game.update(1.1);
      expect(target.position.x, closeTo(10, 0.01));
      expect(owner.position.x, 0);
    });

    testWithFlameGame('removes the effect when aborted', (game) async {
      final component = await _addAgent(game);
      final tree = BehaviorTree(
        PlayEffect(
          (_) => MoveEffect.by(Vector2(10, 0), EffectController(duration: 1)),
        ),
        owner: component,
      );

      tree.tick(0);
      game.update(0.3);
      tree.abort();
      game.update(0.3);
      await game.ready();

      expect(component.children.whereType<Effect>(), isEmpty);
      expect(component.position.x, closeTo(3, 0.01));
    });

    testWithFlameGame('fails if the effect is removed before completing', (
      game,
    ) async {
      final component = await _addAgent(game);
      late Effect effect;
      final tree = BehaviorTree(
        PlayEffect((_) {
          return effect = MoveEffect.by(
            Vector2(10, 0),
            EffectController(duration: 1),
          );
        }),
        owner: component,
      );

      tree.tick(0);
      game.update(0.1);
      effect.removeFromParent();
      game.update(0.1);
      await game.ready();

      expect(tree.tick(0), Status.failure);
    });

    testWithFlameGame('fails if the effect is removed before it was mounted', (
      game,
    ) async {
      final component = await _addAgent(game);
      late Effect effect;
      final tree = BehaviorTree(
        PlayEffect((_) {
          return effect = MoveEffect.by(
            Vector2(10, 0),
            EffectController(duration: 1),
          );
        }),
        owner: component,
      );

      expect(tree.tick(0), Status.running);
      // The effect has not been mounted yet, so this only detaches it.
      effect.removeFromParent();

      expect(tree.tick(0), Status.failure);
    });

    testWithFlameGame('fails as soon as the removal of the effect is pending', (
      game,
    ) async {
      final component = await _addAgent(game);
      late Effect effect;
      final tree = BehaviorTree(
        PlayEffect((_) {
          return effect = MoveEffect.by(
            Vector2(10, 0),
            EffectController(duration: 1),
          );
        }),
        owner: component,
      );
      tree.tick(0);
      game.update(0.1);

      // The effect is only marked as removed in the next update.
      effect.removeFromParent();

      expect(tree.tick(0), Status.failure);
    });

    testWithFlameGame('needs a component as owner if there is no target', (
      game,
    ) async {
      final tree = BehaviorTree(
        PlayEffect(
          (_) => MoveEffect.by(Vector2(1, 0), EffectController(duration: 1)),
        ),
      );
      expect(() => tree.tick(0), throwsStateError);
    });
  });

  group('MoveTo', () {
    testWithFlameGame('moves the owner to the destination', (game) async {
      final component = await _addAgent(game);
      final tree = BehaviorTree(
        MoveTo((_) => Vector2(20, 10), duration: 1),
        owner: component,
      );

      expect(tree.tick(0), Status.running);
      game.update(1.1);
      expect(tree.tick(0), Status.success);
      expect(component.position, Vector2(20, 10));
    });

    testWithFlameGame('evaluates the destination every time it starts', (
      game,
    ) async {
      const destination = BlackboardKey<Vector2>('destination');
      final component = await _addAgent(game);
      final tree = BehaviorTree(
        MoveTo((context) => context.get(destination), duration: 0.1),
        owner: component,
      );

      tree.blackboard.set(destination, Vector2(10, 0));
      tree.tick(0);
      game.update(0.2);
      expect(tree.tick(0), Status.success);
      expect(component.position, Vector2(10, 0));

      tree.blackboard.set(destination, Vector2(10, 30));
      tree.tick(0);
      game.update(0.2);
      expect(tree.tick(0), Status.success);
      expect(component.position, Vector2(10, 30));
    });

    testWithFlameGame('moves at a constant speed', (game) async {
      final component = await _addAgent(game);
      final tree = BehaviorTree(
        MoveTo((_) => Vector2(100, 0), speed: 50),
        owner: component,
      );

      tree.tick(0);
      game.update(1);
      expect(component.position.x, closeTo(50, 0.01));
      expect(tree.tick(0), Status.running);

      game.update(1.1);
      expect(tree.tick(0), Status.success);
      expect(component.position.x, closeTo(100, 0.01));
    });

    testWithFlameGame('moves the target if given', (game) async {
      final owner = await _addAgent(game);
      final target = await _addAgent(game);
      final tree = BehaviorTree(
        MoveTo((_) => Vector2(5, 5), duration: 0.1, target: target),
        owner: owner,
      );

      tree.tick(0);
      game.update(0.2);
      expect(target.position, Vector2(5, 5));
      expect(owner.position, Vector2.zero());
    });

    testWithFlameGame('stops where it is when aborted', (game) async {
      final component = await _addAgent(game);
      final tree = BehaviorTree(
        MoveTo((_) => Vector2(10, 0), duration: 1),
        owner: component,
      );

      tree.tick(0);
      game.update(0.5);
      tree.abort();
      game.update(0.5);
      await game.ready();

      expect(component.position.x, closeTo(5, 0.01));
    });

    test('needs exactly one of duration and speed', () {
      expect(() => MoveTo((_) => Vector2.zero()), throwsAssertionError);
      expect(
        () => MoveTo((_) => Vector2.zero(), duration: 1, speed: 1),
        throwsAssertionError,
      );
    });
  });
}

Future<PositionComponent> _addAgent(FlameGame game) async {
  final component = PositionComponent();
  await game.ensureAdd(component);
  return component;
}
