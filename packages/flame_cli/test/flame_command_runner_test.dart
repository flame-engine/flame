import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _unreachableUri = 'http://127.0.0.1:1/abc=/';

void main() {
  late Directory directory;
  late StringBuffer out;
  late StringBuffer err;
  late FlameCommandRunner runner;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test');
    out = StringBuffer();
    err = StringBuffer();
    runner = FlameCommandRunner(
      out: out,
      err: err,
      workingDirectory: directory,
    );
  });

  tearDown(() => directory.deleteSync(recursive: true));

  test('fails with a usage error for an unknown command', () async {
    expect(await runner.run(['unknown']), ExitCodes.usage);
    expect(err.toString(), contains('Could not find a command named'));
  });

  for (final command in ['snapshot', 'tree']) {
    test('$command asks for flame run or --uri without a game', () async {
      expect(await runner.run([command]), ExitCodes.unavailable);
      expect(err.toString(), contains('Start the game with `flame run`'));
    });
  }

  test('snapshot requires a positive pixel ratio', () async {
    final exitCode = await runner.run([
      'snapshot',
      '--uri',
      _unreachableUri,
      '--pixel-ratio',
      '0',
    ]);

    expect(exitCode, ExitCodes.usage);
    expect(err.toString(), contains('--pixel-ratio has to be a positive'));
  });

  test('reports when the game cannot be reached', () async {
    final exitCode = await runner.run(['tree', '--uri', _unreachableUri]);

    expect(exitCode, ExitCodes.unavailable);
    expect(err.toString(), contains('Could not connect'));
  });

  test('uses the uri that flame run wrote in a parent directory', () async {
    vmServiceUriFile(directory)
      ..createSync(recursive: true)
      ..writeAsStringSync(_unreachableUri);
    final child = Directory(p.join(directory.path, 'lib'))..createSync();
    final runner = FlameCommandRunner(
      out: out,
      err: err,
      workingDirectory: child,
    );

    expect(await runner.run(['tree']), ExitCodes.unavailable);
    expect(err.toString(), contains('Could not connect'));
    expect(err.toString(), contains('The URI was read from'));
  });
}
