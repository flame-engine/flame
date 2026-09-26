import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/commands/control_commands.dart';
import 'package:flame_cli/src/commands/create_command.dart';
import 'package:flame_cli/src/commands/debug_command.dart';
import 'package:flame_cli/src/commands/diff_command.dart';
import 'package:flame_cli/src/commands/game_loop_commands.dart';
import 'package:flame_cli/src/commands/input_commands.dart';
import 'package:flame_cli/src/commands/inspect_command.dart';
import 'package:flame_cli/src/commands/logs_command.dart';
import 'package:flame_cli/src/commands/overlay_commands.dart';
import 'package:flame_cli/src/commands/run_command.dart';
import 'package:flame_cli/src/commands/set_command.dart';
import 'package:flame_cli/src/commands/snapshot_command.dart';
import 'package:flame_cli/src/commands/tree_command.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';

/// The runner of the `flame` command, which returns the exit code instead of
/// throwing when a command fails.
class FlameCommandRunner extends CommandRunner<int> {
  FlameCommandRunner({
    StringSink? out,
    StringSink? err,
    Directory? workingDirectory,
    ProcessStarter? startProcess,
    Stream<List<int>>? input,
  }) : _err = err ?? stderr,
       super(
         'flame',
         'Launch, observe, change and play Flame games that are running in '
             'debug mode.',
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

  final StringSink _err;

  @override
  Future<int> run(Iterable<String> args) async {
    try {
      return await super.run(args) ?? ExitCodes.success;
    } on UsageException catch (error) {
      _err
        ..writeln(error.message)
        ..writeln()
        ..writeln(error.usage);
      return ExitCodes.usage;
    } on FlameCliException catch (error) {
      _err.writeln(error.message);
      return error.exitCode;
    }
  }
}
