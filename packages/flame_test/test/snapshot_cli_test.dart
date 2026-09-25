import 'package:test/test.dart';

import '../bin/snapshot.dart';

void main() {
  group('webSocketUri', () {
    test('converts the uri printed by flutter run', () {
      expect(
        webSocketUri('http://127.0.0.1:50300/abc123=/').toString(),
        'ws://127.0.0.1:50300/abc123=/ws',
      );
    });

    test('uses a secure web socket for https', () {
      expect(
        webSocketUri('https://example.com/abc123=/').toString(),
        'wss://example.com/abc123=/ws',
      );
    });

    test('keeps a web socket uri as it is', () {
      expect(
        webSocketUri('ws://127.0.0.1:50300/abc123=/ws').toString(),
        'ws://127.0.0.1:50300/abc123=/ws',
      );
    });

    test('handles a uri without a trailing slash', () {
      expect(
        webSocketUri(' http://127.0.0.1:50300/abc123= ').toString(),
        'ws://127.0.0.1:50300/abc123=/ws',
      );
    });
  });

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
