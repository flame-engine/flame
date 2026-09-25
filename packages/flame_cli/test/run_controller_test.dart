import 'dart:async';
import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

import 'fake_process.dart';

void main() {
  late Directory directory;
  late FakeProcess process;
  late RunController controller;
  late Future<int> running;

  setUp(() async {
    directory = Directory.systemTemp.createTempSync('flame_cli_test').absolute;
    process = FakeProcess();
    controller = RunController(
      process: process,
      projectDirectory: directory,
      out: StringBuffer(),
      err: StringBuffer(),
      responseTimeout: const Duration(seconds: 2),
    );
    running = controller.run();
    while (!projectFile(directory, controlPortFileName).existsSync()) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  });

  tearDown(() async {
    if (!process.exited) {
      process.exit(0);
    }
    await running;
    directory.deleteSync(recursive: true);
  });

  test(
    'writes the control port and removes it when the process exits',
    () async {
      final portFile = projectFile(directory, controlPortFileName);
      expect(int.tryParse(portFile.readAsStringSync()), isNotNull);

      process.exit(5);

      expect(await running, 5);
      expect(portFile.existsSync(), isFalse);
      expect(projectFile(directory, logFileName).existsSync(), isTrue);
    },
  );

  test('presses r for a reload and responds with the result', () async {
    final response = sendRunRequest(directory, RunRequest.reload);
    await _untilInput(process, 'r\n');
    process
      ..printLine('Performing hot reload...')
      ..printLine('Reloaded 1 of 2 libraries in 123ms.');

    expect(await response, {
      'ok': true,
      'message': 'Reloaded 1 of 2 libraries in 123ms.',
      'output': [
        'Performing hot reload...',
        'Reloaded 1 of 2 libraries in 123ms.',
      ],
    });
  });

  test('presses R for a restart', () async {
    final response = sendRunRequest(directory, RunRequest.restart);
    await _untilInput(process, 'R\n');
    process.printLine('Restarted application in 456ms.');

    expect((await response)['ok'], isTrue);
  });

  test('reports a failed reload with the output', () async {
    final response = sendRunRequest(directory, RunRequest.reload);
    await _untilInput(process, 'r\n');
    process
      ..printLine('lib/main.dart:3:1: Error: Expected ;')
      ..printLine('Try again after fixing the above error(s).');

    final result = await response;
    expect(result['ok'], isFalse);
    expect(result['message'], 'Try again after fixing the above error(s).');
    expect(result['output'], contains('lib/main.dart:3:1: Error: Expected ;'));
  });

  test('reports a timeout when flutter run does not answer', () async {
    final result = await sendRunRequest(directory, RunRequest.reload);

    expect(result['ok'], isFalse);
    expect(result['message'], contains('did not report the result'));
  });

  test('reports when the process stops during a request', () async {
    final response = sendRunRequest(directory, RunRequest.reload);
    await _untilInput(process, 'r\n');
    process.exit(0);

    final result = await response;
    expect(result['ok'], isFalse);
    expect(result['message'], contains('stopped before'));
  });

  test('rejects unknown requests', () async {
    final port = int.parse(
      projectFile(directory, controlPortFileName).readAsStringSync(),
    );
    final socket = await Socket.connect(InternetAddress.loopbackIPv4, port);
    socket.writeln('dance');
    final line = await socket.map(String.fromCharCodes).join();
    socket.destroy();

    expect(line, contains('Unknown request: dance'));
  });
}

Future<void> _untilInput(FakeProcess process, String input) async {
  while (process.input != input) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
}
