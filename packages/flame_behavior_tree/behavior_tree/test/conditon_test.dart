import 'package:behavior_tree/behavior_tree.dart';
import 'package:test/test.dart';

void main() {
  group('Condition', () {
    test('status is success when condition returns true', () {
      final condition = Condition(() => true);
      condition.tick();
      expect(condition.status, NodeStatus.success);
    });

    test('status is failure when condition returns false', () {
      final condition = Condition(() => false);
      condition.tick();
      expect(condition.status, NodeStatus.failure);
    });
  });
}
