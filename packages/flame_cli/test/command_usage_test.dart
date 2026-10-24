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
    expect(
      await runner.run([...arguments, '--uri', _uri]),
      ExitCode.usage.code,
    );
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

    test('requires a positive integer maximum size', () async {
      await expectUsageError(['snapshot', '--max-size', '0'], '--max-size');
      await expectUsageError(['snapshot', '-m', '1.5'], '--max-size has to');
    });

    test(
      'requires --annotate and a valid regular expression for the filter',
      () async {
        await expectUsageError(
          ['snapshot', '--filter', 'player'],
          'it needs --annotate',
        );
        await expectUsageError(
          ['snapshot', '--annotate', '--filter', '('],
          '--filter is not',
        );
      },
    );

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

    test('tap requires either a position or a component', () async {
      await expectUsageError(
        ['input', 'tap', '1,2', '--component', '5'],
        'Pass one position',
      );
      await expectUsageError(
        ['input', 'tap', '1,2', '--anchor', 'topLeft'],
        '--anchor can only be used together with a component',
      );
      await expectUsageError(
        ['input', 'tap', '-c', '5', '--anchor', '1,2,3'],
        'An anchor has to be',
      );
    });

    test('drag requires two positions and positive steps', () async {
      await expectUsageError(['input', 'drag', '1,2'], 'Pass two positions');
      await expectUsageError(['input', 'drag', '1,2', 'x,y'], 'two numbers');
      await expectUsageError(
        ['input', 'drag', '1,2', '3,4', '--steps', '0'],
        '--steps has to be',
      );
    });

    test('drag replaces positions with components', () async {
      await expectUsageError(
        ['input', 'drag', '1,2', '3,4', '--from-component', '5'],
        'Pass two positions',
      );
      await expectUsageError(
        [
          'input',
          'drag',
          '1,2',
          '--from-component',
          '5',
          '--to-component',
          '6',
        ],
        'Pass two positions',
      );
      await expectUsageError(
        ['input', 'drag', '--to-component', '5', 'x,y'],
        'two numbers',
      );
      await expectUsageError(
        ['input', 'drag', '1,2', '3,4', '--to-anchor', 'center'],
        '--to-anchor can only be used together with a component',
      );
      await expectUsageError(
        [
          'input',
          'drag',
          '--from-component',
          '5',
          '--from-anchor',
          'a,b',
          '1,2',
        ],
        'An anchor has to be',
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

  group('wait', () {
    test('requires a type pattern or an id', () async {
      await expectUsageError(['wait', 'component'], 'Pass one regular');
      await expectUsageError(['wait', 'component', 'a', 'b'], 'Pass one');
      await expectUsageError(['wait', 'component', '('], 'not a valid');
      await expectUsageError(
        ['wait', 'component', '--id', 'x'],
        '--id has to be an integer',
      );
    });

    test('validates the count', () async {
      await expectUsageError(
        ['wait', 'component', 'a', '--count', '-1'],
        '--count has to be',
      );
      await expectUsageError(
        ['wait', 'component', 'a', '--at-least', '0'],
        '--at-least has to be',
      );
      await expectUsageError(
        ['wait', 'component', 'a', '--count', '1', '--gone'],
        'Pass only one of',
      );
    });

    test('validates the attribute conditions', () async {
      for (final condition in ['position > 1', 'angle.x > 1', 'size.x ~ 1']) {
        await expectUsageError(
          ['wait', 'component', 'a', '--where', condition],
          '--where has to be',
        );
      }
      await expectUsageError(
        ['wait', 'component', 'a', '--where', 'position.x > a'],
        '--where has to be',
      );
    });

    test('validates the timeout and the interval', () async {
      await expectUsageError(
        ['wait', 'paused', '--timeout', '-1'],
        '--timeout has to be a non-negative',
      );
      await expectUsageError(
        ['wait', 'paused', '--interval', '0'],
        '--interval has to be a positive',
      );
    });

    test('requires an overlay name', () async {
      await expectUsageError(['wait', 'overlay'], 'Pass the name of one');
    });
  });

  group('overlay', () {
    test('requires an overlay name', () async {
      await expectUsageError(['overlay', 'show'], 'Pass the name of one');
      await expectUsageError(['overlay', 'hide', 'a', 'b'], 'Pass the name');
    });
  });
}
