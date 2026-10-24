import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/game_responses.dart';
import 'package:io/io.dart';

/// Sends taps, drags and key presses to the game.
class InputCommand(StringSink out, Directory workingDirectory)
    extends Command<int> {
  this {
    addSubcommand(_TapCommand(out, workingDirectory));
    addSubcommand(_DragCommand(out, workingDirectory));
    addSubcommand(_KeyCommand(out, workingDirectory));
  }

  @override
  String get name => 'input';

  @override
  String get category => CommandCategories.playing;

  @override
  String get description =>
      'Send a tap, a drag or a key press to the game, to play it from the '
      'terminal.';
}

class _TapCommand(super.out, super.workingDirectory) extends FlameCommand {
  this {
    argParser
      ..addOption(
        'component',
        abbr: 'c',
        help:
            'Tap a component instead of a position: its id, from the tree '
            'command, or the name of its ComponentKey.',
      )
      ..addOption(
        'anchor',
        abbr: 'a',
        help:
            'The point of the component to tap, as a name like center or '
            'topLeft, or as x,y between 0 and 1.',
        defaultsTo: 'center',
      );
  }

  @override
  String get name => 'tap';

  @override
  String get description =>
      'Tap the game at a position, in the same coordinates as a snapshot, or '
      'on a component.';

  @override
  String get invocation =>
      'flame input tap <x,y>\n'
      '       flame input tap --component <id or key> [--anchor <anchor>]';

  late InputTarget _target;

  @override
  void validate() {
    final rest = argResults!.rest;
    final component = argResults!.option('component');
    if (rest.length != (component == null ? 1 : 0)) {
      throw UsageException(
        'Pass one position as x,y, or a component with --component.',
        usage,
      );
    }
    _target = InputTarget.parse(
      this,
      position: rest.firstOrNull,
      component: component,
      anchor: _anchorOption(this, 'anchor', component),
    );
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final position = await _target.resolve(connection);
    await connection.tap(position);
    final at = _target.component == null ? 'at ' : '';
    writeResult(
      {
        'input': 'tap',
        'position': _positionJson(position),
        'component': ?_target.component?.toJson(),
      },
      'Tapped $at${_target.describe(position)}.',
    );
    return ExitCode.success.code;
  }
}

class _DragCommand(super.out, super.workingDirectory) extends FlameCommand {
  this {
    argParser
      ..addOption(
        'from-component',
        help:
            'Start the drag on a component instead of a position: its id, '
            'from the tree command, or the name of its ComponentKey.',
      )
      ..addOption(
        'to-component',
        help:
            'End the drag on a component instead of a position: its id, '
            'from the tree command, or the name of its ComponentKey.',
      )
      ..addOption(
        'from-anchor',
        help:
            'The point of the component that the drag starts on, as a name '
            'like center or topLeft, or as x,y between 0 and 1.',
        defaultsTo: 'center',
      )
      ..addOption(
        'to-anchor',
        help:
            'The point of the component that the drag ends on, as a name '
            'like center or topLeft, or as x,y between 0 and 1.',
        defaultsTo: 'center',
      )
      ..addOption(
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
      'coordinates as a snapshot, or from or to a component.';

  @override
  String get invocation =>
      'flame input drag <from x,y> <to x,y>\n'
      '       flame input drag --from-component <id or key> <to x,y>\n'
      '       flame input drag <from x,y> --to-component <id or key>\n'
      '       flame input drag --from-component <id or key> '
      '--to-component <id or key>';

  late InputTarget _from;
  late InputTarget _to;
  late int _steps;

  @override
  void validate() {
    final rest = [...argResults!.rest];
    final fromComponent = argResults!.option('from-component');
    final toComponent = argResults!.option('to-component');
    final componentCount = [fromComponent, toComponent].nonNulls.length;
    if (rest.length != 2 - componentCount) {
      throw UsageException(
        'Pass two positions as x,y, from and to, where --from-component or '
        '--to-component replaces one of them.',
        usage,
      );
    }
    _from = InputTarget.parse(
      this,
      position: fromComponent == null ? rest.removeAt(0) : null,
      component: fromComponent,
      anchor: _anchorOption(this, 'from-anchor', fromComponent),
    );
    _to = InputTarget.parse(
      this,
      position: toComponent == null ? rest.removeAt(0) : null,
      component: toComponent,
      anchor: _anchorOption(this, 'to-anchor', toComponent),
    );
    final steps = int.tryParse(argResults!.option('steps')!);
    if (steps == null || steps < 1) {
      throw UsageException('--steps has to be a positive integer.', usage);
    }
    _steps = steps;
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final from = await _from.resolve(connection);
    final to = await _to.resolve(connection);
    await connection.drag(from, to, steps: _steps);
    writeResult(
      {
        'input': 'drag',
        'from': _positionJson(from),
        'to': _positionJson(to),
        'fromComponent': ?_from.component?.toJson(),
        'toComponent': ?_to.component?.toJson(),
        'steps': _steps,
      },
      'Dragged from ${_from.describe(from)} to ${_to.describe(to)}.',
    );
    return ExitCode.success.code;
  }
}

/// Reads the anchor option [name], which is only allowed together with a
/// [component].
String? _anchorOption(Command<int> command, String name, String? component) {
  if (!command.argResults!.wasParsed(name)) {
    return null;
  }
  if (component == null) {
    throw UsageException(
      '--$name can only be used together with a component.',
      command.usage,
    );
  }
  return command.argResults!.option(name);
}

class _KeyCommand(super.out, super.workingDirectory) extends FlameCommand {
  this {
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
  late KeyAction _action;

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
        ? KeyAction.down
        : up
        ? KeyAction.up
        : KeyAction.press;
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    await connection.key(_key, action: _action);
    writeResult(
      {'input': 'key', 'key': _key, 'action': _action.name},
      switch (_action) {
        KeyAction.down => 'Pressed $_key down.',
        KeyAction.up => 'Released $_key.',
        KeyAction.press => 'Pressed $_key.',
      },
    );
    return ExitCode.success.code;
  }
}

/// A point that input is sent to, given either as a [position] in canvas
/// coordinates or as a [component], whose canvas position is looked up in the
/// game.
///
/// The [anchor] is the point within the [component], where the game uses the
/// center when it is not given.
class InputTarget._({
  final Vector2? position,
  final ComponentReference? component,
  final String? anchor,
}) {
  /// Creates a target from a [position] given as `x,y`, or from a
  /// [component] with an optional [anchor] when no position is given.
  ///
  /// Throws a [UsageException] for [command] when the position or the anchor
  /// is invalid.
  factory InputTarget.parse(
    Command<int> command, {
    String? position,
    String? component,
    String? anchor,
  }) {
    if (component != null) {
      if (anchor != null && !_isAnchor(anchor)) {
        throw UsageException(
          'An anchor has to be a name like center, or two numbers separated '
          'by a comma, got $anchor.',
          command.usage,
        );
      }
      return InputTarget._(
        component: ComponentReference.parse(component),
        anchor: anchor,
      );
    }
    return InputTarget._(position: parsePosition(command, position!));
  }

  /// Returns the [position], or asks the game through [connection] where the
  /// [component] is on the canvas.
  Future<Vector2> resolve(FlameConnection connection) async {
    return position ??
        await connection.getComponentCanvasPosition(component!, anchor: anchor);
  }

  /// Describes the target, which is at the [resolved] canvas position, for
  /// the output of a command.
  String describe(Vector2 resolved) {
    final at =
        '${formatCoordinate(resolved.x)},${formatCoordinate(resolved.y)}';
    return component == null ? at : 'component $component at $at';
  }

  static bool _isAnchor(String value) {
    if (RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return true;
    }
    final parts = value.split(',').map(double.tryParse).toList();
    return parts.length == 2 && parts.every((p) => p != null && p.isFinite);
  }
}

/// Formats a canvas coordinate with at most two decimals.
String formatCoordinate(double value) {
  final fixed = value.toStringAsFixed(2);
  return fixed.replaceFirst(RegExp(r'\.?0+$'), '');
}

Map<String, double> _positionJson(Vector2 position) {
  return {'x': position.x, 'y': position.y};
}

/// Parses a position given as `x,y`.
Vector2 parsePosition(Command<int> command, String value) {
  final parts = value.split(',').map(double.tryParse).toList();
  if (parts.length != 2 || parts.any((p) => p == null || !p.isFinite)) {
    throw UsageException(
      'A position has to be two numbers separated by a comma, got $value.',
      command.usage,
    );
  }
  return (x: parts[0]!, y: parts[1]!);
}
