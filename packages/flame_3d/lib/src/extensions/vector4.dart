import 'package:flame_3d/game.dart';

/// Represents an immutable [Vector3].
typedef ImmutableVector4 = ({double x, double y, double z, double w});

extension Vector4Extension on Vector4 {
  /// Returns an immutable representation of the vector.
  ImmutableVector4 get immutable => (x: x, y: y, z: z, w: w);
}
