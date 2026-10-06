import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/geometry.dart';
import 'package:flame/src/geometry/signed_area.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('convexPieces', () {
    test('keeps a convex polygon whole', () {
      final square = [
        Vector2(0, 0),
        Vector2(1, 0),
        Vector2(1, 1),
        Vector2(0, 1),
      ];
      final pieces = convexPieces(square);
      expect(pieces, hasLength(1));
      expect(pieces.first, hasLength(4));
    });

    test('splits a concave polygon into convex pieces of the same area', () {
      final l = [
        Vector2(0, 0),
        Vector2(2, 0),
        Vector2(2, 1),
        Vector2(1, 1),
        Vector2(1, 2),
        Vector2(0, 2),
      ];
      final pieces = convexPieces(l);
      expect(pieces.length, greaterThan(1));
      expect(pieces.every(_isConvex), isTrue);
      expect(_totalArea(pieces), closeTo(3, 1e-9));
    });

    test('keeps the direction of the polygon', () {
      final clockwise = [
        Vector2(0, 0),
        Vector2(0, 2),
        Vector2(1, 2),
        Vector2(1, 1),
        Vector2(2, 1),
        Vector2(2, 0),
      ];
      final pieces = convexPieces(clockwise);
      expect(pieces.every((piece) => signedArea(piece) < 0), isTrue);
    });

    test('copies the vertices of the polygon', () {
      final square = [
        Vector2(0, 0),
        Vector2(1, 0),
        Vector2(1, 1),
        Vector2(0, 1),
      ];
      final pieces = convexPieces(square);
      expect(pieces.single, unorderedEquals(square));
      for (final vertex in pieces.single) {
        vertex.setZero();
      }
      expect(square, [
        Vector2(0, 0),
        Vector2(1, 0),
        Vector2(1, 1),
        Vector2(0, 1),
      ]);
    });

    test('limits the number of vertices of the pieces', () {
      final circle = [
        for (var i = 0; i < 64; i++)
          Vector2(math.cos(i * math.pi / 32), math.sin(i * math.pi / 32)),
      ];
      final pieces = convexPieces(circle, maxVertices: 5);
      expect(pieces.every((piece) => piece.length <= 5), isTrue);
      expect(_totalArea(pieces), closeTo(signedArea(circle), 1e-9));
    });

    test('welds the vertices closer than minDistance', () {
      // A triangle with a corner split in two vertices 0.01 apart, which
      // would make a degenerate piece.
      final polygon = [
        Vector2(0, 0),
        Vector2(1, 0),
        Vector2(1, 0.01),
        Vector2(0.5, 1),
      ];
      final pieces = convexPieces(polygon, minDistance: 0.02);
      expect(pieces, hasLength(1));
      expect(pieces.first, hasLength(3));
    });

    test('leaves out the pieces narrower than minWidth', () {
      final sliver = [Vector2(0, 0), Vector2(1, 0), Vector2(0.5, 0.005)];
      expect(convexPieces(sliver, minWidth: 0.01), isEmpty);
      expect(convexPieces(sliver), hasLength(1));
    });

    test('keeps the pieces convex with a minWidth', () {
      // A square with a shallow dent in its top edge, shallower than minWidth.
      final dented = [
        Vector2(0, 0),
        Vector2(5, 0.3),
        Vector2(10, 0),
        Vector2(10, 10),
        Vector2(0, 10),
      ];
      final pieces = convexPieces(dented, minWidth: 1);
      expect(pieces, hasLength(2));
      expect(pieces.every(_isConvex), isTrue);
      expect(_totalArea(pieces), closeTo(signedArea(dented).abs(), 1e-9));
    });

    test('splits a polygon where it touches itself', () {
      // Two squares that meet at the corner (1, 1), which is visited twice.
      final touching = [
        Vector2(0, 0),
        Vector2(1, 0),
        Vector2(1, 1),
        Vector2(2, 1),
        Vector2(2, 2),
        Vector2(1, 2),
        Vector2(1, 1),
        Vector2(0, 1),
      ];
      final pieces = convexPieces(touching);
      expect(pieces, hasLength(2));
      expect(pieces.every(_isConvex), isTrue);
      expect(_totalArea(pieces), closeTo(2, 1e-9));
    });

    test('welds the vertices next to where the polygon touches itself', () {
      // Two squares that meet near the corner (1, 1), where the second visit
      // is within minDistance of the first one, and the last vertex is within
      // minDistance of the second visit but not of the first one.
      final touching = [
        Vector2(1, 1),
        Vector2(2, 1),
        Vector2(2, 2),
        Vector2(1, 2),
        Vector2(1.05, 1),
        Vector2(0, 1),
        Vector2(0, 0),
        Vector2(1, 0),
        Vector2(1.1, 0.95),
      ];
      final pieces = convexPieces(touching, minDistance: 0.1);
      expect(pieces, hasLength(2));
      expect(pieces.every(_isConvex), isTrue);
      expect(_totalArea(pieces), closeTo(2.025, 1e-6));
    });

    test('fills a hole that touches the outline at a vertex', () {
      // A square, and a triangular hole that goes the other way, which both
      // start at (0, 0).
      final withHole = [
        Vector2(0, 0),
        Vector2(4, 0),
        Vector2(4, 4),
        Vector2(0, 4),
        Vector2(0, 0),
        Vector2(1, 2),
        Vector2(2, 1),
      ];
      final pieces = convexPieces(withHole);
      expect(pieces.every(_isConvex), isTrue);
      expect(_totalArea(pieces), closeTo(16, 1e-9));
    });

    test('gives no pieces for fewer than three vertices', () {
      expect(convexPieces([]), isEmpty);
      expect(convexPieces([Vector2(0, 0), Vector2(1, 0)]), isEmpty);
    });

    testRandom('covers random concave polygons with convex pieces', (r) {
      // A star with points at random distances from its center, which is
      // concave and simple.
      final count = 3 + r.nextInt(30);
      final star = [
        for (var i = 0; i < 2 * count; i++)
          Vector2(math.cos(i * math.pi / count), math.sin(i * math.pi / count))
            ..scale(i.isEven ? 1 + r.nextDouble() * 9 : 0.2 + r.nextDouble()),
      ];
      final maxVertices = 3 + r.nextInt(6);
      final pieces = convexPieces(star, maxVertices: maxVertices);
      expect(pieces.every(_isConvex), isTrue);
      expect(
        pieces.every(
          (piece) => piece.length >= 3 && piece.length <= maxVertices,
        ),
        isTrue,
      );
      expect(pieces.every((piece) => signedArea(piece) > 0), isTrue);
      expect(_totalArea(pieces), closeTo(signedArea(star), 1e-6));
    }, repeatCount: 100);

    test('covers the polygons of a PathComponent', () {
      final path = Path()
        ..moveTo(0, 0)
        ..lineTo(40, 0)
        ..lineTo(40, 40)
        ..lineTo(30, 40)
        ..lineTo(30, 10)
        ..lineTo(10, 10)
        ..lineTo(10, 40)
        ..lineTo(0, 40)
        ..close();
      final polygon = PathComponent.polygonsOf(path).single;
      final pieces = convexPieces(polygon);
      expect(pieces.length, greaterThan(1));
      expect(pieces.every(_isConvex), isTrue);
      expect(_totalArea(pieces), closeTo(40 * 40 - 20 * 30, 1e-6));
    });
  });
}

double _totalArea(List<List<Vector2>> pieces) {
  return pieces.fold(0, (sum, piece) => sum + signedArea(piece).abs());
}

bool _isConvex(List<Vector2> piece) {
  final sign = signedArea(piece).sign;
  for (var i = 0; i < piece.length; i++) {
    final a = piece[i];
    final b = piece[(i + 1) % piece.length];
    final c = piece[(i + 2) % piece.length];
    if ((b - a).cross(c - b) * sign < -1e-12) {
      return false;
    }
  }
  return true;
}
