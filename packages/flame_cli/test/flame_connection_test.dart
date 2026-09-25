import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

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

    test('handles surrounding whitespace and no trailing slash', () {
      expect(
        webSocketUri(' http://127.0.0.1:50300/abc123= ').toString(),
        'ws://127.0.0.1:50300/abc123=/ws',
      );
    });
  });
}
