import 'package:flame/camera.dart';
import 'package:flame/game.dart';

/// A [Viewfinder] that renders a world measured in meters onto a screen
/// measured in pixels.
///
/// Forge2D has a speed limit that a body reaches very quickly when one meter
/// is rendered as one pixel, so a physics world has to be laid out in meters
/// that are considerably smaller than a pixel. [metersToPixels] is the number
/// of pixels that one meter is rendered as, and keeping it separate from the
/// [zoom] leaves the zoom free for what it is meant for: zooming the camera
/// in and out.
///
/// Only the rendering is affected, so body positions, the [position] of the
/// viewfinder, [visibleGameSize], [CameraComponent.visibleWorldRect] and the
/// local positions that events report are all still in meters.
class Forge2DViewfinder extends Viewfinder {
  Forge2DViewfinder({double metersToPixels = defaultMetersToPixels, super.key})
    : assert(metersToPixels > 0, 'metersToPixels must be positive'),
      _metersToPixels = metersToPixels {
    zoom = 1;
  }

  /// The number of pixels that one meter is rendered as when no other value
  /// is given.
  static const double defaultMetersToPixels = 10;

  double _metersToPixels;

  /// The number of pixels that one meter of the physics world is rendered as.
  double get metersToPixels => _metersToPixels;
  set metersToPixels(double value) {
    assert(value > 0, 'metersToPixels must be positive: $value');
    if (value == _metersToPixels) {
      return;
    }
    final currentZoom = zoom;
    final currentVisibleGameSize = visibleGameSize;
    _metersToPixels = value;
    // Both of these are stored in the base class scaled by the old value, so
    // they have to be written back through the overrides below.
    zoom = currentZoom;
    visibleGameSize = currentVisibleGameSize;
  }

  /// The zoom level of the camera, on top of [metersToPixels].
  ///
  /// A zoom of 1, which is the default, renders the world at its natural
  /// size, where one meter covers [metersToPixels] pixels.
  @override
  double get zoom => super.zoom / _metersToPixels;

  @override
  set zoom(double value) {
    assert(value > 0, 'zoom level must be positive: $value');
    super.zoom = value * _metersToPixels;
  }

  /// How much of the game world, in meters, ought to be visible through the
  /// viewport.
  ///
  /// See [Viewfinder.visibleGameSize].
  @override
  Vector2? get visibleGameSize {
    final size = super.visibleGameSize;
    return size == null ? null : size / _metersToPixels;
  }

  @override
  set visibleGameSize(Vector2? value) {
    // The base class picks the zoom from this size, and that zoom goes back
    // through the setter above, so the size has to be pre-scaled for the two
    // factors of [metersToPixels] to cancel out.
    super.visibleGameSize = value == null ? null : value * _metersToPixels;
  }

  // The [ScaleProvider] API, which effects use to zoom the camera. It is
  // routed through [zoom] so that it stays in the same units.
  @override
  Vector2 get scale => Vector2.all(zoom);

  @override
  set scale(Vector2 value) {
    assert(
      value.x == value.y,
      'Non-uniform scale cannot be applied to a Viewfinder: $value',
    );
    zoom = value.x;
  }
}
