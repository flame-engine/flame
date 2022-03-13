import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';

import 'flame_forge2d.dart';

class Forge2DCamera extends Camera {
  Body? _targetBody;

  /// Used to minimize the amount of [Vector2] objects created
  final Vector2 _unprojectVector = Vector2.zero();
  final Vector2 _projectVector = Vector2.zero();

  @override
  Vector2 unprojectVector(Vector2 screenCoordinates) {
    _unprojectVector.setFrom(screenCoordinates);
    return (_unprojectVector / zoom)
      ..add(position)
      ..y *= -1;
  }

  @override
  Vector2 projectVector(Vector2 worldCoordinates) {
    _projectVector.setFrom(worldCoordinates);
    return ((_projectVector..y *= -1) - position)..scale(zoom);
  }

  @override
  Vector2 unscaleVector(Vector2 screenCoordinates) {
    return screenCoordinates / zoom;
  }

  @override
  Vector2 scaleVector(Vector2 worldCoordinates) {
    return worldCoordinates * zoom;
  }

  @override
  void update(double dt) {
    if (_targetBody != null) {
      if (follow == null) {
        follow = _targetBody!.position.clone()..y *= -1;
      } else {
        follow!
          ..setFrom(_targetBody!.position)
          ..y *= -1;
      }
    }
    super.update(dt);
  }

  /// Immediately snaps the camera to start following the [BodyComponent].
  ///
  /// This means that the camera will move so that the position vector of the
  /// component is in a fixed position on the screen.
  /// That position is determined by a fraction of screen size defined by
  /// [relativeOffset] (default to the center).
  /// [worldBounds] can be optionally set to add boundaries to how far the
  /// camera is allowed to move.
  /// The component is "grabbed" by its anchor (default top left).
  /// So for example if you want the center of the object to be at the fixed
  /// position, set the components anchor to center.
  void followBodyComponent(
    BodyComponent bodyComponent, {
    Anchor relativeOffset = Anchor.center,
    Rect? worldBounds,
  }) {
    _targetBody = bodyComponent.body;
    if (worldBounds != null) {
      this.worldBounds = worldBounds;
    }
    setRelativeOffset(relativeOffset);
    this.relativeOffset.setFrom(relativeOffset.toVector2());
  }

  void unfollowBodyComponent() {
    _targetBody = null;
  }
}
