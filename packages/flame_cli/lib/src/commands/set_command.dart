import 'package:args/command_runner.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/commands/inspect_command.dart';
import 'package:flame_cli/src/exit_codes.dart';
import 'package:flame_cli/src/flame_connection.dart';

/// Changes the attributes of a component.
class SetCommand extends FlameCommand {
  SetCommand(super.out, super.workingDirectory) {
    argParser
      ..addOption(
        'position',
        help: 'The position of the component, as x,y.',
      )
      ..addOption(
        'size',
        help: 'The size of the component, as width,height.',
      )
      ..addOption(
        'angle',
        help: 'The angle of the component, in radians.',
      )
      ..addOption(
        'scale',
        help: 'The scale of the component, as x,y or a single number.',
      )
      ..addOption(
        'anchor',
        help:
            'The anchor of the component, for example center, topLeft or '
            'bottomRight, or as x,y between 0 and 1.',
      )
      ..addOption(
        'priority',
        help: 'The render priority of the component.',
      );
  }

  @override
  String get name => 'set';

  @override
  String get description =>
      'Change the position, size, angle, scale, anchor or priority of a '
      'component.';

  @override
  String get invocation => 'flame set <component id> [options]';

  late String _id;
  late Map<String, String> _values;

  @override
  void validate() {
    _id = componentIdArgument(this);
    _values = {
      ...?_vector('position', 'x', 'y'),
      ...?_vector('size', 'width', 'height'),
      ...?_number('angle'),
      ...?_vector('scale', 'scaleX', 'scaleY', allowSingle: true),
      ...?_anchor(),
      ...?_number('priority', integer: true),
    };
    if (_values.isEmpty) {
      throw UsageException('Pass at least one attribute to change.', usage);
    }
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    for (final entry in _values.entries) {
      await connection.call(
        'setPositionComponentAttributes',
        args: {'id': _id, 'attribute': entry.key, 'value': entry.value},
      );
    }
    final info = await connection.call('getComponentInfo', args: {'id': _id});
    out.write(formatComponentInfo(info));
    return ExitCodes.success;
  }

  Map<String, String>? _number(String option, {bool integer = false}) {
    final value = argResults!.option(option);
    if (value == null) {
      return null;
    }
    final parsed = integer ? int.tryParse(value) : double.tryParse(value);
    if (parsed == null) {
      throw UsageException('--$option has to be a number, got $value.', usage);
    }
    return {option: parsed.toString()};
  }

  Map<String, String>? _vector(
    String option,
    String xAttribute,
    String yAttribute, {
    bool allowSingle = false,
  }) {
    final value = argResults!.option(option);
    if (value == null) {
      return null;
    }
    final parts = value.split(',').map(double.tryParse).toList();
    if (parts.length == 1 && allowSingle && parts.single != null) {
      parts.add(parts.single);
    }
    if (parts.length != 2 || parts.contains(null)) {
      throw UsageException(
        '--$option has to be two numbers separated by a comma, got $value.',
        usage,
      );
    }
    return {
      xAttribute: parts[0].toString(),
      yAttribute: parts[1].toString(),
    };
  }

  Map<String, String>? _anchor() {
    final value = argResults!.option('anchor');
    if (value == null) {
      return null;
    }
    if (RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return {'anchor': value};
    }
    final parts = value.split(',').map(double.tryParse).toList();
    if (parts.length != 2 || parts.contains(null)) {
      throw UsageException(
        '--anchor has to be a name like center, or two numbers separated by '
        'a comma, got $value.',
        usage,
      );
    }
    return {'anchor': 'Anchor(${parts[0]}, ${parts[1]})'};
  }
}
