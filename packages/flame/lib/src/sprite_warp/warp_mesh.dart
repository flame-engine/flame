import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame/src/sprite_warp/warp_grid.dart';
import 'package:meta/meta.dart';

/// A triangle mesh built from a [WarpGrid], ready to be turned into
/// `Vertices`.
///
/// Each grid cell is subdivided into `2^n x 2^n` sub-cells (where `n` is the
/// number of subdivision levels), and every sub-cell is split into two
/// triangles. Positions and texture coordinates of the mesh vertices are
/// interpolated from the grid with the given [WarpInterpolation], and are
/// normalized like the grid's positions.
@internal
class WarpMesh._(
  /// Normalized destination positions, as interleaved x, y values.
  final Float32List positions,

  /// Normalized source positions, as interleaved x, y values.
  final Float32List textureCoordinates,

  /// Indices of the triangles' vertices.
  final Uint16List indices,
) {
  /// Builds the mesh of [grid] using the given [interpolation].
  factory WarpMesh.fromGrid(
    WarpGrid grid,
    WarpInterpolation interpolation, {
    @visibleForTesting int subdivisionLevels = warpSubdivisionLevels,
  }) {
    final subdivisions = 1 << subdivisionLevels;
    final columns = grid.columns * subdivisions + 1;
    final rows = grid.rows * subdivisions + 1;
    final weightsX = _AxisWeights(grid.columns, subdivisions, interpolation);
    final weightsY = _AxisWeights(grid.rows, subdivisions, interpolation);
    final source = _PaddedGrid(
      grid.rawSourcePositions,
      grid.columns,
      grid.rows,
    );
    final destination = _PaddedGrid(
      grid.rawDestinationPositions,
      grid.columns,
      grid.rows,
    );

    final positions = Float32List(2 * columns * rows);
    final textureCoordinates = Float32List(2 * columns * rows);
    var k = 0;
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        destination.interpolate(weightsX, column, weightsY, row, positions, k);
        source.interpolate(
          weightsX,
          column,
          weightsY,
          row,
          textureCoordinates,
          k,
        );
        k += 2;
      }
    }

    final indices = Uint16List(6 * (columns - 1) * (rows - 1));
    var i = 0;
    for (var row = 0; row < rows - 1; row++) {
      for (var column = 0; column < columns - 1; column++) {
        final topLeft = row * columns + column;
        final topRight = topLeft + 1;
        final bottomLeft = topLeft + columns;
        final bottomRight = bottomLeft + 1;
        indices[i++] = topLeft;
        indices[i++] = topRight;
        indices[i++] = bottomLeft;
        indices[i++] = topRight;
        indices[i++] = bottomRight;
        indices[i++] = bottomLeft;
      }
    }
    return WarpMesh._(positions, textureCoordinates, indices);
  }

  /// The bounding box of [positions].
  late final Rect bounds = _boundsOf(positions);

  int get vertexCount => positions.length ~/ 2;

  static Rect _boundsOf(Float32List positions) {
    var left = double.infinity;
    var top = double.infinity;
    var right = double.negativeInfinity;
    var bottom = double.negativeInfinity;
    for (var k = 0; k < positions.length; k += 2) {
      left = min(left, positions[k]);
      right = max(right, positions[k]);
      top = min(top, positions[k + 1]);
      bottom = max(bottom, positions[k + 1]);
    }
    return Rect.fromLTRB(left, top, right, bottom);
  }
}

/// Interpolation weights along one axis of the grid.
///
/// Every mesh vertex along the axis is interpolated from the 4 nearest grid
/// vertices (in padded coordinates, see [_PaddedGrid]), with weights that
/// only depend on the vertex's position within its cell: they are computed
/// once for each of the `subdivisions + 1` possible positions.
class _AxisWeights(
  final int cells,
  final int subdivisions,
  WarpInterpolation interpolation,
) {
  final Float64List _weights = Float64List(4 * (subdivisions + 1));

  this {
    for (var k = 0; k <= subdivisions; k++) {
      final t = k / subdivisions;
      final w = 4 * k;
      switch (interpolation) {
        case WarpInterpolation.bilinear:
          _weights[w + 1] = 1 - t;
          _weights[w + 2] = t;
        case WarpInterpolation.catmullRom:
          final t2 = t * t;
          final t3 = t2 * t;
          _weights[w] = 0.5 * (-t + 2 * t2 - t3);
          _weights[w + 1] = 0.5 * (2 - 5 * t2 + 3 * t3);
          _weights[w + 2] = 0.5 * (t + 4 * t2 - 3 * t3);
          _weights[w + 3] = 0.5 * (-t2 + t3);
      }
    }
  }

  /// The cell containing the mesh vertex at [index]; the last vertex belongs
  /// to the last cell.
  int cellOf(int index) => min(index ~/ subdivisions, cells - 1);

  /// The offset of the weights of the mesh vertex at [index] in its [cell].
  int weightsOffset(int index, int cell) => 4 * (index - cell * subdivisions);

  double operator [](int offset) => _weights[offset];
}

/// Grid positions surrounded by one extra row and column on every side,
/// linearly extrapolated from the grid, so that every cell has 4 x 4
/// neighboring vertices to interpolate from.
///
/// Linear extrapolation makes Catmull-Rom splines reproduce linear functions,
/// so that an undistorted grid stays undistorted, and makes a single cell
/// interpolate bilinearly.
class _PaddedGrid(Float32List values, int columns, int rows) {
  final int _width = columns + 3;
  final Float32List _data = Float32List(2 * (columns + 3) * (rows + 3));

  this {
    for (var row = 0; row <= rows; row++) {
      for (var column = 0; column <= columns; column++) {
        final from = 2 * (row * (columns + 1) + column);
        final to = _offset(column + 1, row + 1);
        _data[to] = values[from];
        _data[to + 1] = values[from + 1];
      }
    }
    for (var row = 1; row <= rows + 1; row++) {
      _extrapolate(0, row, 1, row, 2, row);
      _extrapolate(columns + 2, row, columns + 1, row, columns, row);
    }
    for (var column = 0; column < _width; column++) {
      _extrapolate(column, 0, column, 1, column, 2);
      _extrapolate(column, rows + 2, column, rows + 1, column, rows);
    }
  }

  int _offset(int column, int row) => 2 * (row * _width + column);

  /// Sets the target vertex to `2 * near - far`.
  void _extrapolate(
    int targetColumn,
    int targetRow,
    int nearColumn,
    int nearRow,
    int farColumn,
    int farRow,
  ) {
    final target = _offset(targetColumn, targetRow);
    final near = _offset(nearColumn, nearRow);
    final far = _offset(farColumn, farRow);
    _data[target] = 2 * _data[near] - _data[far];
    _data[target + 1] = 2 * _data[near + 1] - _data[far + 1];
  }

  /// Interpolates the mesh vertex at ([column], [row]) into [out] at [at].
  void interpolate(
    _AxisWeights weightsX,
    int column,
    _AxisWeights weightsY,
    int row,
    Float32List out,
    int at,
  ) {
    final cellX = weightsX.cellOf(column);
    final cellY = weightsY.cellOf(row);
    final wx = weightsX.weightsOffset(column, cellX);
    final wy = weightsY.weightsOffset(row, cellY);
    var x = 0.0;
    var y = 0.0;
    for (var j = 0; j < 4; j++) {
      // Padded row cellY + j is grid row cellY - 1 + j.
      var k = _offset(cellX, cellY + j);
      final weightY = weightsY[wy + j];
      for (var i = 0; i < 4; i++) {
        final weight = weightsX[wx + i] * weightY;
        x += _data[k] * weight;
        y += _data[k + 1] * weight;
        k += 2;
      }
    }
    out[at] = x;
    out[at + 1] = y;
  }
}
