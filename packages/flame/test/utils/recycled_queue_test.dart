import 'dart:collection';
import 'dart:math';

import 'package:flame/src/utils/recycled_queue.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecycledQueue', () {
    test('simple writing/reading', () {
      final queue = RecycledQueue(_Int.new);
      expect(queue.isEmpty, true);
      expect(queue.isNotEmpty, false);
      expect(queue.length, 0);

      queue.addLast().value = 1;
      queue.addLast().value = 2;
      queue.addLast().value = 3;
      expect(queue.isEmpty, false);
      expect(queue.isNotEmpty, true);
      expect(queue.length, 3);

      expect(queue.first.value, 1);
      queue.removeFirst();
      expect(queue.first.value, 2);
      queue.removeFirst();
      expect(queue.first.value, 3);
      queue.removeFirst();
      expect(queue.isEmpty, true);
    });

    test('accessing empty queue', () {
      final queue = RecycledQueue(_Int.new);
      expect(queue.isEmpty, true);
      expect(
        () => queue.first,
        failsAssert('Cannot retrieve first element from an empty queue'),
      );
      expect(
        queue.removeFirst,
        failsAssert('Cannot remove elements from an empty queue'),
      );
    });

    test('queue with overflow', () {
      final queue = RecycledQueue(_Int.new, initialCapacity: 4);
      for (final x in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) {
        queue.addLast().value = x;
      }
      expect(queue.isEmpty, false);
      expect(queue.length, 10);

      for (var x = 1; x <= 10; x++) {
        expect(queue.first.value, x);
        queue.removeFirst();
      }
      expect(queue.isEmpty, true);

      queue.addLast().value = -1;
      expect(queue.first.value, -1);
    });

    test('queue with a hole', () {
      final queue = RecycledQueue(_Int.new);
      for (final x in [1, 2, 3, 4, 5, 6]) {
        queue.addLast().value = x;
      }
      queue.removeFirst();
      queue.removeFirst();
      expect(queue.first.value, 3);

      for (final x in [-1, -2, -3, -4, -5, -6, -7, -8]) {
        queue.addLast().value = x;
      }
      expect(queue.length, 12);
      for (final x in [3, 4, 5, 6, -1, -2, -3, -4, -5, -6, -7, -8]) {
        expect(queue.first.value, x);
        queue.removeFirst();
      }
      expect(queue.isEmpty, true);
    });

    testRandom('random attack', (Random random) {
      final queue0 = Queue<int>();
      final queue1 = RecycledQueue(_Int.new);
      var addAction = true;
      while (true) {
        expect(queue1.length, queue0.length);
        final rnd = random.nextDouble();
        if (rnd < 0.001) {
          break;
        }
        if (rnd < 0.05) {  // change action with 5% probability
          addAction = !addAction;
        }
        if (queue0.isEmpty || addAction) {
          final x = random.nextInt(1024);
          queue0.addLast(x);
          queue1.addLast().value = x;
        } else {
          final x = queue0.removeFirst();
          expect(queue1.first.value, x);
          queue1.removeFirst();
        }
      }
    });
  });
}

class _Int implements Disposable {
  int? value;

  @override
  void dispose() => value = null;

  @override
  String toString() => 'Int($value)';
}
