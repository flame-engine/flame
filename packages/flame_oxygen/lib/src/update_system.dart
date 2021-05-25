part of flame_oxygen;

mixin UpdateSystem on System {
  FlameWorld? get world => super.world as FlameWorld?;

  void update(double delta);

  @override
  void execute(double delta) => throw Exception(
        'UpdateSystem.execute is not supported in flame_oxygen',
      );
}
