part of flame_oxygen.system;

mixin UpdateSystem on System {
  /// The world this system belongs to.
  @override
  FlameWorld? get world => super.world as FlameWorld?;

  void update(double delta);

  @override
  void execute(double delta) => throw Exception(
        'UpdateSystem.execute is not supported in flame_oxygen',
      );
}
