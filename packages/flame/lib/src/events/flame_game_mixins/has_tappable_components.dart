import 'package:flame/components.dart';
import 'package:flame/src/events/component_mixins/tap_callbacks.dart';
import 'package:flame/src/events/flame_game_mixins/has_tappables_bridge.dart';
import 'package:flame/src/events/interfaces/multi_tap_listener.dart';
import 'package:flame/src/events/messages/tap_cancel_event.dart';
import 'package:flame/src/events/messages/tap_down_event.dart';
import 'package:flame/src/events/messages/tap_up_event.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

@Deprecated('''This mixin will be removed in 1.8.0

This mixin does no longer do anything since you can now add tappable
components directly to a game without this mixin.
''')
mixin HasTappableComponents on FlameGame {}

@internal
class MultiTapDispatcher extends Component implements MultiTapListener {
  /// The record of all components currently being touched.
  final Set<TaggedComponent<TapCallbacks>> _record = {};
  bool _eventHandlerRegistered = false;

  FlameGame get game => parent! as FlameGame;

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
      rootComponent: game,
      eventHandler: (TapCallbacks component) {
        _record.add(TaggedComponent(event.pointerId, component));
        component.onTapDown(event);
      },
    );
    // ignore: deprecated_member_use_from_same_package
    if (game is HasTappablesBridge) {
      final info = event.asInfo(game)..handled = event.handled;
      game.propagateToChildren<Tappable>(
        (c) => c.handleTapDown(event.pointerId, info),
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
      rootComponent: game,
      eventHandler: (TapCallbacks component) {
        final record = TaggedComponent(event.pointerId, component);
        if (_record.contains(record)) {
          component.onLongTapDown(event);
        }
      },
      deliverToAll: true,
    );
    // ignore: deprecated_member_use_from_same_package
    if (game is HasTappablesBridge) {
      final info = event.asInfo(game)..handled = event.handled;
      game.propagateToChildren<Tappable>(
        (c) => c.handleLongTapDown(event.pointerId, info),
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
      rootComponent: game,
      eventHandler: (TapCallbacks component) {
        if (_record.remove(TaggedComponent(event.pointerId, component))) {
          component.onTapUp(event);
        }
      },
      deliverToAll: true,
    );
    _tapCancelImpl(TapCancelEvent(event.pointerId));
    // ignore: deprecated_member_use_from_same_package
    if (game is HasTappablesBridge) {
      final info = event.asInfo(game)..handled = event.handled;
      game.propagateToChildren<Tappable>(
        (c) => c.handleTapUp(event.pointerId, info),
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
    // ignore: deprecated_member_use_from_same_package
    if (game is HasTappablesBridge) {
      game.propagateToChildren<Tappable>(
        (c) => c.handleTapCancel(event.pointerId),
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

  @override
  void onMount() {
    if (game.firstChild<MultiTapDispatcher>() == null) {
      game.gestureDetectors.add<MultiTapGestureRecognizer>(
        MultiTapGestureRecognizer.new,
        (MultiTapGestureRecognizer instance) {
          instance.longTapDelay = Duration(
            milliseconds: (longTapDelay * 1000).toInt(),
          );
          instance.onTap = handleTap;
          instance.onTapDown = handleTapDown;
          instance.onTapUp = handleTapUp;
          instance.onTapCancel = handleTapCancel;
          instance.onLongTapDown = handleLongTapDown;
        },
      );
      _eventHandlerRegistered = true;
    } else {
      // Ensures that only one MultiTapDispatcher is attached to the Game.
      removeFromParent();
    }
  }

  @override
  void onRemove() {
    if (_eventHandlerRegistered) {
      game.gestureDetectors.remove<MultiTapGestureRecognizer>();
      _eventHandlerRegistered = false;
    }
  }

  @override
  GameRenderBox get renderBox => game.renderBox;
}
