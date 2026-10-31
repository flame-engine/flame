import 'package:flame_studio/repositories/repositories.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComponentTree', () {
    const grandchild = RectangleComponent(name: 'rectangle3');
    const tree = RectangleComponent(
      name: 'Player',
      children: [
        RectangleComponent(name: 'rectangle1', children: [grandchild]),
        RectangleComponent(name: 'rectangle2'),
      ],
    );

    test('nodeAt follows the path from the root', () {
      expect(tree.nodeAt(const []), same(tree));
      expect(tree.nodeAt(const [1]).name, equals('rectangle2'));
      expect(tree.nodeAt(const [0, 0]), equals(grandchild));
      expect(() => tree.nodeAt(const [5]), throwsRangeError);
    });

    test('hasNodeAt tells whether the path exists', () {
      expect(tree.hasNodeAt(const []), isTrue);
      expect(tree.hasNodeAt(const [0, 0]), isTrue);
      expect(tree.hasNodeAt(const [0, 1]), isFalse);
      expect(tree.hasNodeAt(const [-1]), isFalse);
    });

    test('updateNodeAt replaces only the node at the path', () {
      const size = ComponentSize(width: 1);
      final updated = tree.updateNodeAt(const [
        0,
        0,
      ], (node) => (node as SizedComponent).copyWithSize(size));

      expect((updated.nodeAt(const [0, 0]) as SizedComponent).size, size);
      expect(updated.nodeAt(const [1]), equals(tree.nodeAt(const [1])));
      expect(updated.name, equals('Player'));
    });

    test('addChildAt appends a child to the node at the path', () {
      const child = RectangleComponent(name: 'rectangle4');
      final updated = tree.addChildAt(const [1], child);

      expect(updated.nodeAt(const [1]).children, equals([child]));
    });

    test('addChildAt throws when the node is a hitbox', () {
      const withHitbox = RectangleComponent(
        name: 'Player',
        children: [RectangleHitboxComponent(name: 'rectangleHitbox1')],
      );

      expect(
        () => withHitbox.addChildAt(const [
          0,
        ], const RectangleComponent(name: 'rectangle1')),
        throwsArgumentError,
      );
    });

    test('removeNodeAt removes the node and its children', () {
      final updated = tree.removeNodeAt(const [0]);

      expect(updated.children.map((c) => c.name), equals(['rectangle2']));
      expect(() => tree.removeNodeAt(const []), throwsArgumentError);
    });

    test('nodes lists the tree depth first', () {
      expect(
        tree.nodes.map((node) => node.name),
        equals(['Player', 'rectangle1', 'rectangle3', 'rectangle2']),
      );
    });

    test('usedPaletteColors lists the palette colors of every node', () {
      expect(tree.usedPaletteColors, isEmpty);
      expect(
        const RectangleComponent(
          name: 'Player',
          paint: ComponentPaint(paletteColor: 'primary'),
          children: [
            PositionComponent(
              name: 'body',
              children: [
                CircleComponent(
                  name: 'eye',
                  paint: ComponentPaint(paletteColor: 'accent'),
                ),
                RectangleComponent(
                  name: 'arm',
                  paint: ComponentPaint(paletteColor: 'primary'),
                ),
              ],
            ),
          ],
        ).usedPaletteColors,
        equals({'primary', 'accent'}),
      );
    });

    test('withPaletteColorsResolved sets the palette values as colors', () {
      const palette = Palette(
        colors: [PaletteColor(name: 'primary', color: 0xFF0000FF)],
      );
      final resolved = const RectangleComponent(
        name: 'Player',
        paint: ComponentPaint(color: 0xFF000000, paletteColor: 'primary'),
        children: [
          PositionComponent(
            name: 'body',
            children: [
              CircleComponent(
                name: 'eye',
                paint: ComponentPaint(paletteColor: 'primary'),
              ),
              RectangleComponent(
                name: 'arm',
                paint: ComponentPaint(color: 0xFF00FF00),
              ),
            ],
          ),
        ],
      ).withPaletteColorsResolved(palette);

      int colorAt(List<int> path) =>
          (resolved.nodeAt(path) as PaintedComponent).paint.color;
      expect(colorAt(const []), equals(0xFF0000FF));
      expect(colorAt(const [0, 0]), equals(0xFF0000FF));
      expect(colorAt(const [0, 1]), equals(0xFF00FF00));
      expect(tree.withPaletteColorsResolved(palette), equals(tree));
    });

    test('uniqueChildName picks the first name that is not taken', () {
      expect(
        tree.uniqueChildName(ComponentType.rectangle),
        equals('rectangle4'),
      );
      expect(
        const RectangleComponent(
          name: 'Player',
          children: [RectangleComponent(name: 'rectangle2')],
        ).uniqueChildName(ComponentType.rectangle),
        equals('rectangle1'),
      );
    });

    test('uniqueChildName ignores names that generate the same getter', () {
      expect(
        const RectangleComponent(
          name: 'Player',
          children: [RectangleComponent(name: 'Rectangle1')],
        ).uniqueChildName(ComponentType.rectangle),
        equals('rectangle2'),
      );
    });

    test('uniqueChildName skips names whose class is taken', () {
      expect(
        const RectangleComponent(name: 'Player').uniqueChildName(
          ComponentType.rectangle,
          takenClassNames: {r'$PlayerRectangle1', r'$PlayerRectangle2'},
        ),
        equals('rectangle3'),
      );
    });

    test('generatedClassName is the class of the root', () {
      expect(tree.generatedClassName, equals(r'$Player'));
    });

    test('generatedClassNames reserves a class for the root and every '
        'child', () {
      expect(
        tree.generatedClassNames,
        equals({
          r'$Player',
          r'$PlayerRectangle1',
          r'$PlayerRectangle3',
          r'$PlayerRectangle2',
        }),
      );
    });

    group('validateChildName', () {
      test('accepts a free name, and the current name of the node', () {
        expect(tree.validateChildName(const [0], 'head'), isNull);
        expect(tree.validateChildName(const [0], 'rectangle1'), isNull);
        expect(tree.validateChildName(const [0, 0], 'left_arm'), isNull);
      });

      for (final name in ['', '1head', 'my head', 'class', '_', 'a-b']) {
        test('rejects "$name" as invalid', () {
          expect(
            tree.validateChildName(const [0], name),
            equals(ChildNameError.invalid),
          );
        });
      }

      for (final name in ['size', 'Position', 'paint', 'children', 'parent']) {
        test('rejects "$name" as reserved', () {
          expect(
            tree.validateChildName(const [0], name),
            equals(ChildNameError.reserved),
          );
        });
      }

      test('accepts the members of other Flame classes', () {
        const container = PositionComponent(
          name: 'Player',
          children: [RectangleComponent(name: 'rectangle1')],
        );
        expect(container.validateChildName(const [0], 'paint'), isNull);
        expect(
          container.validateChildName(const [0], 'size'),
          equals(ChildNameError.reserved),
        );
      });

      for (final name in ['rectangle2', 'Rectangle3', 'player']) {
        test('rejects "$name" as duplicate', () {
          expect(
            tree.validateChildName(const [0], name),
            equals(ChildNameError.duplicate),
          );
        });
      }

      for (final name in ['ship_head', 'shipHead', 'ShipHead']) {
        test('rejects "$name" when its class is taken', () {
          expect(
            tree.validateChildName(
              const [0],
              name,
              takenClassNames: {r'$PlayerShipHead'},
            ),
            equals(ChildNameError.conflict),
          );
        });
      }

      test('throws for the root', () {
        expect(
          () => tree.validateChildName(const [], 'head'),
          throwsArgumentError,
        );
      });
    });
  });
}
