import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

class GestureDetectorBuilder {
  GestureDetectorBuilder([this._onChange]);

  final Map<Type, GestureRecognizerFactory> _gestures = {};
  final _registrations = _RegistrationMap();
  final void Function()? _onChange;

  void add<T extends GestureRecognizer>(
    T Function() constructor,
    void Function(T) initializer,
  ) {
    final registration =
        _registrations.get<T>() ?? _registrations.put<T>(constructor);
    registration.initializers.add(initializer);
    _gestures[T] = registration.buildFactory();
    _onChange?.call();
  }

  void remove<T extends GestureRecognizer>() {
    final registration = _registrations.get<T>()!;
    registration.initializers.removeLast();
    if (registration.initializers.isEmpty) {
      _registrations.remove<T>();
      _gestures.remove(T);
    } else {
      _gestures[T] = registration.buildFactory();
    }
    _onChange?.call();
  }

  Widget build(Widget child) {
    if (_gestures.isEmpty) {
      return child;
    }
    return RawGestureDetector(
      gestures: _gestures,
      behavior: HitTestBehavior.deferToChild,
      child: child,
    );
  }

  void initializeGestures(Game game) {
    // support for deprecated detectors
    // ignore: deprecated_member_use_from_same_package
    if (game is TapDetector ||
        game is SecondaryTapDetector ||
        game is TertiaryTapDetector) {
      add(
        TapGestureRecognizer.new,
        (TapGestureRecognizer instance) {
          // support for deprecated detectors
          // ignore: deprecated_member_use_from_same_package
          if (game is TapDetector) {
            instance.onTap = game.onTap;
            instance.onTapCancel = game.onTapCancel;
            instance.onTapUp = game.handleTapUp;
            instance.onTapDown = game.handleTapDown;
          }
          if (game is SecondaryTapDetector) {
            instance.onSecondaryTapCancel = game.onSecondaryTapCancel;
            instance.onSecondaryTapUp = game.handleSecondaryTapUp;
            instance.onSecondaryTapDown = game.handleSecondaryTapDown;
          }
          if (game is TertiaryTapDetector) {
            instance.onTertiaryTapCancel = game.onTertiaryTapCancel;
            instance.onTertiaryTapUp = game.handleTertiaryTapUp;
            instance.onTertiaryTapDown = game.handleTertiaryTapDown;
          }
        },
      );
    }
    if (game is DoubleTapDetector) {
      add(
        DoubleTapGestureRecognizer.new,
        (DoubleTapGestureRecognizer instance) {
          instance.onDoubleTap = game.onDoubleTap;
          instance.onDoubleTapDown = game.handleDoubleTapDown;
          instance.onDoubleTapCancel = game.onDoubleTapCancel;
        },
      );
    }
    if (game is LongPressDetector) {
      add(
        LongPressGestureRecognizer.new,
        (LongPressGestureRecognizer instance) {
          instance.onLongPress = game.onLongPress;
          instance.onLongPressStart = game.handleLongPressStart;
          instance.onLongPressMoveUpdate = game.handleLongPressMoveUpdate;
          instance.onLongPressEnd = game.handleLongPressEnd;
          instance.onLongPressUp = game.onLongPressUp;
          instance.onLongPressCancel = game.onLongPressCancel;
        },
      );
    }
    if (game is VerticalDragDetector) {
      add(
        VerticalDragGestureRecognizer.new,
        (VerticalDragGestureRecognizer instance) {
          instance.onDown = game.handleVerticalDragDown;
          instance.onStart = game.handleVerticalDragStart;
          instance.onUpdate = game.handleVerticalDragUpdate;
          instance.onEnd = game.handleVerticalDragEnd;
          instance.onCancel = game.onVerticalDragCancel;
        },
      );
    }
    if (game is HorizontalDragDetector) {
      add(
        HorizontalDragGestureRecognizer.new,
        (HorizontalDragGestureRecognizer instance) {
          instance.onDown = game.handleHorizontalDragDown;
          instance.onStart = game.handleHorizontalDragStart;
          instance.onUpdate = game.handleHorizontalDragUpdate;
          instance.onEnd = game.handleHorizontalDragEnd;
          instance.onCancel = game.onHorizontalDragCancel;
        },
      );
    }
    if (game is ForcePressDetector) {
      add(
        ForcePressGestureRecognizer.new,
        (ForcePressGestureRecognizer instance) {
          instance.onStart = game.handleForcePressStart;
          instance.onPeak = game.handleForcePressPeak;
          instance.onUpdate = game.handleForcePressUpdate;
          instance.onEnd = game.handleForcePressEnd;
        },
      );
    }
    if (game is PanDetector) {
      add(
        PanGestureRecognizer.new,
        (PanGestureRecognizer instance) {
          instance.onDown = game.handlePanDown;
          instance.onStart = game.handlePanStart;
          instance.onUpdate = game.handlePanUpdate;
          instance.onEnd = game.handlePanEnd;
          instance.onCancel = game.onPanCancel;
        },
      );
    }
    if (game is ScaleDetector) {
      add(
        ScaleGestureRecognizer.new,
        (ScaleGestureRecognizer instance) {
          instance.onStart = game.handleScaleStart;
          instance.onUpdate = game.handleScaleUpdate;
          instance.onEnd = game.handleScaleEnd;
        },
      );
    }
    if (game is MultiTapListener) {
      add(
        MultiTapGestureRecognizer.new,
        (MultiTapGestureRecognizer instance) {
          final g = game as MultiTapListener;
          instance.longTapDelay = Duration(
            milliseconds: (g.longTapDelay * 1000).toInt(),
          );
          instance.onTap = g.handleTap;
          instance.onTapDown = g.handleTapDown;
          instance.onTapUp = g.handleTapUp;
          instance.onTapCancel = g.handleTapCancel;
          instance.onLongTapDown = g.handleLongTapDown;
        },
      );
    }
  }
}

bool hasMouseDetectors(Game game) {
  return game is MouseMovementDetector ||
      game is ScrollDetector ||
      game.mouseDetector != null ||
      game.scrollDetector != null;
}

Widget applyMouseDetectors(Game game, Widget child) {
  final mouseMoveFn = game is MouseMovementDetector ? game.onMouseMove : null;
  final mouseDetector = game.mouseDetector;
  final scrollDetector = game.scrollDetector;
  return Listener(
    child: MouseRegion(
      child: child,
      onHover: (PointerHoverEvent e) {
        mouseMoveFn?.call(PointerHoverInfo.fromDetails(game, e));
        mouseDetector?.call(e);
      },
    ),
    onPointerSignal: (event) {
      if (event is PointerScrollEvent) {
        if (game is ScrollDetector) {
          game.onScroll(PointerScrollInfo.fromDetails(game, event));
        }
        scrollDetector?.call(event);
      }
    },
  );
}

class _RegistrationMap {
  final _map = <Type, _RecognizerRegistration>{};

  _RecognizerRegistration<T>? get<T extends GestureRecognizer>() {
    return _map[T] as _RecognizerRegistration<T>?;
  }

  _RecognizerRegistration<T> put<T extends GestureRecognizer>(
    T Function() constructor,
  ) {
    final registration = _RecognizerRegistration<T>(constructor);
    _map[T] = registration;
    return registration;
  }

  void remove<T extends GestureRecognizer>() => _map.remove(T);
}

class _RecognizerRegistration<T extends GestureRecognizer> {
  _RecognizerRegistration(this.constructor);
  final T Function() constructor;
  final List<void Function(T)> initializers = [];

  GestureRecognizerFactory<T> buildFactory() {
    final currentInitializers = List<void Function(T)>.of(initializers);
    return GestureRecognizerFactoryWithHandlers<T>(
      constructor,
      (T instance) {
        for (final init in currentInitializers) {
          init(instance);
        }
      },
    );
  }
}
