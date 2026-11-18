import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// Elevation axis of a [TerrainMesh3D].
enum TerrainUpAxis() {
  /// Standard 3D `XZ` ground plane with `+Y` elevation.
  y,

  /// Board / isometric `XY` ground plane with `+Z` elevation.
  z,
}

/// {@template terrain_mesh_3d}
/// Heightfield terrain [Mesh] built from a `columns x rows` grid of [heights]
/// (automatically selecting 16-bit or 32-bit indices for `> 65,535` vertices),
/// with central-difference smooth normals, optional height/slope `colorRamp`
/// splatting, and `O(1)` bilinear [sampleHeight] / [sampleNormal] queries.
/// {@endtemplate}
class TerrainMesh3D({
  required final int columns,
  required final int rows,
  required final double width,
  required final double depth,
  required Float32List heights,
  final TerrainUpAxis upAxis = TerrainUpAxis.y,
  double uvScale = 1.0,
  Color Function(double height, double slope)? colorRamp,
  Material? material,
}) extends Mesh {
  /// {@macro terrain_mesh_3d}
  this
    : assert(columns >= 2 && rows >= 2, 'grid must be at least 2x2'),
      assert(width > 0 && depth > 0, 'width and depth must be positive'),
      assert(
        heights.length == columns * rows,
        'heights length must equal columns * rows',
      ) {
    final vertCount = columns * rows;
    final stride = VertexLayout.standard.strideInFloats;
    final verts = Float32List(vertCount * stride);

    final dx = width / (columns - 1);
    final dv = depth / (rows - 1);
    final halfW = width * 0.5;
    final halfD = depth * 0.5;

    double hAt(int ix, int iv) {
      final cx = ix.clamp(0, columns - 1);
      final cv = iv.clamp(0, rows - 1);
      return this.heights[cv * columns + cx];
    }

    var o = 0;
    for (var r = 0; r < rows; r++) {
      final vNorm = r / (rows - 1);
      final coordV = -halfD + vNorm * depth;
      for (var c = 0; c < columns; c++) {
        final uNorm = c / (columns - 1);
        final coordU = -halfW + uNorm * width;
        final h = this.heights[r * columns + c];

        final dhdu = (hAt(c + 1, r) - hAt(c - 1, r)) / (2.0 * dx);
        final dhdv = (hAt(c, r + 1) - hAt(c, r - 1)) / (2.0 * dv);
        final invN = 1.0 / math.sqrt(dhdu * dhdu + dhdv * dhdv + 1.0);
        final nUp = invN;
        final slope = (1.0 - nUp).clamp(0.0, 1.0);
        final col = colorRamp?.call(h, slope) ?? const Color(0xFFFFFFFF);

        if (upAxis == TerrainUpAxis.y) {
          verts[o] = coordU;
          verts[o + 1] = h;
          verts[o + 2] = coordV;
          verts[o + 9] = -dhdu * invN;
          verts[o + 10] = nUp;
          verts[o + 11] = -dhdv * invN;
        } else {
          verts[o] = coordU;
          verts[o + 1] = coordV;
          verts[o + 2] = h;
          verts[o + 9] = -dhdu * invN;
          verts[o + 10] = -dhdv * invN;
          verts[o + 11] = nUp;
        }
        verts[o + 3] = uNorm * uvScale;
        verts[o + 4] = vNorm * uvScale;
        verts[o + 5] = col.r;
        verts[o + 6] = col.g;
        verts[o + 7] = col.b;
        verts[o + 8] = col.a;
        o += stride;
      }
    }

    final quadCount = (columns - 1) * (rows - 1);
    final indices = vertCount > 0xFFFF
        ? Uint32List(quadCount * 6)
        : Uint16List(quadCount * 6);
    var k = 0;
    for (var r = 0; r < rows - 1; r++) {
      final row0 = r * columns;
      final row1 = (r + 1) * columns;
      for (var c = 0; c < columns - 1; c++) {
        final i0 = row0 + c;
        final i1 = i0 + 1;
        final i2 = row1 + c + 1;
        final i3 = row1 + c;
        if (upAxis == TerrainUpAxis.y) {
          // +Y up in right-handed XZ: (i0, i3, i2) and (i0, i2, i1) CCW.
          indices[k] = i0;
          indices[k + 1] = i3;
          indices[k + 2] = i2;
          indices[k + 3] = i0;
          indices[k + 4] = i2;
          indices[k + 5] = i1;
        } else {
          // +Z up in right-handed XY: (i0, i1, i2) and (i0, i2, i3) CCW.
          indices[k] = i0;
          indices[k + 1] = i1;
          indices[k + 2] = i2;
          indices[k + 3] = i0;
          indices[k + 4] = i2;
          indices[k + 5] = i3;
        }
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

  /// Procedural fBm-like multi-octave heightfield generator for islands, hills,
  /// and ridges.
  factory TerrainMesh3D.procedural({
    int columns = 64,
    int rows = 64,
    double width = 12.0,
    double depth = 12.0,
    double amplitude = 1.4,
    double frequency = 0.45,
    bool islandFalloff = true,
    TerrainUpAxis upAxis = TerrainUpAxis.y,
    double uvScale = 4.0,
    Color Function(double height, double slope)? colorRamp,
    Material? material,
  }) {
    final heights = Float32List(columns * rows);
    for (var r = 0; r < rows; r++) {
      final nv = (r / (rows - 1)) * 2.0 - 1.0;
      final wy = nv * depth * 0.5;
      for (var c = 0; c < columns; c++) {
        final nu = (c / (columns - 1)) * 2.0 - 1.0;
        final wx = nu * width * 0.5;

        final o1 =
            math.sin(wx * frequency + 0.4) * math.cos(wy * frequency - 0.3);
        final o2 =
            0.5 *
            math.sin((wx * 1.9 - wy * 1.3) * frequency + 1.7) *
            math.cos((wx * 1.1 + wy * 2.1) * frequency);
        final o3 = 0.25 * math.cos((wx * 3.7 + wy * 3.3) * frequency);
        var h = (0.5 + 0.5 * ((o1 + o2 + o3) / 1.75)) * amplitude;
        if (islandFalloff) {
          final rad2 = nu * nu + nv * nv;
          final mask = (1.0 - rad2).clamp(0.0, 1.0);
          h *= mask * math.sqrt(mask);
        }
        heights[r * columns + c] = h;
      }
    }
    return TerrainMesh3D(
      columns: columns,
      rows: rows,
      width: width,
      depth: depth,
      heights: heights,
      upAxis: upAxis,
      uvScale: uvScale,
      colorRamp: colorRamp,
      material: material,
    );
  }

  final Float32List heights = Float32List.fromList(heights);

  /// Bilinearly samples the local terrain elevation at horizontal coordinates
  /// `(uLocal, vLocal)` (`(x, z)` when `upAxis == y`, `(x, y)` when
  /// `upAxis == z`).
  double sampleHeight(double uLocal, double vLocal) {
    final fx = ((uLocal + width * 0.5) / width * (columns - 1)).clamp(
      0.0,
      columns - 1.0,
    );
    final fv = ((vLocal + depth * 0.5) / depth * (rows - 1)).clamp(
      0.0,
      rows - 1.0,
    );
    final x0 = fx.floor().clamp(0, columns - 1);
    final v0 = fv.floor().clamp(0, rows - 1);
    final x1 = math.min(columns - 1, x0 + 1);
    final v1 = math.min(rows - 1, v0 + 1);
    final tx = fx - x0;
    final tv = fv - v0;

    final h00 = heights[v0 * columns + x0];
    final h10 = heights[v0 * columns + x1];
    final h01 = heights[v1 * columns + x0];
    final h11 = heights[v1 * columns + x1];

    final h0 = h00 + (h10 - h00) * tx;
    final h1 = h01 + (h11 - h01) * tx;
    return h0 + (h1 - h0) * tv;
  }

  /// Approximates the unit surface normal at `(uLocal, vLocal)` via central
  /// finite differences.
  Vector3 sampleNormal(double uLocal, double vLocal, {Vector3? out}) {
    final res = out ?? Vector3.zero();
    final epsU = width / (columns - 1) * 0.5;
    final epsV = depth / (rows - 1) * 0.5;
    final dhdu =
        (sampleHeight(uLocal + epsU, vLocal) -
            sampleHeight(uLocal - epsU, vLocal)) /
        (2.0 * epsU);
    final dhdv =
        (sampleHeight(uLocal, vLocal + epsV) -
            sampleHeight(uLocal, vLocal - epsV)) /
        (2.0 * epsV);
    if (upAxis == TerrainUpAxis.y) {
      res.setValues(-dhdu, 1.0, -dhdv);
    } else {
      res.setValues(-dhdu, -dhdv, 1.0);
    }
    res.normalize();
    return res;
  }
}
