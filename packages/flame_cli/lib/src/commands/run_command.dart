import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/project_files.dart';
import 'package:flame_cli/src/run_controller.dart';

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
///
/// The output of `flutter run` is also written to the log file of the project
/// for the `logs` command, and `reload` and `restart` requests are accepted
/// through a [RunController].
class RunCommand extends Command<int> {
  RunCommand(
    this.workingDirectory, {
    ProcessStarter? startProcess,
    this.input,
    this.out,
    this.err,
  }) : _startProcess = startProcess ?? Process.start;

  final Directory workingDirectory;
  final ProcessStarter _startProcess;

  /// Where the output of `flutter run` is mirrored to, the standard output
  /// and error of this process by default.
  final StringSink? out;
  final StringSink? err;

  /// The input of the terminal, which is forwarded to `flutter run` so that
  /// its keys, such as `r` for hot reload, keep working.
  final Stream<List<int>>? input;

  final _argParser = ArgParser.allowAnything();

  @override
  ArgParser get argParser => _argParser;

  @override
  String get name => 'run';

  @override
  String get category => CommandCategories.launching;

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

    final projectDirectory = findProjectRoot(workingDirectory);
    final uriFile = projectFile(projectDirectory, vmServiceUriFileName);
    if (uriFile.existsSync()) {
      uriFile.deleteSync();
    }
    uriFile.parent.createSync(recursive: true);

    final Process process;
    try {
      process = await _startProcess(
        'flutter',
        ['run', ...arguments, '--vmservice-out-file=${uriFile.path}'],
        workingDirectory: workingDirectory.path,
        runInShell: Platform.isWindows,
        mode: ProcessStartMode.normal,
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
    // able to clean up after `flutter run` has stopped the game.
    final interrupts = ProcessSignal.sigint.watch().listen((_) {});
    final rawMode = _enableRawMode();
    try {
      return await RunController(
        process: process,
        projectDirectory: projectDirectory,
        input: input,
        out: out,
        err: err,
      ).run();
    } finally {
      rawMode?.restore();
      await interrupts.cancel();
    }
  }

  /// Puts the terminal in the same mode as `flutter run` does, so that single
  /// keys are forwarded right away instead of after a newline.
  _TerminalMode? _enableRawMode() {
    if (!identical(input, stdin) || !stdin.hasTerminal) {
      return null;
    }
    try {
      final mode = _TerminalMode(
        echoMode: stdin.echoMode,
        lineMode: stdin.lineMode,
      );
      stdin
        ..echoMode = false
        ..lineMode = false;
      return mode;
    } on StdinException {
      return null;
    }
  }
}

class _TerminalMode {
  _TerminalMode({required this.echoMode, required this.lineMode});

  final bool echoMode;
  final bool lineMode;

  void restore() {
    try {
      stdin
        ..echoMode = echoMode
        ..lineMode = lineMode;
    } on StdinException {
      // The terminal went away, there is nothing to restore.
    }
  }
}
