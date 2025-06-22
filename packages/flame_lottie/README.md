<!-- markdownlint-disable MD013 -->
<p align="center">
  <a href="https://flame-engine.org">
    <img alt="flame" width="200px" src="https://user-images.githubusercontent.com/6718144/101553774-3bc7b000-39ad-11eb-8a6a-de2daa31bd64.png">
  </a>
</p>

<p align="center">
Adds support for <a href="https://github.com/airbnb/lottie-android">Lottie animations</a> to your <a href="https://github.com/flame-engine/flame">Flame</a> games.
</p>

<p align="center">
  <a title="Pub" href="https://pub.dev/packages/flame_lottie" ><img src="https://img.shields.io/pub/v/flame_lottie.svg?style=popout" /></a>
  <a title="Test" href="https://github.com/flame-engine/flame/actions?query=workflow%3Acicd+branch%3Amain"><img src="https://github.com/flame-engine/flame/actions/workflows/cicd.yml/badge.svg?branch=main&event=push"/></a>
  <a title="Discord" href="https://discord.gg/pxrBmy4"><img src="https://img.shields.io/discord/509714518008528896.svg"/></a>
  <a title="Melos" href="https://github.com/invertase/melos"><img src="https://img.shields.io/badge/maintained%20with-melos-f700ff.svg"/></a>
</p>

---
<!-- markdownlint-enable MD013 -->

<!-- markdownlint-disable-next-line MD002 -->

# flame_lottie

This package allows you to load and add Lottie animations to your Flame game.

> Lottie is a mobile library for Android and iOS that parses Adobe After Effects animations
exported as json with Bodymovin and renders them natively on mobile!

Source: [lottie-android](https://github.com/airbnb/lottie-android) on Github


The native Lottie libraries (such as [lottie-android](https://github.com/airbnb/lottie-android))
are maintained by **Airbnb**.

The Flutter package ``lottie``, on which this wrapper is based on, is by **xaha.dev** and can be
found on [pub dev](https://pub.dev/packages/lottie).


## Usage

To use it in your game you just need to add `flame_lottie` to your pubspec.yaml.

Simply load the Lottie animation using the **loadLottie** method and the
[LottieBuilder](https://pub.dev/documentation/lottie/latest/lottie/LottieBuilder-class.html). It
allows all the various ways of loading a Lottie file:

- [Lottie.asset](https://pub.dev/documentation/lottie/latest/lottie/Lottie/asset.html), for
obtaining a Lottie file from an AssetBundle using a key.
- [Lottie.network](https://pub.dev/documentation/lottie/latest/lottie/Lottie/network.html), for
obtaining a lottie file from a URL.
- [Lottie.file](https://pub.dev/documentation/lottie/latest/lottie/Lottie/file.html), for obtaining
 a lottie file from a File.
- [Lottie.memory](https://pub.dev/documentation/lottie/latest/lottie/Lottie/memory.html), for
obtaining a lottie file from a Uint8List.

... and add it as `LottieComponent` to your flame 🔥 game.

Example:

```dart
class MyGame extends FlameGame {
  ...
  @override
  Future<void> onLoad() async {
    final asset = Lottie.asset('assets/LottieLogo1.json');
    final animation = await loadLottie(asset);
    add(
        LottieComponent(
            composition: animation,
            repeating: true, // continuously loop the animation
        ),
    );
  }
  ...
}
```
