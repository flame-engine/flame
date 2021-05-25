part of flame_oxygen;

extension FlameSystemManager on SystemManager {
  Iterable<RenderSystem> get renderSystems =>
      systems.where((s) => s is RenderSystem).cast();

  Iterable<UpdateSystem> get updateSystems =>
      systems.where((s) => s is UpdateSystem).cast();
}
