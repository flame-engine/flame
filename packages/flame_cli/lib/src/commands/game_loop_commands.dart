import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:io/io.dart';

/// Pauses the game loop.
class PauseCommand(super.out, super.workingDirectory) extends FlameCommand {
  @override
  String get name => 'pause';

  @override
  String get category => CommandCategories.changing;

  @override
  String get description =>
      'Pause the game loop, so that snapshots are stable and the game can be '
      'stepped.';

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    await connection.setPaused(paused: true);
    out.writeln('Paused the game.');
    return ExitCode.success.code;
  }
}

/// Resumes the game loop.
class ResumeCommand(super.out, super.workingDirectory) extends FlameCommand {
  @override
  String get name => 'resume';

  @override
  String get category => CommandCategories.changing;

  @override
  String get description => 'Resume the game loop after it was paused.';

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    await connection.setPaused(paused: false);
    out.writeln('Resumed the game.');
    return ExitCode.success.code;
  }
}

/// Advances the paused game by a number of frames.
class StepCommand(super.out, super.workingDirectory) extends FlameCommand {
  this {
    argParser
      ..addOption(
        'time',
        abbr: 't',
        help: 'The time in seconds that passes in each frame.',
        defaultsTo: '0.016667',
      )
      ..addOption(
        'frames',
        abbr: 'n',
        help: 'The number of frames to step.',
        defaultsTo: '1',
      );
  }

  @override
  String get name => 'step';

  @override
  String get category => CommandCategories.changing;

  @override
  String get description =>
      'Advance the game by a number of frames, pausing it first if it is '
      'running.';

  late double _time;
  late int _frames;

  @override
  void validate() {
    final time = double.tryParse(argResults!.option('time')!);
    if (time == null || !time.isFinite || time <= 0) {
      throw UsageException('--time has to be a positive number.', usage);
    }
    final frames = int.tryParse(argResults!.option('frames')!);
    if (frames == null || frames <= 0) {
      throw UsageException('--frames has to be a positive integer.', usage);
    }
    _time = time;
    _frames = frames;
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    if (!await connection.getPaused()) {
      await connection.setPaused(paused: true);
      out.writeln('Paused the game.');
    }
    for (var i = 0; i < _frames; i++) {
      await connection.step(_time);
    }
    final seconds = (_time * _frames).toStringAsFixed(3);
    out.writeln(
      'Stepped $_frames ${_frames == 1 ? 'frame' : 'frames'}, $seconds '
      'seconds in total.',
    );
    return ExitCode.success.code;
  }
}
