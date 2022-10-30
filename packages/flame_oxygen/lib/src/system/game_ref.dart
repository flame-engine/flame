import 'package:flame_oxygen/src/flame_world.dart';
import 'package:flame_oxygen/src/oxygen_game.dart';
import 'package:oxygen/oxygen.dart';

mixin GameRef<T extends OxygenGame> on System {
  /// The world this system belongs to.
  @override
  FlameWorld? get world => super.world as FlameWorld?;

  /// The [T] this system belongs to.
  T? get game => world?.game as T?;
}
