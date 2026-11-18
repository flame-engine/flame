import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// {@template capsule_mesh}
/// Procedural capsule [Mesh] centered at the origin along the `Y` axis, with
/// total height [height] (`>= 2 * radius`), hemispherical end caps of [radius],
/// and `VertexLayout.standard` attributes.
/// {@endtemplate}
class CapsuleMesh({
  required final double radius,
  required final double height,
  int segments = 16,
  int hemisphereRings = 6,
  Material? material,
}) extends Mesh {
  /// {@macro capsule_mesh}
  this
    : assert(radius > 0, 'radius must be positive'),
      assert(segments >= 3, 'segments must be at least 3'),
      assert(hemisphereRings >= 1, 'hemisphereRings must be at least 1') {
    final cylHeight = math.max(0.0, height - 2.0 * radius);
    final halfCyl = cylHeight * 0.5;
    final rings = hemisphereRings * 2 + 1;
    final stride = VertexLayout.standard.strideInFloats;
    final cols = segments + 1;
    final rows = rings + 1;
    final vertCount = rows * cols;
    final verts = Float32List(vertCount * stride);

    var o = 0;
    for (var r = 0; r <= rings; r++) {
      final double phi;
      final double yOffset;
      if (r <= hemisphereRings) {
        final t = r / hemisphereRings;
        phi = t * (math.pi * 0.5);
        yOffset = halfCyl;
      } else {
        final t = (r - 1) / hemisphereRings;
        phi = t * (math.pi * 0.5);
        yOffset = -halfCyl;
      }
      final sinPhi = math.sin(phi);
      final cosPhi = math.cos(phi);
      final ny = cosPhi;
      final py = yOffset + radius * ny;
      final vCoord = r / rings;

      for (var s = 0; s <= segments; s++) {
        final uCoord = s / segments;
        final theta = uCoord * math.pi * 2.0;
        final nx = sinPhi * math.cos(theta);
        final nz = sinPhi * math.sin(theta);

        verts[o] = radius * nx;
        verts[o + 1] = py;
        verts[o + 2] = radius * nz;
        verts[o + 3] = uCoord;
        verts[o + 4] = vCoord;
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

    final quadCount = rings * segments;
    final indices = vertCount > 0xFFFF
        ? Uint32List(quadCount * 6)
        : Uint16List(quadCount * 6);
    var k = 0;
    for (var r = 0; r < rings; r++) {
      final row0 = r * cols;
      final row1 = (r + 1) * cols;
      for (var s = 0; s < segments; s++) {
        final i0 = row0 + s;
        final i1 = i0 + 1;
        final i2 = row1 + s + 1;
        final i3 = row1 + s;
        indices[k] = i0;
        indices[k + 1] = i1;
        indices[k + 2] = i2;
        indices[k + 3] = i0;
        indices[k + 4] = i2;
        indices[k + 5] = i3;
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
