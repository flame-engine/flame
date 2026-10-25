import 'dart:convert';
import 'dart:developer';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
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
/// real input goes through. The canvas position of a component, to tap or drag
/// it without knowing where it is on the screen, is reported by the
/// `ext.flame_devtools.getComponentCanvasPosition` service extension.
class InputConnector() extends DevToolsConnector {
  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.getComponentCanvasPosition',
      (method, parameters) async {
        final anchor = parseAnchor(parameters['anchor']);
        if (anchor == null) {
          return _invalidParams(
            'The anchor has to be a name like center, or two numbers '
            'separated by a comma, got ${parameters['anchor']}.',
          );
        }
        final key = parameters['key'];
        final component = key != null
            ? game.findByKeyName<Component>(key)
            : findComponent<Component>(int.tryParse(parameters['id'] ?? ''));
        if (component == null) {
          return _invalidParams(
            key != null
                ? 'No component with the key $key was found.'
                : 'No component with the id ${parameters['id']} was found.',
          );
        }
        final (:position, :error) = canvasPositionOf(
          game,
          component,
          anchor: anchor,
        );
        if (position == null) {
          return _invalidParams(error!);
        }
        return ServiceExtensionResponse.result(
          json.encode({
            'id': component.hashCode,
            'name': component.runtimeType.toString(),
            'x': position.dx,
            'y': position.dy,
          }),
        );
      },
    );

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

  /// Finds the position of [anchor] within [component] in canvas coordinates,
  /// the same ones that [tap] and [drag] take.
  ///
  /// The position goes through the transforms of all the ancestors of the
  /// component, and for a component in a [World] through the viewfinder and
  /// the viewport of the camera that shows the world, which is
  /// [FlameGame.camera] when it shows the world and otherwise the first other
  /// camera that does, not counting the cameras within the world itself.
  ///
  /// Returns an error message instead of a position if the component is not a
  /// [PositionComponent], or if it is not visible on the canvas.
  static ({Offset? position, String? error}) canvasPositionOf(
    FlameGame game,
    Component component, {
    Anchor anchor = Anchor.center,
  }) {
    final description = '${component.runtimeType} ${component.hashCode}';
    if (component is! PositionComponent) {
      return _failure(
        '$description is not a PositionComponent, so it has no position to '
        'target.',
      );
    }

    Vector2? point = Vector2(
      anchor.x * component.width,
      anchor.y * component.height,
    );
    Component current = component;
    final visitedWorlds = <World>{};
    while (!identical(current, game)) {
      var parent = current.parent;
      if (current is World) {
        final camera = _cameraOf(game, current);
        if (camera == null || !visitedWorlds.add(current)) {
          return _failure('$description is in a world that no camera shows.');
        }
        point = _throughCamera(camera, point!);
        parent = camera.parent;
      } else if (current is Viewfinder && parent is CameraComponent) {
        point = (parent.world?.isMounted ?? false)
            ? _throughCamera(parent, point!)
            : null;
      } else if (current is Route && !current.isRendered) {
        point = null;
      } else {
        if (current is CoordinateTransform) {
          point = (current as CoordinateTransform).localToParent(point!);
        }
        if (parent is CameraComponent &&
            !identical(current, parent.viewport) &&
            point != null) {
          point = identical(current, parent.backdrop)
              ? _throughViewport(parent, point)
              : null;
        }
      }
      if (point == null) {
        return _failure('$description is not visible on the canvas.');
      }
      if (parent == null) {
        return _failure('$description is not mounted in the game.');
      }
      current = parent;
    }

    final position = point!.toOffset();
    final canvasSize = game.canvasSize;
    if (position.dx < 0 ||
        position.dy < 0 ||
        position.dx > canvasSize.x ||
        position.dy > canvasSize.y) {
      return _failure(
        '$description is not visible on the canvas, it is at '
        '${position.dx},${position.dy}.',
      );
    }
    return (position: position, error: null);
  }

  /// Parses an anchor given as a name like `center` or `topLeft`, or as two
  /// numbers separated by a comma, where `0,0` is the top left corner and
  /// `1,1` the bottom right corner.
  ///
  /// A null [value] is the center, and an invalid one returns null.
  static Anchor? parseAnchor(String? value) {
    if (value == null) {
      return Anchor.center;
    }
    for (final anchor in Anchor.values) {
      if (anchor.name.toLowerCase() == value.toLowerCase()) {
        return anchor;
      }
    }
    final parts = value.split(',').map(double.tryParse).toList();
    if (parts.length != 2 || parts.any((p) => p == null || !p.isFinite)) {
      return null;
    }
    return Anchor(parts[0]!, parts[1]!);
  }

  /// Finds the camera that shows [world], ignoring the cameras within the
  /// world itself, since they can only show it when another camera does.
  static CameraComponent? _cameraOf(FlameGame game, World world) {
    bool showsWorld(CameraComponent camera) =>
        identical(camera.world, world) &&
        camera.isMounted &&
        !camera.ancestors().contains(world);

    if (showsWorld(game.camera)) {
      return game.camera;
    }
    return game
        .descendants()
        .whereType<CameraComponent>()
        .where(
          showsWorld,
        )
        .firstOrNull;
  }

  /// Moves [point] from the coordinates of the world of [camera] to the
  /// coordinates of the parent of [camera], or to null if the viewport does
  /// not show it.
  static Vector2? _throughCamera(CameraComponent camera, Vector2 point) {
    return _throughViewport(camera, camera.viewfinder.localToParent(point));
  }

  /// Moves [point] from the coordinates that the viewport of [camera] renders
  /// the world and the backdrop in to the coordinates of the parent of
  /// [camera], or to null if the viewport clips it.
  static Vector2? _throughViewport(CameraComponent camera, Vector2 point) {
    if (!camera.viewport.containsLocalPoint(point)) {
      return null;
    }
    return camera.viewport.localToParent(point);
  }

  static ({Offset? position, String? error}) _failure(String error) {
    return (position: null, error: 'The component $error');
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
