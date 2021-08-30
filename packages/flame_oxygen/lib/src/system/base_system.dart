import 'package:flutter/material.dart';
import 'package:oxygen/oxygen.dart';

import '../component.dart';
import '../system.dart';

/// System that provides base rendering for default components.
///
/// Based on the PositionComponent logic from Flame.
abstract class BaseSystem extends System with RenderSystem {
  Query? _query;

  /// List of all the entities found using the [filters].
  List<Entity> get entities => _query?.entities ?? [];

  /// Filters used for querying entities.
  ///
  /// The [PositionComponent] and [SizeComponent] will be added automatically.
  List<Filter<Component>> get filters;

  @override
  @mustCallSuper
  void init() {
    _query = createQuery([
      Has<PositionComponent>(),
      Has<SizeComponent>(),
      ...filters,
    ]);
  }

  @override
  void dispose() {
    _query = null;
    super.dispose();
  }

  @override
  void render(Canvas canvas) {
    for (final entity in entities) {
      final position = entity.get<PositionComponent>()!;
      final size = entity.get<SizeComponent>()!.size;
      final anchor = entity.get<AnchorComponent>()?.anchor ?? Anchor.topLeft;
      final angle = entity.get<AngleComponent>()?.radians ?? 0;
      final flip = entity.get<FlipComponent>();

      canvas
        ..save()
        ..translate(position.x, position.y)
        ..rotate(angle);

      final delta = -anchor.toVector2()
        ..multiply(size);
      canvas.translate(delta.x, delta.y);

      // Handle inverted rendering by moving center and flipping.
      if (flip != null && (flip.flipX || flip.flipY)) {
        canvas.translate(size.x / 2, size.y / 2);
        canvas.scale(flip.flipX ? -1.0 : 1.0, flip.flipY ? -1.0 : 1.0);
        canvas.translate(-size.x / 2, -size.y / 2);
      }
      renderEntity(canvas, entity);

      canvas.restore();
    }
  }

  /// Render given entity.
  ///
  /// The canvas is already prepared for this entity.
  void renderEntity(Canvas canvas, Entity entity);
}
