<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
An implementation of steering behaviors for Flame Behaviors.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_behaviors" ><img src="https://img.shields.io/pub/v/flame_behaviors.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->
# steering_behaviors


An implementation of steering behaviors for Flame Behaviors.
See [Steering Behaviors For Autonomous Characters](https://www.red3d.com/cwr/steer/) by
[Craig Reynolds](https://www.red3d.com/cwr/) for an in-depth explanation

Developed with 💙 and 🔥 by [Very Good Ventures][very_good_ventures_link] 🦄


---


## Installation 💻

```sh
flutter pub add flame_steering_behaviors
```


## Usage ✨

This package is built on top of the
[`flame_behaviors`](https://pub.dev/packages/flame_behaviors), if you are not
yet familiar with it, we recommend reading up on the documentation of that
package first.


### Steerable

If you want to apply steering behaviors to your entities you have to add the
`Steerable` mixin to your entity class:

```dart
class MyEntity extends Entity with Steerable {
  /// Provide the max velocity this entity can hold.
  double get maxVelocity => 100;

  ...
}
```

The `Steerable` mixin provides a `velocity` value to your entity, this
velocity will then be applied on each update cycle to your entity until the
velocity becomes zero.


### Steering Behaviors

Each algorithm defined by this project is available as a `Behavior` and you
can add them to your [steerable](#steerable) entities as you would with any
behavior:

```dart
class MyEntity extends Entity with Steerable {
  MyEntity()
    : super(
        behaviors: [
          WanderBehavior(
            circleDistance: 200,
            maximumAngle: 45 * degrees2Radians,
            startingAngle: 0,
          ),
        ],
      );
      ...
}
```

Some steering behaviors require information that is not always available on
entity creation, when that happens we recommend using the entity's `onLoad`
method:

```dart
class MyEntity extends Entity with Steerable {
  ...

  @override
  Future<void> onLoad() async {
    world.children.register<MyOtherEntity>();
    await add(
      SeparationBehavior(
        world.children.query<MyOtherEntity>(),
        maxDistance: 25,
        maxAcceleration: 1000,
      ),
    );
  }

  ...
}
```


[very_good_ventures_link]: https://verygood.ventures/?utm_source=github&utm_medium=banner&utm_campaign=CLI

