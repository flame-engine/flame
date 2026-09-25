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

  for (final command in ['reload', 'restart']) {
    test('$command needs a game started with flame run', () async {
      expect(await runner.run([command]), ExitCodes.unavailable);
      expect(err.toString(), contains('started with `flame run`'));
    });

    test('$command reports when flame run has stopped', () async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      final port = server.port;
      await server.close();
      projectFile(directory, controlPortFileName)
        ..createSync(recursive: true)
        ..writeAsStringSync(port.toString());

      expect(await runner.run([command]), ExitCodes.unavailable);
      expect(err.toString(), contains('might have stopped'));
    });
  }

  group('logs', () {
    test('needs a log', () async {
      expect(await runner.run(['logs']), ExitCodes.unavailable);
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

      expect(await runner.run(['logs', '--lines', '2']), ExitCodes.success);
      expect(out.toString(), 'two\nthree\n');
    });

    test('requires a non-negative number of lines', () async {
      expect(await runner.run(['logs', '-n', 'x']), ExitCodes.usage);
      expect(err.toString(), contains('--lines has to be'));
    });
  });
}
