import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_connection.dart';

/// Pauses the game loop.
class PauseCommand extends FlameCommand {
  PauseCommand(super.out, super.workingDirectory);

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
    await setPaused(connection, paused: true);
    out.writeln('Paused the game.');
    return ExitCodes.success;
  }
}

/// Resumes the game loop.
class ResumeCommand extends FlameCommand {
  ResumeCommand(super.out, super.workingDirectory);

  @override
  String get name => 'resume';

  @override
  String get category => CommandCategories.changing;

  @override
  String get description => 'Resume the game loop after it was paused.';

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    await setPaused(connection, paused: false);
    out.writeln('Resumed the game.');
    return ExitCodes.success;
  }
}

/// Advances the paused game by a number of frames.
class StepCommand extends FlameCommand {
  StepCommand(super.out, super.workingDirectory) {
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
    final paused = await connection.call('getPaused');
    if (paused['paused'] != true) {
      await setPaused(connection, paused: true);
      out.writeln('Paused the game.');
    }
    for (var i = 0; i < _frames; i++) {
      await connection.call('step', args: {'step_time': _time.toString()});
    }
    final seconds = (_time * _frames).toStringAsFixed(3);
    out.writeln(
      'Stepped $_frames ${_frames == 1 ? 'frame' : 'frames'}, $seconds '
      'seconds in total.',
    );
    return ExitCodes.success;
  }
}

/// Pauses or resumes the game through the `setPaused` service extension.
Future<void> setPaused(
  FlameConnection connection, {
  required bool paused,
}) async {
  await connection.call('setPaused', args: {'paused': paused.toString()});
}
