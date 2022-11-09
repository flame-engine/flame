import 'package:flame/game.dart';
import 'package:flame_lottie/flame_lottie.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final game = LottieExampleGame();

  @override
  Widget build(BuildContext context) {
    return GameWidget(game: game);
  }
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
