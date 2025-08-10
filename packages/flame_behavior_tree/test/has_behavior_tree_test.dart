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
  });
}

class _BehaviorTreeComponent extends Component with HasBehaviorTree {}

class _MockNode extends Mock implements NodeInterface {}
