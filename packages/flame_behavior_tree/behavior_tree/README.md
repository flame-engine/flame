<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
This package provides a simple and easy to use <a href="https://en.wikipedia.org/wiki/Behavior_tree">behavior tree</a> API in pure dart.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/behavior_tree" ><img src="https://img.shields.io/pub/v/behavior_tree.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->


Behavior trees are a very common way of implementing AI in games and robotics. They let you break
down a complex behavior into many small, reusable nodes that are easy to read, test and rearrange.


## Getting started

Add this package to your Dart project using:

```bash
dart pub add behavior_tree
```

Then build a tree out of nodes, wrap its root in a `BehaviorTree` and tick it regularly (in a game,
once per update):

```dart
import 'package:behavior_tree/behavior_tree.dart';

const hunger = BlackboardKey<double>('hunger', initial: 0.8);

final tree = BehaviorTree(
  Sequence([
    Condition((context) => context.get(hunger) > 0.5),
    Task((context) => walkToShop(context.dt)), // Status.running until it arrives
    Task((context) => buyFood()),
    Task((context) {
      context.set(hunger, 0);
      return Status.success;
    }),
  ]),
);

void update(double dt) => tree.tick(dt);
```

See the [example](example/behavior_tree_example.dart) for a complete, runnable version.


## Concepts


### Ticking and status

Every time a tree is ticked, the tick travels down from the root and every node returns a `Status`:

- `Status.success`: the node did what it was supposed to do.
- `Status.failure`: it could not.
- `Status.running`: it is not done yet and wants to be ticked again.

`BehaviorTree.tick(dt)` returns the status of the root. `dt` is the time in seconds since the last
tick, nodes can read it from `context.dt`.


### Running nodes

Anything that takes time (walking somewhere, waiting, playing an animation) returns
`Status.running` until it is done. On the next tick the tree continues with that same node.

This is what `Sequence` and `Selector` do by default: they *remember* which child was running and
resume from it, instead of starting from their first child again. If you want a node to re-check its
earlier children on every tick, which makes the tree react to changes immediately, use
`reactive: true`:

```dart
Sequence(
  reactive: true,
  [
    // Checked on every tick.
    Condition((context) => context.get(canSeeEnemy)),
    // Aborted if the condition stops holding.
    Task(chaseEnemy),
  ],
)
```


### Aborting

When a parent stops ticking a child that is still running, it *aborts* it. This is your chance to
clean up, for example to stop an effect that was started. Pass `onAbortCallback` to a `Task`, or
override `onAbort` in a custom node. `BehaviorTree.abort()` aborts everything that is running.


### The blackboard

The blackboard is the shared memory of a tree. It is how nodes talk to each other and to the rest
of your program. Values are stored under typed keys, so there are no casts and no typos in strings:

```dart
const health = BlackboardKey<int>('health', initial: 100);
const target = BlackboardKey<Enemy?>('target');

final blackboard = Blackboard()..set(health, 50);
final tree = BehaviorTree(root, blackboard: blackboard);

// In a node:
context.get(health);       // 50, or the initial value if nothing was set
context.getOrNull(target); // null if nothing was set
context.set(target, enemy);
```

`get` throws a `StateError` that names the key if the value was never set and the key has no
`initial`. Keys are compared by identity, so declare each of them once and share it.

`set` throws an `ArgumentError` if the value is not of the type of the key. Be careful with number
literals: for a `BlackboardKey<double>` use `0.0`, because Dart lets a plain `0` through at compile
time.


### The owner

A tree can optionally have an owner, which is typically the object that the AI is controlling.
Nodes can get it from the context:

```dart
final tree = BehaviorTree(root, owner: enemy);

Task((context) {
  final enemy = context.owner<Enemy>();
  ...
})
```


## Nodes

Leaves:

- `Task(callback)`: runs `callback`, which returns the `Status`.
- `Condition(callback)`: succeeds if `callback` returns true, fails otherwise.
- `AsyncTask(callback)`: runs an async callback, it is running until the future completes.
- `Wait(seconds)`: running for `seconds` of game time, then succeeds.

Composites:

- `Sequence(children)`: runs the children in order. Fails at the first failure, succeeds if all of
  them succeed.
- `Selector(children)`: runs the children in order. Succeeds at the first success, fails if all of
  them fail.
- `Parallel(children)`: runs all the children at the same time, and finishes as decided by its
  `ParallelPolicy`.

Decorators:

- `Inverter(child)`: swaps success and failure.
- `AlwaysSucceed(child)` and `AlwaysFail(child)`: ignore how the child finished.
- `Repeat(child, times: n)`: runs the child again whenever it finishes, `n` times or forever.
- `RetryOnFailure(child, times: n)`: runs the child again after a failure, up to `n` attempts.
- `TimeLimit(child, seconds)`: aborts the child and fails if it keeps running for `seconds`.
- `Cooldown(child, seconds)`: fails without running the child for `seconds` after it finished.

`Sequence` and `Selector` take `reactive: true`, see [Running nodes](#running-nodes).


## Writing your own nodes

For most things a `Task` or a `Condition` is enough. When a node needs state or cleanup, extend
`Node` and override the hooks you need:

```dart
class MoveTo extends Node {
  MoveTo(this.destination);

  final Vector2 destination;

  @override
  void onEnter(TickContext context) {
    // Called before the first tick of a run.
  }

  @override
  Status onTick(TickContext context) {
    // Called on every tick, decides the status.
    return arrived ? Status.success : Status.running;
  }

  @override
  void onExit(TickContext context, Status status) {
    // Called after onTick returned success or failure.
  }

  @override
  void onAbort(TickContext context) {
    // Called instead of onExit if a parent interrupts the node while it is running.
  }
}
```

Extend `Decorator` for a node with a single `child`, or `Composite` for one with multiple
`children`; both take care of aborting their children.

Every node has an optional `name`, which tools like the Flame DevTools show to tell nodes apart.
It does not change how a node behaves. Set it with a cascade:

```dart
Condition((context) => context.get(isHungry))..name = 'is hungry?'
```

Nodes keep track of whether they are running, so every place in a tree needs a node instance of its
own. When you need the same node in multiple places, write a function that creates it.

Nodes are free to keep state, but keep in mind that a node is only ticked while its parents tick it.
Prefer keeping game state on the blackboard or in your game objects, and reset what you need in
`onEnter`.


## Migrating from 0.1.x

The API was redesigned to be simpler to use. The main changes are:

- `NodeInterface`, `BaseNode` and `NodeStatus` are replaced by `Node` and `Status`. `Status` has no
  `notStarted` value anymore.
- `tick()` now takes a `TickContext` and returns the `Status`. There is no `status` setter, and
  `reset()` is replaced by `abort()`. In most cases you wrap the root in a `BehaviorTree` and call
  `tree.tick(dt)`.
- Callbacks of `Task`, `Condition` and `AsyncTask` receive the `TickContext`, so they can read the
  blackboard and `dt` without having to subclass a node.
- Custom nodes override `onTick` instead of `tick`.
- Children are now positional: `Sequence([a, b])` instead of `Sequence(children: [a, b])`.
- `Sequence` and `Selector` now resume the running child by default. The old behavior of starting
  over from the first child on every tick is available with `reactive: true`.
- The blackboard uses typed keys: `context.get(health)` instead of
  `blackboard.get<int>('health')`. `BlackboardProvider` is removed, pass the blackboard to
  `BehaviorTree` instead.
- `Limiter` is removed. Use `Repeat`, `RetryOnFailure`, `TimeLimit` or `Cooldown`, depending on
  what you were limiting.
- New nodes: `Parallel`, `Wait`, `Repeat`, `RetryOnFailure`, `TimeLimit`, `Cooldown`,
  `AlwaysSucceed` and `AlwaysFail`.
