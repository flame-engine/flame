import 'package:behavior_tree/behavior_tree.dart';
import 'package:test/test.dart';

import 'helpers.dart';

void main() {
  group('Sequence', () {
    test('succeeds when it has no children', () {
      expect(Sequence([]).tick(context()), Status.success);
    });

    test('succeeds when all the children succeed', () {
      final sequence = Sequence([
        ScriptedNode.always(Status.success),
        ScriptedNode.always(Status.success),
      ]);
      expect(sequence.tick(context()), Status.success);
    });

    test('fails at the first failing child and skips the rest', () {
      final last = ScriptedNode.always(Status.success);
      final sequence = Sequence([
        ScriptedNode.always(Status.success),
        ScriptedNode.always(Status.failure),
        last,
      ]);
      expect(sequence.tick(context()), Status.failure);
      expect(last.ticks, 0);
    });

    test('is running while a child is running', () {
      final last = ScriptedNode.always(Status.success);
      final sequence = Sequence([
        ScriptedNode.always(Status.running),
        last,
      ]);
      expect(sequence.tick(context()), Status.running);
      expect(last.ticks, 0);
    });

    test('resumes at the running child by default', () {
      final first = ScriptedNode.always(Status.success);
      final second = ScriptedNode([Status.running, Status.success]);
      final sequence = Sequence([first, second]);

      expect(sequence.tick(context()), Status.running);
      expect(sequence.tick(context()), Status.success);
      expect(first.ticks, 1);
      expect(second.ticks, 2);
    });

    test('starts from the first child again after finishing', () {
      final first = ScriptedNode.always(Status.success);
      final sequence = Sequence([first, ScriptedNode.always(Status.failure)]);

      sequence.tick(context());
      sequence.tick(context());
      expect(first.ticks, 2);
    });

    test('reactive re-evaluates the earlier children every tick', () {
      final first = ScriptedNode.always(Status.success);
      final second = ScriptedNode.always(Status.running);
      final sequence = Sequence([first, second], reactive: true);

      sequence.tick(context());
      sequence.tick(context());
      expect(first.ticks, 2);
      expect(second.ticks, 2);
      expect(second.aborts, 0);
    });

    test('reactive aborts the running child if an earlier one fails', () {
      final guard = ScriptedNode([Status.success, Status.failure]);
      final running = ScriptedNode.always(Status.running);
      final sequence = Sequence([guard, running], reactive: true);

      expect(sequence.tick(context()), Status.running);
      expect(sequence.tick(context()), Status.failure);
      expect(running.aborts, 1);
    });

    test('aborting aborts the running child', () {
      final running = ScriptedNode.always(Status.running);
      final sequence = Sequence([running])..tick(context());

      sequence.abort(context());
      expect(running.aborts, 1);

      // It starts from scratch afterwards.
      sequence.tick(context());
      expect(running.enters, 2);
    });

    test('copies the list of children', () {
      final children = <Node>[ScriptedNode.always(Status.failure)];
      final sequence = Sequence(children);
      children.clear();
      expect(sequence.children, hasLength(1));
      expect(sequence.children.clear, throwsUnsupportedError);
    });
  });

  group('Selector', () {
    test('fails when it has no children', () {
      expect(Selector([]).tick(context()), Status.failure);
    });

    test('fails when all the children fail', () {
      final selector = Selector([
        ScriptedNode.always(Status.failure),
        ScriptedNode.always(Status.failure),
      ]);
      expect(selector.tick(context()), Status.failure);
    });

    test('succeeds at the first succeeding child and skips the rest', () {
      final last = ScriptedNode.always(Status.success);
      final selector = Selector([
        ScriptedNode.always(Status.failure),
        ScriptedNode.always(Status.success),
        last,
      ]);
      expect(selector.tick(context()), Status.success);
      expect(last.ticks, 0);
    });

    test('is running while a child is running', () {
      final selector = Selector([
        ScriptedNode.always(Status.failure),
        ScriptedNode.always(Status.running),
      ]);
      expect(selector.tick(context()), Status.running);
    });

    test('resumes at the running child by default', () {
      final first = ScriptedNode.always(Status.failure);
      final second = ScriptedNode([Status.running, Status.success]);
      final selector = Selector([first, second]);

      expect(selector.tick(context()), Status.running);
      expect(selector.tick(context()), Status.success);
      expect(first.ticks, 1);
    });

    test('reactive switches to an earlier child that starts succeeding', () {
      final preferred = ScriptedNode([Status.failure, Status.success]);
      final fallback = ScriptedNode.always(Status.running);
      final selector = Selector([preferred, fallback], reactive: true);

      expect(selector.tick(context()), Status.running);
      expect(selector.tick(context()), Status.success);
      expect(fallback.aborts, 1);
    });

    test('aborting aborts the running child', () {
      final running = ScriptedNode.always(Status.running);
      final selector = Selector([running])..tick(context());
      selector.abort(context());
      expect(running.aborts, 1);
    });
  });

  group('Parallel', () {
    test('ticks all the children on every tick', () {
      final a = ScriptedNode.always(Status.running);
      final b = ScriptedNode.always(Status.running);
      final parallel = Parallel([a, b]);

      expect(parallel.tick(context()), Status.running);
      parallel.tick(context());
      expect(a.ticks, 2);
      expect(b.ticks, 2);
    });

    test('requireAll succeeds when all the children succeeded', () {
      final fast = ScriptedNode.always(Status.success);
      final slow = ScriptedNode([Status.running, Status.success]);
      final parallel = Parallel([fast, slow]);

      expect(parallel.tick(context()), Status.running);
      expect(parallel.tick(context()), Status.success);
      // The finished child is not ticked again while the others run.
      expect(fast.ticks, 1);
    });

    test('requireAll fails as soon as one child fails and aborts the rest', () {
      final running = ScriptedNode.always(Status.running);
      final parallel = Parallel([running, ScriptedNode.always(Status.failure)]);

      expect(parallel.tick(context()), Status.failure);
      expect(running.aborts, 1);
    });

    test('requireOne succeeds as soon as one child succeeds', () {
      final running = ScriptedNode.always(Status.running);
      final parallel = Parallel(
        [running, ScriptedNode.always(Status.success)],
        policy: ParallelPolicy.requireOne,
      );

      expect(parallel.tick(context()), Status.success);
      expect(running.aborts, 1);
    });

    test('requireOne fails when all the children failed', () {
      final slow = ScriptedNode([Status.running, Status.failure]);
      final parallel = Parallel(
        [ScriptedNode.always(Status.failure), slow],
        policy: ParallelPolicy.requireOne,
      );

      expect(parallel.tick(context()), Status.running);
      expect(parallel.tick(context()), Status.failure);
    });

    test('starts over after finishing', () {
      final child = ScriptedNode.always(Status.success);
      final parallel = Parallel([child]);

      parallel.tick(context());
      parallel.tick(context());
      expect(child.ticks, 2);
    });

    test('aborting aborts the running children and forgets the results', () {
      final done = ScriptedNode.always(Status.success);
      final running = ScriptedNode.always(Status.running);
      final parallel = Parallel([done, running])..tick(context());

      parallel.abort(context());
      expect(running.aborts, 1);

      parallel.tick(context());
      expect(done.ticks, 2);
    });
  });
}
