import 'package:behavior_tree/behavior_tree.dart';
import 'package:test/test.dart';

void main() {
  group('AsyncTask', () {
    test('sets status to running when ticked.', () {
      final asyncTask = AsyncTask(() async => NodeStatus.success);
      asyncTask.tick();
      expect(asyncTask.status, NodeStatus.running);
    });

    test('updates status to the returned value of the callback.', () async {
      final asyncTask = AsyncTask(() async => NodeStatus.failure);
      asyncTask.tick();
      await Future.delayed(Duration.zero); // Wait for the callback to complete
      expect(asyncTask.status, equals(NodeStatus.failure));
    });
  });
}
