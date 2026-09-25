import 'dart:convert';
import 'dart:developer';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';

/// The [InputConnector] is responsible for delivering synthetic taps, drags
/// and key presses to the game, so that it can be played from the Flame CLI.
///
/// Positions are in canvas coordinates, the same ones that a snapshot of the
/// game uses, and the events are delivered through the same dispatchers that
/// real input goes through.
class InputConnector extends DevToolsConnector {
  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.tap',
      (method, parameters) async {
        final position = _offset(parameters, 'x', 'y');
        if (position == null) {
          return _invalidParams('The x and y parameters have to be numbers.');
        }
        final error = tap(game, position);
        return error == null ? _success() : _invalidParams(error);
      },
    );

    registerExtension(
      'ext.flame_devtools.drag',
      (method, parameters) async {
        final from = _offset(parameters, 'fromX', 'fromY');
        final to = _offset(parameters, 'toX', 'toY');
        final steps = int.tryParse(parameters['steps'] ?? '10');
        if (from == null || to == null) {
          return _invalidParams(
            'The fromX, fromY, toX and toY parameters have to be numbers.',
          );
        }
        if (steps == null || steps < 1) {
          return _invalidParams('The steps parameter has to be at least 1.');
        }
        final error = drag(game, from, to, steps: steps);
        return error == null ? _success() : _invalidParams(error);
      },
    );

    registerExtension(
      'ext.flame_devtools.key',
      (method, parameters) async {
        final key = findLogicalKey(parameters['key'] ?? '');
        if (key == null) {
          return _invalidParams('Unknown key: ${parameters['key']}');
        }
        final action = parameters['action'] ?? 'press';
        if (!const ['press', 'down', 'up'].contains(action)) {
          return _invalidParams('The action has to be press, down or up.');
        }
        final error = pressKey(game, key, action: action);
        return error == null ? _success() : _invalidParams(error);
      },
    );
  }

  /// Taps the game at [position], in canvas coordinates.
  ///
  /// Returns an error message if the game has no component that handles
  /// taps, otherwise null.
  static String? tap(FlameGame game, Offset position) {
    final dispatcher = game.findByKey(const MultiTapDispatcherKey());
    if (dispatcher is! MultiTapDispatcher) {
      return 'The game has no component that handles taps, add the '
          'TapCallbacks mixin to a component first.';
    }
    dispatcher
      ..onTapDown(
        TapDownEvent(
          1,
          game,
          TapDownDetails(
            localPosition: position,
            globalPosition: position,
            kind: PointerDeviceKind.touch,
          ),
        ),
      )
      ..onTapUp(
        TapUpEvent(
          1,
          game,
          TapUpDetails(
            localPosition: position,
            globalPosition: position,
            kind: PointerDeviceKind.touch,
          ),
        ),
      );
    return null;
  }

  /// Drags across the game from [from] to [to], in canvas coordinates, with
  /// [steps] updates in between.
  ///
  /// Returns an error message if the game has no component that handles
  /// drags, otherwise null.
  static String? drag(
    FlameGame game,
    Offset from,
    Offset to, {
    int steps = 10,
  }) {
    final dispatcher = game.findByKey(const MultiDragScaleDispatcherKey());
    if (dispatcher is! MultiDragScaleDispatcher) {
      return 'The game has no component that handles drags, add the '
          'DragCallbacks mixin to a component first.';
    }
    dispatcher.onDragStart(
      DragStartEvent(
        1,
        game,
        DragStartDetails(localPosition: from, globalPosition: from),
      ),
    );
    final delta = (to - from) / steps.toDouble();
    var position = from;
    for (var i = 0; i < steps; i++) {
      position += delta;
      dispatcher.onDragUpdate(
        DragUpdateEvent(
          1,
          game,
          DragUpdateDetails(
            localPosition: position,
            globalPosition: position,
            delta: delta,
          ),
        ),
      );
    }
    dispatcher.onDragEnd(
      DragEndEvent(1, DragEndDetails(localPosition: to, globalPosition: to)),
    );
    return null;
  }

  /// Presses [key] in the game, where [action] is `press` for a key down
  /// followed by a key up, or `down` or `up` for one of them.
  ///
  /// Returns an error message if the game does not handle keyboard events,
  /// otherwise null.
  static String? pressKey(
    FlameGame game,
    LogicalKeyboardKey key, {
    String action = 'press',
  }) {
    if (game is! KeyboardEvents) {
      return 'The game does not handle keyboard events, mix in '
          'HasKeyboardHandlerComponents or KeyboardEvents first.';
    }
    final keyboardGame = game as KeyboardEvents;
    final physicalKey = _physicalKey(key);
    if (action != 'up') {
      keyboardGame.onKeyEvent(
        KeyDownEvent(
          physicalKey: physicalKey,
          logicalKey: key,
          character: key.keyLabel.length == 1 ? key.keyLabel : null,
          timeStamp: Duration.zero,
        ),
        {key},
      );
    }
    if (action != 'down') {
      keyboardGame.onKeyEvent(
        KeyUpEvent(
          physicalKey: physicalKey,
          logicalKey: key,
          timeStamp: Duration.zero,
        ),
        {},
      );
    }
    return null;
  }

  /// Finds the logical key with the given [name], which is matched without
  /// regard to case, spaces and underscores against the names of the keys,
  /// such as `arrowLeft`, `space`, `enter`, `a` or `digit1`.
  static LogicalKeyboardKey? findLogicalKey(String name) {
    final wanted = _normalize(name);
    if (wanted.isEmpty) {
      return null;
    }
    for (final key in LogicalKeyboardKey.knownLogicalKeys) {
      final debugName = _normalize(key.debugName ?? '');
      if (debugName == wanted ||
          (debugName.startsWith('key') && debugName.substring(3) == wanted) ||
          _normalize(key.keyLabel) == wanted) {
        return key;
      }
    }
    return null;
  }

  static PhysicalKeyboardKey _physicalKey(LogicalKeyboardKey key) {
    final wanted = _normalize(key.debugName ?? '');
    for (final physicalKey in PhysicalKeyboardKey.knownPhysicalKeys) {
      if (_normalize(physicalKey.debugName ?? '') == wanted) {
        return physicalKey;
      }
    }
    return const PhysicalKeyboardKey(0);
  }

  static String _normalize(String name) {
    return name.toLowerCase().replaceAll(RegExp('[ _]'), '');
  }

  static Offset? _offset(
    Map<String, String> parameters,
    String xName,
    String yName,
  ) {
    final x = double.tryParse(parameters[xName] ?? '');
    final y = double.tryParse(parameters[yName] ?? '');
    if (x == null || y == null || !x.isFinite || !y.isFinite) {
      return null;
    }
    return Offset(x, y);
  }

  static ServiceExtensionResponse _success() {
    return ServiceExtensionResponse.result(json.encode({'success': true}));
  }

  static ServiceExtensionResponse _invalidParams(String message) {
    return ServiceExtensionResponse.error(
      ServiceExtensionResponse.invalidParams,
      message,
    );
  }
}
