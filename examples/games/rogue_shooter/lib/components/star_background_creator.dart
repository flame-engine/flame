import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:rogue_shooter/components/star_component.dart';

class StarBackGroundCreator extends Component with HasGameRef {
  final gapSize = 12;

  late final SpriteSheet spriteSheet;
  Random random = Random();

  StarBackGroundCreator();

  @override
  Future<void> onLoad() async {
    spriteSheet = SpriteSheet.fromColumnsAndRows(
      image: await gameRef.images.load('rogue_shooter/stars.png'),
      rows: 4,
      columns: 4,
    );

    final starGapTime = (gameRef.size.y / gapSize) / StarComponent.speed;

    add(
      TimerComponent(
        period: starGapTime,
        repeat: true,
        onTick: () => _createRowOfStars(0),
      ),
    );

    _createInitialStars();
  }

  void _createStarAt(double x, double y) {
    final animation = spriteSheet.createAnimation(
      row: random.nextInt(3),
      to: 4,
      stepTime: 0.1,
    )..variableStepTimes = [max(20, 100 * random.nextDouble()), 0.1, 0.1, 0.1];

    gameRef.add(StarComponent(animation: animation, position: Vector2(x, y)));
  }

  void _createRowOfStars(double y) {
    const gapSize = 6;
    final starGap = gameRef.size.x / gapSize;

    for (var i = 0; i < gapSize; i++) {
      _createStarAt(
        starGap * i + (random.nextDouble() * starGap),
        y + (random.nextDouble() * 20),
      );
    }
  }

  void _createInitialStars() {
    final rows = gameRef.size.y / gapSize;

    for (var i = 0; i < gapSize; i++) {
      _createRowOfStars(i * rows);
    }
  }
}
