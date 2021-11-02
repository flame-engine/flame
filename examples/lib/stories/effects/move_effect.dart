import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

import '../../commons/circle_component.dart';
import '../../commons/square_component.dart';

class MoveEffectGame extends FlameGame with TapDetector {
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
    square = SquareComponent(size: 50)..position.setValues(200, 150);
    add(square);
    final pathMarkers =
        path.map((point) => ExampleCircleComponent(radius: 3, position: point));
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
