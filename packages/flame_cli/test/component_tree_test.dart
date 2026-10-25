import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

ComponentNode _node(
  int id,
  String name, {
  ComponentAttributes attributes = const ComponentAttributes(),
  List<ComponentNode> children = const [],
}) {
  return ComponentNode(
    id: id,
    name: name,
    toStringText: '$name()',
    isPositionComponent: attributes.position != null,
    attributes: attributes,
    children: children,
  );
}

final _tree = _node(
  1,
  'MyGame',
  children: [
    _node(
      2,
      'World',
      children: [
        _node(
          3,
          'Player',
          attributes: const ComponentAttributes(
            priority: 2,
            position: (x: 10, y: 20.5),
            size: (x: 32, y: 32),
            angle: 0,
            scale: (x: 1, y: 1),
            anchor: 'center',
          ),
        ),
      ],
    ),
    _node(4, 'CameraComponent'),
  ],
);

void main() {
  group('formatComponentTree', () {
    test('indents children by depth and shows non-default attributes', () {
      expect(
        formatComponentTree(_tree),
        'MyGame (id: 1)\n'
        '  World (id: 2)\n'
        '    Player (id: 3) position 10,20.50, size 32,32, anchor center, '
        'priority 2\n'
        '  CameraComponent (id: 4)\n',
      );
    });

    test('limits the depth', () {
      expect(
        formatComponentTree(_tree, maxDepth: 1),
        'MyGame (id: 1)\n'
        '  World (id: 2)\n'
        '  CameraComponent (id: 4)\n',
      );
    });
  });

  group('formatAttributes', () {
    test('leaves out default values', () {
      expect(formatAttributes(const ComponentAttributes(priority: 0)), '');
      expect(
        formatAttributes(
          const ComponentAttributes(
            priority: 0,
            position: (x: 0, y: 0),
            size: (x: 1, y: 2),
            angle: 0,
            scale: (x: 1, y: 1),
            anchor: 'topLeft',
          ),
        ),
        'position 0,0, size 1,2',
      );
    });

    test('shows angle and scale when they are not the default', () {
      expect(
        formatAttributes(
          const ComponentAttributes(
            position: (x: 1.234, y: 5),
            size: (x: 10, y: 10),
            angle: 1.5707,
            scale: (x: 2, y: 2),
          ),
        ),
        'position 1.23,5, size 10,10, angle 1.57, scale 2,2',
      );
    });
  });

  group('filterComponentTree', () {
    test('keeps matching nodes and their ancestors', () {
      final filtered = filterComponentTree(
        _tree,
        (node) => node.name == 'Player',
      );

      expect(
        formatComponentTree(filtered!),
        'MyGame (id: 1)\n'
        '  World (id: 2)\n'
        '    Player (id: 3) position 10,20.50, size 32,32, anchor center, '
        'priority 2\n',
      );
    });

    test('keeps the children of a matching node', () {
      final filtered = filterComponentTree(
        _tree,
        (node) => node.name == 'World',
      );

      expect(
        formatComponentTree(filtered!),
        'MyGame (id: 1)\n'
        '  World (id: 2)\n'
        '    Player (id: 3) position 10,20.50, size 32,32, anchor center, '
        'priority 2\n',
      );
    });

    test('returns null when nothing matches', () {
      expect(filterComponentTree(_tree, (_) => false), isNull);
    });
  });

  group('findComponentNodes', () {
    test('returns every match in depth first order', () {
      final ids = findComponentNodes(
        _tree,
        (node) => node.id != 2,
      ).map((node) => node.id);
      expect(ids, [1, 3, 4]);
    });

    test('returns an empty list when nothing matches', () {
      expect(findComponentNodes(_tree, (_) => false), isEmpty);
    });
  });

  group('ComponentNode', () {
    test('reads and writes the JSON of the game', () {
      final json = {
        'id': 1,
        'name': 'MyGame',
        'toString': 'MyGame()',
        'isPositionComponent': false,
        'attributes': {'priority': 0},
        'children': [
          {
            'id': 3,
            'name': 'Player',
            'toString': 'Player()',
            'isPositionComponent': true,
            'attributes': {
              'priority': 2,
              'position': [10.0, 20.5],
              'size': [32.0, 32.0],
              'angle': 0.5,
              'scale': [1.0, 2.0],
              'anchor': 'center',
            },
            'children': <Object>[],
          },
        ],
      };

      final node = ComponentNode.fromJson(json);
      final player = node.children.single;
      expect(player.attributes.position, (x: 10.0, y: 20.5));
      expect(player.attributes.scale, (x: 1.0, y: 2.0));
      expect(player.attributes.angle, 0.5);
      expect(node.toJson(), json);
    });
  });

  test('formatComponentInfo prints one field per line', () {
    expect(
      formatComponentInfo(
        const ComponentInfo(
          id: 3,
          name: 'Player',
          toStringText: 'Player()',
          parent: 2,
          childCount: 0,
          debugMode: false,
          attributes: ComponentAttributes(
            priority: 2,
            position: (x: 10, y: 20),
            anchor: 'center',
          ),
        ),
      ),
      'type: Player\n'
      'id: 3\n'
      'parent: 2\n'
      'children: 0\n'
      'debugMode: false\n'
      'priority: 2\n'
      'position: 10.0, 20.0\n'
      'anchor: center\n'
      'toString: Player()\n',
    );
  });
}
