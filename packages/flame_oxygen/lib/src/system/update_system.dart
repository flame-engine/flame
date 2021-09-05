import 'package:oxygen/oxygen.dart';

import '../flame_world.dart';

/// Allow a [System] to be part of the update loop from Flame.
mixin UpdateSystem on System {
  /// The world this system belongs to.
  @override
  FlameWorld? get world => super.world as FlameWorld?;

  /// Implement this method to update the game state, given the time [delta]
  /// that has passed since the last update.
  void update(double delta);

  @override
  void execute(double delta) {
    throw Exception('UpdateSystem.execute is not supported in flame_oxygen');
  }
}
