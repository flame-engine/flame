import 'dart:io';

import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:flame_cli/src/commands/control_commands.dart';
import 'package:flame_cli/src/commands/create_command.dart';
import 'package:flame_cli/src/commands/debug_command.dart';
import 'package:flame_cli/src/commands/devtools_command.dart';
import 'package:flame_cli/src/commands/diff_command.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/commands/game_loop_commands.dart';
import 'package:flame_cli/src/commands/input_commands.dart';
import 'package:flame_cli/src/commands/inspect_command.dart';
import 'package:flame_cli/src/commands/logs_command.dart';
import 'package:flame_cli/src/commands/overlay_commands.dart';
import 'package:flame_cli/src/commands/run_command.dart';
import 'package:flame_cli/src/commands/set_command.dart';
import 'package:flame_cli/src/commands/snapshot_command.dart';
import 'package:flame_cli/src/commands/status_command.dart';
import 'package:flame_cli/src/commands/tree_command.dart';
import 'package:flame_cli/src/commands/wait_command.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/json_output.dart';
import 'package:io/io.dart';

/// The runner of the `flame` command, which returns the exit code instead of
/// throwing when a command fails.
///
/// The message of a failure is printed to the standard error, unless the
/// command was called with `--json`. Then the failure is printed as the
/// [JsonError] object to the standard output instead, so that the standard
/// output of a command with `--json` always holds exactly one JSON value.
class FlameCommandRunner({
  StringSink? out,
  StringSink? err,
  Directory? workingDirectory,
  ProcessStarter? startProcess,
  GameConnector? connect,
  Stream<List<int>>? input,
  WaitClock? waitClock,
}) extends CommandRunner<int> {
  this
    : super(
        'flame',
        'Create Flame games, and launch, observe, change and play the ones '
            'that are running in debug mode.',
      ) {
    final output = _out;
    final directory = workingDirectory ?? Directory.current;
    addCommand(
      CreateCommand(output, directory, startProcess: startProcess, err: err),
    );
    addCommand(
      RunCommand(
        directory,
        startProcess: startProcess,
        input: input,
        out: out,
        err: err,
      ),
    );
    addCommand(ReloadCommand(output, directory));
    addCommand(RestartCommand(output, directory));
    addCommand(StopCommand(output, directory));
    addCommand(StatusCommand(output, directory, connect: connect));
    addCommand(LogsCommand(output, directory));
    addCommand(
      DevToolsCommand(
        directory,
        startProcess: startProcess,
        connect: connect,
        out: out,
        err: err,
      ),
    );
    addCommand(SnapshotCommand(output, directory));
    addCommand(TreeCommand(output, directory));
    addCommand(InspectCommand(output, directory));
    addCommand(
      WaitCommand(output, directory, connect: connect, clock: waitClock),
    );
    addCommand(SetCommand(output, directory));
    addCommand(PauseCommand(output, directory));
    addCommand(ResumeCommand(output, directory));
    addCommand(StepCommand(output, directory));
    addCommand(DebugCommand(output, directory));
    addCommand(OverlaysCommand(output, directory));
    addCommand(OverlayCommand(output, directory));
    addCommand(InputCommand(output, directory));
    addCommand(DiffCommand(output, directory));
  }

  final StringSink _out = out ?? stdout;
  final StringSink _err = err ?? stderr;

  /// Connects the commands to the running game.
  final GameConnector connect = connect ?? FlameConnection.connect;

  bool? _jsonOutput;

  @override
  Future<int> run(Iterable<String> args) async {
    _jsonOutput = null;
    try {
      return await super.run(args) ?? ExitCode.success.code;
    } on UsageException catch (error) {
      if (_isJsonOutput(args)) {
        _out.writeln(
          toJsonOutput(JsonError(error.message, ExitCode.usage).toJson()),
        );
      } else {
        _err
          ..writeln(error.message)
          ..writeln()
          ..writeln(error.usage);
      }
      return ExitCode.usage.code;
    } on FlameCliException catch (error) {
      if (_isJsonOutput(args)) {
        _out.writeln(
          toJsonOutput(JsonError(error.message, error.exitCode).toJson()),
        );
      } else {
        _err.writeln(error.message);
      }
      return error.exitCode.code;
    }
  }

  @override
  Future<int?> runCommand(ArgResults topLevelResults) {
    var results = topLevelResults;
    for (var command = results.command; command != null;) {
      results = command;
      command = command.command;
    }
    _jsonOutput = results.options.contains(jsonFlag) && results.flag(jsonFlag);
    return super.runCommand(topLevelResults);
  }

  /// Whether the command was called with `--json`, which is known from the
  /// parsed arguments once they could be parsed, and is otherwise looked up
  /// in the raw [args], to also report invalid arguments as JSON.
  bool _isJsonOutput(Iterable<String> args) {
    return _jsonOutput ??
        args.takeWhile((arg) => arg != '--').contains('--$jsonFlag');
  }
}
