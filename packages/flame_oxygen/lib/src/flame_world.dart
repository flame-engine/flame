part of flame_oxygen;

class FlameWorld extends World {
  final Game game;

  FlameWorld(this.game) : super();

  void render(Canvas canvas) {
    for (final system in systemManager.renderSystems) {
      system.render(canvas);
    }
  }

  void update(double delta) {
    for (final system in systemManager.updateSystems) {
      system.update(delta);
    }
    entityManager.processRemovedEntities();
  }

  @override
  void execute(double delta) => throw Exception(
        'FlameWorld.execute is not supported in flame_oxygen',
      );
}
