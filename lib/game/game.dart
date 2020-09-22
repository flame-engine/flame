import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;

import '../keyboard.dart';
import 'widget_builder.dart';

/// Represents a generic game.
///
/// Subclass this to implement the [update] and [render] methods.
/// Flame will deal with calling these methods properly when the game's widget is rendered.
abstract class Game {
  // Widget Builder for this Game
  final builder = WidgetBuilder();

  /// Returns the game background color.
  /// By default it will return a black color.
  /// It cannot be changed at runtime, because the game widget does not get rebuild when this value changes.
  Color backgroundColor() => const Color(0xFF000000);

  /// Implement this method to update the game state, given that a time [t] has passed.
  ///
  /// Keep the updates as short as possible. [t] is in seconds, with microseconds precision.
  void update(double t);

  /// Implement this method to render the current game state in the [canvas].
  void render(Canvas canvas);

  /// This is the resize hook; every time the game widget is resized, this hook is called.
  ///
  /// The default implementation does nothing; override to use the hook.
  void resize(Size size) {}

  /// This is the lifecycle state change hook; every time the game is resumed, paused or suspended, this is called.
  ///
  /// The default implementation does nothing; override to use the hook.
  /// Check [AppLifecycleState] for details about the events received.
  void lifecycleStateChange(AppLifecycleState state) {}

  /// Used for debugging
  @Deprecated('Gets called for backward compatibility, will be removed in v1')
  void recordDt(double dt) {}

  /// Use for caluclating the FPS.
  void onTimingsCallback(List<FrameTiming> timings) {}

  /// Returns the game widget. Put this in your structure to start rendering and updating the game.
  /// You can add it directly to the runApp method or inside your widget structure (if you use vanilla screens and widgets).
  Widget get widget => builder.build(this);

  void _handleKeyEvent(e) {
    (this as KeyboardEvents).onKeyEvent(e);
  }

  // Called when the Game widget is attached
  @mustCallSuper
  void onAttach() {
    if (this is KeyboardEvents) {
      RawKeyboard.instance.addListener(_handleKeyEvent);
    }
  }

  // Called when the Game widget is detached
  @mustCallSuper
  void onDetach() {
    // Keeping this here, because if we leave this on HasWidgetsOverlay
    // and somebody overrides this and forgets to call the stream close
    // we can face some leaks.

    // Also we only do this in release mode, otherwise when using hot reload
    // the controller would be closed and errors would happen
    if (this is HasWidgetsOverlay && kReleaseMode) {
      (this as HasWidgetsOverlay).widgetOverlayController.close();
    }

    if (this is KeyboardEvents) {
      RawKeyboard.instance.removeListener(_handleKeyEvent);
    }
  }

  /// Flag to tell the game loop if it should start running upon creation
  bool runOnCreation = true;

  /// Pauses the engine game loop execution
  void pauseEngine() => pauseEngineFn?.call();

  /// Resumes the engine game loop execution
  void resumeEngine() => resumeEngineFn?.call();

  VoidCallback pauseEngineFn;
  VoidCallback resumeEngineFn;
}

class OverlayWidget {
  final String name;
  final Widget widget;

  OverlayWidget(this.name, this.widget);
}

mixin HasWidgetsOverlay on Game {
  @override
  final builder = OverlayWidgetBuilder();

  final StreamController<OverlayWidget> widgetOverlayController =
      StreamController();

  void addWidgetOverlay(String overlayName, Widget widget) {
    widgetOverlayController.sink.add(OverlayWidget(overlayName, widget));
  }

  void removeWidgetOverlay(String overlayName) {
    widgetOverlayController.sink.add(OverlayWidget(overlayName, null));
  }
}
