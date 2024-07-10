import 'package:flame_3d/components.dart';

/// {@template group_3d}
/// [Group3D] is a [Component3D] that acts as a container for other
/// [Component3D]s.
///
/// Changing the position, rotating or scaling the [Component3D] will affect
/// the whole group as if it was a single entity.
///
/// {@endtemplate}
class Group3D extends Component3D {
  /// {@macro group_3d}
  Group3D({
    super.position,
    super.scale,
    super.rotation,
    super.children,
  });
}
