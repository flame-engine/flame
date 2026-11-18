import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';

/// Smooth 3D Catmull-Rom spline passing through `controlPoints` (`>= 2`
/// points), supporting open and closed loops.
class CatmullRomSpline3D(
  List<Vector3> controlPoints, {
  final bool closed = false,
}) {
  this
    : assert(
        controlPoints.length >= 2,
        'CatmullRomSpline3D requires at least 2 control points',
      );

  final List<Vector3> points = [for (final p in controlPoints) p.clone()];

  int get segmentCount => closed ? points.length : points.length - 1;

  Vector3 _pt(int index) {
    final n = points.length;
    if (closed) {
      final m = index % n;
      return points[m < 0 ? m + n : m];
    }
    return points[index.clamp(0, n - 1)];
  }

  /// Evaluates the spline position at normalized parameter `t` in `[0, 1]`.
  Vector3 samplePoint(double t, {Vector3? out}) {
    final res = out ?? Vector3.zero();
    final segs = segmentCount;
    final scaled = t.clamp(0.0, 1.0) * segs;
    final seg = math.min(segs - 1, scaled.floor());
    final u = scaled - seg;
    final u2 = u * u;
    final u3 = u2 * u;

    final p0 = _pt(seg - 1);
    final p1 = _pt(seg);
    final p2 = _pt(seg + 1);
    final p3 = _pt(seg + 2);

    double catmull(double v0, double v1, double v2, double v3) {
      return 0.5 *
          ((2.0 * v1) +
              (-v0 + v2) * u +
              (2.0 * v0 - 5.0 * v1 + 4.0 * v2 - v3) * u2 +
              (-v0 + 3.0 * v1 - 3.0 * v2 + v3) * u3);
    }

    res.setValues(
      catmull(p0.x, p1.x, p2.x, p3.x),
      catmull(p0.y, p1.y, p2.y, p3.y),
      catmull(p0.z, p1.z, p2.z, p3.z),
    );
    return res;
  }

  /// Evaluates the unit tangent vector at normalized parameter `t` in `[0, 1]`.
  Vector3 sampleTangent(double t, {Vector3? out}) {
    final res = out ?? Vector3.zero();
    final segs = segmentCount;
    final scaled = t.clamp(0.0, 1.0) * segs;
    final seg = math.min(segs - 1, scaled.floor());
    final u = scaled - seg;
    final u2 = u * u;

    final p0 = _pt(seg - 1);
    final p1 = _pt(seg);
    final p2 = _pt(seg + 1);
    final p3 = _pt(seg + 2);

    double dCatmull(double v0, double v1, double v2, double v3) {
      return 0.5 *
          ((-v0 + v2) +
              2.0 * (2.0 * v0 - 5.0 * v1 + 4.0 * v2 - v3) * u +
              3.0 * (-v0 + 3.0 * v1 - 3.0 * v2 + v3) * u2);
    }

    res.setValues(
      dCatmull(p0.x, p1.x, p2.x, p3.x),
      dCatmull(p0.y, p1.y, p2.y, p3.y),
      dCatmull(p0.z, p1.z, p2.z, p3.z),
    );
    if (res.length2 > 1e-12) {
      res.normalize();
    } else {
      res
        ..setFrom(p2)
        ..sub(p1);
      if (res.length2 > 1e-12) {
        res.normalize();
      } else {
        res.setValues(0, 0, 1);
      }
    }
    return res;
  }
}

/// {@template tube_spline_mesh}
/// Extrudes a smooth 3D tube, pipe, cable, rail, or flattened road/bridge deck
/// along a [CatmullRomSpline3D] using twist-free parallel-transport (Bishop)
/// frames.
/// {@endtemplate}
class TubeSplineMesh({
  required final CatmullRomSpline3D spline,
  final double radius = 0.18,
  int tubularSegments = 48,
  int radialSegments = 10,
  double crossSectionAspect = 1.0,
  double uvLengthScale = 1.0,
  Color color = const Color(0xFFFFFFFF),
  Material? material,
}) extends Mesh {
  /// {@macro tube_spline_mesh}
  this
    : assert(radius > 0, 'radius must be positive'),
      assert(tubularSegments >= 2, 'tubularSegments must be at least 2'),
      assert(radialSegments >= 3, 'radialSegments must be at least 3') {
    final stride = VertexLayout.standard.strideInFloats;
    final cols = radialSegments + 1;
    final rows = tubularSegments + 1;
    final vertCount = rows * cols;
    final verts = Float32List(vertCount * stride);

    final centers = List<Vector3>.generate(
      rows,
      (i) => spline.samplePoint(i / tubularSegments),
    );
    final tangents = List<Vector3>.generate(
      rows,
      (i) => spline.sampleTangent(i / tubularSegments),
    );

    // Parallel-transport initial normal & binormal along the curve.
    final normalFrame = Vector3.zero();
    final t0 = tangents[0];
    if (t0.y.abs() < 0.9) {
      normalFrame.setFrom(Vector3(0, 1, 0).cross(t0));
    } else {
      normalFrame.setFrom(Vector3(1, 0, 0).cross(t0));
    }
    normalFrame.normalize();
    final binormal = Vector3.zero();
    final rotAxis = Vector3.zero();
    final stepQuat = Quaternion.identity();

    var arcLength = 0.0;
    var o = 0;

    for (var i = 0; i <= tubularSegments; i++) {
      if (i > 0) {
        arcLength += centers[i].distanceTo(centers[i - 1]);
        final prevT = tangents[i - 1];
        final curT = tangents[i];
        rotAxis.setFrom(prevT.cross(curT));
        final sinA = rotAxis.length;
        if (sinA > 1e-6) {
          rotAxis.scale(1.0 / sinA);
          final cosA = prevT.dot(curT).clamp(-1.0, 1.0);
          stepQuat.setAxisAngle(rotAxis, math.atan2(sinA, cosA));
          stepQuat.rotate(normalFrame);
          normalFrame.normalize();
        }
      }
      binormal
        ..setFrom(tangents[i].cross(normalFrame))
        ..normalize();

      final c = centers[i];
      final vCoord = arcLength * uvLengthScale;

      for (var j = 0; j <= radialSegments; j++) {
        final uCoord = j / radialSegments;
        final phi = uCoord * math.pi * 2.0;
        final cosP = math.cos(phi);
        final sinP = math.sin(phi);

        final rx = cosP * radius * crossSectionAspect;
        final ry = sinP * radius;

        final px = c.x + normalFrame.x * rx + binormal.x * ry;
        final py = c.y + normalFrame.y * rx + binormal.y * ry;
        final pz = c.z + normalFrame.z * rx + binormal.z * ry;

        var nx =
            normalFrame.x * (cosP / crossSectionAspect) + binormal.x * sinP;
        var ny =
            normalFrame.y * (cosP / crossSectionAspect) + binormal.y * sinP;
        var nz =
            normalFrame.z * (cosP / crossSectionAspect) + binormal.z * sinP;
        final nLen = math.sqrt(nx * nx + ny * ny + nz * nz);
        if (nLen > 1e-12) {
          nx /= nLen;
          ny /= nLen;
          nz /= nLen;
        }

        verts[o] = px;
        verts[o + 1] = py;
        verts[o + 2] = pz;
        verts[o + 3] = uCoord;
        verts[o + 4] = vCoord;
        verts[o + 5] = color.r;
        verts[o + 6] = color.g;
        verts[o + 7] = color.b;
        verts[o + 8] = color.a;
        verts[o + 9] = nx;
        verts[o + 10] = ny;
        verts[o + 11] = nz;
        o += stride;
      }
    }

    final quadCount = tubularSegments * radialSegments;
    final indices = vertCount > 0xFFFF
        ? Uint32List(quadCount * 6)
        : Uint16List(quadCount * 6);
    var k = 0;
    for (var i = 0; i < tubularSegments; i++) {
      final row0 = i * cols;
      final row1 = (i + 1) * cols;
      for (var j = 0; j < radialSegments; j++) {
        final i0 = row0 + j;
        final i1 = i0 + 1;
        final i2 = row1 + j + 1;
        final i3 = row1 + j;
        indices[k] = i0;
        indices[k + 1] = i2;
        indices[k + 2] = i1;
        indices[k + 3] = i0;
        indices[k + 4] = i3;
        indices[k + 5] = i2;
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
