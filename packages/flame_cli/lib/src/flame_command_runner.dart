import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/commands/run_command.dart';
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
  }) : _err = err ?? stderr,
       super(
         'flame',
         'Inspect and control Flame games that are running in debug mode.',
       ) {
    final output = out ?? stdout;
    final directory = workingDirectory ?? Directory.current;
    addCommand(RunCommand(directory, startProcess: startProcess));
    addCommand(SnapshotCommand(output, directory));
    addCommand(TreeCommand(output, directory));
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
