import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:oxygen/oxygen.dart';

import 'component.dart';
import 'flame_world.dart';

/// This is an Oxygen based implementation of [Game].
///
/// [OxygenGame] should be extended to add your own game logic.
///
/// It is based on the Oxygen package.
abstract class OxygenGame with Loadable, Game {
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
    Anchor? anchor,
    bool flipX = false,
    bool flipY = false,
  }) {
    final entity = world.entityManager.createEntity(name)
      ..add<PositionComponent, Vector2>(position)
      ..add<SizeComponent, Vector2>(size)
      ..add<AnchorComponent, Anchor>(anchor)
      ..add<AngleComponent, double>(angle)
      ..add<FlipComponent, FlipInit>(FlipInit(flipX: flipX, flipY: flipY));
    return entity;
  }

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await super.onLoad();

    // Registering default components.
    world.registerComponent<SizeComponent, Vector2>(() => SizeComponent());
    world.registerComponent<PositionComponent, Vector2>(
      () => PositionComponent(),
    );
    world.registerComponent<AngleComponent, double>(() => AngleComponent());
    world.registerComponent<AnchorComponent, Anchor>(() => AnchorComponent());
    world.registerComponent<SpriteComponent, SpriteInit>(
      () => SpriteComponent(),
    );
    world.registerComponent<TextComponent, TextInit>(() => TextComponent());
    world.registerComponent<FlipComponent, FlipInit>(() => FlipComponent());

    await init();
    world.init();
  }

  /// Initialize the game and world.
  Future<void> init();

  @override
  @mustCallSuper
  void render(Canvas canvas) => world.render(canvas);

  @override
  @mustCallSuper
  void update(double delta) => world.update(delta);
}
