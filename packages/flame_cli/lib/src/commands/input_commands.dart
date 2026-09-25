import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_connection.dart';

/// Sends taps, drags and key presses to the game.
class InputCommand extends Command<int> {
  InputCommand(StringSink out, Directory workingDirectory) {
    addSubcommand(_TapCommand(out, workingDirectory));
    addSubcommand(_DragCommand(out, workingDirectory));
    addSubcommand(_KeyCommand(out, workingDirectory));
  }

  @override
  String get name => 'input';

  @override
  String get description =>
      'Send a tap, a drag or a key press to the game, to play it from the '
      'terminal.';
}

class _TapCommand extends FlameCommand {
  _TapCommand(super.out, super.workingDirectory);

  @override
  String get name => 'tap';

  @override
  String get description =>
      'Tap the game at a position, in the same coordinates as a snapshot.';

  @override
  String get invocation => 'flame input tap <x,y>';

  late ({double x, double y}) _position;

  @override
  void validate() {
    final rest = argResults!.rest;
    if (rest.length != 1) {
      throw UsageException('Pass one position as x,y.', usage);
    }
    _position = parsePosition(this, rest.single);
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    await connection.call(
      'tap',
      args: {'x': '${_position.x}', 'y': '${_position.y}'},
    );
    out.writeln('Tapped at ${_position.x},${_position.y}.');
    return ExitCodes.success;
  }
}

class _DragCommand extends FlameCommand {
  _DragCommand(super.out, super.workingDirectory) {
    argParser.addOption(
      'steps',
      abbr: 's',
      help: 'The number of drag updates between the start and the end.',
      defaultsTo: '10',
    );
  }

  @override
  String get name => 'drag';

  @override
  String get description =>
      'Drag across the game from one position to another, in the same '
      'coordinates as a snapshot.';

  @override
  String get invocation => 'flame input drag <from x,y> <to x,y>';

  late ({double x, double y}) _from;
  late ({double x, double y}) _to;
  late int _steps;

  @override
  void validate() {
    final rest = argResults!.rest;
    if (rest.length != 2) {
      throw UsageException('Pass two positions as x,y, from and to.', usage);
    }
    _from = parsePosition(this, rest[0]);
    _to = parsePosition(this, rest[1]);
    final steps = int.tryParse(argResults!.option('steps')!);
    if (steps == null || steps < 1) {
      throw UsageException('--steps has to be a positive integer.', usage);
    }
    _steps = steps;
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    await connection.call(
      'drag',
      args: {
        'fromX': '${_from.x}',
        'fromY': '${_from.y}',
        'toX': '${_to.x}',
        'toY': '${_to.y}',
        'steps': '$_steps',
      },
    );
    out.writeln('Dragged from ${_from.x},${_from.y} to ${_to.x},${_to.y}.');
    return ExitCodes.success;
  }
}

class _KeyCommand extends FlameCommand {
  _KeyCommand(super.out, super.workingDirectory) {
    argParser
      ..addFlag(
        'down',
        negatable: false,
        help: 'Only press the key down, without releasing it.',
      )
      ..addFlag(
        'up',
        negatable: false,
        help: 'Only release the key.',
      );
  }

  @override
  String get name => 'key';

  @override
  String get description =>
      'Press and release a key, such as space, enter, arrowLeft or a.';

  @override
  String get invocation => 'flame input key <key name>';

  late String _key;
  late String _action;

  @override
  void validate() {
    final rest = argResults!.rest;
    if (rest.length != 1) {
      throw UsageException('Pass the name of one key.', usage);
    }
    _key = rest.single;
    final down = argResults!.flag('down');
    final up = argResults!.flag('up');
    if (down && up) {
      throw UsageException('Pass either --down or --up, not both.', usage);
    }
    _action = down
        ? 'down'
        : up
        ? 'up'
        : 'press';
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    await connection.call('key', args: {'key': _key, 'action': _action});
    out.writeln(switch (_action) {
      'down' => 'Pressed $_key down.',
      'up' => 'Released $_key.',
      _ => 'Pressed $_key.',
    });
    return ExitCodes.success;
  }
}

/// Parses a position given as `x,y`.
({double x, double y}) parsePosition(Command<int> command, String value) {
  final parts = value.split(',').map(double.tryParse).toList();
  if (parts.length != 2 || parts.any((p) => p == null || !p.isFinite)) {
    throw UsageException(
      'A position has to be two numbers separated by a comma, got $value.',
      command.usage,
    );
  }
  return (x: parts[0]!, y: parts[1]!);
}
