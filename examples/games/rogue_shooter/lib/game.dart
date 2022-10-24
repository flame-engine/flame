import 'package:collision_detection_performance/components/enemy_creator.dart';
import 'package:collision_detection_performance/components/player_component.dart';
import 'package:collision_detection_performance/components/star_background_creator.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';

class SpaceShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection {
  late final PlayerComponent player;
  late final TextComponent componentCounter;
  late final TextComponent scoreText;

  int score = 0;

  @override
  Future<void> onLoad() async {
    add(player = PlayerComponent());
    add(FpsTextComponent());
    add(
      componentCounter = TextComponent(
        position: size,
        anchor: Anchor.bottomRight,
        priority: 1,
      ),
    );

    add(EnemyCreator());
    add(StarBackGroundCreator());

    add(
      scoreText = TextComponent(
        position: Vector2(size.x, 0),
        anchor: Anchor.topRight,
        priority: 1,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    scoreText.text = 'Score: $score';
    componentCounter.text = 'Components: ${children.length}';
  }

  @override
  void onPanStart(_) {
    player.beginFire();
  }

  @override
  void onPanEnd(_) {
    player.stopFire();
  }

  @override
  void onPanCancel() {
    player.stopFire();
  }

  @override
  void onPanUpdate(DragUpdateInfo details) {
    player.position += details.delta.game;
  }

  void increaseScore() {
    score++;
  }
}
