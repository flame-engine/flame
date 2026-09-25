import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

const _uri = 'http://127.0.0.1:1/abc=/';

void main() {
  late Directory directory;
  late StringBuffer err;
  late FlameCommandRunner runner;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test');
    err = StringBuffer();
    runner = FlameCommandRunner(
      out: StringBuffer(),
      err: err,
      workingDirectory: directory,
    );
  });

  tearDown(() => directory.deleteSync(recursive: true));

  Future<void> expectUsageError(List<String> arguments, String message) async {
    expect(await runner.run([...arguments, '--uri', _uri]), ExitCodes.usage);
    expect(err.toString(), contains(message));
  }

  group('tree', () {
    test('requires a non-negative depth', () async {
      await expectUsageError(['tree', '--depth', '-1'], '--depth has to be');
    });

    test('requires a valid filter', () async {
      await expectUsageError(['tree', '--filter', '('], '--filter is not');
    });
  });

  group('inspect', () {
    test('requires a component id', () async {
      await expectUsageError(['inspect'], 'Pass the id of one component');
      await expectUsageError(['inspect', 'abc'], 'Pass the id of one');
    });
  });

  group('set', () {
    test('requires an attribute', () async {
      await expectUsageError(['set', '1'], 'Pass at least one attribute');
    });

    test('validates vectors', () async {
      await expectUsageError(
        ['set', '1', '--position', '1'],
        '--position has to be two numbers',
      );
      await expectUsageError(
        ['set', '1', '--size', 'a,b'],
        '--size has to be two numbers',
      );
    });

    test('validates numbers', () async {
      await expectUsageError(['set', '1', '--angle', 'x'], '--angle has to be');
      await expectUsageError(
        ['set', '1', '--priority', '1.5'],
        '--priority has to be',
      );
    });

    test('validates anchors', () async {
      await expectUsageError(
        ['set', '1', '--anchor', '1,2,3'],
        '--anchor has to be a name',
      );
    });
  });

  group('step', () {
    test('requires a positive time and frame count', () async {
      await expectUsageError(['step', '--time', '0'], '--time has to be');
      await expectUsageError(['step', '--frames', '0'], '--frames has to be');
    });
  });

  group('debug', () {
    test('only accepts on or off', () async {
      await expectUsageError(['debug', 'maybe'], 'Pass on, off or nothing');
    });
  });

  group('snapshot', () {
    test('validates the rect', () async {
      await expectUsageError(['snapshot', '--rect', '1,2,3'], '--rect has to');
      await expectUsageError(['snapshot', '-r', '0,0,-1,5'], '--rect has to');
    });

    test('does not combine a component with the world', () async {
      await expectUsageError(
        ['snapshot', '-c', '1', '--world'],
        'cannot be combined',
      );
      await expectUsageError(
        ['snapshot', '-c', '1', '--rect', '0,0,1,1'],
        'cannot be combined',
      );
    });
  });

  group('input', () {
    test('tap requires one position', () async {
      await expectUsageError(['input', 'tap'], 'Pass one position');
      await expectUsageError(['input', 'tap', '1'], 'two numbers');
      await expectUsageError(['input', 'tap', '1,2', '3,4'], 'Pass one');
    });

    test('drag requires two positions and positive steps', () async {
      await expectUsageError(['input', 'drag', '1,2'], 'Pass two positions');
      await expectUsageError(['input', 'drag', '1,2', 'x,y'], 'two numbers');
      await expectUsageError(
        ['input', 'drag', '1,2', '3,4', '--steps', '0'],
        '--steps has to be',
      );
    });

    test('key requires one key and one direction', () async {
      await expectUsageError(['input', 'key'], 'Pass the name of one key');
      await expectUsageError(
        ['input', 'key', 'space', '--down', '--up'],
        'either --down or --up',
      );
    });
  });

  group('overlay', () {
    test('requires an overlay name', () async {
      await expectUsageError(['overlay', 'show'], 'Pass the name of one');
      await expectUsageError(['overlay', 'hide', 'a', 'b'], 'Pass the name');
    });
  });
}
