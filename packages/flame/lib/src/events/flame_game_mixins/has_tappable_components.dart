import 'package:flame/src/components/mixins/tappable.dart';
import 'package:flame/src/events/component_mixins/tap_callbacks.dart';
import 'package:flame/src/events/interfaces/multi_tap_listener.dart';
import 'package:flame/src/events/messages/tap_cancel_event.dart';
import 'package:flame/src/events/messages/tap_down_event.dart';
import 'package:flame/src/events/messages/tap_up_event.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

/// This mixin allows a [FlameGame] to respond to tap events, and also delivers
/// those events to components that have the [TapCallbacks] mixin.
///
/// ----
/// **NOTE**: if your game also uses [Tappable] components, then add the
/// [HasLegacyTappables] mixin as well (instead of `HasTappables`).
mixin HasTappableComponents on FlameGame implements MultiTapListener {
  final Set<_PointerComponentPair> _record = {};

  @mustCallSuper
  void onTapDown(TapDownEvent event) {
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (TapCallbacks component) {
        _record.add(_PointerComponentPair(event.pointerId, component));
        component.onTapDown(event);
      },
    );
    if (this is HasLegacyTappables) {
      final info = event.asInfo(this)..handled = event.handled;
      propagateToChildren(
        (Tappable child) => child.handleTapDown(event.pointerId, info),
      );
      event.handled = info.handled;
    }
  }

  @mustCallSuper
  void onLongTapDown(TapDownEvent event) {
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (TapCallbacks component) {
        final record = _PointerComponentPair(event.pointerId, component);
        if (_record.contains(record)) {
          component.onLongTapDown(event);
        }
      },
    );
    if (this is HasLegacyTappables) {
      final info = event.asInfo(this)..handled = event.handled;
      propagateToChildren(
        (Tappable child) => child.handleLongTapDown(event.pointerId, info),
      );
      event.handled = info.handled;
    }
  }

  @mustCallSuper
  void onTapUp(TapUpEvent event) {
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (TapCallbacks component) {
        if (_record.remove(_PointerComponentPair(event.pointerId, component))) {
          component.onTapUp(event);
        }
      },
    );
    _onTapCancelImpl(TapCancelEvent(event.pointerId));

  }

  @mustCallSuper
  void onTapCancel(TapCancelEvent event) {
    _onTapCancelImpl(event);
  }

  void _onTapCancelImpl(TapCancelEvent event) {
    _record.removeWhere((pair) {
      if (pair.pointerId == event.pointerId) {
        pair.component.onTapCancel(event);
        return true;
      }
      return false;
    });
  }

  //#region MultiTapListener API
  @override
  double get longTapDelay => 0.300;

  @override
  void handleTap(int pointerId) {}

  @override
  void handleTapCancel(int pointerId) {
    onTapCancel(TapCancelEvent(pointerId));
  }

  @override
  void handleTapDown(int pointerId, TapDownDetails details) {
    onTapDown(TapDownEvent(pointerId, details));
  }

  @override
  void handleTapUp(int pointerId, TapUpDetails details) {
    onTapUp(TapUpEvent(pointerId, details));
  }

  @override
  void handleLongTapDown(int pointerId, TapDownDetails details) {
    onLongTapDown(TapDownEvent(pointerId, details));
  }
  //#endregion
}

mixin HasLegacyTappables on FlameGame {}

@immutable
class _PointerComponentPair {
  const _PointerComponentPair(this.pointerId, this.component);
  final int pointerId;
  final TapCallbacks component;

  @override
  int get hashCode => Object.hash(pointerId, component);

  @override
  bool operator ==(Object other) {
    return other is _PointerComponentPair &&
        other.pointerId == pointerId &&
        other.component == component;
  }
}
