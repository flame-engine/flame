import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:gamepads/gamepads.dart';

mixin GamepadCallbacks on Component {
  void onGamepadEvent(NormalizedGamepadEvent event) {}

  final List<StreamSubscription> _unsubscribe = [];

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    _unsubscribe.add(Gamepads.normalizedEvents.listen(onGamepadEvent));
  }

  @override
  @mustCallSuper
  void onRemove() {
    for (final u in _unsubscribe) {
      u.cancel();
    }
    _unsubscribe.clear();
    super.onRemove();
  }
}
