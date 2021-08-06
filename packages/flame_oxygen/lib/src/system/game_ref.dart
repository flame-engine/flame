part of flame_oxygen.system;

mixin GameRef<T extends OxygenGame> on System {
  /// The world this system belongs to.
  @override
  FlameWorld? get world => super.world as FlameWorld?;

  /// The [T] this system belongs to.
  T? get game => world?.game as T?;
}
