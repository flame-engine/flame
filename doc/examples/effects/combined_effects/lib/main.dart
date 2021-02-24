import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/flame.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/widgets.dart';

import './square.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  runApp(
    GameWidget(
      game: MyGame(),
    ),
  );
}

class MyGame extends BaseGame with TapDetector {
  late Square greenSquare;

  MyGame() {
    final green = Paint()..color = const Color(0xAA338833);
    final red = Paint()..color = const Color(0xAA883333);
    greenSquare = Square(green, Vector2.all(100));
    final redSquare = Square(red, Vector2.all(100));
    add(greenSquare);
    add(redSquare);
  }

  @override
  void onTapUp(TapUpDetails details) {
    greenSquare.clearEffects();
    final Vector2 currentTap = details.localPosition.toVector2();

    final move = MoveEffect(
      path: [
        currentTap,
        currentTap - Vector2(50, 20),
        currentTap + Vector2.all(30),
      ],
      duration: 4.0,
      curve: Curves.bounceInOut,
      isInfinite: false,
      isAlternating: false,
    );

    final scale = ScaleEffect(
      size: currentTap,
      speed: 200.0,
      curve: Curves.linear,
      isInfinite: false,
      isAlternating: true,
    );

    final rotate = RotateEffect(
      angle: currentTap.angleTo(Vector2.all(100)),
      duration: 3,
      curve: Curves.decelerate,
      isInfinite: false,
      isAlternating: false,
    );

    final combination = CombinedEffect(
      effects: [move, rotate, scale],
      isInfinite: false,
      isAlternating: true,
      offset: 0.5,
      onComplete: () => print("onComplete callback"),
    );
    greenSquare.addEffect(combination);
  }
}
