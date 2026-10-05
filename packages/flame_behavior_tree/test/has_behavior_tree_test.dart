import 'package:flame/components.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HasBehaviorTree', () {
    test('throws a descriptive error if the tree is accessed before set', () {
      final component = _BehaviorTreeComponent();
      expect(() => component.behaviorTree, throwsStateError);
      expect(() => component.blackboard, throwsStateError);
    });

    test('tick interval can be changed', () {
      final component = _BehaviorTreeComponent();
      expect(component.tickInterval, 0);

      component.tickInterval = 3;
      expect(component.tickInterval, 3);

      component.tickInterval = -53;
      expect(component.tickInterval, 0);
    });

    test('exposes the blackboard of the tree', () {
      final blackboard = Blackboard();
      final component = _BehaviorTreeComponent()
        ..behaviorTree = BehaviorTree(
          Task((_) => Status.success),
          blackboard: blackboard,
        );
      expect(component.blackboard, same(blackboard));
    });

    testWithFlameGame('updates with no tree', (game) async {
      await game.ensureAdd(_BehaviorTreeComponent());
      expect(() => game.update(1), returnsNormally);
    });

    testWithFlameGame('ticks the tree on every update', (game) async {
      final ticks = <double>[];
      final component = _BehaviorTreeComponent()
        ..behaviorTree = BehaviorTree(
          Task((context) {
            ticks.add(context.dt);
            return Status.success;
          }),
        );
      await game.ensureAdd(component);

      game.update(0.1);
      game.update(0.2);
      expect(ticks, [0.1, 0.2]);
    });

    testWithFlameGame('the tree can access the component as owner', (
      game,
    ) async {
      _BehaviorTreeComponent? owner;
      final component = _BehaviorTreeComponent();
      component.behaviorTree = BehaviorTree(
        Task((context) {
          owner = context.owner<_BehaviorTreeComponent>();
          return Status.success;
        }),
        owner: component,
      );
      await game.ensureAdd(component);

      game.update(0.1);
      expect(owner, same(component));
    });

    testWithFlameGame('nodes can share data through the blackboard', (
      game,
    ) async {
      const counter = BlackboardKey<int>('counter', initial: 0);
      final component = _BehaviorTreeComponent()
        ..behaviorTree = BehaviorTree(
          Sequence([
            Task((context) {
              context.set(counter, context.get(counter) + 1);
              return Status.success;
            }),
            Task((context) {
              context.set(counter, context.get(counter) + 10);
              return Status.success;
            }),
          ]),
        );
      await game.ensureAdd(component);

      game.update(0.1);
      game.update(0.1);
      expect(component.blackboard.get(counter), 22);
    });

    group('tick interval', () {
      testWithFlameGame('ticks the tree at a slower rate', (game) async {
        final ticks = <double>[];
        final component = _BehaviorTreeComponent()
          ..tickInterval = 1
          ..behaviorTree = BehaviorTree(
            Task((context) {
              ticks.add(context.dt);
              return Status.success;
            }),
          );
        await game.ensureAdd(component);

        const dt = 0.25;
        for (var i = 0; i < 12; i++) {
          game.update(dt);
        }

        // Immediately on the first update, then once the interval has passed.
        expect(ticks, [dt, 1, 1]);
      });

      testWithFlameGame('can be changed after the component loaded', (
        game,
      ) async {
        var ticks = 0;
        final component = _BehaviorTreeComponent()
          ..behaviorTree = BehaviorTree(
            Task((_) {
              ticks++;
              return Status.success;
            }),
          );
        await game.ensureAdd(component);

        game.update(0.5);
        expect(ticks, 1);

        component.tickInterval = 1;
        for (var i = 0; i < 4; i++) {
          game.update(0.5);
        }
        expect(ticks, 3);
      });
    });

    testWithFlameGame('ticks right away when it is mounted again', (
      game,
    ) async {
      var ticks = 0;
      final component = _BehaviorTreeComponent()
        ..tickInterval = 1
        ..behaviorTree = BehaviorTree(
          Task((_) {
            ticks++;
            return Status.success;
          }),
        );
      await game.ensureAdd(component);

      game.update(0.25);
      expect(ticks, 1);
      // Not yet ticked again, but time has been collected.
      game.update(0.25);
      expect(ticks, 1);

      component.removeFromParent();
      await game.ready();
      await game.ensureAdd(component);

      // The first tick is not delayed, and does not use the time of before.
      game.update(0.25);
      expect(ticks, 2);
      game.update(0.25);
      expect(ticks, 2);
    });

    group('lifecycle', () {
      testWithFlameGame('aborts the tree when the component is removed', (
        game,
      ) async {
        var aborted = 0;
        final component = _BehaviorTreeComponent()
          ..behaviorTree = BehaviorTree(
            Task((_) => Status.running, onAbortCallback: (_) => aborted++),
          );
        await game.ensureAdd(component);
        game.update(0.1);

        component.removeFromParent();
        await game.ready();
        expect(aborted, 1);
      });

      testWithFlameGame('aborts the previous tree when replaced', (
        game,
      ) async {
        var aborted = 0;
        final component = _BehaviorTreeComponent()
          ..behaviorTree = BehaviorTree(
            Task((_) => Status.running, onAbortCallback: (_) => aborted++),
          );
        await game.ensureAdd(component);
        game.update(0.1);

        component.behaviorTree = BehaviorTree(Task((_) => Status.success));
        expect(aborted, 1);
      });
    });
  });
}

class _BehaviorTreeComponent() extends Component with HasBehaviorTree;
