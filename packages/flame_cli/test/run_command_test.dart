import 'dart:async';
import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'fake_process.dart';

ProcessStarter _starter(
  FutureOr<Process> Function(
    String executable,
    List<String> arguments,
    String? workingDirectory,
  )
  onStart,
) {
  return (
    executable,
    arguments, {
    workingDirectory,
    runInShell = false,
    mode = ProcessStartMode.normal,
  }) async => onStart(executable, arguments, workingDirectory);
}

void main() {
  late Directory directory;
  late StringBuffer out;
  late StringBuffer err;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test');
    out = StringBuffer();
    err = StringBuffer();
  });

  tearDown(() => directory.deleteSync(recursive: true));

  FlameCommandRunner createRunner(
    ProcessStarter startProcess, {
    Stream<List<int>>? input,
  }) {
    return FlameCommandRunner(
      out: out,
      err: err,
      workingDirectory: directory,
      startProcess: startProcess,
      input: input,
    );
  }

  test('runs flutter run and removes the uri file afterwards', () async {
    final file = vmServiceUriFile(directory.absolute)
      ..createSync(recursive: true)
      ..writeAsStringSync('stale');
    late String usedExecutable;
    late List<String> usedArguments;
    String? usedDirectory;
    var staleFileExisted = true;

    final runner = createRunner(
      _starter((executable, arguments, workingDirectory) {
        usedExecutable = executable;
        usedArguments = arguments;
        usedDirectory = workingDirectory;
        staleFileExisted = file.existsSync();
        file.writeAsStringSync('http://127.0.0.1:1/abc=/');
        return FakeProcess(exitCode: 3);
      }),
    );

    final exitCode = await runner.run(['run', '-d', 'macos', '--release']);

    expect(exitCode, 3);
    expect(usedExecutable, 'flutter');
    expect(usedArguments, [
      'run',
      '-d',
      'macos',
      '--release',
      '--vmservice-out-file=${file.path}',
    ]);
    expect(usedDirectory, directory.path);
    expect(staleFileExisted, isFalse);
    expect(file.existsSync(), isFalse);
  });

  test('keeps the files in the root of the project', () async {
    File(p.join(directory.path, 'pubspec.yaml')).createSync();
    final lib = Directory(p.join(directory.path, 'lib'))..createSync();
    late List<String> usedArguments;
    final runner = FlameCommandRunner(
      out: out,
      err: err,
      workingDirectory: lib,
      startProcess: _starter((_, arguments, _) {
        usedArguments = arguments;
        return FakeProcess(exitCode: 0);
      }),
    );

    await runner.run(['run']);

    final uriFile = vmServiceUriFile(directory.absolute);
    expect(usedArguments.last, '--vmservice-out-file=${uriFile.path}');
    expect(projectFile(directory.absolute, logFileName).existsSync(), isTrue);
    expect(flameDirectory(lib).existsSync(), isFalse);
  });

  test('mirrors the output to the terminal and the log', () async {
    final process = FakeProcess();
    final runner = createRunner(_starter((_, _, _) => process));

    final running = runner.run(['run']);
    process
      ..printLine('Launching lib/main.dart')
      ..printError('Something went wrong')
      ..exit(0);

    expect(await running, ExitCodes.success);
    expect(out.toString(), 'Launching lib/main.dart\n');
    expect(err.toString(), 'Something went wrong\n');
    expect(
      projectFile(directory.absolute, logFileName).readAsStringSync(),
      'Launching lib/main.dart\nSomething went wrong\n',
    );
  });

  test('forwards the input to flutter run', () async {
    final process = FakeProcess();
    final input = StreamController<List<int>>();
    final runner = createRunner(
      _starter((_, _, _) => process),
      input: input.stream,
    );

    final running = runner.run(['run']);
    input.add('r'.codeUnits);
    await Future<void>.delayed(Duration.zero);
    process.exit(0);
    await running;
    await input.close();

    expect(process.input, 'r');
  });

  test('prints an introduction before the help of flutter run', () async {
    late List<String> usedArguments;
    final runner = createRunner(
      _starter((_, arguments, _) {
        usedArguments = arguments;
        final process = FakeProcess()..printLine('Usage: flutter run');
        return process..exit(0);
      }),
    );

    expect(await runner.run(['run', '--help']), ExitCodes.success);

    expect(usedArguments, ['run', '--help']);
    expect(out.toString(), startsWith('Run the game with `flutter run`'));
    expect(out.toString(), endsWith('Usage: flutter run\n'));
    expect(flameDirectory(directory.absolute).existsSync(), isFalse);
  });

  test('does not allow --vmservice-out-file', () async {
    final runner = createRunner(
      _starter((_, _, _) => fail('flutter run should not be started')),
    );

    final exitCode = await runner.run([
      'run',
      '--vmservice-out-file=uri.txt',
    ]);

    expect(exitCode, ExitCodes.usage);
    expect(err.toString(), contains('sets --vmservice-out-file itself'));
  });

  test('reports when flutter cannot be started', () async {
    final runner = createRunner(
      _starter(
        (_, _, _) => throw const ProcessException('flutter', [], 'Not found'),
      ),
    );

    expect(await runner.run(['run']), ExitCodes.unavailable);
    expect(err.toString(), contains('Make sure that Flutter is installed'));
  });
}
