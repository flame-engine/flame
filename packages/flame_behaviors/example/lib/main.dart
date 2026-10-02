import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_behaviors/flame_behaviors.dart';
import 'package:flame_behaviors_example/behaviors/behaviors.dart';
import 'package:material_ui/material_ui.dart';

class ExampleGame() extends FlameGame with EntityMixin, HasCollisionDetection {
  @override
  Future<void> onLoad() async {
    add(FpsTextComponent(position: Vector2.zero()));
    add(ScreenHitbox());

    // Game-specific behaviors
    add(SpawningBehavior());

    await super.onLoad();
  }
}

void main() {
  runApp(GameWidget(game: ExampleGame()));
}
