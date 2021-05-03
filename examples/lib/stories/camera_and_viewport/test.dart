
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';

//class TestGame extends BaseGame {
//  @override
//  Future<void> onLoad() async {
//    final bigSquare = SquareComponent()..size = Vector2.all(200);
//    final red = Paint()..color = Colors.red;
//    final smallSquare = SquareComponent()..size = Vector2.all(100)..position = Vector2.all(100)..paint = red;
//    add(bigSquare);
//    add(smallSquare);
//    camera.zoom = 2;
//    camera.snapTo(Vector2.all(100));
//  }
//}

class TestGame extends Game {
  @override
  void render(Canvas canvas) {
    const zoom = 3.0;
    canvas.translateVector(-Vector2.all(100)..scale(zoom));
    //canvas.translateVector(-Vector2.all(100));
    canvas.scale(zoom);
    canvas.drawRect(Rect.fromPoints(Offset.zero, const Offset(200, 200)), BasicPalette.white.paint(),);
    canvas.drawRect(Rect.fromPoints(const Offset(100, 100), const Offset(200, 200)), BasicPalette.red.paint(),);
  }

  @override
  void update(double dt) {
    // TODO: implement update
  }
}
