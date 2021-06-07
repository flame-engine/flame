part of flame_oxygen.system;

mixin RenderSystem on System {
  FlameWorld? get flameWorld => world as FlameWorld;

  void render(Canvas canvas);

  @override
  void execute(double delta) => throw Exception(
        'RenderSystem.execute is not supported in flame_oxygen',
      );
}
