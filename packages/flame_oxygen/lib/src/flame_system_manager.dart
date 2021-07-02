part of flame_oxygen;

extension FlameSystemManager on SystemManager {
  Iterable<RenderSystem> get renderSystems => systems.whereType<RenderSystem>();

  Iterable<UpdateSystem> get updateSystems => systems.whereType<UpdateSystem>();
}
