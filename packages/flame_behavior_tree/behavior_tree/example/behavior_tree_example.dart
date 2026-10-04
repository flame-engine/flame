// ignore_for_file: avoid_print

import 'package:behavior_tree/behavior_tree.dart';

// Keys are how nodes share data through the blackboard. Declare them once.
const hunger = BlackboardKey<double>('hunger', initial: 0.8);
const distanceToShop = BlackboardKey<double>('distanceToShop', initial: 10);

void main() {
  final tree = BehaviorTree(
    // A selector tries its children in order until one does not fail.
    Selector([
      // A sequence runs its children in order until one does not succeed.
      Sequence(
        reactive: true,
        [
          Condition((context) => context.get(hunger) > 0.5),
          Task(walkToShop),
          Task(buyFood),
          Task(eat),
        ],
      ),
      Task((context) {
        print('Not hungry, relaxing.');
        return Status.success;
      }),
    ]),
  );

  // Normally you would call this from your game loop. A task that is not done
  // returns Status.running and is simply ticked again on the next tick.
  const dt = 0.5;
  while (tree.tick(dt) == Status.running) {}
}

Status walkToShop(TickContext context) {
  final remaining = context.get(distanceToShop) - 4 * context.dt;
  context.set(distanceToShop, remaining);
  if (remaining > 0) {
    print('Walking to the shop, ${remaining.toStringAsFixed(1)}m to go.');
    return Status.running;
  }
  print('Arrived at the shop.');
  return Status.success;
}

Status buyFood(TickContext context) {
  print('Buying food.');
  return Status.success;
}

Status eat(TickContext context) {
  print('Eating.');
  context.set(hunger, 0);
  return Status.success;
}
