import 'dart:math';

import 'package:examples/stories/bridge_libraries/flame_behavior_tree/common.dart';
import 'package:flame_behavior_tree/flame_behavior_tree.dart';

class DecoratorsExample() extends BehaviorTreeGame {
  this : super(height: 380);

  static const String description = '''
    Decorators wrap a single child node and change how it behaves, for example
    what status it returns, or how many times it runs.

    Every row runs a decorator around a small child. The light on the right
    shows the status that the decorator returned: amber for `running`, green
    for `success` and red for `failure`. Rows start over by themselves once
    they are done.

    Cooldown is ticked on every frame, but only lets its child run once every
    two seconds. In between it fails.
  ''';

  @override
  void onLoad() {
    final random = Random();

    // Succeeds on even seconds and fails on odd ones.
    Condition isEvenSecond() {
      return Condition((context) => context.owner<TreeLane>().time % 2 < 1);
    }

    addLanes(world, [
      TreeLane(
        title: 'Inverter(condition)',
        explanation: 'Flips the condition: success on odd seconds.',
        build: (lane) => Inverter(isEvenSecond()),
      ),
      TreeLane(
        title: 'AlwaysSucceed(condition)',
        explanation: 'Succeeds, although the condition fails half of the time.',
        build: (lane) => AlwaysSucceed(isEvenSecond()),
      ),
      TreeLane(
        title: 'AlwaysFail(wait)',
        explanation: 'Is running as long as the child is, and then fails.',
        build: (lane) => AlwaysFail(Wait(1)),
      ),
      TreeLane(
        title: 'Repeat(wait, times: 3)',
        explanation: 'Runs the child three times in a row, then succeeds.',
        build: (lane) => Repeat(Wait(0.5), times: 3),
      ),
      TreeLane(
        title: 'RetryOnFailure(coin flip, times: 3)',
        explanation: 'Tries up to three times, until the coin flip succeeds.',
        build: (lane) => RetryOnFailure(
          Sequence([
            Wait(0.5),
            Condition((context) => random.nextBool()),
          ]),
          times: 3,
        ),
      ),
      TreeLane(
        title: 'TimeLimit(wait(3), 2)',
        explanation: 'Aborts the child and fails when it takes more than 2s.',
        build: (lane) => TimeLimit(Wait(3), 2),
      ),
      TreeLane(
        title: 'Cooldown(task, 2)',
        explanation: 'Runs the task, then fails for 2s until it may run again.',
        build: (lane) => Cooldown(Task((context) => Status.success), 2),
      ),
    ]);
  }
}
