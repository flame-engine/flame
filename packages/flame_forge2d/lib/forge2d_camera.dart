import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/body_component.dart';

extension Forge2DCameraExtension on Camera {
  /// Immediately snaps the camera to start following the [BodyComponent].
  ///
  /// This means that the camera will move so that the position vector of the
  /// component is in a fixed position on the screen.
  /// That position is determined by a fraction of screen size defined by
  /// [relativeOffset] (default to the center).
  /// [worldBounds] can be optionally set to add boundaries to how far the
  /// camera is allowed to move.
  /// [useCenterOfMass] set true to follow the body's center of mass rather than
  /// position (default to false).
  void followBodyComponent(
    BodyComponent bodyComponent, {
    Anchor relativeOffset = Anchor.center,
    Rect? worldBounds,
    bool useCenterOfMass = false,
  }) {
    followVector2(
      useCenterOfMass
          ? bodyComponent.body.worldCenter
          : bodyComponent.body.position,
      relativeOffset: relativeOffset,
      worldBounds: worldBounds,
    );
  }
}
