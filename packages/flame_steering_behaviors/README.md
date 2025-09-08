# Steering Behaviors

[![Very Good Ventures][logo_white]][very_good_ventures_link_dark]
[![Very Good Ventures][logo_black]][very_good_ventures_link_light]

Developed with 💙 by [Very Good Ventures][very_good_ventures_link] 🦄

[![ci][ci_badge]][ci_link]
[![coverage][coverage_badge]][ci_link]
[![pub package][pub_badge]][pub_link]
[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![License: MIT][license_badge]][license_link]
[![Powered by Flame][flame_badge_link]]([flame_link])

---

An implementation of steering behaviors for Flame Behaviors. 
See [Steering Behaviors For Autonomous Characters](https://www.red3d.com/cwr/steer/) by 
[Craig Reynolds](https://www.red3d.com/cwr/) for an in-depth explanation

---

## Installation 💻

```
flutter pub add flame_steering_behaviors
```

## Usage ✨

This package is built on top of the [`flame_behaviors`](https://pub.dev/packages/flame_behaviors), if you are not yet familiar with it, we recommend reading up on the documentation of that package first.

### Steerable

If you want to apply steering behaviors to your entities you have to add the `Steerable` mixin to your entity class:

```dart
class MyEntity extends Entity with Steerable {
  /// Provide the max velocity this entity can hold.
  double get maxVelocity => 100;

  ...
}
```

The `Steerable` mixin provides a `velocity` value to your entity, this velocity will then be applied on each update cycle to your entity until the velocity becomes zero.

### Steering Behaviors

Each algorithm defined by this project is available as a `Behavior` and you can add them to your [steerable](#steerable) entities as you would with any behavior:

```dart
class MyEntity extends Entity with Steerable {
  MyEntity() : super(
    behaviors: [
      WanderBehavior(
        circleDistance: 200,
        maximumAngle: 45 * degrees2Radians,
        startingAngle: 0,
      )
    ]
  );

  ...
}
```

Some steering behaviors require information that is not always available on entity creation, when that happens we recommend using the entity's `onLoad` method:

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

[ci_badge]: https://github.com/VeryGoodOpenSource/flame_behaviors/workflows/flame_steering_behaviors/badge.svg
[ci_link]: https://github.com/VeryGoodOpenSource/flame_behaviors/actions
[coverage_badge]: https://raw.githubusercontent.com/VeryGoodOpenSource/flame_behaviors/main/coverage_badge.svg
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[pub_badge]: https://img.shields.io/pub/v/flame_steering_behaviors.svg
[pub_link]: https://pub.dartlang.org/packages/flame_steering_behaviors
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_ventures_link]: https://verygood.ventures/?utm_source=github&utm_medium=banner&utm_campaign=CLI
[very_good_ventures_link_dark]: https://verygood.ventures/?utm_source=github&utm_medium=banner&utm_campaign=CLI#gh-dark-mode-only
[very_good_ventures_link_light]: https://verygood.ventures/?utm_source=github&utm_medium=banner&utm_campaign=CLI#gh-light-mode-only
[flame_badge_link]: https://img.shields.io/badge/Powered%20by-%F0%9F%94%A5-orange.svg
[flame_link]: https://flame-engine.org
