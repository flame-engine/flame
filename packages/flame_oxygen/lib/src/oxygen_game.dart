part of flame_oxygen;

abstract class OxygenGame extends Game {
  late FlameWorld world;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    world = FlameWorld(this);
    await init();
    world.init();
  }

  Future<void> init();

  @override
  @mustCallSuper
  void render(Canvas canvas) => world.render(canvas);

  @override
  @mustCallSuper
  void update(double delta) => world.update(delta);
}
