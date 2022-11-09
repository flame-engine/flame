import 'package:flame/game.dart';

import 'package:flame_lottie/flame_lottie.dart';

class LottieAnimationExample extends FlameGame {
  static const String description = '''
    This example shows how to load an Lottie animation. It is configured to 
    continuously loop the animation and restart once its done.
  ''';

  @override
  Future onLoad() async {
    final asset =
        await loadLottie(Lottie.asset('assets/images/lottieLogo.json'));

    add(
      LottieComponent(
        composition: asset,
        repeating: true,
      ),
    );

    return super.onLoad();
  }
}
