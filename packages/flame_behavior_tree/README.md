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
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->


## Features

This package provides a `HasBehaviorTree` mixin for Flame `Components`. It can be added to any
`Component` and it takes care of ticking the behavior tree along with the component's update.


## Getting started

Add this package to your Flutter project using:

```bash
flutter pub add flame_behavior_tree
```


## Usage

- Add the `HasBehaviorTree` mixin to the component that wants to follow a certain AI behavior.

  ```dart
  class MyComponent extends Position with HasBehaviorTree {
  
  }
  ```

- Set-up a behavior tree and set its root as the `treeRoot` of the `HasBehaviorTree`.

  ```dart
  class MyComponent extends Position with HasBehaviorTree {
      Future<void> onLoad async () {
          treeRoot = Selector(
              children: [
                  Sequence(children: [task1, condition, task2]),
                  Sequence(...),
              ]
          );
          super.onLoad();
      }
  }
  ```

- Increase the `tickInterval` to make the tree tick less frequently.

  ```dart
  class MyComponent extends Position with HasBehaviorTree {
      Future<void> onLoad async () {
          treeRoot = Selector(...);
          tickInterval = 4;
          super.onLoad();
      }
  }  
  ```


## Additional information

When working with behavior trees, keep in mind that

- nodes of a behavior tree do not necessarily update on every frame.
- avoid storing data in nodes as much as possible because it can go out of sync with rest of the
game as nodes are not ticked on every frame.
