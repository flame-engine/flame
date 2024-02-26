import 'package:flame_3d/game.dart';

/// Represents an immutable [Vector3].
typedef ImmutableVector3 = ({double x, double y, double z});

extension Vector3Extension on Vector3 {
  /// Returns an immutable representation of the vector.
  ImmutableVector3 get immutable => (x: x, y: y, z: z);
}
