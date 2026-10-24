import 'dart:convert';
import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

void main() {
  late Directory directory;
  late StringBuffer out;
  late StringBuffer err;
  late FlameCommandRunner runner;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test').absolute;
    out = StringBuffer();
    err = StringBuffer();
    runner = FlameCommandRunner(
      out: out,
      err: err,
      workingDirectory: directory,
    );
  });

  tearDown(() => directory.deleteSync(recursive: true));

  for (final command in ['reload', 'restart', 'stop']) {
    test('$command needs a game started with flame run', () async {
      expect(await runner.run([command]), ExitCode.unavailable.code);
      expect(err.toString(), contains('started with `flame run`'));
    });

    test('$command reports when flame run has stopped', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      await server.close();
      projectFile(directory, controlPortFileName)
        ..createSync(recursive: true)
        ..writeAsStringSync(port.toString());

      expect(await runner.run([command]), ExitCode.unavailable.code);
      expect(err.toString(), contains('might have stopped'));
    });
  }

  test('reload sends the request to the given port', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((socket) {
      socket.writeln('{"ok": true, "message": "Reloaded 1 of 2 libraries"}');
      socket.close();
    });

    final exitCode = await runner.run(['reload', '--port', '${server.port}']);
    await server.close();

    expect(exitCode, ExitCode.success.code);
    expect(out.toString(), 'Reloaded 1 of 2 libraries\n');
  });

  test('reload validates the port', () async {
    expect(await runner.run(['reload', '-p', 'x']), ExitCode.usage.code);
    expect(err.toString(), contains('--port has to be'));
  });

  for (final command in ['stop', 'status']) {
    test('$command rejects a port that is out of range', () async {
      expect(await runner.run([command, '-p', '70000']), ExitCode.usage.code);
      expect(err.toString(), contains('between 1 and 65535'));
    });
  }

  test('stop sends a stop request and prints the result', () async {
    final requests = <String>[];
    final server = await _respondingServer(
      (_) => const RunResponse(ok: true, message: 'Stopped the game.'),
      requests: requests,
    );

    final exitCode = await runner.run(['stop', '--port', '${server.port}']);
    await server.close();

    expect(exitCode, ExitCode.success.code);
    expect(requests, ['stop']);
    expect(out.toString(), 'Stopped the game.\n');
  });

  test('stop fails when flutter run does not stop', () async {
    final server = await _respondingServer(
      (_) => const RunResponse(
        ok: false,
        message: 'flutter run did not stop within 120 seconds.',
      ),
    );

    final exitCode = await runner.run(['stop', '-p', '${server.port}']);
    await server.close();

    expect(exitCode, ExitCode.software.code);
    expect(out.toString(), contains('did not stop'));
  });

  group('status', () {
    late List<String> connectedUris;
    late Map<String, dynamic>? pausedResponse;

    setUp(() {
      connectedUris = [];
      pausedResponse = {'paused': false};
      runner = FlameCommandRunner(
        out: out,
        err: err,
        workingDirectory: directory,
        connect: (uri) async {
          connectedUris.add(uri);
          if (uri.contains('unreachable')) {
            throw const FlameCliException(
              'Could not connect to the Dart VM Service.',
              exitCode: ExitCode.unavailable,
            );
          }
          return _FakeConnection(uri, pausedResponse);
        },
      );
    });

    Future<ServerSocket> runningGame({String? vmServiceUri}) async {
      final requests = <String>[];
      final server = await _respondingServer(
        (port) => RunResponse(
          ok: true,
          message: 'flutter run is running.',
          status: RunStatus(
            projectDirectory: directory.path,
            controlPort: port,
            processId: 4242,
            vmServiceUri: vmServiceUri,
          ),
        ),
        requests: requests,
      );
      addTearDown(() => expect(requests, everyElement('status')));
      projectFile(directory, controlPortFileName)
        ..createSync(recursive: true)
        ..writeAsStringSync('${server.port}');
      return server;
    }

    test('reports when no game was started', () async {
      expect(await runner.run(['status']), ExitCode.unavailable.code);
      expect(out.toString(), startsWith('Running: no\n'));
      expect(out.toString(), contains('No game that was started'));
    });

    test('reports when flame run has stopped', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      await server.close();
      projectFile(directory, controlPortFileName)
        ..createSync(recursive: true)
        ..writeAsStringSync('$port');

      expect(await runner.run(['status', '--json']), ExitCode.unavailable.code);
      final status = json.decode(out.toString()) as Map<String, dynamic>;
      expect(status['running'], isFalse);
      expect(status['controlPort'], port);
      expect(status['error'], contains('might have stopped'));
    });

    test('reports a running and reachable game', () async {
      final server = await runningGame(vmServiceUri: 'ws://127.0.0.1:1/a=/ws');

      final exitCode = await runner.run(['status']);
      await server.close();

      expect(exitCode, ExitCode.success.code);
      expect(connectedUris, ['ws://127.0.0.1:1/a=/ws']);
      expect(
        out.toString(),
        'Running: yes\n'
        'Project: ${directory.path}\n'
        'Control port: ${server.port}\n'
        'Process id of flutter run: 4242\n'
        'Dart VM Service URI: ws://127.0.0.1:1/a=/ws\n'
        'Reachable: yes\n'
        'Paused: no\n',
      );
    });

    test('prints the status as JSON', () async {
      pausedResponse = {'paused': true};
      final server = await runningGame(vmServiceUri: 'ws://127.0.0.1:1/a=/ws');

      final exitCode = await runner.run(['status', '--json']);
      await server.close();

      expect(exitCode, ExitCode.success.code);
      expect(json.decode(out.toString()), {
        'running': true,
        'projectDirectory': directory.path,
        'controlPort': server.port,
        'processId': 4242,
        'vmServiceUri': 'ws://127.0.0.1:1/a=/ws',
        'reachable': true,
        'paused': true,
      });
    });

    test('reports a game that is still starting', () async {
      final server = await runningGame();

      final exitCode = await runner.run(['status', '--json']);
      await server.close();

      expect(exitCode, ExitCode.unavailable.code);
      final status = json.decode(out.toString()) as Map<String, dynamic>;
      expect(status['running'], isTrue);
      expect(status['reachable'], isFalse);
      expect(status['error'], contains('still starting'));
      expect(status.containsKey('vmServiceUri'), isFalse);
      expect(connectedUris, isEmpty);
    });

    test('reports a game that cannot be reached', () async {
      final server = await runningGame(vmServiceUri: 'ws://unreachable/ws');

      final exitCode = await runner.run(['status']);
      await server.close();

      expect(exitCode, ExitCode.unavailable.code);
      expect(out.toString(), contains('Reachable: no\n'));
      expect(out.toString(), contains('Could not connect'));
    });

    test(
      'leaves out the paused state when the game has no such extension',
      () async {
        pausedResponse = null;
        final server = await runningGame(
          vmServiceUri: 'ws://127.0.0.1:1/a=/ws',
        );

        final exitCode = await runner.run(['status', '--json']);
        await server.close();

        expect(exitCode, ExitCode.success.code);
        final status = json.decode(out.toString()) as Map<String, dynamic>;
        expect(status.containsKey('paused'), isFalse);
      },
    );

    test('checks a game that was started elsewhere with --uri', () async {
      final exitCode = await runner.run([
        'status',
        '--json',
        '--uri',
        'http://127.0.0.1:1/b=/',
      ]);

      expect(exitCode, ExitCode.success.code);
      expect(json.decode(out.toString()), {
        'running': true,
        'vmServiceUri': 'http://127.0.0.1:1/b=/',
        'reachable': true,
        'paused': false,
      });
    });

    test('reports a game given with --uri that cannot be reached', () async {
      final exitCode = await runner.run(['status', '-u', 'ws://unreachable']);

      expect(exitCode, ExitCode.unavailable.code);
      expect(out.toString(), startsWith('Running: no\n'));
    });

    test('does not combine --uri with --port', () async {
      final exitCode = await runner.run([
        'status',
        '--uri',
        'ws://127.0.0.1:1/ws',
        '--port',
        '1',
      ]);

      expect(exitCode, ExitCode.usage.code);
      expect(err.toString(), contains('cannot be combined'));
    });
  });

  group('logs', () {
    test('needs a log', () async {
      expect(await runner.run(['logs']), ExitCode.unavailable.code);
      expect(err.toString(), contains('No log was found'));
    });

    test('prints the last lines of the log from a subdirectory', () async {
      projectFile(directory, logFileName)
        ..createSync(recursive: true)
        ..writeAsStringSync('one\ntwo\nthree\n');
      final child = Directory(p.join(directory.path, 'lib'))..createSync();
      final runner = FlameCommandRunner(
        out: out,
        err: err,
        workingDirectory: child,
      );

      expect(await runner.run(['logs', '--lines', '2']), ExitCode.success.code);
      expect(out.toString(), 'two\nthree\n');
    });

    test('requires a non-negative number of lines', () async {
      expect(await runner.run(['logs', '-n', 'x']), ExitCode.usage.code);
      expect(err.toString(), contains('--lines has to be'));
    });
  });
}

/// Starts a control port server that records every request in [requests] and
/// answers it with [response].
Future<ServerSocket> _respondingServer(
  RunResponse Function(int port) response, {
  List<String>? requests,
}) async {
  final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
  server.listen((socket) {
    utf8.decoder.bind(socket).transform(const LineSplitter()).first.then((
      line,
    ) {
      requests?.add(line);
      socket.writeln(json.encode(response(server.port).toJson()));
      socket.close();
    });
  });
  return server;
}

/// A connection to a game whose `getPaused` service extension responds with
/// [_pausedResponse], or which does not have the extension when it is null.
class _FakeConnection(
  @override final String uri,
  final Map<String, dynamic>? _pausedResponse,
) implements FlameConnection {
  @override
  Future<Map<String, dynamic>> call(
    String method, {
    Map<String, String>? args,
  }) async {
    final response = _pausedResponse;
    if (method != 'getPaused' || response == null) {
      throw FlameCliException('The game does not support $method.');
    }
    return response;
  }

  @override
  Future<void> dispose() async {}
}
