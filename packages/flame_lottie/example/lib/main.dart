import 'package:flame/game.dart';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: LottieExampleGame()));
}

class LottieExampleGame extends FlameGame {
  @override
  Color backgroundColor() {
    return const Color(0xFFFFFFFF);
  }

  @override
  Future<void> onLoad() async {
    final asset = await loadLottie(Lottie.asset('assets/LottieLogo1.json'));
    add(LottieAnimationComponent(asset));
  }
}

class LottieAnimationComponent extends LottieComponent {
  LottieAnimationComponent(
    LottieComposition composition,
  ) : super(
          composition: composition,
          size: Vector2.all(750),
          repeating: true,
        );
}
