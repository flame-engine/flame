import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'body_component.dart';
import 'forge2d_game.dart';

/// A [PositionBodyComponent] handles a [PositionComponent] on top of a
/// [BodyComponent]. You have to keep track of the size of the
/// [PositionComponent] and it can only have its anchor in the center.
abstract class PositionBodyComponent<T extends Forge2DGame>
    extends BodyComponent<T> {
  PositionComponent positionComponent;
  Vector2 size;

  @override
  bool debugMode = false;

  /// Make sure that the [size] of the position component matches the bounding
  /// shape of the body that is create in createBody()
  PositionBodyComponent(
    this.positionComponent,
    this.size,
  );

  @mustCallSuper
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    updatePositionComponent();
    positionComponent..anchor = Anchor.center;
    gameRef.add(positionComponent);
  }

  @override
  void update(double dt) {
    super.update(dt);
    updatePositionComponent();
  }

  @override
  void onRemove() {
    super.onRemove();
    // Since the PositionComponent was added to the game in this class it should
    // also be removed by this class when the BodyComponent is removed.
    positionComponent.removeFromParent();
  }

  void updatePositionComponent() {
    positionComponent.position..setFrom(body.position);
    positionComponent.position.y *= -1;
    positionComponent
      ..angle = -angle
      ..size = size;
  }
}
