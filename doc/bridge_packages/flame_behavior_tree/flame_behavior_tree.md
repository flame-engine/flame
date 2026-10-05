# flame_behavior_tree

`flame_behavior_tree` lets the components of your game follow a
[behavior tree](https://en.wikipedia.org/wiki/Behavior_tree). A behavior tree is a way of
describing the behavior of an AI by breaking it down into small nodes that are easy to read,
reuse and rearrange. It is used a lot for enemies, NPCs and robots.

The tree itself comes from the `behavior_tree` package, which is written in pure Dart and is
re-exported by `flame_behavior_tree`. The `flame_behavior_tree` package adds the `HasBehaviorTree`
mixin for components, and a few nodes that know about Flame.


## Getting started

Add the package to your `pubspec.yaml`:

```bash
flutter pub add flame_behavior_tree
```

Add the `HasBehaviorTree` mixin to a component and give it a tree:

```dart
class Enemy extends PositionComponent with HasBehaviorTree {
  @override
  Future<void> onLoad() async {
    behaviorTree = BehaviorTree(
      Selector([
        Sequence([
          Condition((context) => canSeePlayer),
          MoveTo((context) => player.position, speed: 80),
        ]),
        Task((context) => patrol(context.dt)),
      ]),
      owner: this,
    );
  }
}
```

The tree is ticked on every update of the component. This one says: "if you can see the player,
move towards them, otherwise patrol".

The `owner` is the object that the nodes can get from their `context`, with
`context.owner<Enemy>()`. It is also what `MoveTo` moves by default.


## Concepts


### Ticking and status

Every time the tree is ticked, the tick travels down from the root, and every node that gets ticked
returns one of three `Status` values:

- `Status.success`: the node did what it was supposed to do.
- `Status.failure`: it could not.
- `Status.running`: it is not done yet and wants to be ticked again.

The nodes that do something are the leaf nodes, like `Task`, `Condition` and `MoveTo`, which have
no children. Composite nodes decide which of their children get to run:

- A `Sequence` ticks its children in order, for as long as they succeed. It fails as soon as a child
  fails, and succeeds when all of them have succeeded.
- A `Selector` ticks its children in order until one of them does not fail. It succeeds as soon as
  a child succeeds, and fails when all of them have failed.

A `Condition` is a leaf node that checks something, and never returns `Status.running`.

The nodes get a `TickContext` when they are ticked. It has the time since the previous tick as
`dt`, the `blackboard`, and the `owner`.


### The blackboard

The blackboard is the memory that all the nodes of a tree share. It is how the nodes talk to each
other, and how the rest of your game talks to the tree. Values are stored using typed keys, so you
do not have to cast anything, and a typo in a string can not make a lookup fail:

```dart
const destination = BlackboardKey<Vector2>('destination');
const health = BlackboardKey<int>('health', initial: 100);

// From the game:
enemy.blackboard.set(destination, Vector2(100, 50));

// In a node:
Condition((context) => context.get(health) < 20)
```

Reading a key that has no value and no `initial` value throws an error that tells you which key it
was. Use `getOrNull` or `blackboard.has` when a value is allowed to be missing. Keys are compared
by identity, so declare each of them once, for example as a top level constant.

In this example, the game puts the position of a bone on the blackboard when the screen is tapped,
and the tree takes care of the rest. The tree is shown below the dog, and the node that is running
is highlighted.

```{flutter-app}
:sources: ../../examples
:page: basic_example
:subfolder: stories/bridge_libraries/flame_behavior_tree
:show: widget code
:width: 400
:height: 340
```


### Running nodes

Anything that takes time, like walking somewhere or waiting, returns `Status.running` until it is
done. On the next tick the tree continues with the node that was running.

By default, `Sequence` and `Selector` have *memory* for this. They remember which child was
running and continue with it, without looking at the earlier children again. If you would rather
have them check the earlier children again on every tick, so that the tree reacts to changes
immediately, pass `reactive: true`.

```dart
Sequence(
  reactive: true,
  [
    Condition((context) => context.get(canSeeEnemy)),
    MoveTo((context) => context.get(enemyPosition), speed: 80),
  ],
)
```

In the example below, both cars drive as long as the traffic light is green. Tap to turn it red,
and only the car with the reactive sequence notices, and stops.

```{flutter-app}
:sources: ../../examples
:page: traffic_example
:subfolder: stories/bridge_libraries/flame_behavior_tree
:show: widget code
:width: 400
:height: 320
```


### Aborting

When a parent stops ticking a child that is still running, like the reactive sequence above does,
the child is *aborted*. This gives the node the chance to clean up, for example to stop something
that it started. `Task` has an `onAbortCallback` for this, and custom nodes can override `onAbort`.

The nodes that play an effect remove it when they are aborted, which is why the agent above stops
moving. `BehaviorTree.abort()` aborts everything that is running in a tree. This is also what
`HasBehaviorTree` does when the component is removed, and when you give it a different tree.


### Sharing nodes

Nodes keep track of whether they are running, so every place in a tree needs a node instance of
its own. When you need the same node in multiple places, write a function that creates it.


## Nodes


### Leaf nodes

Leaf nodes are the nodes that actually do something, they do not have children.

- `Task(callback)` runs a callback that returns the status, every time it is ticked.
- `Condition(callback)` succeeds when a callback returns true, and fails otherwise.
- `Wait(seconds)` is running for the given time, and then succeeds. The time is measured by
  adding up the `dt` of the ticks, so it follows the game time.
- `AsyncTask(callback)` runs an async callback. It is running until the future completes, and
  returns the status that the future completed with. Its result is ignored if it is aborted
  before it completes.

`flame_behavior_tree` adds two nodes that work with the effects of Flame:

- `PlayEffect(builder)` creates an effect with the builder, and adds it to the owner of the tree
  or to the `target` that you pass. It is running while the effect plays, and succeeds when the
  effect completes. If the node is aborted, the effect is removed.
- `MoveTo(destination, ...)` is a `PlayEffect` that moves the owner of the tree, or the `target`,
  to a position. The `destination` is a function, so it can use the blackboard or anything else in
  your game. Give it either a `duration` (and optionally a `curve`) or a `speed` in pixels per
  second.

```dart
Sequence([
  MoveTo((context) => context.get(destination), speed: 100),
  PlayEffect(
    (context) => ColorEffect(
      Colors.red,
      EffectController(duration: 0.3, alternate: true),
    ),
  ),
])
```

The robot below uses all of them. It walks to work spots and scans them, and goes to charge when
its battery is low.

```{flutter-app}
:sources: ../../examples
:page: robot_example
:subfolder: stories/bridge_libraries/flame_behavior_tree
:show: widget code
:width: 400
:height: 390
```


### Decorators

Decorators have a single child, and change how it behaves.

- `Inverter(child)` swaps success and failure.
- `AlwaysSucceed(child)` and `AlwaysFail(child)` ignore how the child finished.
- `Repeat(child, times: n)` runs the child again every time it finishes, `n` times or forever.
- `RetryOnFailure(child, times: n)` runs the child again after a failure, up to `n` attempts.
- `TimeLimit(child, seconds)` aborts the child and fails if it keeps running for too long.
- `Cooldown(child, seconds)` fails without running the child for some time after it finished.

The turret below uses `Cooldown`, `Repeat` and `Inverter` to fire bursts of three shots at a target
in range, and rest in between:

```{flutter-app}
:sources: ../../examples
:page: turret_example
:subfolder: stories/bridge_libraries/flame_behavior_tree
:show: widget code
:width: 400
:height: 380
```

The thief below uses `RetryOnFailure`, `TimeLimit` and `AlwaysSucceed` while trying to pick a lock.
Tap to call a guard: the thief only breaks in when none is nearby, and a reactive sequence aborts
the break-in as soon as one shows up.

```{flutter-app}
:sources: ../../examples
:page: thief_example
:subfolder: stories/bridge_libraries/flame_behavior_tree
:show: widget code
:width: 400
:height: 480
```


### Parallel

A `Parallel` node ticks all of its children on every tick, so that they run at the same time. Its
`ParallelPolicy` decides when it is done. With `requireAll`, which is the default, it succeeds
when all the children have succeeded, and fails as soon as one of them fails. With `requireOne`
it succeeds as soon as one child succeeds, and fails when all of them have failed. When the result
is known, the children that are still running are aborted. In the example below, the runners are
the children of a `Parallel` node, and the orange one is stopped by `requireOne`.

```{flutter-app}
:sources: ../../examples
:page: race_example
:subfolder: stories/bridge_libraries/flame_behavior_tree
:show: widget code
:width: 400
:height: 440
```


### Your own nodes

A `Task` or a `Condition` is enough for most things. When a node needs some state or has to clean
up after itself, extend `Node` and override what you need:

```dart
class Chase extends Node {
  @override
  void onEnter(TickContext context) {
    // Called before the first tick of a run.
  }

  @override
  Status onTick(TickContext context) {
    // Called on every tick, and decides the status of the node.
    return Status.running;
  }

  @override
  void onExit(TickContext context, Status status) {
    // Called when onTick returned success or failure.
  }

  @override
  void onAbort(TickContext context) {
    // Called instead of onExit when the node is interrupted while running.
  }
}
```

Extend `Decorator` for a node with one `child`, or `Composite` for a node with `children`. They
take care of aborting their children.


## HasBehaviorTree

The `HasBehaviorTree` mixin can be added to any `Component`. It has the following members:

- `behaviorTree` is the tree of the component. Assigning a new tree aborts the one that was
  running before. Reading it before a tree has been assigned throws an error.
- `blackboard` is a shortcut to the blackboard of the tree.
- `tickInterval` is the time between two ticks of the tree.

When the component is removed from the game, its tree is aborted.


### Tick interval

By default the tree is ticked on every update of the component. That is often more than needed,
and thinking less often costs less. Set `tickInterval` to the number of seconds between two ticks
to change that. The first tick still happens immediately, and the `dt` that the nodes see is the
time that has passed since the previous tick, so for example movement stays as fast as it was.
The interval can be changed at any time.

```{flutter-app}
:sources: ../../examples
:page: tick_interval_example
:subfolder: stories/bridge_libraries/flame_behavior_tree
:show: widget code
:width: 400
:height: 300
```


### Switching trees

A component can switch to another tree whenever it wants, for example when it changes mode. The
nodes that are running in the old tree are aborted.

```{flutter-app}
:sources: ../../examples
:page: switch_tree_example
:subfolder: stories/bridge_libraries/flame_behavior_tree
:show: widget code
:width: 400
:height: 300
```


## Migrating from 0.2.0-dev

The API of the nodes was redesigned, and the mixin changed along with it:

- `treeRoot = root` becomes `behaviorTree = BehaviorTree(root, owner: this)`.
- `HasBehaviorTree` is not generic anymore.
- The blackboard belongs to the `BehaviorTree`. It is always there and has typed keys. Pass your
  own with `BehaviorTree(root, blackboard: ...)` if you need to.
- `Node` and `Status` replace `BaseNode`, `NodeInterface` and `NodeStatus`. Custom nodes override
  `onTick`, which gets a `TickContext` and returns a `Status`.
- The callbacks of `Task`, `Condition` and `AsyncTask` get the `TickContext`.
- Children are positional: `Sequence([a, b])`.
- `Sequence` and `Selector` continue with the running child by default. Pass `reactive: true` for
  the old behavior.
- `Limiter` is gone, use `Repeat`, `RetryOnFailure`, `TimeLimit` or `Cooldown`.
- Setting `tickInterval` after the component was loaded works now, and the first tick happens
  immediately.
