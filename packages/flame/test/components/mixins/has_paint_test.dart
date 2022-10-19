import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HasPaint', () {
    test('paint returns the default paint', () {
      final comp = _MyComponent();

      expect(comp.paint, comp.getPaint());
    });

    test(
      'paint setter sets the main paint',
      () {
        final comp = _MyComponent();

        const color = Color(0xFFE5E5E5);
        comp.paint = Paint()..color = color;

        expect(comp.getPaint().color, color);
      },
    );

    test(
      'getPaint throws exception when retrieving a paint that does not exist',
      () {
        final comp = _MyComponentWithType();

        expect(
          () => comp.getPaint(_MyComponentKeys.background),
          throwsArgumentError,
        );
      },
    );

    test(
      'setPaint sets a paint',
      () {
        final comp = _MyComponentWithType();

        const color = Color(0xFFA9A9A9);
        comp.setPaint(_MyComponentKeys.background, Paint()..color = color);

        expect(comp.getPaint(_MyComponentKeys.background).color, color);
      },
    );

    test(
      'deletePaint removes a paint from the map',
      () {
        final comp = _MyComponentWithType();

        comp.setPaint(_MyComponentKeys.foreground, Paint());
        comp.deletePaint(_MyComponentKeys.foreground);

        expect(
          () => comp.getPaint(_MyComponentKeys.foreground),
          throwsArgumentError,
        );
      },
    );

    test('paintLayers set to default', () {
      final comp = _MyComponent();

      expect(
        (comp.paintLayers.length == 1) &&
            (comp.paintLayers[0] == comp.getPaint()),
        true,
      );
    });

    test(
      'append paint to paintLayers',
      () {
        final comp = _MyComponent();

        const color = Color(0xFFE5E5E5);
        comp.paintLayers.add(Paint()..color = color);

        expect(comp.paintLayers[1].color, color);
      },
    );

    test(
      'append paint to paintLayers using addPaintLayer',
      () {
        final comp = _MyComponent();

        const color = Color(0xFFE5E5E5);
        const anotherColor = Color(0xFFABABAB);
        comp.setPaint('test', Paint()..color = color, updatePaintLayers: false);
        comp.setPaint(
          'anotherTest',
          Paint()..color = anotherColor,
          updatePaintLayers: false,
        );
        comp.addPaintLayer('test');

        expect(comp.paintLayers[1].color, color);
      },
    );

    test(
      'setPaint appends paint to paintLayers by default',
      () {
        final comp = _MyComponent();

        const color = Color(0xFFE5E5E5);
        comp.setPaint('test', Paint()..color = color);

        expect(comp.paintLayers[1].color, color);
      },
    );

    test(
      'setPaint does not append paint to paintLayers when updatePaintLayers '
      'is false',
      () {
        final comp = _MyComponent();

        const color = Color(0xFFE5E5E5);
        comp.setPaint('test', Paint()..color = color, updatePaintLayers: false);

        expect(comp.paintLayers.length, 1);
      },
    );

    test(
      'deletePaint deletes paint from paintLayers by default',
      () {
        final comp = _MyComponent();

        const color = Color(0xFFE5E5E5);
        comp.setPaint('test', Paint()..color = color);
        comp.deletePaint('test');

        expect(comp.paintLayers.length, 1);
      },
    );

    test(
      'deletePaint does not delete paint from paintLayers when '
      'updatePaintLayers is false',
      () {
        final comp = _MyComponent();

        const color = Color(0xFFE5E5E5);
        comp.setPaint('test', Paint()..color = color);
        comp.deletePaint('test', updatePaintLayers: false);

        expect(comp.paintLayers[1].color, color);
      },
    );

    test(
      'delete paint from paintLayers using removePaintIdFromLayers',
      () {
        final comp = _MyComponent();

        const color = Color(0xFFE5E5E5);
        const anotherColor = Color(0xFFABABAB);
        const thirdColor = Color(0xFF123456);
        comp.setPaint('test', Paint()..color = color);
        comp.setPaint('anotherTest', Paint()..color = anotherColor);
        comp.setPaint('thirdTest', Paint()..color = thirdColor);
        comp.removePaintIdFromLayers('anotherTest');

        expect(comp.paintLayers[2].color, thirdColor);
      },
    );

    test(
      'use setPaintLayers to set mutliple paintIds in paintLayers',
      () {
        final comp = _MyComponent();

        const color = Color(0xFFE5E5E5);
        const anotherColor = Color(0xFFABABAB);
        const thirdColor = Color(0xFF123456);
        comp.setPaint(
          'test',
          Paint()..color = color,
          updatePaintLayers: false,
        );
        comp.setPaint(
          'anotherTest',
          Paint()..color = anotherColor,
          updatePaintLayers: false,
        );
        comp.setPaint(
          'thirdTest',
          Paint()..color = thirdColor,
          updatePaintLayers: false,
        );

        comp.setPaintLayers(['thirdTest', 'test']);

        expect(
          (comp.paintLayers[0].color == thirdColor) &&
              (comp.paintLayers[1].color == color),
          true,
        );
      },
    );

    test(
      'setPaintLayers throws exception if unrecognised paintId',
      () {
        final comp = _MyComponent();

        const color = Color(0xFFE5E5E5);
        comp.setPaint('test', Paint()..color = color);
        comp.setPaint('anotherTest', Paint()..color = color);
        comp.setPaint('thirdTest', Paint()..color = color);

        expect(
          () => comp.setPaintLayers(['thirdTest', 'wrong']),
          throwsArgumentError,
        );
      },
    );

    test(
      'makeTransparent sets opacity to 0 on the main when paintId is omitted',
      () {
        final comp = _MyComponent();
        comp.makeTransparent();

        expect(comp.paint.color.opacity, 0);
      },
    );

    test(
      'makeTransparent sets opacity to 0 on informed paintId',
      () {
        final comp = _MyComponentWithType();
        comp.setPaint(_MyComponentKeys.background, Paint());
        comp.makeTransparent(paintId: _MyComponentKeys.background);

        expect(comp.getPaint(_MyComponentKeys.background).color.opacity, 0);
      },
    );

    test(
      'makeOpaque sets opacity to 1 on the main when paintId is omitted',
      () {
        final comp = _MyComponent();
        comp.makeTransparent();
        comp.makeOpaque();

        expect(comp.paint.color.opacity, 1);
      },
    );

    test(
      'makeOpaque sets opacity to 1 on informed paintId',
      () {
        final comp = _MyComponentWithType();
        comp.setPaint(
          _MyComponentKeys.background,
          Paint()..color = const Color(0x00E5E5E5),
        );
        comp.makeOpaque(paintId: _MyComponentKeys.background);

        expect(comp.getPaint(_MyComponentKeys.background).color.opacity, 1);
      },
    );

    test(
      'setOpacity sets opacity of the main when paintId is omitted',
      () {
        final comp = _MyComponent();
        comp.setOpacity(0.2);

        expect(comp.paint.color.opacity, 0.2);
      },
    );

    test(
      'setOpacity sets opacity of the informed paintId',
      () {
        final comp = _MyComponentWithType();
        comp.setPaint(_MyComponentKeys.background, Paint());
        comp.setOpacity(0.2, paintId: _MyComponentKeys.background);

        expect(comp.getPaint(_MyComponentKeys.background).color.opacity, 0.2);
      },
    );

    test(
      'throws error if opacity is less than 0',
      () {
        final comp = _MyComponent();

        expect(
          () => comp.setOpacity(-0.5),
          throwsArgumentError,
        );
      },
    );

    test(
      'throws error if opacity is greater than 1',
      () {
        final comp = _MyComponent();

        expect(
          () => comp.setOpacity(1.1),
          throwsArgumentError,
        );
      },
    );

    test(
      'setColor sets color of the main when paintId is omitted',
      () {
        final comp = _MyComponent();
        const color = Color(0xFFE5E5E5);
        comp.setColor(color);

        expect(comp.paint.color, color);
      },
    );

    test(
      'setOpacity sets opacity of the informed paintId',
      () {
        final comp = _MyComponentWithType();
        const color = Color(0xFFE5E5E5);
        comp.setPaint(_MyComponentKeys.background, Paint());
        comp.setColor(color, paintId: _MyComponentKeys.background);

        expect(comp.getPaint(_MyComponentKeys.background).color, color);
      },
    );

    test(
      'tint sets the correct color filter of the main when paintId is omitted',
      () {
        final comp = _MyComponent();
        const color = Color(0xFFE5E5E5);
        comp.tint(color);

        expect(
          comp.paint.colorFilter,
          const ColorFilter.mode(color, BlendMode.srcATop),
        );
      },
    );

    test(
      'setOpacity sets opacity of the informed paintId',
      () {
        final comp = _MyComponentWithType();
        const color = Color(0xFFE5E5E5);
        comp.setPaint(_MyComponentKeys.background, Paint());
        comp.tint(color, paintId: _MyComponentKeys.background);

        expect(
          comp.getPaint(_MyComponentKeys.background).colorFilter,
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
