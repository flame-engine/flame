import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';

/// This mixin can be added to a [Component] allowing it to receive
/// normalized gamepad events while the component is mounted.
///
/// If this is added to multiple components that are concurrently
/// mounted, all of them will receive the event.
mixin GamepadCallbacks on Component {
  void onGamepadEvent(NormalizedGamepadEvent event) {}

  final List<StreamSubscription> _subscriptions = [];

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    _subscriptions.add(Gamepads.normalizedEvents.listen(onGamepadEvent));
  }

  @override
  @mustCallSuper
  void onRemove() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    super.onRemove();
  }
}
