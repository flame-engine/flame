import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template torus_mesh}
/// Procedural torus [Mesh] lying in the XZ plane around the origin (`+Y` axis
/// through the center hole), with [majorRadius] from the origin to the tube
/// center and [minorRadius] for the tube cross-section.
/// {@endtemplate}
class TorusMesh({
  final double majorRadius = 0.7,
  final double minorRadius = 0.22,
  int majorSegments = 28,
  int minorSegments = 14,
  Material? material,
}) extends Mesh {
  /// {@macro torus_mesh}
  this
    : assert(majorRadius > 0, 'majorRadius must be positive'),
      assert(minorRadius > 0, 'minorRadius must be positive'),
      assert(majorSegments >= 3, 'majorSegments must be at least 3'),
      assert(minorSegments >= 3, 'minorSegments must be at least 3') {
    final stride = VertexLayout.standard.strideInFloats;
    final cols = minorSegments + 1;
    final rows = majorSegments + 1;
    final vertCount = rows * cols;
    final verts = Float32List(vertCount * stride);

    var o = 0;
    for (var i = 0; i <= majorSegments; i++) {
      final u = i / majorSegments;
      final theta = u * math.pi * 2.0;
      final cosT = math.cos(theta);
      final sinT = math.sin(theta);

      for (var j = 0; j <= minorSegments; j++) {
        final v = j / minorSegments;
        final phi = v * math.pi * 2.0;
        final cosP = math.cos(phi);
        final sinP = math.sin(phi);

        final radial = majorRadius + minorRadius * cosP;
        final px = radial * cosT;
        final py = minorRadius * sinP;
        final pz = radial * sinT;

        final nx = cosP * cosT;
        final ny = sinP;
        final nz = cosP * sinT;

        verts[o] = px;
        verts[o + 1] = py;
        verts[o + 2] = pz;
        verts[o + 3] = u;
        verts[o + 4] = v;
        verts[o + 5] = 1.0;
        verts[o + 6] = 1.0;
        verts[o + 7] = 1.0;
        verts[o + 8] = 1.0;
        verts[o + 9] = nx;
        verts[o + 10] = ny;
        verts[o + 11] = nz;
        o += stride;
      }
    }

    final quadCount = majorSegments * minorSegments;
    final indices = vertCount > 0xFFFF
        ? Uint32List(quadCount * 6)
        : Uint16List(quadCount * 6);
    var k = 0;
    for (var i = 0; i < majorSegments; i++) {
      final row0 = i * cols;
      final row1 = (i + 1) * cols;
      for (var j = 0; j < minorSegments; j++) {
        final i0 = row0 + j;
        final i1 = i0 + 1;
        final i2 = row1 + j + 1;
        final i3 = row1 + j;
        // Outward-facing CCW winding in right-handed space.
        indices[k] = i0;
        indices[k + 1] = i3;
        indices[k + 2] = i2;
        indices[k + 3] = i0;
        indices[k + 4] = i2;
        indices[k + 5] = i1;
        k += 6;
      }
    }

    addSurface(
      Surface.fromBuffers(
        vertices: verts,
        indices: indices,
        material: material,
      ),
    );
  }
}
