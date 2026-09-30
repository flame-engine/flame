import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

void main() {
  test('formatComponentTree indents children by depth', () {
    final tree = {
      'id': 1,
      'name': 'MyGame',
      'children': [
        {
          'id': 2,
          'name': 'World',
          'children': [
            {'id': 3, 'name': 'Player', 'children': <dynamic>[]},
          ],
        },
        {'id': 4, 'name': 'CameraComponent', 'children': <dynamic>[]},
      ],
    };

    expect(
      formatComponentTree(tree),
      'MyGame (id: 1)\n'
      '  World (id: 2)\n'
      '    Player (id: 3)\n'
      '  CameraComponent (id: 4)\n',
    );
  });
}
