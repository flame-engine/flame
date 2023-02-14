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
