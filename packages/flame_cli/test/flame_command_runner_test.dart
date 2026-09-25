import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

void main() {
  late StringBuffer out;
  late StringBuffer err;
  late FlameCommandRunner runner;

  setUp(() {
    out = StringBuffer();
    err = StringBuffer();
    runner = FlameCommandRunner(out: out, err: err);
  });

  test('fails with a usage error for an unknown command', () async {
    expect(await runner.run(['unknown']), ExitCodes.usage);
    expect(err.toString(), contains('Could not find a command named'));
  });

  for (final command in ['snapshot', 'tree']) {
    test('$command requires the uri option', () async {
      expect(await runner.run([command]), ExitCodes.usage);
      expect(err.toString(), contains('The --uri option is required.'));
    });
  }

  test('snapshot requires a positive pixel ratio', () async {
    final exitCode = await runner.run([
      'snapshot',
      '--uri',
      'http://127.0.0.1:1/abc=/',
      '--pixel-ratio',
      '0',
    ]);

    expect(exitCode, ExitCodes.usage);
    expect(err.toString(), contains('--pixel-ratio has to be a positive'));
  });

  test('reports when the game cannot be reached', () async {
    final exitCode = await runner.run([
      'tree',
      '--uri',
      'http://127.0.0.1:1/abc=/',
    ]);

    expect(exitCode, ExitCodes.unavailable);
    expect(err.toString(), contains('Could not connect'));
  });
}
