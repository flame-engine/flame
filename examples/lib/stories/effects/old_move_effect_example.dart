import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

import '../../commons/square_component.dart';

class OldMoveEffectExample extends FlameGame with TapDetector {
  static const String description = '''
    This example showcases the `MoveEffect`. Click somewhere on the screen and
    the white square will go there and then it will follow the path that is
    laid out by the white circular markers. After it has finished the path it
    waits for a bit and then returns to its original position.
  ''';

  late SquareComponent square;

  final List<Vector2> path = [
    Vector2(100, 100),
    Vector2(50, 120),
    Vector2(200, 400),
    Vector2(150, 150),
    Vector2(100, 300),
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    square = SquareComponent(size: 50, position: Vector2(200, 150));
    add(square);
    final pathMarkers =
        path.map((p) => CircleComponent(radius: 3, position: p));
    addAll(pathMarkers);
  }

  @override
  void onTapUp(TapUpInfo info) {
    square.add(
      MoveEffect(
        path: [info.eventPosition.game] + path,
        speed: 250.0,
        isAlternating: true,
        peakDelay: 2.0,
      ),
    );
  }
}
