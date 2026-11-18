import 'dart:math' as math;

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math.dart' show Frustum, Plane;

// Matrix math shared by the Matrix4 and Frustum extensions and the 3D camera.
//
// Every matrix here is a flat list of 16 values in column-major order, the
// layout of `Matrix4.storage`, so the same code writes a Matrix4 (Float32List)
// and the camera's double-precision working copies (Float64List).
//
// Clip space follows Impeller (and WebGPU): x and y in [-w, w] with +y up,
// and the visible depth is 0 <= z <= w, the near plane at 0 and the far plane
// at 1. View space is right-handed with the camera looking down -z.

/// Writes a right-handed look-at view matrix for an eye at (ex, ey, ez)
/// looking at (tx, ty, tz) with the up vector (ux, uy, uz) into [out].
///
/// The rows of the rotation are the camera's right, up and backward axes.
/// When the eye and the target coincide the camera looks down -z, and when
/// the up vector is zero or parallel to the view direction another world axis
/// stands in for it, so the result is always a rigid transform.
@internal
void writeLookAt(
  List<double> out,
  double ex,
  double ey,
  double ez,
  double tx,
  double ty,
  double tz,
  double ux,
  double uy,
  double uz,
) {
  // z: from the target towards the eye (the camera looks down -z).
  var zx = ex - tx;
  var zy = ey - ty;
  var zz = ez - tz;
  final zLength = math.sqrt(zx * zx + zy * zy + zz * zz);
  if (zLength == 0) {
    zx = 0;
    zy = 0;
    zz = 1;
  } else {
    zx /= zLength;
    zy /= zLength;
    zz /= zLength;
  }

  // x = up × z.
  var xx = uy * zz - uz * zy;
  var xy = uz * zx - ux * zz;
  var xz = ux * zy - uy * zx;
  var xLength = math.sqrt(xx * xx + xy * xy + xz * xz);
  final upLength = math.sqrt(ux * ux + uy * uy + uz * uz);
  if (upLength == 0 || xLength <= 1e-12 * upLength) {
    // The up vector does not define a plane with z: use -z (or +y when z is
    // close to the z axis) as up instead.
    final (fx, fy, fz) = zz.abs() < 0.9 ? (0.0, 0.0, -1.0) : (0.0, 1.0, 0.0);
    xx = fy * zz - fz * zy;
    xy = fz * zx - fx * zz;
    xz = fx * zy - fy * zx;
    xLength = math.sqrt(xx * xx + xy * xy + xz * xz);
  }
  xx /= xLength;
  xy /= xLength;
  xz /= xLength;

  // y = z × x, already unit length.
  final yx = zy * xz - zz * xy;
  final yy = zz * xx - zx * xz;
  final yz = zx * xy - zy * xx;

  out[0] = xx;
  out[1] = yx;
  out[2] = zx;
  out[3] = 0;
  out[4] = xy;
  out[5] = yy;
  out[6] = zy;
  out[7] = 0;
  out[8] = xz;
  out[9] = yz;
  out[10] = zz;
  out[11] = 0;
  out[12] = -(xx * ex + xy * ey + xz * ez);
  out[13] = -(yx * ex + yy * ey + yz * ez);
  out[14] = -(zx * ex + zy * ey + zz * ez);
  out[15] = 1;
}

/// Writes the inverse of a rigid [view] matrix (rotation and translation, as
/// written by [writeLookAt]) for an eye at (ex, ey, ez) into [out].
@internal
void writeRigidInverse(
  List<double> view,
  double ex,
  double ey,
  double ez,
  List<double> out,
) {
  out[0] = view[0];
  out[1] = view[4];
  out[2] = view[8];
  out[3] = 0;
  out[4] = view[1];
  out[5] = view[5];
  out[6] = view[9];
  out[7] = 0;
  out[8] = view[2];
  out[9] = view[6];
  out[10] = view[10];
  out[11] = 0;
  out[12] = ex;
  out[13] = ey;
  out[14] = ez;
  out[15] = 1;
}

/// Writes a symmetric perspective projection into [out].
///
/// [fovYRadians] is the full vertical field of view and the depth maps the
/// [near] plane to 0 and the [far] plane to 1 (`0 < near < far`).
@internal
void writePerspective(
  List<double> out,
  double fovYRadians,
  double aspectRatio,
  double near,
  double far,
) {
  final focal = 1 / math.tan(fovYRadians / 2);
  final rangeInverse = 1 / (near - far);
  out[0] = focal / aspectRatio;
  out[1] = 0;
  out[2] = 0;
  out[3] = 0;
  out[4] = 0;
  out[5] = focal;
  out[6] = 0;
  out[7] = 0;
  out[8] = 0;
  out[9] = 0;
  out[10] = far * rangeInverse;
  out[11] = -1;
  out[12] = 0;
  out[13] = 0;
  out[14] = near * far * rangeInverse;
  out[15] = 0;
}

/// Writes an orthographic projection of the view-space box
/// `[left, right] × [bottom, top]` between the [near] and [far] distances into
/// [out], mapping [near] to depth 0 and [far] to depth 1 (`near < far`; [near]
/// may be zero or negative).
@internal
void writeOrthographic(
  List<double> out,
  double left,
  double right,
  double bottom,
  double top,
  double near,
  double far,
) {
  final width = right - left;
  final height = top - bottom;
  out[0] = 2 / width;
  out[1] = 0;
  out[2] = 0;
  out[3] = 0;
  out[4] = 0;
  out[5] = 2 / height;
  out[6] = 0;
  out[7] = 0;
  out[8] = 0;
  out[9] = 0;
  out[10] = 1 / (near - far);
  out[11] = 0;
  out[12] = -(right + left) / width;
  out[13] = -(top + bottom) / height;
  out[14] = near / (near - far);
  out[15] = 1;
}

/// Writes `a × b` into [out], which must not be [a] or [b].
@internal
void multiplyMatrices(List<double> a, List<double> b, List<double> out) {
  for (var column = 0; column < 4; column++) {
    final b0 = b[column * 4];
    final b1 = b[column * 4 + 1];
    final b2 = b[column * 4 + 2];
    final b3 = b[column * 4 + 3];
    for (var row = 0; row < 4; row++) {
      out[column * 4 + row] =
          a[row] * b0 + a[4 + row] * b1 + a[8 + row] * b2 + a[12 + row] * b3;
    }
  }
}

/// Writes the inverse of [m] into [out] (which must not be [m]) and returns
/// whether [m] is invertible. A singular [m] fills [out] with NaN.
@internal
bool invertMatrix(List<double> m, List<double> out) {
  final a00 = m[0];
  final a01 = m[1];
  final a02 = m[2];
  final a03 = m[3];
  final a10 = m[4];
  final a11 = m[5];
  final a12 = m[6];
  final a13 = m[7];
  final a20 = m[8];
  final a21 = m[9];
  final a22 = m[10];
  final a23 = m[11];
  final a30 = m[12];
  final a31 = m[13];
  final a32 = m[14];
  final a33 = m[15];

  final b00 = a00 * a11 - a01 * a10;
  final b01 = a00 * a12 - a02 * a10;
  final b02 = a00 * a13 - a03 * a10;
  final b03 = a01 * a12 - a02 * a11;
  final b04 = a01 * a13 - a03 * a11;
  final b05 = a02 * a13 - a03 * a12;
  final b06 = a20 * a31 - a21 * a30;
  final b07 = a20 * a32 - a22 * a30;
  final b08 = a20 * a33 - a23 * a30;
  final b09 = a21 * a32 - a22 * a31;
  final b10 = a21 * a33 - a23 * a31;
  final b11 = a22 * a33 - a23 * a32;

  final determinant =
      b00 * b11 - b01 * b10 + b02 * b09 + b03 * b08 - b04 * b07 + b05 * b06;
  if (determinant == 0 || !determinant.isFinite) {
    for (var i = 0; i < 16; i++) {
      out[i] = double.nan;
    }
    return false;
  }
  final d = 1 / determinant;

  out[0] = (a11 * b11 - a12 * b10 + a13 * b09) * d;
  out[1] = (a02 * b10 - a01 * b11 - a03 * b09) * d;
  out[2] = (a31 * b05 - a32 * b04 + a33 * b03) * d;
  out[3] = (a22 * b04 - a21 * b05 - a23 * b03) * d;
  out[4] = (a12 * b08 - a10 * b11 - a13 * b07) * d;
  out[5] = (a00 * b11 - a02 * b08 + a03 * b07) * d;
  out[6] = (a32 * b02 - a30 * b05 - a33 * b01) * d;
  out[7] = (a20 * b05 - a22 * b02 + a23 * b01) * d;
  out[8] = (a10 * b10 - a11 * b08 + a13 * b06) * d;
  out[9] = (a01 * b08 - a00 * b10 - a03 * b06) * d;
  out[10] = (a30 * b04 - a31 * b02 + a33 * b00) * d;
  out[11] = (a21 * b02 - a20 * b04 - a23 * b00) * d;
  out[12] = (a11 * b07 - a10 * b09 - a12 * b06) * d;
  out[13] = (a00 * b09 - a01 * b07 + a02 * b06) * d;
  out[14] = (a31 * b01 - a30 * b03 - a32 * b00) * d;
  out[15] = (a20 * b03 - a21 * b01 + a22 * b00) * d;
  return true;
}

/// Sets the planes of [frustum] from a view-projection matrix [m] whose clip
/// space has the visible depth 0 <= z <= w.
///
/// The plane order matches `Frustum.setFromMatrix`: right, left, bottom, top,
/// far, near. A plane whose normal vanishes (a projection that flattens depth,
/// for example) is replaced by one that contains every point.
@internal
void writeFrustumPlanes(Frustum frustum, List<double> m) {
  final r0x = m[0];
  final r0y = m[4];
  final r0z = m[8];
  final r0w = m[12];
  final r1x = m[1];
  final r1y = m[5];
  final r1z = m[9];
  final r1w = m[13];
  final r2x = m[2];
  final r2y = m[6];
  final r2z = m[10];
  final r2w = m[14];
  final r3x = m[3];
  final r3y = m[7];
  final r3z = m[11];
  final r3w = m[15];
  _setPlane(frustum.plane0, r3x - r0x, r3y - r0y, r3z - r0z, r3w - r0w);
  _setPlane(frustum.plane1, r3x + r0x, r3y + r0y, r3z + r0z, r3w + r0w);
  _setPlane(frustum.plane2, r3x + r1x, r3y + r1y, r3z + r1z, r3w + r1w);
  _setPlane(frustum.plane3, r3x - r1x, r3y - r1y, r3z - r1z, r3w - r1w);
  _setPlane(frustum.plane4, r3x - r2x, r3y - r2y, r3z - r2z, r3w - r2w);
  _setPlane(frustum.plane5, r2x, r2y, r2z, r2w);
}

void _setPlane(Plane plane, double x, double y, double z, double w) {
  final length = math.sqrt(x * x + y * y + z * z);
  if (length == 0 || !length.isFinite) {
    plane.setFromComponents(0, 0, 0, 1);
    return;
  }
  final inverse = 1 / length;
  plane.setFromComponents(x * inverse, y * inverse, z * inverse, w * inverse);
}
