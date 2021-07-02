part of flame_oxygen.system;

class ParticleSystem extends System with RenderSystem, UpdateSystem {
  Query? query;

  @override
  void init() => query = createQuery([Has<ParticleComponent>()]);

  @override
  void dispose() {
    query = null;
    super.dispose();
  }

  @override
  void render(Canvas canvas) {
    for (final entity in query?.entities ?? <Entity>[]) {
      final particle = entity.get<ParticleComponent>()!.particle;
      particle?.render(canvas);
    }
  }

  @override
  void update(double delta) {
    for (final entity in query?.entities ?? <Entity>[]) {
      final particle = entity.get<ParticleComponent>()!.particle;
      particle?.update(delta);
    } 
  }
}
