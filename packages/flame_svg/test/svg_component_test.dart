import 'package:flame_svg/flame_svg.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class MockSvg extends Mock implements Svg {}

void main() {
  group('SvgComponent', () {
    late Svg svg;

    setUp(() {
      svg = MockSvg();
      when(svg.dispose).thenAnswer((_) {});
    });

    test('disposes the svg instance when it is removed', () {
      final component = SvgComponent(svg: svg);
      component.onRemove();

      verify(svg.dispose).called(1);
    });

    test('disposes the old svg instance when a new one is received', () {
      final component = SvgComponent(svg: svg);

      final newSvg = MockSvg();
      component.svg = newSvg;

      verify(svg.dispose).called(1);
    });
  });
}
