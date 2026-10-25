import 'dart:async';

import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

void main() {
  group('call', () {
    late StreamController<String> responses;
    late List<String> requests;
    late FlameConnection connection;

    setUp(() {
      responses = StreamController<String>();
      requests = [];
      connection = FlameConnection.withService(
        'http://127.0.0.1:1/abc=/',
        VmService(responses.stream, requests.add),
        'isolates/1',
        {'ext.flame_devtools.getPaused'},
      );
    });

    tearDown(() => connection.dispose());

    test('fails as unavailable when the game stops during a call', () async {
      final call = connection.call('getPaused');
      await Future<void>.delayed(Duration.zero);
      expect(requests, hasLength(1));
      await responses.close();

      await expectLater(
        call,
        throwsA(
          isA<FlameCliException>()
              .having((e) => e.exitCode, 'exitCode', ExitCode.unavailable)
              .having((e) => e.message, 'message', contains('no longer')),
        ),
      );
    });

    test('fails as unavailable after the game has stopped', () async {
      await responses.close();
      await Future<void>.delayed(Duration.zero);

      await expectLater(
        connection.call('getPaused'),
        throwsA(
          isA<FlameCliException>().having(
            (e) => e.exitCode,
            'exitCode',
            ExitCode.unavailable,
          ),
        ),
      );
    });
  });

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
