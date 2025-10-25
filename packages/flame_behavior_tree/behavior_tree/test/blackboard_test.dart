import 'package:behavior_tree/behavior_tree.dart';
import 'package:test/test.dart';

void main() {
  group('Blackboard', () {
    late Blackboard blackboard;

    setUp(() {
      blackboard = Blackboard();
    });

    group('set and get', () {
      test('can store and retrieve values', () {
        blackboard.set('key', 42);
        expect(blackboard.get<int>('key'), 42);
      });

      test('can store different types', () {
        blackboard.set('int', 42);
        blackboard.set('string', 'hello');
        blackboard.set('bool', true);
        blackboard.set('double', 3.14);

        expect(blackboard.get<int>('int'), 42);
        expect(blackboard.get<String>('string'), 'hello');
        expect(blackboard.get<bool>('bool'), true);
        expect(blackboard.get<double>('double'), 3.14);
      });

      test('can store complex objects', () {
        final list = [1, 2, 3];
        final map = {'a': 1, 'b': 2};

        blackboard.set('list', list);
        blackboard.set('map', map);

        expect(blackboard.get<List<int>>('list'), list);
        expect(blackboard.get<Map<String, int>>('map'), map);
      });

      test('can update existing values', () {
        blackboard.set('key', 42);
        expect(blackboard.get<int>('key'), 42);

        blackboard.set('key', 100);
        expect(blackboard.get<int>('key'), 100);
      });

      test('throws error for non-existent keys without default', () {
        expect(
          () => blackboard.get<int>('nonexistent'),
          throwsA(isA<StateError>()),
        );
      });

      test('returns default value for non-existent keys', () {
        expect(blackboard.get<int>('nonexistent', defaultValue: 0), 0);
      });
    });

    group('has', () {
      test('returns true for existing keys', () {
        blackboard.set('key', 42);
        expect(blackboard.has('key'), isTrue);
      });

      test('returns false for non-existent keys', () {
        expect(blackboard.has('nonexistent'), isFalse);
      });

      test('returns true even if value is null', () {
        blackboard.set('key', null);
        expect(blackboard.has('key'), isTrue);
      });
    });

    group('remove', () {
      test('removes existing keys', () {
        blackboard.set('key', 42);
        expect(blackboard.has('key'), isTrue);

        blackboard.remove('key');
        expect(blackboard.has('key'), isFalse);
        expect(
          () => blackboard.get<int>('key'),
          throwsA(isA<StateError>()),
        );
      });

      test('does nothing for non-existent keys', () {
        expect(() => blackboard.remove('nonexistent'), returnsNormally);
      });
    });

    group('clear', () {
      test('removes all entries', () {
        blackboard.set('key1', 1);
        blackboard.set('key2', 2);
        blackboard.set('key3', 3);

        expect(blackboard.has('key1'), isTrue);
        expect(blackboard.has('key2'), isTrue);
        expect(blackboard.has('key3'), isTrue);

        blackboard.clear();

        expect(blackboard.has('key1'), isFalse);
        expect(blackboard.has('key2'), isFalse);
        expect(blackboard.has('key3'), isFalse);
      });

      test('works on empty blackboard', () {
        expect(() => blackboard.clear(), returnsNormally);
      });
    });

    group('copy', () {
      test('creates independent copy', () {
        blackboard.set('key1', 1);
        blackboard.set('key2', 'hello');

        final copy = blackboard.copy();

        expect(copy.get<int>('key1'), 1);
        expect(copy.get<String>('key2'), 'hello');

        // Modifying copy doesn't affect original
        copy.set('key1', 999);
        expect(blackboard.get<int>('key1'), 1);
        expect(copy.get<int>('key1'), 999);

        // Modifying original doesn't affect copy
        blackboard.set('key2', 'world');
        expect(blackboard.get<String>('key2'), 'world');
        expect(copy.get<String>('key2'), 'hello');
      });

      test('copies empty blackboard', () {
        final copy = blackboard.copy();
        expect(copy.has('anything'), isFalse);
      });
    });
  });

  group('Blackboard integration with nodes', () {
    late Blackboard blackboard;
    late _MockBlackboardProvider provider;

    setUp(() {
      blackboard = Blackboard();
      provider = _MockBlackboardProvider(blackboard);
    });

    test('nodes can access blackboard through parent chain', () {
      blackboard.set('value', 42);

      final task = _TestTask();
      final sequence = Sequence(children: [task]);

      sequence.blackboardProvider = provider;

      sequence.tick();

      expect(task.accessedValue, 42);
    });

    test('nested nodes can access blackboard', () {
      blackboard.set('value', 100);

      final deepTask = _TestTask();
      final innerSequence = Sequence(children: [deepTask]);
      final outerSequence = Sequence(children: [innerSequence]);

      outerSequence.blackboardProvider = provider;

      outerSequence.tick();

      expect(deepTask.accessedValue, 100);
    });

    test('nodes can modify blackboard', () {
      blackboard.set('counter', 0);

      final incrementTask = _IncrementTask();
      final sequence = Sequence(children: [incrementTask]);

      sequence.blackboardProvider = provider;

      sequence.tick();
      expect(blackboard.get<int>('counter'), 1);

      sequence.reset();
      sequence.tick();
      expect(blackboard.get<int>('counter'), 2);
    });

    test('multiple nodes share same blackboard', () {
      blackboard.set('shared', 0);

      final task1 = _IncrementSharedTask();
      final task2 = _IncrementSharedTask();
      final task3 = _IncrementSharedTask();

      final sequence = Sequence(children: [task1, task2, task3]);
      sequence.blackboardProvider = provider;

      sequence.tick();

      expect(blackboard.get<int>('shared'), 3);
    });

    test('blackboard works with selectors', () {
      blackboard.set('flag', false);

      final checkTask = _CheckFlagTask();
      final fallbackTask = _SetFlagTask();

      final selector = Selector(children: [checkTask, fallbackTask]);
      selector.blackboardProvider = provider;

      // First tick: flag is false, so fallbackTask runs
      selector.tick();
      expect(blackboard.get<bool>('flag'), true);

      // Second tick: flag is now true, so checkTask succeeds
      selector.reset();
      selector.tick();
      expect(checkTask.wasExecuted, true);
    });

    test('blackboard works with inverter', () {
      blackboard.set('condition', false);

      final checkTask = _ConditionTask();
      final inverter = Inverter(checkTask);
      final sequence = Sequence(children: [inverter]);

      sequence.blackboardProvider = provider;

      sequence.tick();

      // Condition is false, inverted to success
      expect(sequence.status, NodeStatus.success);
    });

    test('blackboard works with limiter', () {
      blackboard.set('executeCount', 0);

      final countTask = _CountExecutionTask();
      final limiter = Limiter(countTask, 3);
      final sequence = Sequence(children: [limiter]);

      sequence.blackboardProvider = provider;

      // Execute 5 times, but task is limited to 3 executions
      for (var i = 0; i < 5; i++) {
        sequence.tick();
      }

      expect(blackboard.get<int>('executeCount'), 3);
    });

    test('nodes without provider get null blackboard', () {
      final task = _TestTask();
      final sequence = Sequence(children: [task]);

      // No provider set
      sequence.tick();

      expect(task.accessedValue, isNull);
    });
  });
}

// Test helper classes

class _MockBlackboardProvider implements BlackboardProvider {
  _MockBlackboardProvider(this.blackboard);

  @override
  final Blackboard blackboard;
}

class _TestTask extends BaseNode {
  int? accessedValue;

  @override
  void tick() {
    accessedValue = blackboard?.get<int>('value');
    status = NodeStatus.success;
  }
}

class _IncrementTask extends BaseNode {
  @override
  void tick() {
    final current = blackboard?.get<int>('counter') ?? 0;
    blackboard?.set('counter', current + 1);
    status = NodeStatus.success;
  }
}

class _IncrementSharedTask extends BaseNode {
  @override
  void tick() {
    final current = blackboard?.get<int>('shared') ?? 0;
    blackboard?.set('shared', current + 1);
    status = NodeStatus.success;
  }
}

class _CheckFlagTask extends BaseNode {
  bool wasExecuted = false;

  @override
  void tick() {
    wasExecuted = true;
    final flag = blackboard?.get<bool>('flag') ?? false;
    status = flag ? NodeStatus.success : NodeStatus.failure;
  }
}

class _SetFlagTask extends BaseNode {
  @override
  void tick() {
    blackboard?.set('flag', true);
    status = NodeStatus.success;
  }
}

class _ConditionTask extends BaseNode {
  @override
  void tick() {
    final condition = blackboard?.get<bool>('condition') ?? false;
    status = condition ? NodeStatus.success : NodeStatus.failure;
  }
}

class _CountExecutionTask extends BaseNode {
  @override
  void tick() {
    final count = blackboard?.get<int>('executeCount') ?? 0;
    blackboard?.set('executeCount', count + 1);
    status = NodeStatus.success;
  }
}
