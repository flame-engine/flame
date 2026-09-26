import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'fake_process.dart';

void main() {
  late Directory directory;
  late StringBuffer out;
  late StringBuffer err;
  late List<List<String>> calls;
  late List<String?> callDirectories;
  late FlameCommandRunner runner;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test').absolute;
    out = StringBuffer();
    err = StringBuffer();
    calls = [];
    callDirectories = [];
    runner = FlameCommandRunner(
      out: out,
      err: err,
      workingDirectory: directory,
      startProcess:
          (
            executable,
            arguments, {
            workingDirectory,
            runInShell = false,
            mode = ProcessStartMode.normal,
          }) async {
            expect(executable, 'flutter');
            calls.add(arguments);
            callDirectories.add(workingDirectory);
            if (arguments.first == 'create') {
              final project = Directory(arguments.last)
                ..createSync(recursive: true);
              File(p.join(project.path, 'pubspec.yaml')).createSync();
              File(
                p.join(project.path, 'test', 'widget_test.dart'),
              ).createSync(recursive: true);
            }
            return FakeProcess()
              ..printLine('flutter ${arguments[0]}')
              ..exit(0);
          },
    );
  });

  tearDown(() => directory.deleteSync(recursive: true));

  String read(String path) =>
      File(p.join(directory.path, 'my_game', path)).readAsStringSync();

  test('creates a game from the basics template by default', () async {
    expect(await runner.run(['create', 'my_game']), ExitCodes.success);

    final project = p.join(directory.path, 'my_game');
    expect(calls, [
      [
        'create',
        '--empty',
        '--project-name',
        'my_game',
        '--org',
        'com.example',
        '--description',
        'A new Flame game.',
        project,
      ],
      ['pub', 'remove', 'flutter_lints'],
      ['pub', 'add', 'flame', 'dev:flame_lint', 'dev:flame_test'],
    ]);
    expect(callDirectories, [directory.path, project, project]);
    expect(read('lib/main.dart'), contains('class MyGame extends FlameGame'));
    expect(
      read('test/player_test.dart'),
      contains("import 'package:my_game/main.dart';"),
    );
    expect(
      read('analysis_options.yaml'),
      'include: package:flame_lint/analysis_options.yaml\n',
    );
    expect(
      File(
        p.join(directory.path, 'my_game', 'test', 'widget_test.dart'),
      ).existsSync(),
      isFalse,
    );
    expect(out.toString(), contains('Created the Flame game my_game'));
    expect(out.toString(), contains('flame run'));
  });

  test('passes the options on', () async {
    final exitCode = await runner.run([
      'create',
      'games/my_game',
      '--project-name',
      'space_shooter',
      '--org',
      'org.flame_engine',
      '--description',
      'Pew pew.',
      '--template',
      'simple',
      '--platforms',
      'macos,web',
      '--packages',
      'flame_audio,flame_tiled',
      '--flame-version',
      '^1.30.0',
      '--overwrite',
    ]);

    expect(exitCode, ExitCodes.success);
    expect(calls[0], [
      'create',
      '--empty',
      '--project-name',
      'space_shooter',
      '--org',
      'org.flame_engine',
      '--description',
      'Pew pew.',
      '--platforms=macos,web',
      '--overwrite',
      p.join(directory.path, 'games', 'my_game'),
    ]);
    expect(calls[2], [
      'pub',
      'add',
      'flame@^1.30.0',
      'dev:flame_lint',
      'flame_audio',
      'flame_tiled',
    ]);
    expect(
      Directory(p.join(directory.path, 'games', 'my_game', 'test')).listSync(),
      isEmpty,
    );
  });

  test('writes every file of the example template', () async {
    await runner.run(['create', 'my_game', '-t', 'example']);

    for (final path in CreateTemplate.example.files.keys) {
      expect(
        File(p.join(directory.path, 'my_game', path)).existsSync(),
        isTrue,
        reason: path,
      );
    }
    expect(read('lib/player.dart'), contains('package:my_game/my_game.dart'));
    expect(read('lib/main.dart'), isNot(contains('{{')));
  });

  test('refuses to overwrite an existing project', () async {
    File(
      p.join(directory.path, 'my_game', 'pubspec.yaml'),
    ).createSync(recursive: true);

    expect(await runner.run(['create', 'my_game']), ExitCodes.data);
    expect(err.toString(), contains('already contains a project'));
    expect(calls, isEmpty);
  });

  test('validates the arguments', () async {
    expect(await runner.run(['create']), ExitCodes.usage);
    expect(await runner.run(['create', 'My-Game']), ExitCodes.usage);
    expect(err.toString(), contains('try "my_game" instead'));
    expect(
      await runner.run(['create', 'dir', '--project-name', 'flame']),
      ExitCodes.usage,
    );
    expect(await runner.run(['create', 'dir', '--org', 'com-example']), 64);
    expect(await runner.run(['create', 'dir', '-t', 'fancy']), 64);
    expect(calls, isEmpty);
  });

  test('reports when flutter create fails', () async {
    final runner = FlameCommandRunner(
      out: out,
      err: err,
      workingDirectory: directory,
      startProcess:
          (
            _,
            _, {
            workingDirectory,
            runInShell = false,
            mode = ProcessStartMode.normal,
          }) async => FakeProcess(exitCode: 1),
    );

    expect(await runner.run(['create', 'my_game']), ExitCodes.software);
    expect(err.toString(), contains('failed with exit code 1'));
  });

  group('validateProjectName', () {
    test('accepts valid package names', () {
      expect(validateProjectName('my_game'), isNull);
      expect(validateProjectName('_private'), isNull);
      expect(validateProjectName('game2'), isNull);
    });

    test('rejects invalid names with a suggestion', () {
      expect(validateProjectName('My_Game'), contains('try "my_game" instead'));
      expect(validateProjectName('my-game'), contains('try "my_game"'));
      expect(validateProjectName('2games'), isNot(contains('try')));
      expect(validateProjectName('class'), contains('not a valid'));
      expect(validateProjectName(''), contains('not a valid'));
    });

    test('rejects names that clash with dependencies', () {
      expect(validateProjectName('flame'), contains('clash'));
      expect(validateProjectName('flutter'), contains('clash'));
      expect(validateProjectName('test'), contains('clash'));
    });
  });
}
