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
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
  <a title="AI Assist" href="https://app.commanddash.io/agent/flame_engine"><img src="https://img.shields.io/badge/AI-Code%20Assist-EB9FDA.svg"></a>
</p>

---
<!-- markdownlint-enable MD013 -->


Behavior tree is a very common way of implementing AI behavior in game and robotics. Using this, you
can break-down a complex behavior of an in game AI, into multiple smaller nodes.


## Features

- Nodes
  - Composite
    - Sequence: Continues execution until one of the children fails.
    - Selector: Continues execution until one of the children succeeds.
  - Decorator
    - Inverter: Flips the status of the child node.
    - Limiter: Limits the number of ticks for child node.
  - Task
    - Task: Executes a given callback when ticked.
    - AsyncTask: Executes an async callback when ticked.
    - Condition: Checks a condition when ticked.


## Getting started

Add this package to your dart project using,

```bash
dart pub add behavior_tree
```


## Usage

- Create a behavior tree.

```dart
final treeRoot = Sequence(
  children: [
    Condition(() => isHungry),
    Task(() => goToShop()),
    Task(() => buyFood()),
    Task(() => goToHome()),
    Task(() => eatFood()),
  ]
);
```

- Tick the root node to update the tree.

```dart
final treeRoot = ...;
treeRoot.tick();
```
