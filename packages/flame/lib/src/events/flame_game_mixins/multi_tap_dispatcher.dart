import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flame/src/events/tagged_component.dart';
import 'package:flame/src/game/flame_game.dart';
import 'package:flame/src/game/game_render_box.dart';
import 'package:flutter/gestures.dart';
import 'package:meta/meta.dart';

class MultiTapDispatcherKey implements ComponentKey {
  const MultiTapDispatcherKey();

  @override
  int get hashCode => 401913931; // 'MultiTapDispatcherKey' as hashCode

  @override
  bool operator ==(Object other) =>
      other is MultiTapDispatcherKey && other.hashCode == hashCode;
}

class MultiTapDispatcher extends Component implements MultiTapListener {
  /// The record of all components currently being touched.
  final Set<TaggedComponent<TapCallbacks>> _record = {};

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
  double get longTapDelay => TapConfig.longTapDelay;

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
    onTapDown(TapDownEvent(pointerId, game, details));
  }

  @internal
  @override
  void handleTapUp(int pointerId, TapUpDetails details) {
    onTapUp(TapUpEvent(pointerId, game, details));
  }

  @internal
  @override
  void handleLongTapDown(int pointerId, TapDownDetails details) {
    onLongTapDown(TapDownEvent(pointerId, game, details));
  }

  //#endregion

  @override
  void onMount() {
    game.gestureDetectors.add<MultiTapGestureRecognizer>(
      () => MultiTapGestureRecognizer(
        allowedButtonsFilter: (buttons) => buttons == kPrimaryButton,
      ),
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
  }

  @override
  void onRemove() {
    game.gestureDetectors.remove<MultiTapGestureRecognizer>();
    game.unregisterKey(const MultiTapDispatcherKey());
  }

  @override
  GameRenderBox get renderBox => game.renderBox;
}
