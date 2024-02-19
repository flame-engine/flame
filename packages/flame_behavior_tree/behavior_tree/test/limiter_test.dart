import 'package:behavior_tree/behavior_tree.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('Limiter', () {
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

    test('can be instantiated.', () {
      expect(() => Limiter(alwaysRunning, 5), returnsNormally);
    });

    test('default status same as status of child.', () {
      final limiter = Limiter(alwaysSuccess, 5);
      expect(limiter.status, alwaysSuccess.status);
    });

    test('limits tick count of child.', () {
      const limit = 5;
      final limiter = Limiter(alwaysRunning, limit);

      var count = 0;
      while (count < 23) {
        limiter.tick();
        ++count;
      }

      expect(limiter.tickCount, limit);
      expect(limiter.status, alwaysRunning.status);
    });

    test('overrides status after crossing limit.', () {
      const limit = 5;
      final failAfterLimit = Limiter(
        alwaysSuccess,
        limit,
        statusAfterLimit: NodeStatus.failure,
      );

      final succeedAfterLimit = Limiter(
        alwaysRunning,
        limit,
        statusAfterLimit: NodeStatus.success,
      );

      var count = 0;
      while (count < 23) {
        failAfterLimit.tick();
        succeedAfterLimit.tick();
        ++count;
      }

      expect(failAfterLimit.status, NodeStatus.failure);
      expect(succeedAfterLimit.status, NodeStatus.success);
    });
  });
}

class _MockNode extends Mock implements Node {}
