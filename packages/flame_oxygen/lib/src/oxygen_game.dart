part of flame_oxygen;

/// This is a Oxygen based implementation of [Game].
///
/// OxygenGame should be extended to add your game logic.
///
/// It is based on the Oxygen package.
abstract class OxygenGame extends Game {
  late final FlameWorld world;

  OxygenGame() {
    world = FlameWorld(this);
  }

  /// Create a new [Entity].
  Entity createEntity({
    String? name,
    required Vector2 position,
    required Vector2 size,
    double? angle,
  }) {
    final entity = world.entityManager.createEntity(name)
      ..add<PositionComponent, Vector2>(position)
      ..add<SizeComponent, Vector2>(size);
    if (angle != null) {
      entity.add<AngleComponent, double>(angle);
    }
    return entity;
  }

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    // Registering few default components.
    world.registerComponent<SizeComponent, Vector2>(() => SizeComponent());
    world.registerComponent<PositionComponent, Vector2>(
      () => PositionComponent(),
    );
    world.registerComponent<AngleComponent, double>(() => AngleComponent());
    world.registerComponent<SpriteComponent, SpriteInit>(
      () => SpriteComponent(),
    );

    // Registering default systems.
    // world.registerSystem(BaseSystem());

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
