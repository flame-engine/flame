import 'package:flame_3d/game.dart';
import 'package:flame_3d/src/extensions/clip_space.dart';
import 'package:vector_math/vector_math.dart' show Frustum;

extension FrustumExtension on Frustum {
  /// Set the six planes from a [viewProjection] matrix whose clip space has
  /// the visible depth `0 <= z <= w`, as the projections of flame_3d have
  /// (see `Matrix4Extension`).
  ///
  /// vector_math's `setFromMatrix` assumes OpenGL's `-w <= z <= w` and puts
  /// the near plane in the wrong place for those matrices. The plane order is
  /// the same: right, left, bottom, top, far, near.
  void setFromViewProjection(Matrix4 viewProjection) {
    writeFrustumPlanes(this, viewProjection.storage);
  }
}
