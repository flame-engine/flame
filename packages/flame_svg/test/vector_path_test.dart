import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_svg/vector_paint.dart';
import 'package:flame_svg/vector_path.dart';
import 'package:flutter_test/flutter_test.dart';

Paint _fill(int color) => Paint()
  ..style = PaintingStyle.fill
  ..color = Color(color);

Paint _stroke(int color, [double width = 4]) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..color = Color(color);

VectorPaint get _filled => VectorPaint(fill: _fill(0xffff0000));
VectorPaint get _stroked => VectorPaint(stroke: _stroke(0xff0000ff));

/// A closed square.
Path _square(double left, double top, double size) =>
    Path()..addRect(Rect.fromLTWH(left, top, size, size));

/// An open triangle, which a fill closes implicitly.
Path _openTriangle(double left, double top, double size) => Path()
  ..moveTo(left, top)
  ..lineTo(left + size, top)
  ..lineTo(left + size, top + size);

Future<ByteData> _render(
  WidgetTester tester,
  VectorPath path, [
  VectorPaint? overridePaint,
]) async {
  return (await tester.runAsync(() async {
    final recorder = PictureRecorder();
    path.render(Canvas(recorder), overridePaint);
    final image = await recorder.endRecording().toImage(100, 100);
    return await image.toByteData();
  }))!;
}

int _alphaAt(ByteData data, int x, int y) {
  return data.getUint8((y * 100 + x) * 4 + 3);
}

void main() {
  group('VectorPath', () {
    test('keeps its path and paint', () {
      final path = _square(0, 0, 10);
      final paint = _filled;
      final vectorPath = VectorPath(path, paint);
      expect(vectorPath.path, path);
      expect(vectorPath.paint, paint);
    });

    test('needs a fill or a stroke', () {
      expect(
        () => VectorPath(_square(0, 0, 10), const VectorPaint()),
        throwsA(isA<Error>()),
      );
    });

    group('equality', () {
      test('is by paint and path', () {
        // Both are compared by identity.
        final paint = _filled;
        final path = _square(0, 0, 10);
        final a = VectorPath(path, paint);
        final b = VectorPath(path, paint);
        expect(a, b);
        expect(a.hashCode, b.hashCode);
      });

      test('differs with another path, even with the same contours', () {
        final paint = _filled;
        final a = VectorPath(_square(0, 0, 10), paint);
        final b = VectorPath(_square(50, 50, 20), paint);
        expect(a, isNot(b));
      });

      test('works in sets', () {
        final paint = _filled;
        final path = _square(0, 0, 10);
        final other = VectorPath(_square(50, 50, 20), paint);
        final set = {VectorPath(path, paint), VectorPath(path, paint), other};
        expect(set.length, 2);
      });

      test('differs with another paint', () {
        final path = _square(0, 0, 10);
        expect(
          VectorPath(path, _filled),
          isNot(VectorPath(path, VectorPaint(fill: _fill(0xff00ff00)))),
        );
        expect(VectorPath(path, _filled), isNot('not a path'));
      });
    });

    test('toString has the paint', () {
      final paint = _filled;
      expect(
        VectorPath(_square(0, 0, 10), paint).toString(),
        'VectorPath(paint: $paint)',
      );
    });

    group('render', () {
      testWidgets('fills a closed path', (tester) async {
        final data = await _render(
          tester,
          VectorPath(_square(10, 10, 50), _filled),
        );
        expect(_alphaAt(data, 30, 30), 255);
        expect(_alphaAt(data, 80, 80), 0);
      });

      testWidgets('fills an open contour as if it were closed', (tester) async {
        final data = await _render(
          tester,
          VectorPath(_openTriangle(10, 10, 50), _filled),
        );
        // Inside of the triangle, but not above its diagonal.
        expect(_alphaAt(data, 50, 20), 255);
        expect(_alphaAt(data, 20, 50), 0);
      });

      testWidgets('fills all the open contours of a path', (tester) async {
        final path = _square(0, 0, 10)
          ..addPath(_openTriangle(20, 0, 30), Offset.zero)
          ..addPath(_openTriangle(60, 0, 30), Offset.zero);
        final data = await _render(tester, VectorPath(path, _filled));
        expect(_alphaAt(data, 45, 10), 255);
        expect(_alphaAt(data, 85, 10), 255);
      });

      testWidgets('strokes an open contour without closing it', (tester) async {
        final path = Path()
          ..moveTo(10, 50)
          ..lineTo(90, 50);
        final data = await _render(tester, VectorPath(path, _stroked));
        expect(_alphaAt(data, 50, 50), 255);
        expect(_alphaAt(data, 50, 20), 0);
      });

      testWidgets('strokes the closed contours of a filled path', (
        tester,
      ) async {
        final paint = VectorPaint(
          fill: _fill(0xffff0000),
          stroke: _stroke(0xff0000ff, 10),
        );
        final data = await _render(
          tester,
          VectorPath(_square(30, 30, 40), paint),
        );
        // The stroke is centered on the edge, so it covers both sides of it.
        expect(_alphaAt(data, 50, 50), 255);
        expect(_alphaAt(data, 27, 50), 255);
        expect(_alphaAt(data, 10, 50), 0);
      });

      testWidgets('can use another paint', (tester) async {
        final vectorPath = VectorPath(_square(10, 10, 50), _filled);
        final data = await _render(
          tester,
          vectorPath,
          VectorPaint(stroke: _stroke(0xff00ff00, 2)),
        );
        // Only the stroke of the other paint is drawn.
        expect(_alphaAt(data, 30, 30), 0);
        expect(_alphaAt(data, 10, 30), 255);
      });
    });
  });
}
