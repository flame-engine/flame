import 'package:flame/components.dart';
import 'package:flame/devtools.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:flame_behavior_tree/src/devtools/behavior_tree_connector.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

class _Agent() extends PositionComponent with HasBehaviorTree;

void main() {
  group('describeBehaviorTree', () {
    test('has no tree for a plain component', () {
      expect(describeBehaviorTree(Component()), {'hasBehaviorTree': false});
    });

    test('has no tree if none was set yet', () {
      expect(describeBehaviorTree(_Agent()), {'hasBehaviorTree': false});
    });

    test('describes the nodes of the tree', () {
      final agent = _Agent()
        ..tickInterval = 0.5
        ..behaviorTree = BehaviorTree(
          Selector([
            Sequence([
              Condition((_) => true)..name = 'always',
              Task((_) => Status.running),
            ])..name = 'main',
            Inverter(Wait(1)),
          ]),
        );
      agent.behaviorTree.tick(0.1);

      final description = describeBehaviorTree(agent);

      expect(description['hasBehaviorTree'], isTrue);
      expect(description['tickInterval'], 0.5);
      expect(description['status'], 'running');
      expect(description['tree'], {
        'type': 'Selector',
        'status': 'running',
        'isRunning': true,
        'children': [
          {
            'type': 'Sequence',
            'name': 'main',
            'status': 'running',
            'isRunning': true,
            'children': [
              {
                'type': 'Condition',
                'name': 'always',
                'status': 'success',
                'isRunning': false,
                'children': <Object?>[],
              },
              {
                'type': 'Task',
                'status': 'running',
                'isRunning': true,
                'children': <Object?>[],
              },
            ],
          },
          {
            'type': 'Inverter',
            'status': null,
            'isRunning': false,
            'children': [
              {
                'type': 'Wait',
                'status': null,
                'isRunning': false,
                'children': <Object?>[],
              },
            ],
          },
        ],
      });
    });

    test('has no status for nodes that were aborted', () {
      final agent = _Agent()
        ..behaviorTree = BehaviorTree(Task((_) => Status.running));
      agent.behaviorTree.tick(0);
      agent.behaviorTree.abort();

      final tree = describeBehaviorTree(agent)['tree'] as Map<String, dynamic>;
      expect(tree['status'], isNull);
      expect(tree['isRunning'], isFalse);
    });

    test('lists the blackboard sorted by key', () {
      const health = BlackboardKey<int>('health');
      const name = BlackboardKey<String>('name');
      const target = BlackboardKey<Vector2?>('target');
      final agent = _Agent()
        ..behaviorTree = BehaviorTree(Task((_) => Status.success));
      agent.blackboard
        ..set(name, 'Dash')
        ..set(health, 3)
        ..set(target, null);

      expect(describeBehaviorTree(agent)['blackboard'], [
        {'key': 'health', 'value': '3'},
        {'key': 'name', 'value': 'Dash'},
        {'key': 'target', 'value': 'null'},
      ]);
    });
  });

  group('BehaviorTreeConnector', () {
    testWithFlameGame('is registered once, when a component is mounted', (
      game,
    ) async {
      final connectors = DevToolsService.instance.connectors;
      final registered = connectors.whereType<BehaviorTreeConnector>();
      addTearDown(
        () => connectors.removeWhere((c) => c is BehaviorTreeConnector),
      );

      expect(registered, isEmpty);

      await game.ensureAdd(_Agent());
      await game.ensureAdd(_Agent());

      expect(registered, hasLength(1));
      expect(registered.single.game, game);
    });
  });
}
