import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/vm_service_uri_file.dart';

/// Starts a process, with the same signature as [Process.start].
typedef ProcessStarter =
    Future<Process> Function(
      String executable,
      List<String> arguments, {
      String? workingDirectory,
      bool runInShell,
      ProcessStartMode mode,
    });

/// Runs the game with `flutter run` and writes the Dart VM Service URI of the
/// game to a file in the project, so that the other commands can find the game
/// without the `--uri` option.
class RunCommand extends Command<int> {
  RunCommand(this.workingDirectory, {ProcessStarter? startProcess})
    : _startProcess = startProcess ?? Process.start;

  final Directory workingDirectory;
  final ProcessStarter _startProcess;
  final _argParser = ArgParser.allowAnything();

  @override
  ArgParser get argParser => _argParser;

  @override
  String get name => 'run';

  @override
  String get description =>
      'Run the game with `flutter run`, so that the other commands can find '
      'it without --uri. All the arguments are passed on to `flutter run`.';

  @override
  String get invocation => 'flame run [flutter run arguments]';

  @override
  Future<int> run() async {
    final arguments = argResults!.rest;
    if (arguments.any((a) => a.startsWith('--vmservice-out-file'))) {
      throw UsageException(
        'flame run sets --vmservice-out-file itself, remove it from the '
        'arguments.',
        usage,
      );
    }

    final file = vmServiceUriFile(workingDirectory.absolute);
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.parent.createSync(recursive: true);

    final Process process;
    try {
      process = await _startProcess(
        'flutter',
        ['run', ...arguments, '--vmservice-out-file=${file.path}'],
        workingDirectory: workingDirectory.path,
        runInShell: Platform.isWindows,
        mode: ProcessStartMode.inheritStdio,
      );
    } on ProcessException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        FlameCliException(
          'Could not start `flutter run`: ${error.message}\n'
          'Make sure that Flutter is installed and on your PATH.',
          exitCode: ExitCodes.unavailable,
        ),
        stackTrace,
      );
    }

    // Ctrl+C is sent to `flutter run` as well, so it is ignored here to be
    // able to remove the file after `flutter run` has stopped the game.
    final interrupts = ProcessSignal.sigint.watch().listen((_) {});
    try {
      return await process.exitCode;
    } finally {
      await interrupts.cancel();
      if (file.existsSync()) {
        file.deleteSync();
      }
    }
  }
}
