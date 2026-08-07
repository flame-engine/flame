import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/foundation.dart';

/// This mixin can be added to a [Component] allowing it to receive force press
/// events, i.e. touches that report how hard the user is pressing.
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method -- only a gesture that starts on top of the
/// component will be delivered to it.
///
/// The following callbacks are available:
/// - [onForcePressStart]: the press crossed the pressure threshold at which
///   the gesture is recognized.
/// - [onForcePressPeak]: the press crossed the "peak" pressure threshold.
/// - [onForcePressUpdate]: the pressure changed during an active force press.
/// - [onForcePressEnd]: the pointer was lifted.
///
/// Note that force press requires a pressure-sensitive screen; see
/// [ForcePressEvent] for the details of which devices support it.
///
/// This callback uses [ForcePressDispatcher] to route events.
mixin ForcePressCallbacks on Component {
  bool _isForcePressed = false;

  /// Returns true while a force press gesture is active on this component.
  bool get isForcePressed => _isForcePressed;

  @mustCallSuper
  void onForcePressStart(ForcePressEvent event) {
    _isForcePressed = true;
  }

  void onForcePressPeak(ForcePressEvent event) {}

  void onForcePressUpdate(ForcePressEvent event) {}

  @mustCallSuper
  void onForcePressEnd(ForcePressEvent event) {
    _isForcePressed = false;
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    ForcePressDispatcher.addDispatcher(this);
  }
}
