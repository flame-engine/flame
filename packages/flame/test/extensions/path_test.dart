import 'package:flame/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('walkContours', () {
    test('every contour is walked', () {
      final path = Path()
        ..addRect(const Rect.fromLTWH(0, 0, 10, 10))
        ..addRect(const Rect.fromLTWH(20, 20, 5, 5));
      final contours = path.walkContours();
      expect(contours, hasLength(2));
      expect(contours[1].first, const Offset(20, 20));
      expect(Path().walkContours(), isEmpty);
    });

    test('an invalid granularity is rejected', () {
      final path = Path()..addRect(const Rect.fromLTWH(0, 0, 10, 10));
      for (final granularity in [0.0, -5.0, double.nan, double.infinity]) {
        expect(
          () => path.walkContours(granularity),
          throwsA(isA<AssertionError>()),
        );
      }
    });
  });
}
