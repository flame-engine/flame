import 'package:flame/extensions.dart';
import 'package:flame_oxygen/src/flame_world.dart';
import 'package:oxygen/oxygen.dart';

/// Allow a [System] to be part of the render loop from Flame.
mixin RenderSystem on System {
  /// The world this system belongs to.
  @override
  FlameWorld? get world => super.world as FlameWorld?;

  /// Implement this method to render the current game state in the [canvas].
  void render(Canvas canvas);

  @override
  void execute(double delta) {
    throw Exception('RenderSystem.execute is not supported in flame_oxygen');
  }
}
