<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Adds support for [Flare animations](https://rive.app/explore/popular/trending/all) to your [Flame](https://github.com/flame-engine/flame) games.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_flare" ><img src="https://img.shields.io/pub/v/flame_flare.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/workflows/cicd/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->

# flame_flare

Integrate awesome [Flare animations](https://rive.app/explore/popular/trending/all) to your [Flame](https://flame-engine.org/)
game.

> :warning: **Flare is deprecated and no longer supported.**
> Please consider upgrading to Rive.


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
[![Patreon](https://c5.patreon.com/external/logo/become_a_patron_button.png)](https://www.patreon.com/bluefireoss)

Or by making a single donation by buying us a coffee:
[![Buy Me A Coffee](https://user-images.githubusercontent.com/835641/60540201-fcd7fa00-9ce4-11e9-87ec-1e98568e9f58.png)](https://www.buymeacoffee.com/bluefire)
