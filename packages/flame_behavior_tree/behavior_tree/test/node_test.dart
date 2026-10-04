import 'package:behavior_tree/behavior_tree.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Node', () {
    test('is idle before it is ticked', () {
      final node = ScriptedNode.always(Status.success);
      expect(node.isRunning, isFalse);
      expect(node.lastStatus, isNull);
    });

    test('has no name by default, and one can be set', () {
      final node = ScriptedNode.always(Status.success);
      expect(node.name, isNull);

      node.name = 'a node';
      expect(node.name, 'a node');
    });

    test('tick returns and remembers the status', () {
      final node = ScriptedNode.always(Status.failure);
      expect(node.tick(context()), Status.failure);
      expect(node.lastStatus, Status.failure);
      expect(node.isRunning, isFalse);
    });

    test('calls onEnter once per run and onExit when it finishes', () {
      final node = ScriptedNode([
        Status.running,
        Status.running,
        Status.success,
        Status.running,
      ]);

      node.tick(context());
      node.tick(context());
      expect(node.isRunning, isTrue);
      expect(node.enters, 1);
      expect(node.exits, 0);

      node.tick(context());
      expect(node.isRunning, isFalse);
      expect(node.exits, 1);

      node.tick(context());
      expect(node.enters, 2);
    });

    test('abort interrupts a running node', () {
      final node = ScriptedNode.always(Status.running)..tick(context());
      node.abort(context());

      expect(node.aborts, 1);
      expect(node.exits, 0);
      expect(node.isRunning, isFalse);
      expect(node.lastStatus, isNull);
    });

    test('abort does nothing if the node is not running', () {
      final node = ScriptedNode.always(Status.success)..tick(context());
      node.abort(context());
      expect(node.aborts, 0);
    });

    test('a node is entered again after an abort', () {
      final node = ScriptedNode.always(Status.running)..tick(context());
      node.abort(context());
      node.tick(context());
      expect(node.enters, 2);
    });
  });

  group('BehaviorTree', () {
    test('ticks the root with the blackboard, owner and dt', () {
      const key = BlackboardKey<double>('dt');
      final tree = BehaviorTree(
        Task((context) {
          context.set(key, context.dt);
          expect(context.owner<String>(), 'owner');
          return Status.success;
        }),
        owner: 'owner',
      );

      expect(tree.lastStatus, isNull);
      expect(tree.tick(0.5), Status.success);
      expect(tree.lastStatus, Status.success);
      expect(tree.blackboard.get(key), 0.5);
    });

    test('uses the provided blackboard', () {
      const key = BlackboardKey<int>('key');
      final blackboard = Blackboard()..set(key, 1);
      final tree = BehaviorTree(
        Task((context) {
          context.set(key, context.get(key) + 1);
          return Status.success;
        }),
        blackboard: blackboard,
      )..tick(0);
      expect(blackboard.get(key), 2);
      expect(tree.blackboard, same(blackboard));
    });

    test('abort aborts the running nodes', () {
      final running = ScriptedNode.always(Status.running);
      final tree = BehaviorTree(Sequence([running]))..tick(0);
      expect(running.isRunning, isTrue);

      tree.abort();
      expect(running.aborts, 1);
      expect(running.isRunning, isFalse);
    });
  });
}
