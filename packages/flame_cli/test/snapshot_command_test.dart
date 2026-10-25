import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/flame_cli.dart';
import 'package:flame_cli/src/commands/snapshot_command.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

final _png = base64Encode([137, 80, 78, 71]);

/// A connection that answers every call with [response] and records the
/// calls.
class _FakeConnection(final Map<String, dynamic> response)
    implements FlameConnection {
  final calls = <(String, Map<String, String>?)>[];

  @override
  String get uri => 'http://127.0.0.1:1/abc=/';

  @override
  Future<Map<String, dynamic>> call(
    String method, {
    Map<String, String>? args,
  }) async {
    calls.add((method, args));
    return response;
  }

  @override
  Future<void> dispose() async {}
}

/// Runs the snapshot command with a fake connection instead of connecting to
/// a game.
class _TestSnapshotCommand(
  super.out,
  super.workingDirectory,
  final FlameConnection connection,
) extends SnapshotCommand {
  @override
  Future<int> run() async {
    validate();
    return await runWithConnection(connection);
  }
}

void main() {
  late Directory directory;
  late StringBuffer out;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test').absolute;
    out = StringBuffer();
  });

  tearDown(() => directory.deleteSync(recursive: true));

  Future<int?> runSnapshot(
    _FakeConnection connection,
    List<String> arguments,
  ) {
    final runner = CommandRunner<int>('flame', 'test')
      ..addCommand(_TestSnapshotCommand(out, directory, connection));
    return runner.run(['snapshot', ...arguments]);
  }

  test('passes the annotation and size options to the game', () async {
    final connection = _FakeConnection({
      'snapshot': _png,
      'width': 100,
      'height': 75,
      'pixelRatio': 0.125,
      'annotations': [
        {
          'id': 220731871,
          'name': 'Player',
          'box': [10.4, 20.6, 32, 31.5],
        },
      ],
    });

    final exitCode = await runSnapshot(connection, [
      '--annotate',
      '--filter',
      'player',
      '--max-size',
      '100',
      '--pixel-ratio',
      '2',
      '--world',
    ]);

    expect(exitCode, ExitCode.success.code);
    expect(connection.calls.single.$1, 'getGameSnapshot');
    expect(connection.calls.single.$2, {
      'pixelRatio': '2.0',
      'annotate': 'true',
      'annotationFilter': 'player',
      'maxSize': '100',
      'world': 'true',
    });
    final path = p.join(directory.path, 'flame_snapshot.png');
    expect(
      out.toString(),
      'Player (id: 220731871) box 10,21,32,32\n'
      'The image was scaled down to 100x75 pixels to fit --max-size, a pixel '
      'ratio of 0.125.\n'
      '$path\n',
    );
    expect(File(path).readAsBytesSync(), base64Decode(_png));
  });

  test('annotates a single component', () async {
    final connection = _FakeConnection({
      'snapshot': _png,
      'pixelRatio': 1,
      'annotations': <dynamic>[],
    });

    await runSnapshot(connection, ['-c', '42', '-a']);

    expect(connection.calls.single.$1, 'getComponentSnapshot');
    expect(connection.calls.single.$2, {
      'id': '42',
      'pixelRatio': '1.0',
      'annotate': 'true',
    });
    expect(
      out.toString(),
      startsWith('No visible components were annotated.\n'),
    );
  });

  test('only prints the path without the new options', () async {
    final connection = _FakeConnection({
      'snapshot': _png,
      'width': 800,
      'height': 600,
      'pixelRatio': 1,
    });

    await runSnapshot(connection, ['--max-size', '1000']);

    expect(
      out.toString(),
      '${p.join(directory.path, 'flame_snapshot.png')}\n',
    );
  });

  test('fails cleanly on a game without annotations', () async {
    final connection = _FakeConnection({
      'snapshot': _png,
      'width': 800,
      'height': 600,
    });

    await expectLater(
      runSnapshot(connection, ['--annotate', '--max-size', '100']),
      throwsA(
        isA<FlameCliException>()
            .having(
              (e) => e.message,
              'message',
              contains('does not support --annotate and --max-size'),
            )
            .having((e) => e.exitCode, 'exitCode', ExitCode.unavailable),
      ),
    );
    expect(
      File(p.join(directory.path, 'flame_snapshot.png')).existsSync(),
      isFalse,
    );
  });

  group('formatSnapshotAnnotations', () {
    test('formats one component per line', () {
      expect(
        formatSnapshotAnnotations(const [
          SnapshotAnnotation(
            id: 1,
            name: 'Enemy',
            box: (x: 0, y: 0, width: 10, height: 10),
          ),
          SnapshotAnnotation(
            id: 2,
            name: 'Player',
            box: (x: -5.5, y: 3.2, width: 1.4, height: 2.6),
          ),
        ]),
        'Enemy (id: 1) box 0,0,10,10\nPlayer (id: 2) box -6,3,1,3\n',
      );
    });
  });
}
