import 'package:doc_flame_examples/ember.dart';
import 'package:flame/experimental.dart';
import 'package:flame/game.dart';

class CollisionDetectionGame extends FlameGame with HasTappableComponents {
  @override
  Future<void> onLoad() async {
    final emberPlayer = EmberPlayer(
      position: Vector2.all(10),
    );
    add(emberPlayer);
  }
}
