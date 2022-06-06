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
/// The following events are supported by the mixin: [onTapDown], [onTapUp],
/// [onTapCancel] and [onLongTapDown] -- see their individual descriptions for
/// more details. There is no "onTap" event though -- use [onTapUp] instead.
///
/// Each event handler can be overridden. One scenario when this could be useful
/// is to check the `event.handled` property after the event has been sent down
/// the component tree.
///
/// === Usage notes ===
/// - If your game uses components with [TapCallbacks], then this mixin must be
///   added to the [FlameGame] in order for [TapCallbacks] to work properly.
/// - If your game also uses [Tappable] components, then add the
///   [HasTappablesBridge] mixin as well (instead of `HasTappables`).
/// - If your game has no tappable components, then do not use this mixin.
///   Instead, consider `MultiTouchTapDetector`.
mixin HasTappableComponents on FlameGame implements MultiTapListener {
  /// The record of all components currently being touched.
  final Set<_TaggedComponent> _record = {};

  /// Called when the user touches the device screen within the game canvas,
  /// either with a finger, a stylus, or a mouse.
  ///
  /// The handler propagates the [event] to any component located at the point
  /// of touch and that uses the [TapCallbacks] mixin. The event will be first
  /// delivered to the topmost such component, and then propagated to the
  /// components below only if explicitly requested.
  ///
  /// Each [event] has an `event.pointerId` to keep track of multiple touches
  /// that may occur simultaneously.
  @mustCallSuper
  void onTapDown(TapDownEvent event) {
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (TapCallbacks component) {
        _record.add(_TaggedComponent(event.pointerId, component));
        component.onTapDown(event);
      },
    );
    if (this is HasTappablesBridge) {
      final info = event.asInfo(this)..handled = event.handled;
      propagateToChildren(
        (Tappable child) => child.handleTapDown(event.pointerId, info),
      );
      event.handled = info.handled;
    }
  }

  /// Called after the user has been touching the screen for [longTapDelay]
  /// seconds without the tap being cancelled.
  ///
  /// This event will be delivered to all the components that previously
  /// received the `onTapDown` event, and who remain at the point where the user
  /// is touching the screen.
  @mustCallSuper
  void onLongTapDown(TapDownEvent event) {
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (TapCallbacks component) {
        final record = _TaggedComponent(event.pointerId, component);
        if (_record.contains(record)) {
          component.onLongTapDown(event);
        }
      },
      deliverToAll: true,
    );
    if (this is HasTappablesBridge) {
      final info = event.asInfo(this)..handled = event.handled;
      propagateToChildren(
        (Tappable child) => child.handleLongTapDown(event.pointerId, info),
      );
      event.handled = info.handled;
    }
  }

  /// Called when the user stops touching the device screen within the game
  /// canvas (and if there was an [onTapDown] event before).
  ///
  /// This event is propagated to the components at the point of touch, but only
  /// if those components have received the `onTapDown` event previously. For
  /// those components that moved away from the point of touch, an `onTapCancel`
  /// will be triggered instead.
  ///
  /// Note that if a component that was touched moves away from the point of
  /// touch, then `onTapCancel` will be triggered for this component only when
  /// the user stops the touch, not when the component moves away.
  @mustCallSuper
  void onTapUp(TapUpEvent event) {
    event.deliverAtPoint(
      rootComponent: this,
      eventHandler: (TapCallbacks component) {
        if (_record.remove(_TaggedComponent(event.pointerId, component))) {
          component.onTapUp(event);
        }
      },
      deliverToAll: true,
    );
    _tapCancelImpl(TapCancelEvent(event.pointerId));
    if (this is HasTappablesBridge) {
      final info = event.asInfo(this)..handled = event.handled;
      propagateToChildren(
        (Tappable child) => child.handleTapUp(event.pointerId, info),
      );
      event.handled = info.handled;
    }
  }

  /// Called when there was an [onTapDown] event previously, but the [onTapUp]
  /// can no longer occur.
  ///
  /// Usually this happens when the user starts a drag gesture, but could also
  /// occur for other reasons (e.g. another app coming to the foreground).
  ///
  /// This event will be propagated to all components that has previously
  /// received the `onTapDown` event.
  @mustCallSuper
  void onTapCancel(TapCancelEvent event) {
    _tapCancelImpl(event);
    if (this is HasTappablesBridge) {
      propagateToChildren(
        (Tappable child) => child.handleTapCancel(event.pointerId),
      );
    }
  }

  void _tapCancelImpl(TapCancelEvent event) {
    _record.removeWhere((pair) {
      if (pair.pointerId == event.pointerId) {
        pair.component.onTapCancel(event);
        return true;
      }
      return false;
    });
  }

  //#region MultiTapListener API

  /// The delay (in seconds) after which a tap is considered a long tap.
  @override
  double get longTapDelay => 0.300;

  @override
  void handleTap(int pointerId) {}

  @internal
  @override
  void handleTapCancel(int pointerId) {
    onTapCancel(TapCancelEvent(pointerId));
  }

  @internal
  @override
  void handleTapDown(int pointerId, TapDownDetails details) {
    onTapDown(TapDownEvent(pointerId, details));
  }

  @internal
  @override
  void handleTapUp(int pointerId, TapUpDetails details) {
    onTapUp(TapUpEvent(pointerId, details));
  }

  @internal
  @override
  void handleLongTapDown(int pointerId, TapDownDetails details) {
    onLongTapDown(TapDownEvent(pointerId, details));
  }
  //#endregion
}

/// Mixin that can be added to a game to indicate that is has [Tappable]
/// components (in addition to components with [TapCallbacks]).
///
/// This is a temporary mixin to facilitate the transition between the old and
/// the new event system. In the future it will be deprecated.
mixin HasTappablesBridge on HasTappableComponents {}

@immutable
class _TaggedComponent {
  const _TaggedComponent(this.pointerId, this.component);
  final int pointerId;
  final TapCallbacks component;

  @override
  int get hashCode => Object.hash(pointerId, component);

  @override
  bool operator ==(Object other) {
    return other is _TaggedComponent &&
        other.pointerId == pointerId &&
        other.component == component;
  }
}
