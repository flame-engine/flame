import 'dart:io';

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
import 'package:flame_cli/src/commands/tree_command.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:io/io.dart';

/// The runner of the `flame` command, which returns the exit code instead of
/// throwing when a command fails.
class FlameCommandRunner({
  StringSink? out,
  StringSink? err,
  Directory? workingDirectory,
  ProcessStarter? startProcess,
  GameConnector? connect,
  Stream<List<int>>? input,
}) extends CommandRunner<int> {
  this
    : super(
        'flame',
        'Create Flame games, and launch, observe, change and play the ones '
            'that are running in debug mode.',
      ) {
    final output = out ?? stdout;
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

  final StringSink _err = err ?? stderr;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      return await super.run(args) ?? ExitCode.success.code;
    } on UsageException catch (error) {
      _err
        ..writeln(error.message)
        ..writeln()
        ..writeln(error.usage);
      return ExitCode.usage.code;
    } on FlameCliException catch (error) {
      _err.writeln(error.message);
      return error.exitCode.code;
    }
  }
}
