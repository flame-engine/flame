part of flame_oxygen.system;

class FlameSystem extends System with RenderSystem, UpdateSystem {
  Query? query;

  @override
  void init() {
    query = createQuery([
      Has<PositionComponent>(),
      Has<SizeComponent>(),
    ]);
    // TODO: implement init
  }

  @override
  void dispose() {
    query = null;
    super.dispose();
  }

  @override
  void render(Canvas canvas) {
    for (final entity in query?.entities ?? <Entity>[]) {
      final position = entity.get<PositionComponent>()!;
      final size = entity.get<SizeComponent>()!.size;

      canvas.save();

      canvas.translate(position.x, position.y);
      if (entity.has<AngleComponent>()) {
        final angle = entity.get<AngleComponent>()!.radians;
        canvas.rotate(angle);
      }
      // final delta = -anchor.toVector2()
      //   ..multiply(size);
      // canvas.translate(delta.x, delta.y);

      // Handle inverted rendering by moving center and flipping.
      // if (renderFlipX || renderFlipY) {
      //   canvas.translate(width / 2, height / 2);
      //   canvas.scale(renderFlipX ? -1.0 : 1.0, renderFlipY ? -1.0 : 1.0);
      //   canvas.translate(-width / 2, -height / 2);
      // }

      if (entity.has<SpriteComponent>()) {
        final sprite = entity.get<SpriteComponent>()?.sprite;
        sprite?.render(canvas, size: size);
      }

      canvas.restore();
    }
  }

  @override
  void update(double delta) {
    // TODO: implement update
  }
}
