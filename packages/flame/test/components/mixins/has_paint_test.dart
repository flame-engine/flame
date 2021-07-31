import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

class MyComponent extends PositionComponent with HasPaint {}

enum MyComponentKeys {
  background,
  foreground,
}

class MyComponentWithType extends PositionComponent
    with HasPaint<MyComponentKeys> {}

void main() {
  group('Components - HasPaint', () {
    test('paint returns the default paint', () {
      final comp = MyComponent();

      expect(comp.paint, comp.getPaint());
    });

    test(
      'paint setter sets the main paint',
      () {
        final comp = MyComponent();

        const color = Color(0xFFE5E5E5);
        comp.paint = Paint()..color = color;

        expect(comp.getPaint().color, color);
      },
    );

    test(
      'getPaint throws exception when retrieving a paint that does not exists',
      () {
        final comp = MyComponentWithType();

        expect(
          () => comp.getPaint(MyComponentKeys.background),
          throwsArgumentError,
        );
      },
    );

    test(
      'getPaint throws exception when used on genericless component',
      () {
        final comp = MyComponent();

        expect(
          () => comp.getPaint(MyComponentKeys.background),
          throwsAssertionError,
        );
      },
    );

    test(
      'setPaint sets a paint',
      () {
        final comp = MyComponentWithType();

        const color = Color(0xFFA9A9A9);
        comp.setPaint(MyComponentKeys.background, Paint()..color = color);

        expect(comp.getPaint(MyComponentKeys.background).color, color);
      },
    );

    test(
      'setPaint throws exception when used on genericless component',
      () {
        final comp = MyComponent();

        const color = Color(0xFFA9A9A9);
        expect(
          () => comp.setPaint(
            MyComponentKeys.background,
            Paint()..color = color,
          ),
          throwsAssertionError,
        );
      },
    );

    test(
      'deletePaint removes a paint from the map',
      () {
        final comp = MyComponentWithType();

        comp.setPaint(MyComponentKeys.background, Paint());
        comp.deletePaint(MyComponentKeys.background);

        expect(
          () => comp.getPaint(MyComponentKeys.background),
          throwsArgumentError,
        );
      },
    );

    test(
      'deletePaint throws exception when used on genericless component',
      () {
        final comp = MyComponent();

        expect(
          () => comp.deletePaint(MyComponentKeys.background),
          throwsAssertionError,
        );
      },
    );

    test(
      'makeTransparent sets opacity to 0 on the main when paintId is omitted',
      () {
        final comp = MyComponent();
        comp.makeTransparent();

        expect(comp.paint.color.opacity, 0);
      },
    );

    test(
      'makeTransparent sets opacity to 0 on informed paintId',
      () {
        final comp = MyComponentWithType();
        comp.setPaint(MyComponentKeys.background, Paint());
        comp.makeTransparent(paintId: MyComponentKeys.background);

        expect(comp.getPaint(MyComponentKeys.background).color.opacity, 0);
      },
    );

    test(
      'makeOpaque sets opacity to 1 on the main when paintId is omitted',
      () {
        final comp = MyComponent();
        comp.makeTransparent();
        comp.makeOpaque();

        expect(comp.paint.color.opacity, 1);
      },
    );

    test(
      'makeOpaque sets opacity to 1 on informed paintId',
      () {
        final comp = MyComponentWithType();
        comp.setPaint(
          MyComponentKeys.background,
          Paint()..color = const Color(0x00E5E5E5),
        );
        comp.makeOpaque(paintId: MyComponentKeys.background);

        expect(comp.getPaint(MyComponentKeys.background).color.opacity, 1);
      },
    );

    test(
      'setOpacity sets opacity of the main when paintId is omitted',
      () {
        final comp = MyComponent();
        comp.setOpacity(0.2);

        expect(comp.paint.color.opacity, 0.2);
      },
    );

    test(
      'setOpacity sets opacity of the informed paintId',
      () {
        final comp = MyComponentWithType();
        comp.setPaint(MyComponentKeys.background, Paint());
        comp.setOpacity(0.2, paintId: MyComponentKeys.background);

        expect(comp.getPaint(MyComponentKeys.background).color.opacity, 0.2);
      },
    );

    test(
      'throws error if opacity is less than 0',
      () {
        final comp = MyComponent();

        expect(
          () => comp.setOpacity(-0.5),
          throwsArgumentError,
        );
      },
    );

    test(
      'throws error if opacity is greater than 1',
      () {
        final comp = MyComponent();

        expect(
          () => comp.setOpacity(1.1),
          throwsArgumentError,
        );
      },
    );

    test(
      'setColor sets color of the main when paintId is omitted',
      () {
        final comp = MyComponent();
        const color = Color(0xFFE5E5E5);
        comp.setColor(color);

        expect(comp.paint.color, color);
      },
    );

    test(
      'setOpacity sets opacity of the informed paintId',
      () {
        final comp = MyComponentWithType();
        const color = Color(0xFFE5E5E5);
        comp.setPaint(MyComponentKeys.background, Paint());
        comp.setColor(color, paintId: MyComponentKeys.background);

        expect(comp.getPaint(MyComponentKeys.background).color, color);
      },
    );

    test(
      'tint sets the correct color filter of the main when paintId is omitted',
      () {
        final comp = MyComponent();
        const color = Color(0xFFE5E5E5);
        comp.tint(color);

        expect(
          comp.paint.colorFilter,
          const ColorFilter.mode(color, BlendMode.multiply),
        );
      },
    );

    test(
      'setOpacity sets opacity of the informed paintId',
      () {
        final comp = MyComponentWithType();
        const color = Color(0xFFE5E5E5);
        comp.setPaint(MyComponentKeys.background, Paint());
        comp.tint(color, paintId: MyComponentKeys.background);

        expect(
          comp.getPaint(MyComponentKeys.background).colorFilter,
          const ColorFilter.mode(color, BlendMode.multiply),
        );
      },
    );
  });
}
