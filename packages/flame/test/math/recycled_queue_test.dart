import 'dart:collection';
import 'dart:math';

import 'package:flame/src/components/core/recycled_queue.dart';
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
      expect(queue.last.value, 3);

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
        failsAssert('Cannot retrieve elements from an empty queue'),
      );
      expect(
        () => queue.last,
        failsAssert('Cannot retrieve elements from an empty queue'),
      );
      expect(
        queue.removeFirst,
        failsAssert('Cannot remove elements from an empty queue'),
      );
      expect(
        queue.removeCurrent,
        failsAssert('Cannot remove current element if not iterating'),
      );
    });

    test('queue with no initial capacity', () {
      final queue = RecycledQueue(_Int.new, initialCapacity: 0);
      expect(queue.isEmpty, true);
      queue.addLast().value = 42;
      expect(queue.isEmpty, false);
      expect(queue.first.value, 42);
      expect(queue.last.value, 42);
    });

    test('queue with overflow', () {
      final queue = RecycledQueue(_Int.new, initialCapacity: 4);
      for (final x in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) {
        queue.addLast().value = x;
      }
      expect(queue.isEmpty, false);
      expect(queue.length, 10);

      for (var x = 1; x <= 10; x++) {
        expect(queue.first, _Int(x));
        queue.removeFirst();
      }
      expect(queue.isEmpty, true);

      queue.addLast().value = -1;
      expect(queue.first, _Int(-1));
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

    testRandom('random attack: add/remove elements', (Random random) {
      final queue0 = Queue<int>();
      final queue1 = RecycledQueue(_Int.new);
      var addAction = true;
      while (true) {
        expect(queue1.length, queue0.length);
        final rnd = random.nextDouble();
        if (rnd < 0.001) {
          break;
        }
        if (rnd < 0.05) {
          // change action with 5% probability
          addAction = !addAction;
        }
        if (queue0.isEmpty || addAction) {
          final x = random.nextInt(1024);
          queue0.addLast(x);
          queue1.addLast().value = x;
        } else {
          final x = queue0.removeFirst();
          expect(queue1.first, _Int(x));
          queue1.removeFirst();
        }
      }
    });

    group('iteration', () {
      test('iterate over an empty queue', () {
        final queue1 = RecycledQueue(_Int.new, initialCapacity: 0);
        expect(queue1.toList(), <_Int>[]);
        expect(queue1.toString(), 'RecycledQueue()');
        final queue2 = RecycledQueue(_Int.new, initialCapacity: 4);
        expect(queue2.toList(), <_Int>[]);
      });

      test('iterate over a single-element queue', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 0);
        queue.addLast().value = 13;
        expect(queue.toList(), [_Int(13)]);
        expect(queue.toString(), 'RecycledQueue(<13>)');
      });

      test('iterate over a simple queue', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 0);
        for (final x in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]) {
          queue.addLast().value = x;
        }
        expect(queue.toList(), [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map(_Int.new));
        expect(
          queue.toString(),
          'RecycledQueue(<1>, <2>, <3>, <4>, <5>, <6>, <7>, <8>, <9>, <10>)',
        );
      });

      test('iterate over a queue with a gap', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 2);
        for (final x in [0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 5]) {
          queue.addLast().value = x;
        }
        while (queue.first.value == 0) {
          queue.removeFirst();
        }
        for (final x in [6, 7, 8, 9]) {
          queue.addLast().value = x;
        }
        expect(queue.toList(), [1, 2, 3, 4, 5, 6, 7, 8, 9].map(_Int.new));
      });

      test('toString() while iterating', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 0);
        for (final x in [1, 2, 3, 4, 5]) {
          queue.addLast().value = x;
        }
        var i = 1;
        for (final x in queue) {
          expect(x.value, i);
          i += 1;
          expect('$queue', 'RecycledQueue(<1>, <2>, <3>, <4>, <5>)');
        }
        expect(i, 6);
      });

      test('add elements while iterating', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 3);
        queue.addLast().value = 1;
        queue.addLast().value = 1;
        queue.removeFirst();
        var i = 5;
        for (final _ in queue) {
          queue.addLast().value = i;
          i += 1;
          if (i > 10) {
            break;
          }
        }
        expect(queue.toList(), [1, 5, 6, 7, 8, 9, 10].map(_Int.new));
      });

      test('add elements while iterating a wrapped-around queue', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 0);
        queue.addLast().value = 1;
        queue.addLast().value = 1;
        queue.removeFirst();
        queue.addLast().value = 2;
        var i = 3;
        for (final _ in queue) {
          queue.addLast().value = i;
          i += 1;
          if (i > 6) {
            break;
          }
        }
        expect(queue.toList(), [1, 2, 3, 4, 5, 6].map(_Int.new));
      });

      test('remove elements while iterating', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 0);
        for (final x in [0, 0, 0, 0, 1, 2, 0, 3, 4, 5, 0, 0]) {
          queue.addLast().value = x;
        }
        for (final element in queue) {
          if (element.value == 0) {
            queue.removeCurrent();
          }
        }
        expect(queue.toList(), [1, 2, 3, 4, 5].map(_Int.new));
      });

      test('remove all elements while iterating', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 0);
        for (final x in [1, 2, 0, 3, 4, 5, 0, 0]) {
          queue.addLast().value = x;
        }
        for (final _ in queue) {
          queue.removeCurrent();
        }
        expect(queue.isEmpty, true);
        expect(queue.isNotEmpty, false);
        expect(queue.toList(), <_Int>[]);
      });

      test('remove all elements while iterating wrapped queue', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 0);
        queue.addLast().value = 1;
        queue.addLast().value = 1;
        queue.addLast().value = 1;
        queue.removeFirst();
        for (final x in [1, 2, 0, 3, 4, 5, 0, 0]) {
          queue.addLast().value = x;
        }
        for (final _ in queue) {
          queue.removeCurrent();
        }
        expect(queue.isEmpty, true);
        expect(queue.isNotEmpty, false);
        expect(queue.toList(), <_Int>[]);
      });

      test('remove almost all elements while iterating', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 0);
        for (final x in [-1, 1, 2, 0, 3, 4, 5, 0, 0]) {
          queue.addLast().value = x;
        }
        for (final x in queue) {
          if (x.value! >= 0) {
            queue.removeCurrent();
          }
        }
        expect(queue.toList(), [_Int(-1)]);
      });

      test('iterate and remove almost all elements from wrapped queue', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 0);
        queue.addLast().value = -2;
        queue.addLast().value = -2;
        queue.removeFirst();
        for (final x in [-1, 1, 2, 0, 3, 4, 5, 0, 0]) {
          queue.addLast().value = x;
        }
        for (final x in queue) {
          if (x.value! >= 0) {
            queue.removeCurrent();
          }
        }
        expect(queue.toList(), [_Int(-2), _Int(-1)]);
        for (final x in queue) {
          if (x.value! == -1) {
            queue.removeCurrent();
          }
        }
        expect(queue.toList(), [_Int(-2)]);
      });

      test('removeFirst() while iterating breaks iteration', () {
        final queue = RecycledQueue(_Int.new);
        for (final x in [1, 2, 3, 4, 5]) {
          queue.addLast().value = x;
        }
        for (final x in queue) {
          expect(x.value, 1);
          if (x.value == 1) {
            queue.removeFirst();
          }
        }
      });

      test('add and remove elements while iterating', () {
        final queue = RecycledQueue(_Int.new, initialCapacity: 0);
        queue.addLast().value = 1;
        queue.addLast().value = 2;
        queue.addLast().value = 1;
        queue.removeFirst();
        queue.addLast().value = 1;
        var i = 3;
        expect('$queue', 'RecycledQueue(<2>, <1>, <1>)');
        for (final x in queue) {
          expect(x, queue.current);
          if (i <= 10) {
            queue.addLast().value = i;
            i += 1;
          }
          if (x.value!.isOdd) {
            queue.removeCurrent();
          }
          if (i == 4) {
            expect(x.value, 2);
            expect('$queue', 'RecycledQueue(<2>, <1>, <1>, <3>)');
          }
          if (i == 5) {
            expect(x.value, null);
            expect('$queue', 'RecycledQueue(<2>, <null>, <1>, <3>, <4>)');
          }
        }
        expect(queue.toList(), [2, 4, 6, 8, 10].map(_Int.new));
        expect(queue.toString(), 'RecycledQueue(<2>, <4>, <6>, <8>, <10>)');
      });

      testRandom('random attack: add/remove while iterating', (Random random) {
        final queue0 = Queue<int>();
        final queue1 = RecycledQueue(_Int.new);
        var nextNumberToAdd = 1;
        while (true) {
          if (random.nextDouble() < 0.01) {
            break;
          }
          if (queue0.isEmpty && queue1.isEmpty) {
            for (var i = 0; i < 10; i++) {
              queue0.addLast(nextNumberToAdd);
              queue1.addLast().value = nextNumberToAdd;
              nextNumberToAdd += 1;
            }
          }
          var it0 = queue0.iterator;
          for (final item1 in queue1) {
            expect(it0.moveNext(), true);
            final item0 = it0.current;
            expect(item0, item1.value);
            final rnd = random.nextDouble();
            if (rnd < 0.2) {
              queue0.addLast(nextNumberToAdd);
              queue1.addLast().value = nextNumberToAdd;
              nextNumberToAdd += 1;
              it0 = queue0.iterator;
              expect(it0.moveNext(), true);
              while (it0.current != item0) {
                it0.moveNext();
              }
            } else if (rnd < 0.4) {
              final index = queue0.toList().indexOf(item0);
              queue0.remove(item0);
              queue1.removeCurrent();
              it0 = queue0.skip(index).iterator;
            }
          }
          expect(it0.moveNext(), false);
        }
      });
    });
  });
}

class _Int implements Disposable {
  _Int([this.value]);

  int? value;

  @override
  void dispose() => value = null;

  @override
  String toString() => '<$value>';

  // ignore_for_file: hash_and_equals
  // ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes
  @override
  bool operator ==(Object other) => other is _Int && other.value == value;
}
