import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

/// This extension adds some helpers for [TiledObject] that make it easier to
/// use it with Flame.
extension TiledObjectHelpers on TiledObject {
  /// Returns the position of this tiled object as a Vector2.
  Vector2 get position => Vector2(x, y);

  /// Returns the size of this tiled object as a Vector2.
  Vector2 get size => Vector2(width, height);
}
