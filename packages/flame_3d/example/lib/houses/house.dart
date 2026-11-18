import 'dart:math' as math;
import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// A low-poly house on the cell [cell] of a board whose scene has z up: a
/// box of walls [height] cells high under a four-sided roof.
///
/// The `walls` and `roof` meshes are shared by every house; each house only
/// has its own transforms and per-instance colors, so all the houses are
/// drawn together, one instanced draw call per mesh.
class House({
  required final (int, int) cell,
  required Mesh walls,
  required Mesh roof,
  required final double height,
  required final Color wallColor,
  required Color roofColor,
}) extends Object3D {
  this
    : super(
        position: Vector3(cell.$1 + 0.5, cell.$2 + 0.5, 0),
        // The meshes are built with y up; the board has z up.
        rotation: Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2),
      ) {
    addAll([
      _walls = MeshComponent(
        mesh: walls,
        position: Vector3(0, height / 2, 0),
        scale: Vector3(1, height, 1),
        color: wallColor,
      ),
      MeshComponent(
        mesh: roof,
        position: Vector3(0, height, 0),
        // Square the pyramid with the walls.
        rotation: Quaternion.axisAngle(Vector3(0, 1, 0), math.pi / 4),
        color: roofColor,
      ),
    ]);
  }

  static const double roofHeight = 0.42;

  late final MeshComponent _walls;

  /// The height of the tip of the roof above the board, in cells.
  double get top => height + roofHeight;

  /// A box around the house, tighter than [aabb] (which grows with the roof
  /// turned by 45 degrees): the walls, up to the tip of the roof.
  Aabb3 get pickBox => _pickBox ??= Aabb3.copy(_walls.aabb)..max.z = top;
  Aabb3? _pickBox;

  /// Whether the walls are painted in the highlight color.
  bool get highlighted => _highlighted;
  bool _highlighted = false;
  set highlighted(bool value) {
    _highlighted = value;
    _walls.color = value ? const Color(0xFFFFD54A) : wallColor;
  }

  @override
  void draw(RenderContext context) {}
}
