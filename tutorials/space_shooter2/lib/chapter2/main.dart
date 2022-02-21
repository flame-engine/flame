import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';

void main() {
  final game = MyGame();
  runApp(GameWidget(game: game));
}

class MyGame extends FlameGame {
  @override
  Color backgroundColor() => const Color(0xff4b189c);

  @override
  void render(Canvas canvas) {
    final paint = Paint() ..color = const Color(0xffe5b83f);
    canvas.drawCircle(const Offset(200, 200), 20, paint);
  }
}
