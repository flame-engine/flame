import 'dart:async';

import 'package:behavior_tree/behavior_tree.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Task', () {
    test('returns what the callback returns', () {
      for (final status in Status.values) {
        expect(Task((_) => status).tick(context()), status);
      }
    });

    test('gets the context', () {
      const key = BlackboardKey<int>('key', initial: 7);
      var seen = 0;
      Task((context) {
        seen = context.get(key);
        return Status.success;
      }).tick(context());
      expect(seen, 7);
    });

    test('calls onAbortCallback only when aborted while running', () {
      var aborted = 0;
      final task = Task(
        (_) => Status.running,
        onAbortCallback: (_) => aborted++,
      );

      task.abort(context());
      expect(aborted, 0);

      task.tick(context());
      task.abort(context());
      expect(aborted, 1);
    });
  });

  group('Condition', () {
    test('succeeds if the callback returns true', () {
      expect(Condition((_) => true).tick(context()), Status.success);
    });

    test('fails if the callback returns false', () {
      expect(Condition((_) => false).tick(context()), Status.failure);
    });
  });

  group('Wait', () {
    test('runs until enough time has passed', () {
      final wait = Wait(1);
      expect(wait.tick(context(dt: 0.4)), Status.running);
      expect(wait.tick(context(dt: 0.4)), Status.running);
      expect(wait.tick(context(dt: 0.4)), Status.success);
    });

    test('starts over after finishing', () {
      final wait = Wait(1)..tick(context(dt: 1));
      expect(wait.tick(context(dt: 0.5)), Status.running);
    });

    test('starts over after an abort', () {
      final wait = Wait(1)..tick(context(dt: 0.9));
      wait.abort(context());
      expect(wait.tick(context(dt: 0.5)), Status.running);
    });

    test('zero seconds succeeds immediately', () {
      expect(Wait(0).tick(context()), Status.success);
    });
  });

  group('AsyncTask', () {
    test('is running until the future completes', () async {
      final completer = Completer<Status>();
      final task = AsyncTask((_) => completer.future);

      expect(task.tick(context()), Status.running);
      expect(task.tick(context()), Status.running);

      completer.complete(Status.success);
      await pumpEventQueue();
      expect(task.tick(context()), Status.success);
    });

    test('only starts the callback once while running', () async {
      var calls = 0;
      final completer = Completer<Status>();
      final task = AsyncTask((_) {
        calls++;
        return completer.future;
      });

      task
        ..tick(context())
        ..tick(context())
        ..tick(context());
      expect(calls, 1);
    });

    test('runs the callback again after it finished', () async {
      var calls = 0;
      final task = AsyncTask((_) async {
        calls++;
        return Status.failure;
      });

      task.tick(context());
      await pumpEventQueue();
      expect(task.tick(context()), Status.failure);

      task.tick(context());
      expect(calls, 2);
    });

    test('ignores the result of an aborted run', () async {
      final first = Completer<Status>();
      final second = Completer<Status>();
      final completers = [first, second];
      final task = AsyncTask((_) => completers.removeAt(0).future);

      task.tick(context());
      task.abort(context());
      task.tick(context());

      first.complete(Status.failure);
      await pumpEventQueue();
      expect(task.tick(context()), Status.running);

      second.complete(Status.success);
      await pumpEventQueue();
      expect(task.tick(context()), Status.success);
    });

    test('rethrows an error that the callback throws directly', () async {
      final task = AsyncTask((_) => throw StateError('boom'));

      // It does not throw from the tick that started the callback.
      expect(task.tick(context()), Status.running);
      await pumpEventQueue();
      expect(() => task.tick(context()), throwsStateError);
    });

    test('rethrows errors from the next tick', () async {
      final task = AsyncTask((_) async => throw StateError('boom'));
      task.tick(context());
      await pumpEventQueue();
      expect(() => task.tick(context()), throwsStateError);
    });
  });
}
