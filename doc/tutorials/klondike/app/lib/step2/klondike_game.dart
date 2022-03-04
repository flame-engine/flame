import 'package:flame/game.dart';

class KlondikeGame extends FlameGame {
  @override
  Future<void> onLoad() async {
    await images.load('klondike-sprites.png');
  }
}
