import 'dart:io';
import 'dart:typed_data';

import 'package:args/command_runner.dart';
import 'package:flame_cli/src/command_categories.dart';
import 'package:flame_cli/src/commands/flame_command.dart';
import 'package:flame_cli/src/commands/overlay_commands.dart';
import 'package:flame_cli/src/component_tree.dart';
import 'package:flame_cli/src/flame_cli_exception.dart';
import 'package:flame_cli/src/flame_connection.dart';
import 'package:flame_cli/src/json_output.dart';
import 'package:io/io.dart';

/// The clock that the wait commands measure the timeout with and wait between
/// two checks with, which can be replaced to not depend on the real time.
class WaitClock() {
  /// Starts measuring the time, and returns a function that gives the time
  /// that has passed since then.
  Duration Function() start() {
    final stopwatch = Stopwatch()..start();
    return () => stopwatch.elapsed;
  }

  /// Waits for [duration] before the condition is checked again.
  Future<void> sleep(Duration duration) => Future<void>.delayed(duration);
}

/// Waits until a condition holds in the running game, or fails with
/// [ExitCode.tempFail] when it doesn't hold before the timeout.
class WaitCommand(
  StringSink out,
  Directory workingDirectory, {
  GameConnector? connect,
  WaitClock? clock,
}) extends Command<int> {
  this {
    final waitClock = clock ?? WaitClock();
    addSubcommand(
      _WaitComponentCommand(
        out,
        workingDirectory,
        connect: connect,
        clock: waitClock,
      ),
    );
    addSubcommand(
      _WaitOverlayCommand(
        out,
        workingDirectory,
        connect: connect,
        clock: waitClock,
      ),
    );
    for (final paused in [true, false]) {
      addSubcommand(
        _WaitPausedCommand(
          out,
          workingDirectory,
          connect: connect,
          clock: waitClock,
          paused: paused,
        ),
      );
    }
  }

  @override
  String get name => 'wait';

  @override
  String get category => CommandCategories.observing;

  @override
  String get description =>
      'Wait until a component exists or is gone, an overlay is shown or '
      'hidden, or the game is paused or resumed. Exits with '
      '${ExitCode.tempFail.code} when the timeout is reached first.';
}

/// The outcome of checking the condition of a wait command once.
///
/// When the condition [holds], the [text] is printed, otherwise it describes
/// what was found instead, for the message on a timeout.
class _Check(
  final String text, {
  required final bool holds,
  final Object? json,
});

abstract class _WaitConditionCommand(
  super.out,
  super.workingDirectory, {
  required final WaitClock clock,
  super.connect,
}) extends FlameCommand {
  this {
    argParser
      ..addOption(
        'timeout',
        abbr: 't',
        help:
            'The number of seconds to wait for the condition. With 0 the '
            'condition is checked once.',
        defaultsTo: '10',
      )
      ..addOption(
        'interval',
        abbr: 'i',
        help: 'The number of seconds between two checks of the condition.',
        defaultsTo: '0.2',
      )
      ..addFlag(
        'json',
        negatable: false,
        help: 'Print what matched as JSON instead of text.',
      );
  }

  /// What the command waits for, as it is shown when the timeout is reached.
  String get condition;

  /// Checks the condition once against the current state of the game.
  Future<_Check> check(FlameConnection connection);

  late Duration _timeout;
  late Duration _interval;

  @override
  void validate() {
    _timeout = _secondsOption('timeout', allowZero: true);
    _interval = _secondsOption('interval', allowZero: false);
  }

  Duration _secondsOption(String option, {required bool allowZero}) {
    final seconds = double.tryParse(argResults!.option(option)!);
    if (seconds == null ||
        !seconds.isFinite ||
        seconds < 0 ||
        (!allowZero && seconds == 0)) {
      throw UsageException(
        '--$option has to be a ${allowZero ? 'non-negative' : 'positive'} '
        'number of seconds.',
        usage,
      );
    }
    return Duration(microseconds: (seconds * 1000000).round());
  }

  @override
  Future<int> runWithConnection(FlameConnection connection) async {
    final elapsed = clock.start();
    while (true) {
      final left = _timeout - elapsed();
      final result = await check(connection).timeout(
        left > _interval ? left : _interval,
        onTimeout: () => throw FlameCliException(
          'Timed out after ${_formatSeconds(_timeout)} waiting for '
          '$condition, the game did not answer.',
          exitCode: ExitCode.tempFail,
        ),
      );
      if (result.holds) {
        out.writeln(
          argResults!.flag('json') ? toJsonOutput(result.json) : result.text,
        );
        return ExitCode.success.code;
      }

      final remaining = _timeout - elapsed();
      if (remaining <= Duration.zero) {
        throw FlameCliException(
          'Timed out after ${_formatSeconds(_timeout)} waiting for '
          '$condition, ${result.text}.',
          exitCode: ExitCode.tempFail,
        );
      }
      await clock.sleep(remaining < _interval ? remaining : _interval);
    }
  }
}

class _WaitComponentCommand(
  super.out,
  super.workingDirectory, {
  required super.clock,
  super.connect,
}) extends _WaitConditionCommand {
  this {
    argParser
      ..addOption(
        'id',
        help: 'Only match the component with this id.',
      )
      ..addMultiOption(
        'where',
        abbr: 'w',
        splitCommas: false,
        help:
            'Only match the components with an attribute that compares to a '
            'number like this, for example "position.x > 100". The '
            'attributes are position.x, position.y, size.x, size.y, scale.x, '
            'scale.y, angle and priority, and the operators are <, <=, >, '
            '>=, == and !=. Can be given several times.',
      )
      ..addOption(
        'count',
        abbr: 'n',
        help: 'Wait until exactly this number of components match.',
      )
      ..addOption(
        'at-least',
        help: 'Wait until at least this number of components match.',
      )
      ..addFlag(
        'gone',
        negatable: false,
        help:
            'Wait until no components match, for example until the component '
            'with an id has been removed.',
      );
  }

  @override
  String get name => 'component';

  @override
  String get description =>
      'Wait until a component of a type that matches a regular expression '
      '(case insensitive) exists, until a number of them exist, or until '
      'none of them exist.';

  @override
  String get invocation => 'flame wait component [<type pattern>] [arguments]';

  RegExp? _type;
  String? _typeText;
  int? _id;
  late List<_AttributeCondition> _where;
  int? _exact;
  late int _minimum;

  @override
  void validate() {
    super.validate();
    _type = null;
    _typeText = null;
    _id = null;
    _exact = null;
    _minimum = 1;
    final rest = argResults!.rest;
    final id = argResults!.option('id');
    if (rest.length > 1 || (rest.isEmpty && id == null)) {
      throw UsageException(
        'Pass one regular expression for the type of the components, or the '
        'id of a component with --id.',
        usage,
      );
    }

    if (rest.isNotEmpty) {
      _typeText = rest.single;
      try {
        _type = RegExp(rest.single, caseSensitive: false);
      } on FormatException catch (error, stackTrace) {
        Error.throwWithStackTrace(
          UsageException(
            'The type pattern is not a valid regular expression: '
            '${error.message}',
            usage,
          ),
          stackTrace,
        );
      }
    }

    if (id != null) {
      _id = int.tryParse(id);
      if (_id == null) {
        throw UsageException('--id has to be an integer.', usage);
      }
    }

    _where = [
      for (final text in argResults!.multiOption('where'))
        _AttributeCondition.tryParse(text) ??
            (throw UsageException(
              '--where has to be an attribute, an operator and a number, for '
              'example "position.x > 100", got "$text".',
              usage,
            )),
    ];

    final count = argResults!.option('count');
    final atLeast = argResults!.option('at-least');
    final gone = argResults!.flag('gone');
    if ([count, atLeast].nonNulls.length + (gone ? 1 : 0) > 1) {
      throw UsageException(
        'Pass only one of --count, --at-least and --gone.',
        usage,
      );
    }
    if (count != null) {
      _exact = int.tryParse(count);
      if (_exact == null || _exact! < 0) {
        throw UsageException(
          '--count has to be a non-negative integer.',
          usage,
        );
      }
    }
    if (atLeast != null) {
      final minimum = int.tryParse(atLeast);
      if (minimum == null || minimum < 1) {
        throw UsageException('--at-least has to be a positive integer.', usage);
      }
      _minimum = minimum;
    }
    if (gone) {
      _exact = 0;
    }
  }

  String get _filter {
    return [
      if (_typeText != null) 'a type matching $_typeText',
      if (_id != null) 'the id $_id',
      ..._where.map((condition) => condition.text),
    ].join(' and ');
  }

  @override
  String get condition {
    final quantity = switch ((_exact, _minimum)) {
      (0, _) => 'no components',
      (1, _) => 'exactly 1 component',
      (final int exact, _) => 'exactly $exact components',
      (null, 1) => 'a component',
      (null, final minimum) => 'at least $minimum components',
    };
    return '$quantity with $_filter';
  }

  bool _matches(Map<String, dynamic> node) {
    final attributes =
        (node['attributes'] as Map<String, dynamic>?) ?? const {};
    return (_type?.hasMatch(node['name'] as String) ?? true) &&
        (_id == null || node['id'] == _id) &&
        _where.every((condition) => condition.holdsFor(attributes));
  }

  @override
  Future<_Check> check(FlameConnection connection) async {
    final response = await connection.call('getComponentTree');
    final tree = response['component_tree'] as Map<String, dynamic>?;
    final matches = tree == null
        ? <Map<String, dynamic>>[]
        : findComponentNodes(tree, _matches);
    final count = matches.length;
    final exact = _exact;
    final holds = exact == null ? count >= _minimum : count == exact;
    if (!holds) {
      return _Check('found $count', holds: false);
    }

    final noun = count == 1 ? 'component' : 'components';
    final text = count == 0
        ? 'Found no components with $_filter.'
        : [
            'Found $count $noun with $_filter:',
            for (final node in matches)
              formatComponentTree(node, maxDepth: 0).trimRight(),
          ].join('\n');
    return _Check(
      text,
      holds: true,
      json: {
        'components': [
          for (final node in matches) {...node}..remove('children'),
        ],
      },
    );
  }
}

class _WaitOverlayCommand(
  super.out,
  super.workingDirectory, {
  required super.clock,
  super.connect,
}) extends _WaitConditionCommand {
  this {
    argParser.addFlag(
      'hidden',
      negatable: false,
      help: 'Wait until the overlay is hidden instead of shown.',
    );
  }

  @override
  String get name => 'overlay';

  @override
  String get description => 'Wait until an overlay is shown or hidden.';

  @override
  String get invocation => 'flame wait overlay <overlay name> [arguments]';

  late String _overlay;

  bool get _shown => !argResults!.flag('hidden');

  @override
  void validate() {
    super.validate();
    _overlay = overlayNameArgument(this);
  }

  @override
  String get condition =>
      'the overlay $_overlay to be ${_shown ? 'shown' : 'hidden'}';

  @override
  Future<_Check> check(FlameConnection connection) async {
    final response = await connection.call('getOverlays');
    final overlays = (response['overlays'] as List).cast<String>();
    final active = ((response['active'] as List?) ?? []).cast<String>();
    if (!overlays.contains(_overlay)) {
      throw FlameCliException(
        'Unknown overlay: $_overlay, use the overlays command to list them.',
        exitCode: ExitCode.data,
      );
    }

    if (active.contains(_overlay) != _shown) {
      return _Check(
        active.isEmpty
            ? 'no overlays are shown'
            : 'the shown overlays are ${active.join(', ')}',
        holds: false,
      );
    }
    return _Check(
      'The overlay $_overlay is ${_shown ? 'shown' : 'hidden'}.',
      holds: true,
      json: {'overlays': overlays, 'active': active},
    );
  }
}

class _WaitPausedCommand(
  super.out,
  super.workingDirectory, {
  required super.clock,
  required final bool paused,
  super.connect,
}) extends _WaitConditionCommand {
  @override
  String get name => paused ? 'paused' : 'resumed';

  @override
  String get description => paused
      ? 'Wait until the game loop is paused.'
      : 'Wait until the game loop is running.';

  @override
  String get condition => 'the game to be ${paused ? 'paused' : 'running'}';

  @override
  Future<_Check> check(FlameConnection connection) async {
    final response = await connection.call('getPaused');
    final isPaused = response['paused'] == true;
    if (isPaused != paused) {
      return _Check('it is ${isPaused ? 'paused' : 'running'}', holds: false);
    }
    return _Check(
      'The game is ${isPaused ? 'paused' : 'running'}.',
      holds: true,
      json: {'paused': isPaused},
    );
  }
}

/// A comparison of a numeric attribute of a component with a number, as it
/// is given to `--where`.
class _AttributeCondition._(
  final String text,
  final String _attribute,
  final int? _index,
  final String _operator,
  final double _value,
) {
  static final _pattern = RegExp(
    r'^\s*([a-z]+)(?:\.([xy]))?\s*(<=|>=|==|!=|<|>)\s*(\S+)\s*$',
  );
  static const _vectors = {'position', 'size', 'scale'};
  static const _numbers = {'angle', 'priority'};

  static _AttributeCondition? tryParse(String text) {
    final match = _pattern.firstMatch(text);
    if (match == null) {
      return null;
    }
    final attribute = match[1]!;
    final axis = match[2];
    final number = double.tryParse(match[4]!);
    final value = axis == null || number == null
        ? number
        : Float32List.fromList([number]).first;
    final isValid = axis == null
        ? _numbers.contains(attribute)
        : _vectors.contains(attribute);
    if (!isValid || value == null || !value.isFinite) {
      return null;
    }
    final name = axis == null ? attribute : '$attribute.$axis';
    return _AttributeCondition._(
      '$name ${match[3]} ${match[4]}',
      attribute,
      axis == null ? null : (axis == 'x' ? 0 : 1),
      match[3]!,
      value,
    );
  }

  bool holdsFor(Map<String, dynamic> attributes) {
    final attribute = attributes[_attribute];
    final actual = switch ((attribute, _index)) {
      (final List<dynamic> vector, final int index) => vector[index] as num,
      (final num number, null) => number,
      _ => null,
    };
    if (actual == null) {
      return false;
    }
    return switch (_operator) {
      '<' => actual < _value,
      '<=' => actual <= _value,
      '>' => actual > _value,
      '>=' => actual >= _value,
      '==' => actual == _value,
      _ => actual != _value,
    };
  }
}

String _formatSeconds(Duration duration) {
  final seconds = duration.inMicroseconds / Duration.microsecondsPerSecond;
  final text = seconds == seconds.roundToDouble()
      ? seconds.toInt().toString()
      : seconds.toString();
  return '$text ${seconds == 1 ? 'second' : 'seconds'}';
}
