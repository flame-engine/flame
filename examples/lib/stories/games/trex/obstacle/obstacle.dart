import 'package:examples/stories/games/trex/obstacle/obstacle_type.dart';
import 'package:examples/stories/games/trex/random_extension.dart';
import 'package:examples/stories/games/trex/trex_game.dart';
import 'package:flame/components.dart';

class Obstacle extends SpriteComponent with HasGameRef<TRexGame> {
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
    sprite = settings.sprite(gameRef.spriteImage);
    x = gameRef.size.x + width * groupIndex;
    y = settings.y;
    gap = computeGap(_gapCoefficient, gameRef.currentSpeed);
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
    x -= gameRef.currentSpeed * dt;

    if (!isVisible) {
      removeFromParent();
    }
  }
}
