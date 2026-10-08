<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">This is a bridge package that integrates the <a href="https://github.com/flame-engine/flame/tree/main/packages/flame_behavior_tree/behavior_tree">behavior_tree</a> dart package with <a href="https://flame-engine.org/">Flame engine</a>.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_behavior_tree" ><img src="https://img.shields.io/pub/v/flame_behavior_tree.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->


## Features

This package provides a `HasBehaviorTree` mixin for Flame `Components`. It can be added to any
`Component` and it takes care of ticking the behavior tree along with the component's update.

The behavior tree itself comes from the
[behavior_tree](https://github.com/flame-engine/flame/tree/main/packages/flame_behavior_tree/behavior_tree)
package, which is re-exported from here. Read its README to learn about the available nodes, how
running nodes work and how to share data using the blackboard.


## Getting started

Add this package to your Flutter project using:

```bash
flutter pub add flame_behavior_tree
```


## Usage

Add the `HasBehaviorTree` mixin to the component that wants to follow a certain AI behavior, and
assign a `BehaviorTree` to `behaviorTree`:

```dart
class Enemy extends PositionComponent with HasBehaviorTree {
  @override
  Future<void> onLoad() async {
    behaviorTree = BehaviorTree(
      Selector([
        Sequence([
          Condition((context) => canSeePlayer()),
          Task((context) => chasePlayer(context.dt)),
        ]),
        Task((context) => patrol(context.dt)),
      ]),
      owner: this,
    );
  }
}
```

- The tree is ticked on every update of the component. `context.dt` in the nodes is the time since
  the previous tick.
- Passing `owner: this` lets nodes get the component with `context.owner<Enemy>()`.
- The blackboard of the tree is available as `blackboard` on the component, so the rest of your
  game can read and write the values that the AI works with.
- The running nodes of the tree are aborted when the component is removed, or when you assign a new
  tree.

To tick the tree less often, increase `tickInterval`. This can be done at any time. The tree is
ticked on the first update, and then whenever `tickInterval` seconds have passed. The `dt` that
the nodes see is the time since the previous tick of the tree.

```dart
class Enemy extends PositionComponent with HasBehaviorTree {
  Enemy() {
    tickInterval = 0.5; // Think twice per second.
  }
}
```


## Flame nodes

Besides the nodes of `behavior_tree`, this package has two nodes that work with the effects of
Flame:

- `PlayEffect(builder)` adds an effect to the owner of the tree (or to a `target`), is running while
  it plays and succeeds when it completes. The effect is removed if the node is aborted.
- `MoveTo(destination, ...)` moves the owner (or a `target`) to a position, either in a given
  `duration` or at a given `speed`.

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


## Debugging

In debug mode, the behavior tree of a component is shown in the Flame DevTools when you select the
component. It shows what every node is doing, and the blackboard. Give nodes a `name` to make the
tree easier to read:

```dart
Condition((context) => context.get(isHungry))..name = 'is hungry?'
```


## Documentation and examples

The [documentation](https://docs.flame-engine.org/latest/bridge_packages/flame_behavior_tree/flame_behavior_tree.html)
explains how behavior trees work, with small interactive examples for the nodes and for
`HasBehaviorTree`. They can also be found in the
[examples app](https://github.com/flame-engine/flame/tree/main/examples/lib/stories/bridge_libraries/flame_behavior_tree).

See the [example](example/lib/main.dart) for an agent that walks in and out of a house.


## Migrating from 0.1.x / 0.2.0-dev

- Instead of `treeRoot = root`, assign `behaviorTree = BehaviorTree(root, owner: this)`.
- `HasBehaviorTree` is not generic anymore.
- The blackboard now belongs to the `BehaviorTree`. It is always available, uses typed keys and is
  not assigned on the component. Pass an existing one to `BehaviorTree(blackboard: ...)` if you need
  to.
- Setting `tickInterval` after the component was loaded now works, and the first tick happens
  immediately instead of after the first interval.

The nodes themselves changed too, see the migration guide in the
[behavior_tree README](https://github.com/flame-engine/flame/tree/main/packages/flame_behavior_tree/behavior_tree#migrating-from-01x).
