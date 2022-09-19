[![Pub](https://img.shields.io/pub/v/flame_flare.svg?style=popout)](https://pub.dartlang.org/packages/flame_flare)
![Test](https://github.com/flame-engine/flame_flare/workflows/Test/badge.svg?branch=master&event=push)
[![Discord](https://img.shields.io/discord/509714518008528896.svg)](https://discord.gg/pxrBmy4)


# Flame Flare

Integrate awesome [Flare animations](https://rive.app/explore/popular/trending/all) to your [Flame](https://flame-engine.org/)
game.

```{warning}
**Flare is deprecated and no longer supported.** Please consider upgrading to Rive.
```


## Install

Add `flame_flare` as a dependency in your `pubspec.yaml` file ([what?](https://flutter.io/using-packages/)).

Import the package:

```dart
import 'package:flame_flare/flame_flare.dart';
```


## Usage

This lib exposes a set of tools to integrate a flare animation into a flame game, they are:

- `FlareActorAnimation`: A simple animation object that wraps a `FlareActorRenderBox`.
- `FlareActorComponent`: A Flame's `PositionComponent` sub class that receives and render a
  `FlareActorAnimation`.
- `FlareParticle`: A Flame's `Particle` sub class that receives and renders a `FlareActorAnimation`
  as a particle.


### Simple usage

```dart
class MyAnimationController extends FlareControls {
  void playSomeAnimation() {
    play('Some animation');
  }
}

class MyAnimationComponent extends FlareActorComponent {
  final MyAnimationController animationController;

  MyAnimationComponent(this.animationController)
      : super(
        FlareActorAnimation(
          'assets/my_animation.flr',
          controller: animationController,
          fit: BoxFit.contain,
          alignment: Alignment.bottomCenter,
          size: Vector2(306, 500),
        ),
      );
}
```

See the example app for a slightly more complex usage.


## Support

The simplest way to show us your support is by giving the project a star.

You can also support us by becoming a patron on Patreon:
[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/fireslime)

Or by making a single donation by buying us a coffee:
[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/fireslime)
