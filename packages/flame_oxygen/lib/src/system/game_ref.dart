part of flame_oxygen.system;

mixin GameRef<T extends Game> on System {
  /// The [Game] this system belongs to.
  T? get game => world?.game;
}
