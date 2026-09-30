import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

Map<String, dynamic> _node(
  int id,
  String name, {
  Map<String, dynamic> attributes = const {},
  List<Map<String, dynamic>> children = const [],
}) {
  return {
    'id': id,
    'name': name,
    'attributes': attributes,
    'children': children,
  };
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
          attributes: {
            'priority': 2,
            'position': [10.0, 20.5],
            'size': [32.0, 32.0],
            'angle': 0.0,
            'scale': [1.0, 1.0],
            'anchor': 'center',
          },
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
      expect(formatAttributes({'priority': 0}), '');
      expect(
        formatAttributes({
          'priority': 0,
          'position': [0, 0],
          'size': [1, 2],
          'angle': 0,
          'scale': [1, 1],
          'anchor': 'topLeft',
        }),
        'position 0,0, size 1,2',
      );
    });

    test('shows angle and scale when they are not the default', () {
      expect(
        formatAttributes({
          'position': [1.234, 5],
          'size': [10, 10],
          'angle': 1.5707,
          'scale': [2, 2],
        }),
        'position 1.23,5, size 10,10, angle 1.57, scale 2,2',
      );
    });
  });

  group('filterComponentTree', () {
    test('keeps matching nodes and their ancestors', () {
      final filtered = filterComponentTree(
        _tree,
        (node) => node['name'] == 'Player',
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
        (node) => node['name'] == 'World',
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

  test('formatComponentInfo prints one field per line', () {
    expect(
      formatComponentInfo({
        'id': 3,
        'name': 'Player',
        'toString': 'Player()',
        'parent': 2,
        'childCount': 0,
        'debugMode': false,
        'attributes': {
          'priority': 2,
          'position': [10.0, 20.0],
          'anchor': 'center',
        },
      }),
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
