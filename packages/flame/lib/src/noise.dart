// This code is translated from
// https://github.com/stegu/perlin-noise/blob/master/src/noise1234.c
// https://github.com/stegu/perlin-noise/blob/master/src/simplexnoise1234.c
// by Stefan Gustavson, (c) 2003-2005, released into public domain.
import 'dart:typed_data';

//#region Perlin noise
// This implementation is "Improved Noise" as presented by Ken Perlin at
// Siggraph 2002. The 3D function is a direct port of his Java reference code
// which was once publicly available on www.noisemachine.com, but the 1D, 2D
// and 4D functions were implemented by Stefan Gustavson.

/// 1D float Perlin noise
///
/// Perlin noise is a procedurally-generated smooth yet chaotic-looking
/// function that has variety of applications. The function is NOT random: it
/// returns fixed values for each argument `x`. The return value is in the
/// range of approximately [-0.752 .. +0.705].
///
/// Note that the function returns 0 for every integer value of x.
double noise1(double x) {
  var ix0 = x.floor(); // integer part of x
  final fx0 = x - ix0; // fractional part of x
  final fx1 = fx0 - 1.0;
  final ix1 = (ix0 + 1) & 255;
  ix0 &= 255; // wrap to 0..255
  final s = _fade(fx0);
  final n0 = _grad1(_perm[ix0], fx0);
  final n1 = _grad1(_perm[ix1], fx1);
  return 0.188 * _lerp(s, n0, n1);
}

/// 2D float Perlin noise
double noise2(double x, double y) {
  var ix0 = x.floor(); // integer part of x
  var iy0 = y.floor(); // integer part of y
  final fx0 = x - ix0; // fractional part of x
  final fy0 = y - iy0; // fractional part of y
  final fx1 = fx0 - 1;
  final fy1 = fy0 - 1;
  final ix1 = (ix0 + 1) & 255; // wrap to 0..255
  final iy1 = (iy0 + 1) & 255;
  ix0 &= 255;
  iy0 &= 255;
  final t = _fade(fy0);
  final s = _fade(fx0);
  final nx00 = _grad2(_perm[ix0 + _perm[iy0]], fx0, fy0);
  final nx01 = _grad2(_perm[ix0 + _perm[iy1]], fx0, fy1);
  final n0 = _lerp(t, nx00, nx01);
  final nx10 = _grad2(_perm[ix1 + _perm[iy0]], fx1, fy0);
  final nx11 = _grad2(_perm[ix1 + _perm[iy1]], fx1, fy1);
  final n1 = _lerp(t, nx10, nx11);
  return 0.507 * _lerp(s, n0, n1);
}

//#endregion

//#region Simplex noise
// This is a clean, fast, modern and free Perlin Simplex noise function.

/// 1D simplex noise
double snoise1(double x) {
  final i0 = x.floor();
  final i1 = i0 + 1;
  final x0 = x - i0;
  final x1 = x0 - 1;
  var t0 = 1 - x0 * x0;
  t0 *= t0;
  final n0 = t0 * t0 * _grad1(_perm[i0 & 255], x0);
  var t1 = 1 - x1 * x1;
  t1 *= t1;
  final n1 = t1 * t1 * _grad1(_perm[i1 & 255], x1);
  // The maximum value of this noise is 8*(0.75)^4 = 2.53125.
  // A factor of 0.395 would scale to fit exactly within [-1, 1], but
  // we want to match PRMan's 1D noise, so we scale it down some more.
  return 0.25 * (n0 + n1);
}

/// 2D Simplex noise
double snoise2(double x, double y) {
  const f2 = 0.366025403; // f2 = 0.5*(sqrt(3.0)-1.0)
  const g2 = 0.211324865; // g2 = (3.0-Math.sqrt(3.0))/6.0

  // Noise contributions from the three corners
  double n0, n1, n2;

  // Skew the input space to determine which simplex cell we're in
  final s = (x + y) * f2; // Hairy factor for 2D
  final xs = x + s;
  final ys = y + s;
  final i = xs.floor();
  final j = ys.floor();
  final t = (i + j) * g2;
  final x0 = x - (i - t); // The x,y distances from the cell origin
  final y0 = y - (j - t);

  // For the 2D case, the simplex shape is an equilateral triangle.
  // Determine which simplex we are in.
  int i1, j1; // Offsets for second (middle) corner of simplex in (i,j) coords
  if (x0 > y0) {
    // lower triangle, XY order: (0,0)->(1,0)->(1,1)
    i1 = 1;
    j1 = 0;
  } else {
    // upper triangle, YX order: (0,0)->(0,1)->(1,1)
    i1 = 0;
    j1 = 1;
  }

  // A step of (1,0) in (i,j) means a step of (1-c,-c) in (x,y), and
  // a step of (0,1) in (i,j) means a step of (-c,1-c) in (x,y), where
  // c = (3-sqrt(3))/6
  // Offsets for middle corner in (x,y) un-skewed coordinates
  final x1 = x0 - i1 + g2;
  final y1 = y0 - j1 + g2;
  // Offsets for last corner in (x,y) un-skewed coordinates
  final x2 = x0 - 1.0 + 2.0 * g2;
  final y2 = y0 - 1.0 + 2.0 * g2;

  // Wrap the integer indices at 256, to avoid indexing perm[] out of bounds
  final ii = i & 255;
  final jj = j & 255;

  // Calculate the contribution from the three corners
  var t0 = 0.5 - x0 * x0 - y0 * y0;
  if (t0 < 0) {
    n0 = 0;
  } else {
    t0 *= t0;
    n0 = t0 * t0 * _grad2(_perm[ii + _perm[jj]], x0, y0);
  }

  var t1 = 0.5 - x1 * x1 - y1 * y1;
  if (t1 < 0) {
    n1 = 0;
  } else {
    t1 *= t1;
    n1 = t1 * t1 * _grad2(_perm[ii + i1 + _perm[jj + j1]], x1, y1);
  }

  var t2 = 0.5 - x2 * x2 - y2 * y2;
  if (t2 < 0) {
    n2 = 0;
  } else {
    t2 *= t2;
    n2 = t2 * t2 * _grad2(_perm[ii + 1 + _perm[jj + 1]], x2, y2);
  }

  // Add contributions from each corner to get the final noise value.
  // The result is scaled to return values in the interval [-1,1].
  return 40.0 * (n0 + n1 + n2);
}

//#endregion

//#region Private helpers

double _fade(double t) {
  return t * t * t * (t * (t * 6 - 15) + 10);
}

double _lerp(double t, double a, double b) => a + t * (b - a);

Uint8List _perm = Uint8List.fromList(<int>[
  // This list is a random of permutation of [0 .. 255], repeated twice
  240, 38, 159, 218, 112, 108, 164, 213, 36, 27, 111, 47, 181, 220, 225, 114,
  128, 135, 245, 176, 67, 210, 99, 83, 143, 199, 132, 33, 11, 59, 17, 161, 51,
  39, 107, 75, 173, 7, 155, 84, 93, 4, 235, 153, 53, 77, 249, 208, 10, 251,
  182, 105, 172, 120, 177, 5, 131, 81, 134, 194, 151, 70, 42, 98, 147, 206,
  106, 252, 250, 29, 92, 152, 13, 148, 236, 231, 180, 234, 96, 117, 88, 167,
  104, 95, 100, 26, 14, 222, 118, 139, 0, 175, 188, 157, 165, 201, 86, 52, 8,
  239, 144, 20, 55, 226, 80, 238, 97, 183, 87, 243, 174, 247, 154, 244, 21, 72,
  187, 203, 62, 50, 133, 185, 63, 170, 216, 253, 66, 43, 193, 254, 179, 211,
  150, 34, 196, 94, 130, 136, 142, 119, 126, 232, 37, 162, 204, 69, 214, 246,
  16, 73, 200, 58, 195, 90, 74, 6, 3, 23, 186, 189, 221, 45, 160, 54, 121, 28,
  89, 41, 123, 15, 184, 163, 116, 191, 156, 229, 197, 32, 255, 25, 205, 171,
  190, 78, 145, 166, 125, 230, 149, 65, 140, 19, 102, 64, 248, 22, 124, 115,
  68, 146, 178, 169, 192, 85, 40, 12, 31, 44, 18, 46, 227, 137, 228, 138, 76,
  224, 71, 48, 129, 49, 113, 242, 101, 109, 127, 91, 82, 2, 219, 233, 223, 237,
  56, 61, 202, 103, 241, 1, 79, 30, 212, 141, 168, 9, 158, 24, 110, 57, 215,
  198, 217, 60, 35, 122, 207, 209,
  240, 38, 159, 218, 112, 108, 164, 213, 36, 27, 111, 47, 181, 220, 225, 114,
  128, 135, 245, 176, 67, 210, 99, 83, 143, 199, 132, 33, 11, 59, 17, 161, 51,
  39, 107, 75, 173, 7, 155, 84, 93, 4, 235, 153, 53, 77, 249, 208, 10, 251,
  182, 105, 172, 120, 177, 5, 131, 81, 134, 194, 151, 70, 42, 98, 147, 206,
  106, 252, 250, 29, 92, 152, 13, 148, 236, 231, 180, 234, 96, 117, 88, 167,
  104, 95, 100, 26, 14, 222, 118, 139, 0, 175, 188, 157, 165, 201, 86, 52, 8,
  239, 144, 20, 55, 226, 80, 238, 97, 183, 87, 243, 174, 247, 154, 244, 21, 72,
  187, 203, 62, 50, 133, 185, 63, 170, 216, 253, 66, 43, 193, 254, 179, 211,
  150, 34, 196, 94, 130, 136, 142, 119, 126, 232, 37, 162, 204, 69, 214, 246,
  16, 73, 200, 58, 195, 90, 74, 6, 3, 23, 186, 189, 221, 45, 160, 54, 121, 28,
  89, 41, 123, 15, 184, 163, 116, 191, 156, 229, 197, 32, 255, 25, 205, 171,
  190, 78, 145, 166, 125, 230, 149, 65, 140, 19, 102, 64, 248, 22, 124, 115,
  68, 146, 178, 169, 192, 85, 40, 12, 31, 44, 18, 46, 227, 137, 228, 138, 76,
  224, 71, 48, 129, 49, 113, 242, 101, 109, 127, 91, 82, 2, 219, 233, 223, 237,
  56, 61, 202, 103, 241, 1, 79, 30, 212, 141, 168, 9, 158, 24, 110, 57, 215,
  198, 217, 60, 35, 122, 207, 209,
]);

/// Helper functions to compute gradients-dot-residual-vectors (1D to 4D). Note
/// that these generate gradients of more than unit length. To make a close
/// match with the value range of classic Perlin noise, the final noise values
/// need to be rescaled. To match the RenderMan noise in a statistical sense,
/// the approximate scaling values are:
///   1D noise needs rescaling with 0.188
///   2D noise needs rescaling with 0.507
///   3D noise needs rescaling with 0.936
///   4D noise needs rescaling with 0.870
/// Note that these noise functions are the most practical and useful signed
/// version of Perlin noise. To return values according to the RenderMan
/// specification from the SL `noise()` and `pnoise()` functions, the noise
/// values need to be scaled and offset to [0,1] like this:
///   double SLnoise = (noise3(x, y, z) + 1.0) * 0.5

double _grad1(int hash, double x) {
  final h = hash & 15;
  final grad = 1.0 + (h & 7); // Gradient value 1.0, 2.0, ..., 8.0
  // And a random sign for the gradient
  return ((h & 8) > 0) ? -grad * x : grad * x;
}

double _grad2(int hash, double x, double y) {
  // Convert low 3 bits of hash code into 8 simple gradient directions and
  // compute the dot product with (x, y).
  final h = hash & 7;
  final u = h < 4 ? x : y;
  final v = h < 4 ? y : x;
  return ((h & 1) > 0 ? -u : u) + ((h & 2) > 0 ? -2 * v : 2 * v);
}

//#endregion
