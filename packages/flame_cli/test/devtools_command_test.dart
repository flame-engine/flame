import 'dart:async';
import 'dart:io';

import 'package:flame_cli/flame_cli.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';

import 'fake_process.dart';

const _uri = 'http://127.0.0.1:1/abc=/';

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

/// A connection to a game that is reachable at [uri], and that records
/// whether it was disposed.
class _FakeConnection implements FlameConnection {
  _FakeConnection(this.uri);

  @override
  final String uri;

  bool disposed = false;

  @override
  Future<Map<String, dynamic>> call(
    String method, {
    Map<String, String>? args,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> dispose() async {
    disposed = true;
  }
}

void main() {
  late Directory directory;
  late StringBuffer out;
  late StringBuffer err;
  late List<_FakeConnection> connections;

  setUp(() {
    directory = Directory.systemTemp.createTempSync('flame_cli_test').absolute;
    out = StringBuffer();
    err = StringBuffer();
    connections = [];
  });

  tearDown(() => directory.deleteSync(recursive: true));

  Future<FlameConnection> connect(String uri) async {
    final connection = _FakeConnection(uri);
    connections.add(connection);
    return connection;
  }

  FlameCommandRunner createRunner(
    ProcessStarter startProcess, {
    Directory? workingDirectory,
    GameConnector? connect,
  }) {
    return FlameCommandRunner(
      out: out,
      err: err,
      workingDirectory: workingDirectory ?? directory,
      startProcess: startProcess,
      connect: connect,
    );
  }

  test('opens the devtools for the game started with flame run', () async {
    vmServiceUriFile(directory)
      ..createSync(recursive: true)
      ..writeAsStringSync(_uri);
    final lib = Directory(p.join(directory.path, 'lib'))..createSync();
    late String usedExecutable;
    late List<String> usedArguments;
    String? usedDirectory;
    final runner = createRunner(
      _starter((executable, arguments, workingDirectory) {
        usedExecutable = executable;
        usedArguments = arguments;
        usedDirectory = workingDirectory;
        return FakeProcess(exitCode: 0);
      }),
      workingDirectory: lib,
      connect: connect,
    );

    expect(await runner.run(['devtools']), ExitCode.success.code);

    expect(usedExecutable, 'dart');
    expect(usedArguments, ['devtools', _uri]);
    expect(usedDirectory, lib.path);
    expect(connections.map((c) => c.uri), [_uri]);
    expect(connections.single.disposed, isTrue);
  });

  test('enables the extension in the root of the project', () async {
    File(p.join(directory.path, 'pubspec.yaml')).createSync();
    final lib = Directory(p.join(directory.path, 'lib'))..createSync();
    final runner = createRunner(
      _starter((_, _, _) => FakeProcess(exitCode: 0)),
      workingDirectory: lib,
      connect: connect,
    );

    await runner.run(['devtools', '--uri', _uri]);

    final optionsFile = File(p.join(directory.path, devToolsOptionsFileName));
    expect(optionsFile.readAsStringSync(), contains('- flame: true'));
    expect(out.toString(), contains('Enabled the Flame DevTools extension'));
  });

  test('does not touch an options file that enables the extension', () async {
    final optionsFile = File(p.join(directory.path, devToolsOptionsFileName))
      ..writeAsStringSync('extensions:\n  - flame: true\n');
    final runner = createRunner(
      _starter((_, _, _) => FakeProcess(exitCode: 0)),
      connect: connect,
    );

    await runner.run(['devtools', '--uri', _uri]);

    expect(optionsFile.readAsStringSync(), 'extensions:\n  - flame: true\n');
    expect(out.toString(), isNot(contains('Enabled')));
  });

  test('opens the devtools for the given uri', () async {
    late List<String> usedArguments;
    final runner = createRunner(
      _starter((_, arguments, _) {
        usedArguments = arguments;
        return FakeProcess(exitCode: 0);
      }),
      connect: connect,
    );

    expect(await runner.run(['devtools', '-u', _uri]), ExitCode.success.code);

    expect(usedArguments, ['devtools', _uri]);
    expect(connections.map((c) => c.uri), [_uri]);
  });

  test('only prints the url with --no-launch-browser', () async {
    late List<String> usedArguments;
    final runner = createRunner(
      _starter((_, arguments, _) {
        usedArguments = arguments;
        return FakeProcess(exitCode: 0);
      }),
      connect: connect,
    );

    await runner.run(['devtools', '--no-launch-browser', '--uri', _uri]);

    expect(usedArguments, ['devtools', '--no-launch-browser', _uri]);
  });

  test('mirrors the output and exit code of dart devtools', () async {
    final process = FakeProcess();
    final runner = createRunner(
      _starter((_, _, _) => process),
      connect: connect,
    );

    final running = runner.run(['devtools', '--uri', _uri]);
    process
      ..printLine('Serving DevTools at http://127.0.0.1:9100.')
      ..printError('Something went wrong')
      ..exit(3);

    expect(await running, 3);
    expect(
      out.toString(),
      endsWith('Serving DevTools at http://127.0.0.1:9100.\n'),
    );
    expect(err.toString(), 'Something went wrong\n');
  });

  test('needs a running game', () async {
    final runner = createRunner(
      _starter((_, _, _) => fail('dart devtools should not be started')),
      connect: connect,
    );

    expect(await runner.run(['devtools']), ExitCode.unavailable.code);
    expect(err.toString(), contains('No running game was found'));
    expect(connections, isEmpty);
  });

  test('reports when the game cannot be reached', () async {
    vmServiceUriFile(directory)
      ..createSync(recursive: true)
      ..writeAsStringSync(_uri);
    final runner = createRunner(
      _starter((_, _, _) => fail('dart devtools should not be started')),
      connect: (uri) => throw FlameCliException(
        'Could not connect to the Dart VM Service at $uri',
        exitCode: ExitCode.unavailable,
      ),
    );

    expect(await runner.run(['devtools']), ExitCode.unavailable.code);
    expect(err.toString(), contains('Could not connect to the Dart VM'));
    expect(err.toString(), contains('might have been stopped'));
  });

  test('reports when dart cannot be started', () async {
    final runner = createRunner(
      _starter(
        (_, _, _) => throw const ProcessException('dart', [], 'Not found'),
      ),
      connect: connect,
    );

    expect(
      await runner.run(['devtools', '-u', _uri]),
      ExitCode.unavailable.code,
    );
    expect(err.toString(), contains('Could not start `dart devtools`'));
    expect(err.toString(), contains('Make sure that the Dart SDK'));
  });
}
