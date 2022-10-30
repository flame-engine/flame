import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HasPaint', () {
    test('paint returns the default paint', () {
      final component = _MyComponent();

      expect(component.paint, component.getPaint());
    });

    test(
      'paint setter sets the main paint',
      () {
        final component = _MyComponent();

        const color = Color(0xFFE5E5E5);
        component.paint = Paint()..color = color;

        expect(component.getPaint().color, color);
      },
    );

    test('paintLayers defaults to empty list', () {
      final component = _MyComponent();

      const color = Color(0xFFE5E5E5);
      component.paint = Paint()..color = color;

      expect(
        component.paintLayers,
        equals(<Paint>[]),
      );
    });

    test('paintLayers returns correct colors', () {
      const firstColor = Color(0xFFE5E5E5);
      const secondColor = Color(0xFF123456);
      const thirdColor = Color(0xFFABABAB);
      final firstPaint = Paint()..color = firstColor;
      final secondPaint = Paint()..color = secondColor;
      final thirdPaint = Paint()..color = thirdColor;

      final circle = CircleComponent(
        radius: 10,
        paint: firstPaint,
        paintLayers: [secondPaint, thirdPaint],
      );

      expect(
        circle.paintLayers,
        equals([secondPaint, thirdPaint]),
      );
      expect(
        circle.paint,
        equals(firstPaint),
      );
    });

    test('can clear paintLayers', () {
      const firstColor = Color(0xFFE5E5E5);
      const secondColor = Color(0xFF123456);
      const thirdColor = Color(0xFFABABAB);
      final firstPaint = Paint()..color = firstColor;
      final secondPaint = Paint()..color = secondColor;
      final thirdPaint = Paint()..color = thirdColor;

      final circle = CircleComponent(
        radius: 10,
        paint: firstPaint,
        paintLayers: [secondPaint, thirdPaint],
      );

      circle.paintLayers.clear();

      expect(
        circle.paintLayers,
        equals(<Paint>[]),
      );
      expect(
        circle.paint,
        equals(firstPaint),
      );
    });

    test(
      'getPaint throws exception when retrieving a paint that does not exist',
      () {
        final component = _MyComponentWithType();

        expect(
          () => component.getPaint(_MyComponentKeys.background),
          throwsArgumentError,
        );
      },
    );

    test(
      'setPaint sets a paint',
      () {
        final component = _MyComponentWithType();

        const color = Color(0xFFA9A9A9);
        component.setPaint(_MyComponentKeys.background, Paint()..color = color);

        expect(
          component.getPaint(_MyComponentKeys.background).color,
          equals(color),
        );
      },
    );

    test(
      'deletePaint removes a paint from the map',
      () {
        final component = _MyComponentWithType();

        component.setPaint(_MyComponentKeys.foreground, Paint());
        component.deletePaint(_MyComponentKeys.foreground);

        expect(
          () => component.getPaint(_MyComponentKeys.foreground),
          throwsArgumentError,
        );
      },
    );

    test(
      'append paint to paintLayers',
      () {
        final component = _MyComponent();

        const color = Color(0xFFE5E5E5);
        component.paintLayers.add(Paint()..color = color);

        expect(component.paintLayers[0].color, equals(color));
      },
    );

    test(
      'use setPaintLayers to set multiple paintIds in paintLayers',
      () {
        final component = _MyComponent();

        const color = Color(0xFFE5E5E5);
        const anotherColor = Color(0xFFABABAB);
        const thirdColor = Color(0xFF123456);
        component.setPaint('test', Paint()..color = color);
        component.setPaint('anotherTest', Paint()..color = anotherColor);
        component.setPaint('thirdTest', Paint()..color = thirdColor);

        component.paintLayers = [
          component.getPaint('thirdTest'),
          component.getPaint('test'),
        ];

        expect(
          (component.paintLayers[0].color == thirdColor) &&
              (component.paintLayers[1].color == color),
          isTrue,
        );
      },
    );

    test(
      'makeTransparent sets opacity to 0 on the main when paintId is omitted',
      () {
        final component = _MyComponent();
        component.makeTransparent();

        expect(component.paint.color.opacity, 0);
      },
    );

    test(
      'makeTransparent sets opacity to 0 on informed paintId',
      () {
        final component = _MyComponentWithType();
        component.setPaint(_MyComponentKeys.background, Paint());
        component.makeTransparent(paintId: _MyComponentKeys.background);

        expect(
          component.getPaint(_MyComponentKeys.background).color.opacity,
          0,
        );
      },
    );

    test(
      'makeOpaque sets opacity to 1 on the main when paintId is omitted',
      () {
        final component = _MyComponent();
        component.makeTransparent();
        component.makeOpaque();

        expect(component.paint.color.opacity, 1);
      },
    );

    test(
      'makeOpaque sets opacity to 1 on informed paintId',
      () {
        final component = _MyComponentWithType();
        component.setPaint(
          _MyComponentKeys.background,
          Paint()..color = const Color(0x00E5E5E5),
        );
        component.makeOpaque(paintId: _MyComponentKeys.background);

        expect(
          component.getPaint(_MyComponentKeys.background).color.opacity,
          1,
        );
      },
    );

    test(
      'setOpacity sets opacity of the main when paintId is omitted',
      () {
        final component = _MyComponent();
        component.setOpacity(0.2);

        expect(component.paint.color.opacity, 0.2);
      },
    );

    test(
      'setOpacity sets opacity of the informed paintId',
      () {
        final component = _MyComponentWithType();
        component.setPaint(_MyComponentKeys.background, Paint());
        component.setOpacity(0.2, paintId: _MyComponentKeys.background);

        expect(
          component.getPaint(_MyComponentKeys.background).color.opacity,
          0.2,
        );
      },
    );

    test(
      'throws error if opacity is less than 0',
      () {
        final component = _MyComponent();

        expect(
          () => component.setOpacity(-0.5),
          throwsArgumentError,
        );
      },
    );

    test(
      'throws error if opacity is greater than 1',
      () {
        final component = _MyComponent();

        expect(
          () => component.setOpacity(1.1),
          throwsArgumentError,
        );
      },
    );

    test(
      'setColor sets color of the main when paintId is omitted',
      () {
        final component = _MyComponent();
        const color = Color(0xFFE5E5E5);
        component.setColor(color);

        expect(component.paint.color, color);
      },
    );

    test(
      'setOpacity sets opacity of the informed paintId',
      () {
        final component = _MyComponentWithType();
        const color = Color(0xFFE5E5E5);
        component.setPaint(_MyComponentKeys.background, Paint());
        component.setColor(color, paintId: _MyComponentKeys.background);

        expect(component.getPaint(_MyComponentKeys.background).color, color);
      },
    );

    test(
      'tint sets the correct color filter of the main when paintId is omitted',
      () {
        final component = _MyComponent();
        const color = Color(0xFFE5E5E5);
        component.tint(color);

        expect(
          component.paint.colorFilter,
          const ColorFilter.mode(color, BlendMode.srcATop),
        );
      },
    );

    test(
      'setOpacity sets opacity of the informed paintId',
      () {
        final component = _MyComponentWithType();
        const color = Color(0xFFE5E5E5);
        component.setPaint(_MyComponentKeys.background, Paint());
        component.tint(color, paintId: _MyComponentKeys.background);

        expect(
          component.getPaint(_MyComponentKeys.background).colorFilter,
          const ColorFilter.mode(color, BlendMode.srcATop),
        );
      },
    );
  });
}

class _MyComponent extends PositionComponent with HasPaint {}

enum _MyComponentKeys {
  background,
  foreground,
}

class _MyComponentWithType extends PositionComponent
    with HasPaint<_MyComponentKeys> {}
