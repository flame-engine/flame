import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import 'body_component.dart';
import 'forge2d_game.dart';

/// A [PositionBodyComponent] handles a [PositionComponent] on top of a
/// [BodyComponent]. You have to keep track of the size of the
/// [PositionComponent] and it can only have its anchor in the center.
/// You can initialize it either by sending in a [PositionComponent] and a
/// [size] in the constructor, or set those fields in [onLoad].
abstract class PositionBodyComponent<T extends Forge2DGame>
    extends BodyComponent<T> {
  PositionComponent? positionComponent;
  final Vector2? _size;
  Vector2 get size => _size!;

  @override
  bool debugMode = false;

  /// Make sure that the [size] of the position component matches the bounding
  /// shape of the body that is create in createBody()
  PositionBodyComponent({
    this.positionComponent,
    Vector2? size,
  }) : _size = size;

  @mustCallSuper
  @override
  Future<void> onMount() async {
    super.onMount();
    assert(
      positionComponent != null,
      'The positionComponent has to be either sent in as an argument or set in onLoad',
    );
    assert(
      positionComponent != null,
      'The size has to be either sent in as an argument or set in onLoad',
    );
    positionComponent!.anchor = Anchor.center;
    positionComponent!.size = size;
    if (!gameRef.contains(positionComponent!)) {
      gameRef.add(positionComponent!);
    }
    _updatePositionComponent();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updatePositionComponent();
  }

  @override
  void onRemove() {
    // Since the PositionComponent was added to the game in this class it should
    // also be removed by this class when the BodyComponent is removed.
    positionComponent?.removeFromParent();
    super.onRemove();
  }

  void _updatePositionComponent() {
    positionComponent?.position.setFrom(body.position);
    positionComponent?.position.y *= -1;
    positionComponent!.angle = -angle;
  }
}
