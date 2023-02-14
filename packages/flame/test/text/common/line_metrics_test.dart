import 'package:flame/src/text/common/line_metrics.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('LineMetrics', () {
    test('default LineMetrics box', () {
      final box = LineMetrics(left: 10, baseline: 20);
      expect(box.left, 10);
      expect(box.right, 10);
      expect(box.width, 0);
      expect(box.baseline, 20);
      expect(box.top, 20);
      expect(box.bottom, 20);
      expect(box.ascent, 0);
      expect(box.descent, 0);
      expect(box.height, 0);
    });

    test('with height only', () {
      final box = LineMetrics(baseline: 15, height: 10);
      expect(box.baseline, 15);
      expect(box.height, 10);
      expect(box.top, 15 - 10);
      expect(box.bottom, 15);
      expect(box.ascent, 10);
      expect(box.descent, 0);
    });

    test('with height and ascent', () {
      final box = LineMetrics(baseline: 15, height: 10, ascent: 8);
      expect(box.baseline, 15);
      expect(box.height, 10);
      expect(box.top, 15 - 8);
      expect(box.bottom, 15 - 8 + 10);
      expect(box.ascent, 8);
      expect(box.descent, 10 - 8);
    });

    test('with height and descent', () {
      final box = LineMetrics(baseline: 15, height: 10, descent: 3);
      expect(box.baseline, 15);
      expect(box.height, 10);
      expect(box.top, 15 + 3 - 10);
      expect(box.bottom, 15 + 3);
      expect(box.ascent, 10 - 3);
      expect(box.descent, 3);
    });

    test('with ascent and descent', () {
      final box = LineMetrics(baseline: 15, ascent: 10, descent: 3);
      expect(box.baseline, 15);
      expect(box.height, 10 + 3);
      expect(box.top, 15 - 10);
      expect(box.bottom, 15 + 3);
      expect(box.ascent, 10);
      expect(box.descent, 3);
    });

    test('translate', () {
      final box = LineMetrics(width: 40, descent: 2, ascent: 8);
      expect(box.left, 0);
      expect(box.baseline, 0);
      box.translate(5, 11);
      expect(box.left, 5);
      expect(box.baseline, 11);
      expect(box.width, 40);
      expect(box.height, 10);
      expect(box.ascent, 8);
      box.translate(-1, -1);
      expect(box.left, 4);
      expect(box.baseline, 10);
    });

    test('moveToOrigin', () {
      final box = LineMetrics(left: 33, baseline: 78, ascent: 8, descent: 2);
      box.moveToOrigin();
      expect(box.left, 0);
      expect(box.baseline, 0);
      expect(box.top, -8);
      expect(box.bottom, 2);
    });

    test('setLeftEdge', () {
      final box = LineMetrics(left: 33, baseline: 78, width: 101);
      expect(box.right, 33 + 101);
      box.setLeftEdge(49);
      expect(box.right, 33 + 101);
      expect(box.left, 49);
    });

    test('append', () {
      final box1 = LineMetrics(left: 4, width: 10, baseline: 17, height: 6);
      final box2 = LineMetrics(
        left: 18,
        width: 40,
        baseline: 17,
        ascent: 8,
        descent: 2,
      );
      box1.append(box2);
      expect(box1.left, 4);
      expect(box1.right, 18 + 40);
      expect(box1.top, 17 - 8);
      expect(box1.bottom, 17 + 2);

      expect(
        () => box1.append(LineMetrics()),
        failsAssert('Baselines do not match: 17.0 vs 0.0'),
      );
    });

    test('toString', () {
      final box = LineMetrics(left: 33, baseline: 78, width: 101, height: 11);
      expect(
        box.toString(),
        'LineMetrics(left: 33.0, baseline: 78.0, width: 101.0, ascent: 11.0, '
        'descent: 0.0)',
      );
    });
  });
}
