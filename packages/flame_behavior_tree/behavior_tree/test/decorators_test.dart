import 'package:behavior_tree/behavior_tree.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Inverter', () {
    test('swaps success and failure and keeps running', () {
      Status invert(Status status) {
        return Inverter(ScriptedNode.always(status)).tick(context());
      }

      expect(invert(Status.success), Status.failure);
      expect(invert(Status.failure), Status.success);
      expect(invert(Status.running), Status.running);
    });

    test('aborting aborts the child', () {
      final child = ScriptedNode.always(Status.running);
      final inverter = Inverter(child)..tick(context());
      inverter.abort(context());
      expect(child.aborts, 1);
    });
  });

  group('AlwaysSucceed and AlwaysFail', () {
    test('AlwaysSucceed turns finished results into success', () {
      for (final status in [Status.success, Status.failure]) {
        final node = AlwaysSucceed(ScriptedNode.always(status));
        expect(node.tick(context()), Status.success);
      }
      final running = AlwaysSucceed(ScriptedNode.always(Status.running));
      expect(running.tick(context()), Status.running);
    });

    test('AlwaysFail turns finished results into failure', () {
      for (final status in [Status.success, Status.failure]) {
        final node = AlwaysFail(ScriptedNode.always(status));
        expect(node.tick(context()), Status.failure);
      }
      final running = AlwaysFail(ScriptedNode.always(Status.running));
      expect(running.tick(context()), Status.running);
    });
  });

  group('Repeat', () {
    test('runs the child the given number of times', () {
      final child = ScriptedNode.always(Status.success);
      final repeat = Repeat(child, times: 3);

      expect(repeat.tick(context()), Status.running);
      expect(repeat.tick(context()), Status.running);
      expect(repeat.tick(context()), Status.success);
      expect(child.ticks, 3);
    });

    test('returns the status of the last run', () {
      final child = ScriptedNode([Status.success, Status.failure]);
      final repeat = Repeat(child, times: 2)..tick(context());
      expect(repeat.tick(context()), Status.failure);
    });

    test('does not count ticks of a running child', () {
      final child = ScriptedNode([
        Status.running,
        Status.running,
        Status.success,
      ]);
      final repeat = Repeat(child, times: 1);

      expect(repeat.tick(context()), Status.running);
      expect(repeat.tick(context()), Status.running);
      expect(repeat.tick(context()), Status.success);
    });

    test('repeats forever without a limit', () {
      final repeat = Repeat(ScriptedNode.always(Status.success));
      for (var i = 0; i < 100; i++) {
        expect(repeat.tick(context()), Status.running);
      }
    });

    test('starts counting from zero on the next run', () {
      final child = ScriptedNode.always(Status.success);
      final repeat = Repeat(child, times: 2)
        ..tick(context())
        ..tick(context());
      expect(repeat.tick(context()), Status.running);
    });
  });

  group('RetryOnFailure', () {
    test('succeeds as soon as the child succeeds', () {
      final child = ScriptedNode([Status.failure, Status.success]);
      final retry = RetryOnFailure(child, times: 3);

      expect(retry.tick(context()), Status.running);
      expect(retry.tick(context()), Status.success);
    });

    test('fails after all the attempts failed', () {
      final child = ScriptedNode.always(Status.failure);
      final retry = RetryOnFailure(child, times: 3);

      expect(retry.tick(context()), Status.running);
      expect(retry.tick(context()), Status.running);
      expect(retry.tick(context()), Status.failure);
      expect(child.ticks, 3);
    });

    test('passes running through', () {
      final retry = RetryOnFailure(
        ScriptedNode.always(Status.running),
        times: 2,
      );
      expect(retry.tick(context()), Status.running);
    });
  });

  group('TimeLimit', () {
    test('passes the result of a child that finishes in time', () {
      final timeout = TimeLimit(ScriptedNode.always(Status.success), 1);
      expect(timeout.tick(context(dt: 0.5)), Status.success);
    });

    test('fails and aborts a child that runs for too long', () {
      final child = ScriptedNode.always(Status.running);
      final timeout = TimeLimit(child, 1);

      expect(timeout.tick(context(dt: 0.6)), Status.running);
      expect(timeout.tick(context(dt: 0.6)), Status.failure);
      expect(child.aborts, 1);
    });

    test('measures the time from the start of each run', () {
      final child = ScriptedNode.always(Status.running);
      final timeout = TimeLimit(child, 1);

      timeout.tick(context(dt: 0.9));
      timeout.abort(context());
      expect(timeout.tick(context(dt: 0.9)), Status.running);
    });
  });

  group('Cooldown', () {
    test('blocks the child for the given time after it finished', () {
      final child = ScriptedNode.always(Status.success);
      final cooldown = Cooldown(child, 1);

      expect(cooldown.tick(context(dt: 0.1)), Status.success);
      expect(cooldown.tick(context(dt: 0.4)), Status.failure);
      expect(cooldown.tick(context(dt: 0.4)), Status.failure);
      expect(child.ticks, 1);

      expect(cooldown.tick(context(dt: 0.4)), Status.success);
      expect(child.ticks, 2);
    });

    test('does not block a running child', () {
      final child = ScriptedNode.always(Status.running);
      final cooldown = Cooldown(child, 1);

      expect(cooldown.tick(context(dt: 0.1)), Status.running);
      expect(cooldown.tick(context(dt: 0.1)), Status.running);
      expect(child.ticks, 2);
    });
  });
}
