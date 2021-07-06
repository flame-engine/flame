part of flame_oxygen;

/// Extension class for adding Flame specific system filters.
extension FlameSystemManager on SystemManager {
  Iterable<RenderSystem> get renderSystems => systems.whereType<RenderSystem>();

  Iterable<UpdateSystem> get updateSystems => systems.whereType<UpdateSystem>();
}
