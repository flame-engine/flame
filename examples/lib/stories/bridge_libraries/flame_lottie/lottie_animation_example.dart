import 'package:flame/game.dart';
import 'package:flame_lottie/flame_lottie.dart';

class LottieAnimationExample extends FlameGame {
  static const String description = '''
    This example shows how to load a Lottie animation. It is configured to 
    continuously loop the animation and restart once its done.
  ''';

  @override
  Future<void> onLoad() async {
    final asset = await loadLottie(
      Lottie.asset('assets/images/animations/lottieLogo.json'),
    );

    add(LottieComponent(asset, size: Vector2.all(400), repeating: true));
  }
}
