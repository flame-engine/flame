import 'dart:typed_data';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/src/geometry/signed_area.dart';
import 'package:flutter_test/flutter_test.dart';

/// The pixels of the [rows], where each character is a pixel: '#' is opaque,
/// '+' has half alpha and anything else is transparent.
Uint8List _pixels(List<String> rows) {
  final width = rows.first.length;
  final pixels = Uint8List(width * rows.length * 4);
  for (var y = 0; y < rows.length; y++) {
    for (var x = 0; x < width; x++) {
      final alpha = switch (rows[y][x]) {
        '#' => 255,
        '+' => 128,
        _ => 0,
      };
      pixels[(y * width + x) * 4 + 3] = alpha;
    }
  }
  return pixels;
}

Path _contour(
  List<String> rows, {
  Rect? region,
  Vector2? size,
  double alphaThreshold = 0.5,
}) {
  return ImageExtension.contourFromPixels(
    _pixels(rows),
    rows.first.length,
    rows.length,
    region: region,
    size: size,
    alphaThreshold: alphaThreshold,
  );
}

Future<Image> _image(List<String> rows) {
  return ImageExtension.fromPixels(
    _pixels(rows),
    rows.first.length,
    rows.length,
  );
}

/// The vertices of each contour of the [path], without the samples along its
/// edges.
List<List<Offset>> _vertices(Path path) => path.walkContours(1, 0.001);

void main() {
  group('ImageExtension.contourFromPixels', () {
    test('is empty for a transparent image', () {
      final path = _contour(['...', '...']);
      expect(path.contours, isEmpty);
    });

    test('is empty for an empty region', () {
      final path = _contour(['##', '##'], region: Rect.zero);
      expect(path.contours, isEmpty);
    });

    test('cuts the corners of a single pixel', () {
      final path = _contour(['...', '.#.', '...']);
      final vertices = _vertices(path);
      expect(vertices, hasLength(1));
      expect(
        vertices.single,
        unorderedEquals(const [
          Offset(1.5, 1),
          Offset(2, 1.5),
          Offset(1.5, 2),
          Offset(1, 1.5),
        ]),
      );
    });

    test('follows the sides of the pixels with straight edges', () {
      final path = _contour(['....', '.##.', '.##.', '....']);
      final vertices = _vertices(path);
      expect(vertices.single, hasLength(8));
      expect(path.getBounds(), const Rect.fromLTRB(1, 1, 3, 3));
    });

    test('reaches the borders of a fully opaque image', () {
      final path = _contour(['###', '###']);
      expect(path.contours, hasLength(1));
      expect(path.getBounds(), const Rect.fromLTRB(0, 0, 3, 2));
    });

    test('goes clockwise on the screen', () {
      final vertices = _vertices(_contour(['##', '##'])).single;
      expect(
        signedArea([for (final vertex in vertices) vertex.toVector2()]),
        greaterThan(0),
      );
    });

    test('follows concave outlines', () {
      final path = _contour([
        '#..',
        '#..',
        '###',
      ]);
      expect(path.contours, hasLength(1));
      expect(path.contains(const Offset(0.5, 0.5)), isTrue);
      expect(path.contains(const Offset(2.5, 2.5)), isTrue);
      expect(path.contains(const Offset(2, 1)), isFalse);
    });

    test('leaves out the holes', () {
      final path = _contour([
        '###',
        '#.#',
        '###',
      ]);
      expect(path.contours, hasLength(1));
      expect(path.getBounds(), const Rect.fromLTRB(0, 0, 3, 3));
      expect(path.contains(const Offset(1.5, 1.5)), isTrue);
    });

    test('gives a contour for each separate area', () {
      final path = _contour([
        '##..#',
        '##...',
        '....#',
      ]);
      expect(path.contours, hasLength(3));
    });

    test('joins diagonal pixels when the center reaches the threshold', () {
      expect(_contour(['#.', '.#']).contours, hasLength(1));
      expect(
        _contour(['#.', '.#'], alphaThreshold: 0.6).contours,
        hasLength(2),
      );
    });

    test('places the edges where the alpha reaches the threshold', () {
      final half = _contour(['#+']).getBounds();
      expect(half.right, closeTo(1.5 + 0.004, 0.001));
      final low = _contour(['#+.'], alphaThreshold: 0.25).getBounds();
      expect(low.right, closeTo(1.5 + 1 - 0.25 / (128 / 255), 0.001));
      final high = _contour(['#+'], alphaThreshold: 0.75).getBounds();
      expect(high.right, closeTo(0.5 + 0.25 / (127 / 255), 0.001));
    });

    test('stays within the region at a low threshold', () {
      final low = _contour(['##', '##'], alphaThreshold: 1 / 255);
      expect(low.getBounds(), const Rect.fromLTRB(0, 0, 2, 2));
      final region = _contour(
        ['....', '.##.', '....'],
        region: const Rect.fromLTWH(1, 1, 2, 1),
        alphaThreshold: 0.25,
      );
      expect(region.getBounds(), const Rect.fromLTRB(0, 0, 2, 1));
    });

    test('keeps the corners where the alpha is exactly the threshold', () {
      // The outline passes through the centers of the opaque pixels, where
      // all the edges of the pixels are crossed at the same point.
      final path = _contour([
        '.....',
        '.###.',
        '.###.',
        '.###.',
        '.....',
      ], alphaThreshold: 1);
      expect(_vertices(path).single, hasLength(4));
      expect(path.getBounds(), const Rect.fromLTRB(1.5, 1.5, 3.5, 3.5));
    });

    test('asserts that the region is within the image', () {
      expect(
        () => _contour(['##', '##'], region: const Rect.fromLTWH(-1, 0, 2, 2)),
        throwsAssertionError,
      );
      expect(
        () => _contour(['##', '##'], region: const Rect.fromLTWH(1, 1, 2, 1)),
        throwsAssertionError,
      );
    });

    test('counts only the pixels in the region, relative to it', () {
      final path = _contour([
        '#....',
        '...#.',
        '.....',
      ], region: const Rect.fromLTWH(2, 0, 3, 3));
      expect(path.contours, hasLength(1));
      expect(path.getBounds(), const Rect.fromLTRB(1, 1, 2, 2));
    });

    test('scales the region to the size', () {
      final path = _contour(
        ['....', '..#.'],
        region: const Rect.fromLTWH(2, 0, 2, 2),
        size: Vector2(20, 10),
      );
      expect(path.getBounds(), const Rect.fromLTRB(0, 5, 10, 10));
    });

    test('keeps the same outline at any size', () {
      final rows = [
        '......',
        '.##+..',
        '.####.',
        '.+##..',
        '......',
      ];
      final expected = _contour(rows);
      for (final size in [
        Vector2(6e-6, 5e-6),
        Vector2(6e-2, 5e-2),
        Vector2(6e3, 5e3),
        Vector2(6e-6, 5),
        Vector2(6e3, 5e-2),
      ]) {
        final actual = _contour(rows, size: size);
        expect(actual.contours, hasLength(1), reason: 'size $size');
        // Points every quarter of a pixel, which tell apart the outlines
        // that miss a corner, since the corners cut off half a pixel. They
        // are shifted so that none of them is on an edge.
        for (var y = 0.2; y < 5; y += 0.25) {
          for (var x = 0.1; x < 6; x += 0.25) {
            expect(
              actual.contains(Offset(x * size.x / 6, y * size.y / 5)),
              expected.contains(Offset(x, y)),
              reason: '($x, $y) at size $size',
            );
          }
        }
      }
    });
  });

  group('ImageExtension.contour', () {
    test('reads the pixels of the image', () async {
      final rows = ['....', '.##.', '..#.'];
      final image = await _image(rows);
      final path = await image.contour(size: Vector2(8, 6));
      expect(
        _vertices(path),
        _vertices(_contour(rows, size: Vector2(8, 6))),
      );
    });
  });

  group('Sprite.contour', () {
    test('follows the region of the sprite', () async {
      final image = await _image(['##..', '##.#']);
      final sprite = Sprite(
        image,
        srcPosition: Vector2(2, 0),
        srcSize: Vector2(2, 2),
      );
      final path = await sprite.contour(size: Vector2(4, 4));
      expect(path.contours, hasLength(1));
      expect(path.getBounds(), const Rect.fromLTRB(2, 2, 4, 4));
    });
  });

  group('hitboxes from the contour', () {
    test('a PolygonHitbox follows a concave outline', () {
      final path = _contour([
        '....',
        '.#..',
        '.#..',
        '.###',
      ]);
      final hitbox = PolygonHitbox.fromPath(path, sampling: 0.5);
      expect(hitbox.position, Vector2(1, 1));
      expect(hitbox.size, Vector2(3, 3));
      expect(hitbox.containsLocalPoint(Vector2(0.5, 0.5)), isTrue);
      expect(hitbox.containsLocalPoint(Vector2(2.5, 2.5)), isTrue);
      expect(hitbox.containsLocalPoint(Vector2(2, 1)), isFalse);
    });

    test('a PathHitbox covers every area', () {
      final path = _contour([
        '#..',
        '...',
        '..#',
      ]);
      final hitbox = PathHitbox(
        path: path,
        position: path.getBounds().topLeft.toVector2(),
      );
      expect(hitbox.polygons, hasLength(2));
      expect(hitbox.containsPoint(Vector2(0.5, 0.5)), isTrue);
      expect(hitbox.containsPoint(Vector2(2.5, 2.5)), isTrue);
      expect(hitbox.containsPoint(Vector2(1.5, 1.5)), isFalse);
    });
  });
}
