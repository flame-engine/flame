import 'dart:typed_data';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
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
      var area = 0.0;
      for (var i = 0; i < vertices.length; i++) {
        final a = vertices[i];
        final b = vertices[(i + 1) % vertices.length];
        area += a.dx * b.dy - b.dx * a.dy;
      }
      expect(area, greaterThan(0));
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
      final low = _contour(['#+'], alphaThreshold: 0.25).getBounds();
      expect(low.right, closeTo(1.5 + 1 - 0.25 / (128 / 255), 0.001));
      final high = _contour(['#+'], alphaThreshold: 0.75).getBounds();
      expect(high.right, closeTo(0.5 + 0.25 / (127 / 255), 0.001));
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
