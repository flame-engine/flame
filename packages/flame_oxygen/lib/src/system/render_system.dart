part of flame_oxygen.system;

mixin RenderSystem on System {
  /// The world this system belongs to.
  @override
  FlameWorld? get world => super.world as FlameWorld?;

  void render(Canvas canvas);

  @override
  void execute(double delta) => throw Exception(
        'RenderSystem.execute is not supported in flame_oxygen',
      );
}
