import 'dart:typed_data';

import 'package:flame/src/extensions/vector2.dart';
import 'package:meta/meta.dart';

/// Number of subdivision iterations used to build the rendered mesh of a
/// [WarpGrid]: each grid cell is split into `2^n x 2^n` sub-cells.
@internal
const int warpSubdivisionLevels = 2;

/// Maximum number of vertices of a rendered mesh, bound by 16-bit indices.
const int _maxMeshVertices = 1 << 16;

/// An immutable grid that describes how to warp (distort) a sprite.
///
/// The grid has [columns] x [rows] cells, and therefore
/// `(columns + 1) * (rows + 1)` vertices (see [vertexCount]). Each vertex has
/// a source position and a destination position: the content found at the
/// source position of the sprite is drawn at the destination position, and
/// everything in between is interpolated.
///
/// Vertices are stored in row-major order starting from the top-left corner
/// (see [vertexIndex]), and positions are normalized with the y axis pointing
/// down, following Flame's conventions:
///  * source positions are relative to the sprite's source rectangle, so
///    `(0, 0)` is its top-left corner and `(1, 1)` its bottom-right corner;
///  * destination positions are relative to the size of the component, and
///    values outside of the `0..1` range are valid: they correspond to
///    positions outside of the undistorted bounds.
///
/// When omitted, both source and destination positions describe a regular
/// grid, so that the sprite is rendered without distortion.
///
/// Note that SpriteKit's `SKWarpGeometryGrid` uses a bottom-left origin with
/// the y axis pointing up, so its positions must be converted accordingly.
@immutable
class const WarpGrid.raw(
  /// The number of cells in the horizontal direction.
  final int columns,

  /// The number of cells in the vertical direction.
  final int rows,
  final Float32List _source,
  final Float32List _destination,
) {
  /// Creates a grid from interleaved x, y source and destination positions,
  /// which are used as is and must not be modified afterwards.
  ///
  /// Both lists must hold `2 * (columns + 1) * (rows + 1)` values.
  @internal
  this;

  /// Creates a grid with the given positions, which default to those of an
  /// undistorted grid.
  ///
  /// Throws an [ArgumentError] when [columns] or [rows] are not positive, when
  /// the rendered mesh of the grid would have more than 65536 vertices, e.g.
  /// with more than 63 x 63 cells, or when there isn't one position per
  /// vertex.
  factory WarpGrid({
    required int columns,
    required int rows,
    List<Vector2>? sourcePositions,
    List<Vector2>? destinationPositions,
  }) {
    if (columns <= 0 || rows <= 0) {
      throw ArgumentError(
        'Columns and rows must be positive, got $columns x $rows',
      );
    }
    final meshVertices =
        (columns * (1 << warpSubdivisionLevels) + 1) *
        (rows * (1 << warpSubdivisionLevels) + 1);
    if (meshVertices > _maxMeshVertices) {
      throw ArgumentError(
        'Too many columns and rows: $columns x $rows (at most '
        '$_maxMeshVertices mesh vertices, got $meshVertices)',
      );
    }
    return WarpGrid.raw(
      columns,
      rows,
      _positionsOrIdentity(sourcePositions, columns, rows),
      _positionsOrIdentity(destinationPositions, columns, rows),
    );
  }

  /// Creates a grid that renders the sprite without distortion.
  ///
  /// Throws an [ArgumentError] in the same cases as the default constructor.
  factory WarpGrid.identity({int columns = 1, int rows = 1}) {
    return WarpGrid(columns: columns, rows: rows);
  }

  /// The number of vertices, equal to `(columns + 1) * (rows + 1)`.
  int get vertexCount => (columns + 1) * (rows + 1);

  /// The index of the vertex at the given [column] and [row], where `(0, 0)`
  /// is the top-left vertex and `(columns, rows)` the bottom-right one.
  int vertexIndex(int column, int row) {
    assert(column >= 0 && column <= columns, 'Invalid column: $column');
    assert(row >= 0 && row <= rows, 'Invalid row: $row');
    return row * (columns + 1) + column;
  }

  /// The normalized source position of the vertex at [index].
  Vector2 sourcePosition(int index) => _positionAt(_source, index);

  /// The normalized destination position of the vertex at [index].
  Vector2 destinationPosition(int index) => _positionAt(_destination, index);

  /// A copy of all the source positions, in vertex order.
  List<Vector2> get sourcePositions => _toVectors(_source);

  /// A copy of all the destination positions, in vertex order.
  List<Vector2> get destinationPositions => _toVectors(_destination);

  /// The source positions as interleaved x, y values.
  ///
  /// The returned list must not be modified.
  @internal
  Float32List get rawSourcePositions => _source;

  /// The destination positions as interleaved x, y values.
  ///
  /// The returned list must not be modified.
  @internal
  Float32List get rawDestinationPositions => _destination;

  /// Returns a copy of this grid with the given source [positions].
  ///
  /// Throws an [ArgumentError] when there isn't one position per vertex.
  WarpGrid replacingSourcePositions(List<Vector2> positions) {
    return WarpGrid.raw(
      columns,
      rows,
      _fromVectors(positions, vertexCount),
      _destination,
    );
  }

  /// Returns a copy of this grid with the given destination [positions].
  ///
  /// Throws an [ArgumentError] when there isn't one position per vertex.
  WarpGrid replacingDestinationPositions(List<Vector2> positions) {
    return WarpGrid.raw(
      columns,
      rows,
      _source,
      _fromVectors(positions, vertexCount),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is WarpGrid &&
        columns == other.columns &&
        rows == other.rows &&
        _equals(_source, other._source) &&
        _equals(_destination, other._destination);
  }

  @override
  int get hashCode => Object.hash(
    columns,
    rows,
    Object.hashAll(_source),
    Object.hashAll(_destination),
  );

  @override
  String toString() => 'WarpGrid($columns x $rows)';

  static Float32List _positionsOrIdentity(
    List<Vector2>? positions,
    int columns,
    int rows,
  ) {
    final vertexCount = (columns + 1) * (rows + 1);
    if (positions != null) {
      return _fromVectors(positions, vertexCount);
    }
    final result = Float32List(2 * vertexCount);
    var k = 0;
    for (var row = 0; row <= rows; row++) {
      for (var column = 0; column <= columns; column++) {
        result[k++] = column / columns;
        result[k++] = row / rows;
      }
    }
    return result;
  }

  static Float32List _fromVectors(List<Vector2> positions, int vertexCount) {
    if (positions.length != vertexCount) {
      throw ArgumentError(
        'Expected $vertexCount positions, got ${positions.length}',
      );
    }
    final result = Float32List(2 * vertexCount);
    for (var i = 0; i < vertexCount; i++) {
      result[2 * i] = positions[i].x;
      result[2 * i + 1] = positions[i].y;
    }
    return result;
  }

  static List<Vector2> _toVectors(Float32List values) {
    return List.generate(
      values.length ~/ 2,
      (i) => Vector2(values[2 * i], values[2 * i + 1]),
      growable: false,
    );
  }

  static Vector2 _positionAt(Float32List values, int index) {
    assert(index >= 0 && 2 * index < values.length, 'Invalid index: $index');
    return Vector2(values[2 * index], values[2 * index + 1]);
  }

  static bool _equals(Float32List a, Float32List b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
}

/// How a [WarpGrid] is interpolated between its vertices.
enum WarpInterpolation() {
  /// Bilinear interpolation within each cell, matching SpriteKit's
  /// `SKWarpGeometryGrid` rendering.
  ///
  /// Moving a vertex only affects the cells that share it, and the edges
  /// between cells stay straight.
  bilinear,

  /// Catmull-Rom spline interpolation across cells.
  ///
  /// The warped sprite passes through all the grid vertices and bends
  /// smoothly across cell boundaries. Moving a vertex also affects cells up to
  /// two cells away, and strong distortions can slightly overshoot.
  catmullRom,
}
