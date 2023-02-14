import 'package:flame/game.dart';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/material.dart';

void main() async {
  runApp(GameWidget(game: LottieExampleGame()));
}

class LottieExampleGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    final asset = await loadLottie(Lottie.asset('assets/LottieLogo1.json'));
    add(
      LottieComponent(
        asset,
        size: Vector2.all(400),
        repeating: true,
      ),
    );
  }
}
