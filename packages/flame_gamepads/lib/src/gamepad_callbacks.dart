import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';

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
