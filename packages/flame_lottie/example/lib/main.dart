import 'package:flame/game.dart';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(GameWidget(game: LottieGame()));
}

class LottieGame extends FlameGame {
  @override
  Future<void>? onLoad() async {
    final lottie = await AssetLottie('assets/LottieLogo1.json').load();

    add(
      LottieComponent(
        renderer: LottieRenderer(composition: lottie),
        size: Vector2.all(600),
      ),
    );

    return super.onLoad();
  }
}
