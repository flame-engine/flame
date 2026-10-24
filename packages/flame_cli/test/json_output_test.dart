import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/flame_cli.dart';
import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'fake_process.dart';

const _uri = 'http://127.0.0.1:1/abc=/';

/// A connection that answers the service extension calls with [responses],
/// and records the calls that were made.
class _FakeConnection(final Map<String, Map<String, dynamic>> responses)
    implements FlameConnection {
  final calls = <(String, Map<String, String>?)>[];

  @override
  String get uri => _uri;

  @override
  Future<Map<String, dynamic>> call(
    String method, {
    Map<String, String>? args,
  }) async {
    calls.add((method, args));
    return responses[method] ?? {};
  }

  @override
  Future<void> dispose() async {}
}

void main() {
  late Directory directory;
  late StringBuffer out;
  late StringBuffer err;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test').absolute;
    out = StringBuffer();
    err = StringBuffer();
  });

  tearDown(() => directory.deleteSync(recursive: true));

  Future<Object?> runJson(
    List<String> arguments, {
    Map<String, Map<String, dynamic>> responses = const {},
    int exitCode = 0,
    ProcessStarter? startProcess,
  }) async {
    final connection = _FakeConnection(responses);
    final runner = FlameCommandRunner(
      out: out,
      err: err,
      workingDirectory: directory,
      connect: (_) async => connection,
      startProcess: startProcess,
    );
    expect(await runner.run([...arguments, '--json']), exitCode);
    return json.decode(out.toString());
  }

  group('game commands', () {
    Future<Object?> runGameJson(
      List<String> arguments, {
      Map<String, Map<String, dynamic>> responses = const {},
    }) {
      return runJson([...arguments, '--uri', _uri], responses: responses);
    }

    test('tree prints the tree as before', () async {
      final tree = {
        'id': 1,
        'name': 'MyGame',
        'toString': 'MyGame()',
        'isPositionComponent': false,
        'attributes': {'priority': 0},
        'children': <Object>[],
      };
      expect(
        await runGameJson(
          ['tree'],
          responses: {
            'getComponentTree': {'component_tree': tree},
          },
        ),
        tree,
      );
    });

    test('tree prints null when nothing matches the filter', () async {
      final result = await runGameJson(
        ['tree', '--filter', 'enemy'],
        responses: {
          'getComponentTree': {
            'component_tree': {'id': 1, 'name': 'MyGame', 'children': []},
          },
        },
      );
      expect(result, isNull);
    });

    test('inspect and set print the component info', () async {
      final info = {
        'id': 1,
        'name': 'Player',
        'toString': 'Player()',
        'parent': 2,
        'childCount': 0,
        'debugMode': false,
        'attributes': {
          'priority': 0,
          'position': [1.0, 2.0],
          'angle': 1.0,
        },
      };
      final responses = {'getComponentInfo': info};
      expect(await runGameJson(['inspect', '1'], responses: responses), info);

      out.clear();
      expect(
        await runGameJson(
          ['set', '1', '--angle', '1'],
          responses: responses,
        ),
        info,
      );
    });

    test('snapshot prints the path, size and pixel ratio', () async {
      final png = img.encodePng(img.Image(width: 4, height: 3));
      final result = await runGameJson(
        ['snapshot', '--output', 'shot.png', '--pixel-ratio', '2'],
        responses: {
          'getGameSnapshot': {'snapshot': base64Encode(png)},
        },
      );
      expect(result, {
        'path': p.join(directory.path, 'shot.png'),
        'width': 4,
        'height': 3,
        'pixelRatio': 2.0,
        'bytes': png.length,
      });
    });

    test('snapshot prints the annotations and the used pixel ratio', () async {
      final png = img.encodePng(img.Image(width: 4, height: 3));
      final annotation = {
        'id': 7,
        'name': 'Player',
        'box': [1, 0, 2, 2],
      };
      final result = await runGameJson(
        ['snapshot', '--annotate', '--max-size', '4', '--pixel-ratio', '2'],
        responses: {
          'getGameSnapshot': {
            'snapshot': base64Encode(png),
            'pixelRatio': 0.5,
            'annotations': [annotation],
          },
        },
      );
      expect(result, {
        'path': p.join(directory.path, 'flame_snapshot.png'),
        'width': 4,
        'height': 3,
        'pixelRatio': 0.5,
        'bytes': png.length,
        'annotations': [annotation],
      });
    });

    test('snapshot prints no size when the image cannot be read', () async {
      final truncated = img
          .encodePng(img.Image(width: 4, height: 3))
          .sublist(
            0,
            20,
          );
      final responses = {
        'getGameSnapshot': {'snapshot': base64Encode(truncated)},
      };
      expect(
        await runGameJson(['snapshot'], responses: responses),
        containsPair('width', null),
      );

      out.clear();
      final runner = FlameCommandRunner(
        out: out,
        err: err,
        workingDirectory: directory,
        connect: (_) async => _FakeConnection(responses),
      );
      expect(
        await runner.run(['snapshot', '--uri', _uri]),
        ExitCode.success.code,
      );
      expect(
        out.toString().trim(),
        p.join(directory.path, 'flame_snapshot.png'),
      );
    });

    test('pause and resume print the paused state', () async {
      expect(await runGameJson(['pause']), {'paused': true});
      out.clear();
      expect(await runGameJson(['resume']), {'paused': false});
    });

    test('step prints one object even when it paused the game', () async {
      final result = await runGameJson(
        ['step', '--frames', '2', '--time', '0.5'],
        responses: {
          'getPaused': {'paused': false},
        },
      );
      expect(result, {
        'paused': true,
        'wasPaused': false,
        'frames': 2,
        'frameTime': 0.5,
        'totalTime': 1.0,
      });
    });

    test('debug prints the debug mode', () async {
      expect(
        await runGameJson(
          ['debug'],
          responses: {
            'getDebugMode': {'debug_mode': true},
          },
        ),
        {'debugMode': true, 'component': null},
      );
      out.clear();
      expect(
        await runGameJson(['debug', 'off', '--component', '7']),
        {'debugMode': false, 'component': 7},
      );
    });

    test('overlays and overlay print the overlays', () async {
      expect(
        await runGameJson(
          ['overlays'],
          responses: {
            'getOverlays': {
              'overlays': ['Menu', 'Hud'],
              'active': ['Hud'],
            },
          },
        ),
        {
          'overlays': ['Menu', 'Hud'],
          'active': ['Hud'],
        },
      );
      out.clear();
      expect(
        await runGameJson(['overlay', 'show', 'Menu']),
        {'overlay': 'Menu', 'shown': true},
      );
      out.clear();
      expect(
        await runGameJson(['overlay', 'hide', 'Menu']),
        {'overlay': 'Menu', 'shown': false},
      );
      out.clear();
      expect(
        await runGameJson(['overlay', 'only', 'Menu']),
        {'overlay': 'Menu', 'shown': true, 'othersHidden': true},
      );
    });

    test('input prints the sent input', () async {
      expect(await runGameJson(['input', 'tap', '1,2']), {
        'input': 'tap',
        'position': {'x': 1.0, 'y': 2.0},
      });
      out.clear();
      expect(
        await runGameJson(['input', 'drag', '1,2', '3,4', '--steps', '5']),
        {
          'input': 'drag',
          'from': {'x': 1.0, 'y': 2.0},
          'to': {'x': 3.0, 'y': 4.0},
          'steps': 5,
        },
      );
      out.clear();
      expect(
        await runGameJson(['input', 'key', 'space', '--down']),
        {'input': 'key', 'key': 'space', 'action': 'down'},
      );
    });

    test('input prints the resolved position of a component', () async {
      final responses = {
        'getComponentCanvasPosition': {'id': 7, 'x': 10.5, 'y': 20},
      };
      expect(
        await runGameJson(
          ['input', 'tap', '--component', '7'],
          responses: responses,
        ),
        {
          'input': 'tap',
          'position': {'x': 10.5, 'y': 20.0},
          'component': 7,
        },
      );
      out.clear();
      expect(
        await runGameJson(
          ['input', 'drag', '1,2', '--to-component', 'player'],
          responses: responses,
        ),
        {
          'input': 'drag',
          'from': {'x': 1.0, 'y': 2.0},
          'to': {'x': 10.5, 'y': 20.0},
          'toComponent': 'player',
          'steps': 10,
        },
      );
    });
  });

  group('diff', () {
    void writeImage(String name, {bool dot = false}) {
      final image = img.Image(width: 4, height: 4);
      if (dot) {
        image.setPixelRgba(1, 2, 255, 255, 255, 255);
      }
      File(p.join(directory.path, name)).writeAsBytesSync(img.encodePng(image));
    }

    test('prints the difference', () async {
      writeImage('a.png');
      writeImage('b.png', dot: true);

      final result = await runJson([
        'diff',
        'a.png',
        'b.png',
        '--output',
        'diff.png',
        '--exit-code',
      ], exitCode: 1);

      expect(result, {
        'identical': false,
        'differingPixels': 1,
        'totalPixels': 16,
        'percentage': 6.25,
        'bounds': {'left': 1, 'top': 2, 'width': 1, 'height': 1},
        'output': p.join(directory.path, 'diff.png'),
      });
    });

    test('prints identical images', () async {
      writeImage('a.png');

      final result = await runJson(['diff', 'a.png', 'a.png']);

      expect(result, containsPair('identical', true));
      expect(result, containsPair('bounds', null));
      expect(result, containsPair('output', null));
    });
  });

  group('logs', () {
    test('prints the last lines', () async {
      final log = projectFile(directory, logFileName)
        ..createSync(recursive: true)
        ..writeAsStringSync('one\ntwo\nthree\n');

      expect(await runJson(['logs', '-n', '2']), {
        'path': log.path,
        'lines': ['two', 'three'],
      });
    });

    test('cannot follow', () async {
      final result = await runJson(
        ['logs', '--follow'],
        exitCode: ExitCode.usage.code,
      );
      expect(
        (result! as Map)['error'],
        containsPair('message', contains('--follow cannot be combined')),
      );
    });
  });

  group('reload', () {
    Future<Object?> reload(String response, {int exitCode = 0}) async {
      final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
      server.listen((socket) {
        socket.writeln(response);
        socket.close();
      });
      try {
        return await runJson([
          'reload',
          '--port',
          '${server.port}',
        ], exitCode: exitCode);
      } finally {
        await server.close();
      }
    }

    test('prints the result', () async {
      expect(
        await reload(
          '{"ok": true, "message": "Reloaded 1 of 2 libraries", '
          '"output": ["Reloaded 1 of 2 libraries"]}',
        ),
        {
          'ok': true,
          'message': 'Reloaded 1 of 2 libraries',
          'output': ['Reloaded 1 of 2 libraries'],
        },
      );
    });

    test('prints a failed reload with its output', () async {
      expect(
        await reload(
          '{"ok": false, "message": "Try again after fixing the above '
          'error(s).", "output": ["lib/main.dart:1:1: Error"]}',
          exitCode: ExitCode.software.code,
        ),
        {
          'ok': false,
          'message': 'Try again after fixing the above error(s).',
          'output': ['lib/main.dart:1:1: Error'],
        },
      );
    });
  });

  test(
    'create prints the game and sends the flutter output to stderr',
    () async {
      final result = await runJson(
        ['create', 'my_game'],
        startProcess:
            (
              executable,
              arguments, {
              workingDirectory,
              runInShell = false,
              mode = ProcessStartMode.normal,
            }) async {
              if (arguments.first == 'create') {
                Directory(arguments.last).createSync(recursive: true);
              }
              return FakeProcess()
                ..printLine('flutter ${arguments.first}')
                ..exit(0);
            },
      );

      expect(result, {
        'name': 'my_game',
        'path': p.join(directory.path, 'my_game'),
        'template': 'basics',
      });
      expect(err.toString(), contains('flutter create'));
    },
  );

  test('devtools starts dart devtools in machine mode', () async {
    late List<String> usedArguments;
    final runner = FlameCommandRunner(
      out: out,
      err: err,
      workingDirectory: directory,
      connect: (_) async => _FakeConnection(const {}),
      startProcess:
          (
            executable,
            arguments, {
            workingDirectory,
            runInShell = false,
            mode = ProcessStartMode.normal,
          }) async {
            usedArguments = arguments;
            return FakeProcess(exitCode: 0);
          },
    );

    expect(
      await runner.run(['devtools', '--json', '--uri', _uri]),
      ExitCode.success.code,
    );

    expect(usedArguments, ['devtools', '--machine', '--launch-browser', _uri]);
    expect(out.toString(), isEmpty);
    expect(err.toString(), contains('Enabled the Flame DevTools extension'));
  });

  group('errors', () {
    Future<Map<String, dynamic>> runError(
      List<String> arguments,
      ExitCode exitCode,
    ) async {
      final runner = FlameCommandRunner(
        out: out,
        err: err,
        workingDirectory: directory,
      );
      expect(await runner.run(arguments), exitCode.code);
      expect(err.toString(), isEmpty);
      final result = json.decode(out.toString()) as Map<String, dynamic>;
      expect(result.keys, ['error']);
      final error = result['error'] as Map<String, dynamic>;
      expect(error['exitCode'], exitCode.code);
      return error;
    }

    test('reports a missing game', () async {
      final error = await runError(['tree', '--json'], ExitCode.unavailable);
      expect(error['kind'], 'unavailable');
      expect(error['message'], contains('No running game was found'));
    });

    test('reports invalid options of a command', () async {
      final error = await runError([
        'step',
        '--json',
        '--frames',
        '0',
      ], ExitCode.usage);
      expect(error['kind'], 'usage');
      expect(error['message'], '--frames has to be a positive integer.');
    });

    test('reports options that cannot be parsed', () async {
      final error = await runError([
        'pause',
        '--json',
        '--unknown',
      ], ExitCode.usage);
      expect(error['kind'], 'usage');
      expect(error['message'], contains('unknown'));
    });

    test('reports invalid input files', () async {
      final error = await runError([
        'diff',
        'missing.png',
        'missing.png',
        '--json',
      ], ExitCode.data);
      expect(error['kind'], 'data');
      expect(error['message'], contains('Could not read'));
    });

    test('are printed as text without --json', () async {
      final runner = FlameCommandRunner(
        out: out,
        err: err,
        workingDirectory: directory,
      );
      expect(await runner.run(['tree']), ExitCode.unavailable.code);
      expect(out.toString(), isEmpty);
      expect(err.toString(), contains('No running game was found'));
    });
  });

  test('every command that prints a result has --json', () {
    final runner = FlameCommandRunner(out: out, err: err);
    final withoutJson = <String>[];
    void check(Iterable<Command<int>> commands, String prefix) {
      for (final command in commands.toSet()) {
        final name = '$prefix${command.name}';
        if (command.subcommands.isNotEmpty) {
          check(command.subcommands.values, '$name ');
        } else if (!command.argParser.options.containsKey('json')) {
          withoutJson.add(name);
        }
      }
    }

    check(runner.commands.values.where((c) => c.name != 'help'), '');
    expect(withoutJson, ['run']);
  });

  test('exit code names match the ExitCode constants', () {
    for (final exitCode in [
      ExitCode.success,
      ExitCode.usage,
      ExitCode.data,
      ExitCode.unavailable,
      ExitCode.software,
      ExitCode.cantCreate,
      ExitCode.tempFail,
    ]) {
      expect(exitCode.toString(), startsWith('${exitCodeName(exitCode)}:'));
    }
  });
}
