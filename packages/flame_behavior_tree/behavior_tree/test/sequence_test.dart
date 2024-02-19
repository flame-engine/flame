import 'package:behavior_tree/behavior_tree.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('Sequence', () {
    const nTries = 20;
    final alwaysFailure = _MockNode();
    final alwaysSuccess = _MockNode();
    final alwaysRunning = _MockNode();
    final successAfterTries = _StatusAfterNTries(nTries, NodeStatus.success);
    final failureAfterTries = _StatusAfterNTries(nTries, NodeStatus.failure);

    setUp(() {
      reset(alwaysFailure);
      reset(alwaysSuccess);
      reset(alwaysRunning);

      when(() => alwaysFailure.status).thenReturn(NodeStatus.failure);
      when(() => alwaysSuccess.status).thenReturn(NodeStatus.success);
      when(() => alwaysRunning.status).thenReturn(NodeStatus.running);

      successAfterTries.reset();
      failureAfterTries.reset();
    });

    test('can be instantiated without the children.', () {
      expect(Sequence.new, returnsNormally);
    });

    test('can be instantiated with the children.', () {
      expect(
        () => Sequence(children: [Sequence(), Sequence()]),
        returnsNormally,
      );
    });

    test('default status is running.', () {
      final sequence = Sequence();
      expect(sequence.status, NodeStatus.running);
    });

    test('can be ticked without the children.', () {
      final selector = Sequence();
      expect(selector.tick, returnsNormally);
    });

    test('can be ticked with the children.', () {
      final selector = Sequence(children: [Sequence(), Sequence()]);
      expect(selector.tick, returnsNormally);
    });

    test('succeeds if all of the children succeed.', () {
      final sequence = Sequence(children: [alwaysSuccess, alwaysSuccess])
        ..tick();
      expect(sequence.status, NodeStatus.success);
    });

    test('fails if any of the children fails.', () {
      final sequence = Sequence(children: [alwaysSuccess, alwaysFailure])
        ..tick();
      expect(sequence.status, NodeStatus.failure);
    });

    test('runs until first failure.', () {
      final sequence = Sequence(
        children: [alwaysSuccess, failureAfterTries],
      );

      var count = 0;
      while (count <= nTries) {
        sequence.tick();

        expect(
          sequence.status,
          count == nTries ? NodeStatus.failure : NodeStatus.running,
        );

        ++count;
      }

      verify(alwaysSuccess.tick).called(count);
      expect(failureAfterTries.tickCount, count);
    });

    test('runs until all children succeed.', () {
      final sequence = Sequence(children: [alwaysSuccess, successAfterTries]);

      var count = 0;
      while (count <= nTries) {
        sequence.tick();

        expect(
          sequence.status,
          count == nTries ? NodeStatus.success : NodeStatus.running,
        );

        ++count;
      }

      verify(alwaysSuccess.tick).called(count);
      expect(successAfterTries.tickCount, count);
    });
  });
}

class _MockNode extends Mock implements Node {}

class _StatusAfterNTries implements Node {
  _StatusAfterNTries(this.nTries, this.statusAfterTries);

  final int nTries;
  final NodeStatus statusAfterTries;

  var _tickCount = 0;
  var _nodeStatus = NodeStatus.running;

  int get tickCount => _tickCount;

  @override
  NodeStatus get status => _nodeStatus;

  @override
  void tick() {
    _nodeStatus = _tickCount++ < nTries ? NodeStatus.running : statusAfterTries;
  }

  void reset() {
    _tickCount = 0;
    _nodeStatus = NodeStatus.running;
  }
}
