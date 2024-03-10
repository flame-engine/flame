import 'package:behavior_tree/behavior_tree.dart';
import 'package:test/test.dart';

void main() {
  group('Task', () {
    test('returns the status returned by the task callback', () {
      const expectedStatus = NodeStatus.success;
      final task = Task(() => expectedStatus);

      task.tick();
      expect(task.status, equals(expectedStatus));
    });

    test('executes the task callback when ticked', () {
      var executed = false;
      final task = Task(() {
        executed = true;
        return NodeStatus.success;
      });

      task.tick();
      expect(executed, isTrue);
    });
  });
}
