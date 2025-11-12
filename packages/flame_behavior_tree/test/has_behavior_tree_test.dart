import 'package:flame/components.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('HasBehaviorTree', () {
    final alwaysFailure = _MockNode();
    final alwaysSuccess = _MockNode();
    final alwaysRunning = _MockNode();

    setUp(() {
      reset(alwaysFailure);
      reset(alwaysSuccess);
      reset(alwaysRunning);

      when(() => alwaysFailure.status).thenReturn(NodeStatus.failure);
      when(() => alwaysSuccess.status).thenReturn(NodeStatus.success);
      when(() => alwaysRunning.status).thenReturn(NodeStatus.running);
    });

    testWithFlameGame(
      'updates with null tree.',
      (game) async {
        final component = _BehaviorTreeComponent();
        expect(() => game.add(component), returnsNormally);
      },
    );

    test('tick interval can be changed', () {
      final component = _BehaviorTreeComponent();
      expect(component.tickInterval, 0);

      component.tickInterval = 3;
      expect(component.tickInterval, 3);

      component.tickInterval = -53;
      expect(component.tickInterval, 0);
    });

    test('throws if treeNode is accessed before setting.', () {
      final component = _BehaviorTreeComponent();
      expect(() => component.treeRoot, throwsA(isA<TypeError>()));

      component.treeRoot = _MockNode();
      expect(() => component.treeRoot, returnsNormally);
    });

    testWithFlameGame(
      'updates without errors with a valid tree.',
      (game) async {
        final component = _BehaviorTreeComponent()
          ..treeRoot = Sequence(
            children: [alwaysSuccess, alwaysFailure, alwaysRunning],
          );

        expect(() async => await game.add(component), returnsNormally);

        await game.ready();
        expect(() => game.update(10), returnsNormally);

        verify(alwaysSuccess.tick).called(1);
        verify(alwaysFailure.tick).called(1);
        verifyNever(alwaysRunning.tick);
      },
    );

    testWithFlameGame(
      'tree updates at a slower rate.',
      (game) async {
        final component = _BehaviorTreeComponent()
          ..treeRoot = Sequence(
            children: [alwaysSuccess, alwaysFailure, alwaysRunning],
          )
          ..tickInterval = 1;

        await game.add(component);
        await game.ready();

        const dt = 1 / 60;
        const gameTime = 3.0;
        var elapsedTime = 0.0;

        while (elapsedTime < gameTime) {
          game.update(dt);
          elapsedTime += dt;
        }

        verify(alwaysSuccess.tick).called(gameTime.toInt());
        verify(alwaysFailure.tick).called(gameTime.toInt());
        verifyNever(alwaysRunning.tick);
      },
    );

    group('Blackboard support', () {
      test('blackboard can be set and retrieved', () {
        final component = _BehaviorTreeComponent();
        expect(component.blackboard, isNull);

        final blackboard = Blackboard();
        component.blackboard = blackboard;

        expect(component.blackboard, same(blackboard));
      });

      test('blackboard can be set to null', () {
        final component = _BehaviorTreeComponent();
        final blackboard = Blackboard();
        component.blackboard = blackboard;

        component.blackboard = null;
        expect(component.blackboard, isNull);
      });

      test('implements BlackboardProvider', () {
        final component = _BehaviorTreeComponent();
        expect(component, isA<BlackboardProvider>());
      });

      testWithFlameGame(
        'nodes can access blackboard through component',
        (game) async {
          final component = _BehaviorTreeComponent();
          final blackboard = Blackboard();
          blackboard.set('testValue', 42);

          component.blackboard = blackboard;

          final task = _TestTask();
          component.treeRoot = Sequence(children: [task]);

          await game.add(component);
          await game.ready();

          game.update(0.1);

          expect(task.retrievedValue, 42);
        },
      );

      testWithFlameGame(
        'nested nodes can access blackboard',
        (game) async {
          final component = _BehaviorTreeComponent();
          final blackboard = Blackboard();
          blackboard.set('nestedValue', 'hello');

          component.blackboard = blackboard;

          final deepTask = _TestTask();
          final innerSequence = Sequence(children: [deepTask]);
          final outerSequence = Sequence(children: [innerSequence]);
          component.treeRoot = outerSequence;

          await game.add(component);
          await game.ready();

          game.update(0.1);

          expect(deepTask.retrievedValue, 'hello');
        },
      );

      testWithFlameGame(
        'nodes can modify blackboard',
        (game) async {
          final component = _BehaviorTreeComponent();
          final blackboard = Blackboard();
          blackboard.set('counter', 0);

          component.blackboard = blackboard;

          final incrementTask = _IncrementTask();
          component.treeRoot = Sequence(children: [incrementTask]);

          await game.add(component);
          await game.ready();

          game.update(0.1);
          expect(blackboard.get<int>('counter'), 1);

          component.treeRoot.reset();
          game.update(0.1);
          expect(blackboard.get<int>('counter'), 2);
        },
      );

      testWithFlameGame(
        'multiple nodes share same blackboard',
        (game) async {
          final component = _BehaviorTreeComponent();
          final blackboard = Blackboard();
          blackboard.set('shared', 0);

          component.blackboard = blackboard;

          final task1 = _IncrementSharedTask();
          final task2 = _IncrementSharedTask();
          final task3 = _IncrementSharedTask();

          component.treeRoot = Sequence(children: [task1, task2, task3]);

          await game.add(component);
          await game.ready();

          game.update(0.1);

          expect(blackboard.get<int>('shared'), 3);
        },
      );

      testWithFlameGame(
        'nodes work without blackboard set',
        (game) async {
          final component = _BehaviorTreeComponent();
          // No blackboard set

          final task = _TestTask();
          component.treeRoot = Sequence(children: [task]);

          await game.add(component);
          await game.ready();

          expect(() => game.update(0.1), returnsNormally);
          expect(task.retrievedValue, isNull);
        },
      );

      testWithFlameGame(
        'blackboard provider is set on root node',
        (game) async {
          final component = _BehaviorTreeComponent();
          final blackboard = Blackboard();
          component.blackboard = blackboard;

          final rootNode = Sequence(children: []);
          component.treeRoot = rootNode;

          await game.add(component);
          await game.ready();

          // Root node should have access to blackboard
          expect(rootNode.blackboard, same(blackboard));
        },
      );

      testWithFlameGame(
        'changing blackboard updates accessible data',
        (game) async {
          final component = _BehaviorTreeComponent();
          final blackboard1 = Blackboard();
          blackboard1.set('value', 'first');

          component.blackboard = blackboard1;

          final task = _TestTask();
          component.treeRoot = Sequence(children: [task]);

          await game.add(component);
          await game.ready();

          game.update(0.1);
          expect(task.retrievedValue, 'first');

          // Change to a different blackboard
          final blackboard2 = Blackboard();
          blackboard2.set('value', 'second');
          component.blackboard = blackboard2;

          component.treeRoot.reset();
          game.update(0.1);
          expect(task.retrievedValue, 'second');
        },
      );
    });
  });
}

class _BehaviorTreeComponent extends Component with HasBehaviorTree {}

class _MockNode extends Mock implements NodeInterface {}

// Test helper nodes for blackboard testing

class _TestTask extends BaseNode {
  Object? retrievedValue;

  @override
  void tick() {
    if (blackboard?.has('testValue') ?? false) {
      retrievedValue = blackboard?.get('testValue');
    } else if (blackboard?.has('nestedValue') ?? false) {
      retrievedValue = blackboard?.get('nestedValue');
    } else if (blackboard?.has('value') ?? false) {
      retrievedValue = blackboard?.get('value');
    }
    status = NodeStatus.success;
  }
}

class _IncrementTask extends BaseNode {
  @override
  void tick() {
    final current = blackboard?.get<int>('counter') ?? 0;
    blackboard?.set('counter', current + 1);
    status = NodeStatus.success;
  }
}

class _IncrementSharedTask extends BaseNode {
  @override
  void tick() {
    final current = blackboard?.get<int>('shared') ?? 0;
    blackboard?.set('shared', current + 1);
    status = NodeStatus.success;
  }
}
