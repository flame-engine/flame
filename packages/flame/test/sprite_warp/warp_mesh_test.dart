import 'dart:math';
import 'dart:typed_data';

import 'package:flame/components.dart';
import 'package:flame/src/sprite_warp/warp_mesh.dart';
import 'package:test/test.dart';

/// A 3x2 grid with every vertex displaced, including the border ones.
WarpGrid _warpedGrid() {
  final grid = WarpGrid.identity(columns: 3, rows: 2);
  final random = Random(42);
  return grid.replacingDestinationPositions([
    for (final p in grid.destinationPositions)
      p +
          Vector2(
            random.nextDouble() * 0.2 - 0.1,
            random.nextDouble() * 0.2 - 0.1,
          ),
  ]);
}

Vector2 _at(Float32List values, int index) =>
    Vector2(values[2 * index], values[2 * index + 1]);

Matcher _closeToVector(Vector2 expected) => predicate<Vector2>(
  (v) => (v - expected).length < 1e-6,
  'close to $expected',
);

void main() {
  group('WarpMesh', () {
    for (final interpolation in WarpInterpolation.values) {
      group(interpolation.name, () {
        test('has 4x4 sub-cells per cell, 2 triangles each', () {
          final mesh = WarpMesh.fromGrid(
            WarpGrid.identity(columns: 2, rows: 3),
            interpolation,
          );

          expect(mesh.vertexCount, 9 * 13);
          expect(mesh.textureCoordinates.length, 2 * 9 * 13);
          expect(mesh.indices.length, 3 * 2 * 8 * 12);
          expect(mesh.indices.reduce(max), mesh.vertexCount - 1);
        });

        test('passes through the grid vertices', () {
          final grid = _warpedGrid();
          final mesh = WarpMesh.fromGrid(grid, interpolation);
          const meshColumns = 3 * 4 + 1;

          for (var row = 0; row <= grid.rows; row++) {
            for (var column = 0; column <= grid.columns; column++) {
              final index = grid.vertexIndex(column, row);
              final meshIndex = 4 * row * meshColumns + 4 * column;
              expect(
                _at(mesh.positions, meshIndex),
                _closeToVector(grid.destinationPosition(index)),
              );
              expect(
                _at(mesh.textureCoordinates, meshIndex),
                _closeToVector(grid.sourcePosition(index)),
              );
            }
          }
        });

        test('keeps an identity grid undistorted', () {
          final mesh = WarpMesh.fromGrid(
            WarpGrid.identity(columns: 3, rows: 5),
            interpolation,
          );
          const meshColumns = 3 * 4 + 1;
          const meshRows = 5 * 4 + 1;

          for (var row = 0; row < meshRows; row++) {
            for (var column = 0; column < meshColumns; column++) {
              final index = row * meshColumns + column;
              final expected = Vector2(
                column / (meshColumns - 1),
                row / (meshRows - 1),
              );
              expect(_at(mesh.positions, index), _closeToVector(expected));
              expect(
                _at(mesh.textureCoordinates, index),
                _closeToVector(expected),
              );
            }
          }
        });

        test('subdivision level 0 uses the grid vertices only', () {
          final grid = _warpedGrid();
          final mesh = WarpMesh.fromGrid(
            grid,
            interpolation,
            subdivisionLevels: 0,
          );

          expect(mesh.vertexCount, grid.vertexCount);
          for (var i = 0; i < grid.vertexCount; i++) {
            expect(
              _at(mesh.positions, i),
              _closeToVector(grid.destinationPosition(i)),
            );
          }
          expect(mesh.indices.length, 6 * grid.columns * grid.rows);
        });

        test('bounds contain all the positions', () {
          final mesh = WarpMesh.fromGrid(_warpedGrid(), interpolation);
          final xs = [
            for (var i = 0; i < mesh.vertexCount; i++) mesh.positions[2 * i],
          ];
          final ys = [
            for (var i = 0; i < mesh.vertexCount; i++)
              mesh.positions[2 * i + 1],
          ];

          expect(mesh.bounds.left, closeTo(xs.reduce(min), 1e-6));
          expect(mesh.bounds.right, closeTo(xs.reduce(max), 1e-6));
          expect(mesh.bounds.top, closeTo(ys.reduce(min), 1e-6));
          expect(mesh.bounds.bottom, closeTo(ys.reduce(max), 1e-6));
        });
      });
    }

    test('bilinear interpolation within a cell', () {
      final grid = WarpGrid.identity().replacingDestinationPositions([
        Vector2(0, 0),
        Vector2(1.2, -0.2),
        Vector2(0, 1),
        Vector2(1, 1),
      ]);
      final mesh = WarpMesh.fromGrid(grid, WarpInterpolation.bilinear);

      // The center of a cell is the average of its corners.
      expect(
        _at(mesh.positions, 2 * 5 + 2),
        _closeToVector(Vector2(0.55, 0.45)),
      );
      // Edges are straight: the middle of the top edge is its midpoint.
      expect(_at(mesh.positions, 2), _closeToVector(Vector2(0.6, -0.1)));
    });

    test('Catmull-Rom on a single cell is bilinear', () {
      final grid = WarpGrid.identity().replacingDestinationPositions([
        Vector2(0.1, 0),
        Vector2(1.2, -0.2),
        Vector2(-0.1, 0.9),
        Vector2(1, 1.3),
      ]);
      final bilinear = WarpMesh.fromGrid(grid, WarpInterpolation.bilinear);
      final catmullRom = WarpMesh.fromGrid(grid, WarpInterpolation.catmullRom);

      for (var i = 0; i < bilinear.positions.length; i++) {
        expect(catmullRom.positions[i], closeTo(bilinear.positions[i], 1e-6));
      }
    });

    test('Catmull-Rom is smooth across cells, bilinear is not', () {
      // A zigzag along a 4x1 grid: odd columns are moved down.
      final grid = WarpGrid.identity(columns: 4).replacingDestinationPositions(
        [
          for (final p in WarpGrid.identity(columns: 4).destinationPositions)
            p + Vector2(0, (p.x * 4).round().isOdd ? 0.2 : 0),
        ],
      );

      // Jump in slope of the top edge at the interior grid vertex in column
      // 2, between its left and right sides, using a finely subdivided mesh
      // so that the one-sided slopes approximate the derivatives.
      double slopeJump(WarpInterpolation interpolation) {
        const levels = 6;
        const subdivisions = 1 << levels;
        final mesh = WarpMesh.fromGrid(
          grid,
          interpolation,
          subdivisionLevels: levels,
        );
        double y(int column) => mesh.positions[2 * column + 1];
        const vertex = 2 * subdivisions;
        const h = 1 / (4 * subdivisions);
        final right = (y(vertex + 1) - y(vertex)) / h;
        final left = (y(vertex) - y(vertex - 1)) / h;
        return (right - left).abs();
      }

      // Bilinear edges go straight from 0.2 down to 0 and back up, over 1/4
      // of the width: the slope jumps from -0.8 to 0.8.
      expect(slopeJump(WarpInterpolation.bilinear), closeTo(1.6, 1e-3));
      expect(slopeJump(WarpInterpolation.catmullRom), lessThan(0.2));
    });
  });
}
