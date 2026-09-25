import 'dart:async';
import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:test/test.dart';

class _FakeProcess implements Process {
  _FakeProcess(int code) : exitCode = Future.value(code);

  @override
  final Future<int> exitCode;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
  late StringBuffer err;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test');
    err = StringBuffer();
  });

  tearDown(() => directory.deleteSync(recursive: true));

  FlameCommandRunner createRunner(ProcessStarter startProcess) {
    return FlameCommandRunner(
      err: err,
      workingDirectory: directory,
      startProcess: startProcess,
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
        return _FakeProcess(3);
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
