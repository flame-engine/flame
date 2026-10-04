import 'package:behavior_tree/behavior_tree.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Blackboard', () {
    const health = BlackboardKey<int>('health');
    const mana = BlackboardKey<int>('mana', initial: 50);
    const target = BlackboardKey<String?>('target');

    test('returns the value that was set', () {
      final blackboard = Blackboard()..set(health, 10);
      expect(blackboard.get(health), 10);
      expect(blackboard.has(health), isTrue);
    });

    test('throws a descriptive error for a missing key', () {
      expect(
        () => Blackboard().get(health),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('health'),
          ),
        ),
      );
    });

    test('falls back to the initial value', () {
      final blackboard = Blackboard();
      expect(blackboard.get(mana), 50);
      expect(blackboard.has(mana), isFalse);

      blackboard.set(mana, 5);
      expect(blackboard.get(mana), 5);

      blackboard.remove(mana);
      expect(blackboard.get(mana), 50);
    });

    test('set rejects a value of the wrong type', () {
      const progress = BlackboardKey<double>('progress');
      final blackboard = Blackboard();

      // The compiler infers `num` here and lets the int through.
      expect(() => blackboard.set(progress, 0), throwsArgumentError);
      expect(blackboard.has(progress), isFalse);

      blackboard.set(progress, 0.0);
      expect(blackboard.get(progress), 0.0);
    });

    test('set accepts null for nullable keys only', () {
      final blackboard = Blackboard()..set(target, null);
      expect(blackboard.get(target), isNull);
      expect(
        () => blackboard.set(health, null as dynamic),
        throwsArgumentError,
      );
    });

    test('getOrNull returns null for missing keys', () {
      final blackboard = Blackboard();
      expect(blackboard.getOrNull(health), isNull);
      expect(blackboard.getOrNull(mana), 50);
      expect(blackboard.getOrNull(target), isNull);
    });

    test('keys are compared by identity', () {
      // Not const on purpose, identical consts would be the same instance.
      // ignore: prefer_const_constructors
      final a = BlackboardKey<int>('same');
      // ignore: prefer_const_constructors
      final b = BlackboardKey<int>('same');
      final blackboard = Blackboard()..set(a, 1);
      expect(blackboard.has(b), isFalse);
    });

    test('clear removes everything', () {
      final blackboard = Blackboard()
        ..set(health, 1)
        ..set(mana, 2)
        ..clear();
      expect(blackboard.keys, isEmpty);
    });

    test('copy is independent of the original', () {
      final original = Blackboard()..set(health, 1);
      final copy = original.copy()..set(health, 2);
      expect(original.get(health), 1);
      expect(copy.get(health), 2);
    });

    test('TickContext shortcuts use the blackboard', () {
      final tickContext = context()..set(health, 3);
      expect(tickContext.get(health), 3);
      expect(tickContext.blackboard.get(health), 3);
      expect(tickContext.getOrNull(mana), 50);
    });

    test('TickContext.owner returns the owner with the right type', () {
      expect(context(owner: 'me').owner<String>(), 'me');
    });

    test('TickContext.owner throws for a missing or wrong owner', () {
      expect(() => context().owner<String>(), throwsStateError);
      expect(() => context(owner: 1).owner<String>(), throwsStateError);
    });
  });
}
