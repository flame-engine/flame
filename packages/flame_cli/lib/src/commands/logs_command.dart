import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/project_files.dart';

/// Prints the output of the `flutter run` that `flame run` started.
class LogsCommand extends Command<int> {
  LogsCommand(this.out, this.workingDirectory) {
    argParser
      ..addOption(
        'lines',
        abbr: 'n',
        help: 'The number of lines from the end of the log to print.',
        defaultsTo: '100',
      )
      ..addFlag(
        'follow',
        abbr: 'f',
        negatable: false,
        help:
            'Keep printing new output until the game is stopped or Ctrl+C is '
            'pressed.',
      );
  }

  final StringSink out;
  final Directory workingDirectory;

  @override
  String get name => 'logs';

  @override
  String get category => CommandCategories.launching;

  @override
  String get description =>
      'Print the output of the game, which has to have been started with '
      '`flame run`. The log is kept after the game has stopped.';

  @override
  Future<int> run() async {
    final lines = int.tryParse(argResults!.option('lines')!);
    if (lines == null || lines < 0) {
      throw UsageException('--lines has to be a non-negative integer.', usage);
    }

    final logFile = findProjectFile(workingDirectory, logFileName);
    if (logFile == null) {
      throw const FlameCliException(
        'No log was found. Start the game with `flame run` to record its '
        'output.',
        exitCode: ExitCodes.unavailable,
      );
    }

    final content = logFile.readAsStringSync();
    final allLines = const LineSplitter().convert(content);
    final start = allLines.length > lines ? allLines.length - lines : 0;
    for (final line in allLines.skip(start)) {
      out.writeln(line);
    }

    if (argResults!.flag('follow')) {
      await _follow(logFile, content.length);
    }
    return ExitCodes.success;
  }

  Future<void> _follow(File logFile, int position) async {
    final portFile = projectFile(
      logFile.parent.parent.parent,
      controlPortFileName,
    );
    var offset = position;
    while (portFile.existsSync()) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final length = logFile.lengthSync();
      if (length > offset) {
        final stream = logFile.openRead(offset, length);
        await for (final chunk in stream.transform(utf8.decoder)) {
          out.write(chunk);
        }
        offset = length;
      }
    }
  }
}
