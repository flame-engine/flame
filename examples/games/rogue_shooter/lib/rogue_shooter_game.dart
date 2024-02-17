import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:rogue_shooter/components/enemy_creator.dart';
import 'package:rogue_shooter/components/player_component.dart';
import 'package:rogue_shooter/components/star_background_creator.dart';

class RogueShooterGame extends FlameGame
    with PanDetector, HasCollisionDetection, HasPerformanceTracker {
  static const String description = '''
    A simple space shooter game used for testing performance of the collision
    detection system in Flame.
  ''';

  late final PlayerComponent _player;
  late final TextComponent _componentCounter;
  late final TextComponent _scoreText;

  final _updateTime = TextComponent(
    text: 'Update time: 0ms',
    position: Vector2(0, 0),
    priority: 1,
  );

  final TextComponent _renderTime = TextComponent(
    text: 'Render time: 0ms',
    position: Vector2(0, 25),
    priority: 1,
  );

  int _score = 0;

  @override
  Future<void> onLoad() async {
    add(_player = PlayerComponent());
    addAll([
      FpsTextComponent(
        position: size - Vector2(0, 50),
        anchor: Anchor.bottomRight,
      ),
      _scoreText = TextComponent(
        position: size - Vector2(0, 25),
        anchor: Anchor.bottomRight,
        priority: 1,
      ),
      _componentCounter = TextComponent(
        position: size,
        anchor: Anchor.bottomRight,
        priority: 1,
      ),
    ]);

    add(EnemyCreator());
    add(StarBackGroundCreator());

    addAll([_updateTime, _renderTime]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _scoreText.text = 'Score: $_score';
    _componentCounter.text = 'Components: ${children.length}';
    _updateTime.text = 'Update time: $updateTime ms';
    _renderTime.text = 'Render time: $renderTime ms';
  }

  @override
  void onPanStart(_) {
    _player.beginFire();
  }

  @override
  void onPanEnd(_) {
    _player.stopFire();
  }

  @override
  void onPanCancel() {
    _player.stopFire();
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    _player.position += info.delta.global;
  }

  void increaseScore() {
    _score++;
  }
}
