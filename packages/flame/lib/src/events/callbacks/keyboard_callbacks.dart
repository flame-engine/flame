import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive keyboard
/// events while the game has focus.
///
/// Every [KeyboardCallbacks] component receives every key event, regardless of
/// its position. Set [Event.continuePropagation] to false inside a handler to
/// stop the event from reaching the components after this one.
///
/// Override [onKeyPress], [onKeyHold] and [onKeyRelease] to react to a single
/// kind of key event, or [onKeyboardEvent] to receive all of them in one place.
///
/// This callback uses [KeyboardDispatcher] to route events.
mixin KeyboardCallbacks on Component implements InputCallbacks {
  /// Receives every keyboard event delivered to this component.
  ///
  /// By default it forwards the event to [onKeyPress], [onKeyHold] or
  /// [onKeyRelease]. Overriding it without calling `super` means those three
  /// are no longer called.
  void onKeyboardEvent(KeyboardEvent event) {
    switch (event) {
      case final KeyPressEvent event:
        onKeyPress(event);
      case final KeyHoldEvent event:
        onKeyHold(event);
      case final KeyReleaseEvent event:
        onKeyRelease(event);
    }
  }

  /// Called when a key is pressed down.
  void onKeyPress(KeyPressEvent event) {}

  /// Called repeatedly while a key is held down.
  void onKeyHold(KeyHoldEvent event) {}

  /// Called when a key is released.
  void onKeyRelease(KeyReleaseEvent event) {}

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    KeyboardDispatcher.addDispatcher(this);
  }
}
