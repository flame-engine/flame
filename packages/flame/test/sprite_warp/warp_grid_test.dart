import 'package:flame/components.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('WarpGrid', () {
    test('identity grid has regularly spaced positions', () {
      final grid = WarpGrid.identity(columns: 2, rows: 4);

      expect(grid.columns, 2);
      expect(grid.rows, 4);
      expect(grid.vertexCount, 15);
      for (var row = 0; row <= 4; row++) {
        for (var column = 0; column <= 2; column++) {
          final index = grid.vertexIndex(column, row);
          final expected = Vector2(column / 2, row / 4);
          expect(grid.sourcePosition(index), expected);
          expect(grid.destinationPosition(index), expected);
        }
      }
    });

    test('default identity grid is 1x1', () {
      final grid = WarpGrid.identity();

      expect(grid.vertexCount, 4);
      expect(grid.destinationPositions, [
        Vector2(0, 0),
        Vector2(1, 0),
        Vector2(0, 1),
        Vector2(1, 1),
      ]);
    });

    test('vertices are in row-major order from the top-left', () {
      final grid = WarpGrid.identity(columns: 3, rows: 2);

      expect(grid.vertexIndex(0, 0), 0);
      expect(grid.vertexIndex(3, 0), 3);
      expect(grid.vertexIndex(0, 1), 4);
      expect(grid.vertexIndex(3, 2), 11);
      expect(grid.sourcePosition(grid.vertexIndex(3, 0)), Vector2(1, 0));
      expect(grid.sourcePosition(grid.vertexIndex(0, 2)), Vector2(0, 1));
    });

    test('uses the given positions', () {
      final source = [
        Vector2(0, 0),
        Vector2(1, 0),
        Vector2(0, 1),
        Vector2(1, 1),
      ];
      final destination = [
        Vector2(-0.5, 0),
        Vector2(1, -0.25),
        Vector2(0, 1),
        Vector2(1.5, 2),
      ];
      final grid = WarpGrid(
        columns: 1,
        rows: 1,
        sourcePositions: source,
        destinationPositions: destination,
      );

      expect(grid.sourcePositions, source);
      expect(grid.destinationPositions, destination);
    });

    test('omitted positions default to identity', () {
      final destination = [
        Vector2(0, 0),
        Vector2(1.25, 0),
        Vector2(0, 1),
        Vector2(1, 1),
      ];
      final grid = WarpGrid(
        columns: 1,
        rows: 1,
        destinationPositions: destination,
      );

      expect(grid.sourcePositions, WarpGrid.identity().sourcePositions);
      expect(grid.destinationPositions, destination);
    });

    test('is not affected by later changes to the given positions', () {
      final destination = WarpGrid.identity().destinationPositions;
      final grid = WarpGrid(
        columns: 1,
        rows: 1,
        destinationPositions: destination,
      );

      destination[0].setValues(0.5, 0.5);
      grid.destinationPosition(1).setValues(0.5, 0.5);
      grid.destinationPositions[2].setValues(0.5, 0.5);

      expect(grid, WarpGrid.identity());
    });

    test('replacing positions returns a modified copy', () {
      final grid = WarpGrid.identity(columns: 2, rows: 2);
      final center = grid.vertexIndex(1, 1);

      final destination = grid.destinationPositions;
      destination[center].setValues(0.7, 0.3);
      final warped = grid.replacingDestinationPositions(destination);

      expect(warped.destinationPosition(center), Vector2(0.7, 0.3));
      expect(warped.sourcePositions, grid.sourcePositions);
      expect(grid.destinationPosition(center), Vector2(0.5, 0.5));

      final source = grid.sourcePositions;
      source[center].setValues(0.25, 0.25);
      final shifted = warped.replacingSourcePositions(source);

      expect(shifted.sourcePosition(center), Vector2(0.25, 0.25));
      expect(shifted.destinationPositions, warped.destinationPositions);
      expect(warped.sourcePosition(center), Vector2(0.5, 0.5));
    });

    test('compares by value', () {
      final a = WarpGrid.identity(columns: 2, rows: 3);
      final b = WarpGrid(columns: 2, rows: 3);
      final c = WarpGrid.identity(columns: 3, rows: 2);
      final d = a.replacingDestinationPositions(
        a.destinationPositions..[0] = Vector2(-0.1, 0),
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(d));
      expect(
        d,
        a.replacingDestinationPositions(d.destinationPositions),
      );
    });

    test('fails on invalid dimensions', () {
      expect(() => WarpGrid(columns: 0, rows: 1), throwsArgumentError);
      expect(() => WarpGrid(columns: 1, rows: -1), throwsArgumentError);
      expect(
        () => WarpGrid.identity(columns: -1, rows: -1),
        throwsArgumentError,
      );
      // The rendered mesh must fit 16-bit indices.
      expect(WarpGrid.identity(columns: 63, rows: 63).vertexCount, 4096);
      expect(() => WarpGrid(columns: 64, rows: 64), throwsArgumentError);
      expect(
        () => WarpGrid.identity(columns: 4000),
        throwsArgumentError,
      );
    });

    test('fails on wrong number of positions', () {
      final grid = WarpGrid.identity(columns: 2, rows: 2);

      expect(
        () => WarpGrid(
          columns: 1,
          rows: 1,
          sourcePositions: grid.sourcePositions,
        ),
        throwsArgumentError,
      );
      expect(
        () => WarpGrid(
          columns: 2,
          rows: 2,
          destinationPositions: [Vector2.zero()],
        ),
        throwsArgumentError,
      );
      expect(
        () => grid.replacingSourcePositions(
          [...grid.sourcePositions, Vector2.zero()],
        ),
        throwsArgumentError,
      );
      expect(
        () => grid.replacingDestinationPositions([Vector2.zero()]),
        throwsArgumentError,
      );
    });

    test('fails on invalid vertex coordinates', () {
      final grid = WarpGrid.identity(columns: 2, rows: 2);

      expect(() => grid.vertexIndex(3, 0), failsAssert());
      expect(() => grid.vertexIndex(0, -1), failsAssert());
      expect(() => grid.sourcePosition(9), failsAssert());
    });
  });
}
