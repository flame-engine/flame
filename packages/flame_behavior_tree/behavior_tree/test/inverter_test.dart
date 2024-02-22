import 'package:behavior_tree/behavior_tree.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

void main() {
  group('Inverter', () {
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
      expect(() => Inverter(alwaysRunning), returnsNormally);
    });

    test('default status is inverted child status.', () {
      final inverter = Inverter(alwaysSuccess);
      expect(inverter.status, NodeStatus.failure);
    });

    test('inverts status of child.', () {
      final inverter1 = Inverter(alwaysSuccess)..tick();
      expect(inverter1.status, NodeStatus.failure);

      final inverter2 = Inverter(alwaysFailure)..tick();
      expect(inverter2.status, NodeStatus.success);
    });

    test('keeping running if child is running.', () {
      final inverter = Inverter(alwaysRunning)..tick();
      expect(inverter.status, NodeStatus.running);
    });
  });
}

class _MockNode extends Mock implements INode {}
