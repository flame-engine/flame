import 'package:flame/components.dart';
import 'package:trex_game/obstacle/obstacle_type.dart';
import 'package:trex_game/random_extension.dart';
import 'package:trex_game/trex_game.dart';

class Obstacle extends SpriteComponent with HasGameReference<TRexGame> {
  Obstacle({
    required this.settings,
    required this.groupIndex,
  }) : super(size: settings.size);

  final double _gapCoefficient = 0.6;
  final double _maxGapCoefficient = 1.5;

  bool followingObstacleCreated = false;
  late double gap;
  final ObstacleTypeSettings settings;
  final int groupIndex;

  bool get isVisible => (x + width) > 0;

  @override
  Future<void> onLoad() async {
    sprite = settings.sprite(game.spriteImage);
    x = game.size.x + width * groupIndex;
    y = settings.y;
    gap = computeGap(_gapCoefficient, game.currentSpeed);
    addAll(settings.generateHitboxes());
  }

  double computeGap(double gapCoefficient, double speed) {
    final minGap =
        (width * speed * settings.minGap * gapCoefficient).roundToDouble();
    final maxGap = (minGap * _maxGapCoefficient).roundToDouble();
    return random.fromRange(minGap, maxGap);
  }

  @override
  void update(double dt) {
    super.update(dt);
    x -= game.currentSpeed * dt;

    if (!isVisible) {
      removeFromParent();
    }
  }
}
