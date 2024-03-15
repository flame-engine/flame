import 'package:behavior_tree/behavior_tree.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('Selector', () {
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
      expect(Selector.new, returnsNormally);
    });

    test('can be instantiated with the children.', () {
      expect(
        () => Selector(children: [Selector(), Selector()]),
        returnsNormally,
      );
    });

    test('default status is not started.', () {
      final selector = Selector();
      expect(selector.status, NodeStatus.notStarted);
    });

    test('can be ticked without the children.', () {
      final selector = Selector();
      expect(selector.tick, returnsNormally);
    });

    test('can be ticked with the children.', () {
      final selector = Selector(children: [Selector(), Selector()]);
      expect(selector.tick, returnsNormally);
    });

    test('succeeds if any one of the children succeeds.', () {
      final selector = Selector(children: [alwaysFailure, alwaysSuccess])
        ..tick();
      expect(selector.status, NodeStatus.success);
    });

    test('fails if all of the children fail.', () {
      final selector = Selector(children: [alwaysFailure, alwaysFailure])
        ..tick();
      expect(selector.status, NodeStatus.failure);
    });

    test('runs until all children fail.', () {
      final selector = Selector(
        children: [alwaysFailure, failureAfterTries],
      );

      var count = 0;
      while (count <= nTries) {
        selector.tick();

        expect(
          selector.status,
          count == nTries ? NodeStatus.failure : NodeStatus.running,
        );

        ++count;
      }

      verify(alwaysFailure.tick).called(count);
      expect(failureAfterTries.tickCount, count);
    });

    test('runs until one of the children succeeds.', () {
      final selector = Selector(children: [successAfterTries, alwaysFailure]);

      var count = 0;
      while (count <= nTries) {
        selector.tick();

        expect(
          selector.status,
          count == nTries ? NodeStatus.success : NodeStatus.running,
        );

        ++count;
      }

      verifyNever(alwaysFailure.tick);
      expect(successAfterTries.tickCount, count);
    });
  });
}

class _MockNode extends Mock implements NodeInterface {}

class _StatusAfterNTries extends BaseNode implements NodeInterface {
  _StatusAfterNTries(this.nTries, this.statusAfterTries);

  final int nTries;
  final NodeStatus statusAfterTries;

  var _tickCount = 0;
  int get tickCount => _tickCount;

  @override
  void tick() {
    status = _tickCount++ < nTries ? NodeStatus.running : statusAfterTries;
  }

  @override
  void reset() {
    super.reset();
    _tickCount = 0;
  }
}
