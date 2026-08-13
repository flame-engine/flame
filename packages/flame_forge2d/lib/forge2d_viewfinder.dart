import 'package:flame/camera.dart';
import 'package:flame/game.dart';
import 'package:forge2d/forge2d.dart' show Tolerances;

/// A [Viewfinder] that renders a world measured in meters onto a screen
/// measured in pixels.
///
/// Forge2D is tuned for meters, so a physics world is laid out in them and
/// [metersToPixels] decides how large a meter is on screen. Keeping the two
/// apart leaves the [zoom] free for what it is meant for: zooming the camera
/// in and out. It also keeps the choice of screen size from leaking into the
/// simulation, which matters because a world laid out at a much smaller
/// scale than a meter runs into Forge2D's absolute tolerances; see
/// [Tolerances].
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
  ///
  /// A meter of physics world covers a hundred pixels, which puts a
  /// human-sized body at a couple of hundred pixels tall and a phone screen
  /// at roughly ten meters. Laying a world out so that it fills the screen at
  /// this scale lands it in the range that Forge2D is tuned for.
  static const double defaultMetersToPixels = 100;

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
