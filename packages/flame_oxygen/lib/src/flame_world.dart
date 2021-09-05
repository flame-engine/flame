import 'package:flame/extensions.dart';
import 'package:oxygen/oxygen.dart';

import 'flame_system_manager.dart';
import 'oxygen_game.dart';
import 'system.dart';

class FlameWorld extends World {
  /// The game this world belongs to.
  final OxygenGame game;

  FlameWorld(this.game) : super();

  /// Render all the [RenderSystem]s.
  void render(Canvas canvas) {
    for (final system in systemManager.renderSystems) {
      system.render(canvas);
    }
  }

  /// Render all the [UpdateSystem]s.
  void update(double delta) {
    for (final system in systemManager.updateSystems) {
      system.update(delta);
    }
    entityManager.processRemovedEntities();
  }

  @override
  void execute(double delta) => throw Exception(
        'FlameWorld.execute is not supported in flame_oxygen',
      );
}
