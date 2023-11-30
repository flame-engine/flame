import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/events/flame_game_mixins/multi_drag_dispatcher.dart';
import 'package:flame/src/events/messages/drag_cancel_event.dart';
import 'package:flame/src/events/messages/drag_end_event.dart';
import 'package:flame/src/events/messages/drag_start_event.dart';
import 'package:flame/src/events/messages/drag_update_event.dart';
import 'package:meta/meta.dart';

/// This mixin can be added to a [Component] allowing it to receive drag events.
///
/// In addition to adding this mixin, the component must also implement the
/// [containsLocalPoint] method -- the component will only register the start of
/// a drag if the point where the initial touch event has occurred was inside
/// the component.
///
/// This mixin is the replacement of the Draggable mixin.
mixin DragCallbacks on Component {
  bool _isDragged = false;

  /// Returns true while the component is being dragged.
  bool get isDragged => _isDragged;

  /// The user initiated a drag gesture on top of this component.
  ///
  /// By default, only one component will receive a drag event. However, setting
  /// the property `event.continuePropagation` to true will allow the event to
  /// also reach the components below this one.
  ///
  /// Once a component receives the [onDragStart] event, the subsequent events
  /// [onDragUpdate], [onDragEnd], and [onDragCancel] with the same pointer id
  /// will be delivered to the same component. If multiple components have
  /// received the initial [onDragStart] event, then all of them will be
  /// receiving the follow-up events.
  @mustCallSuper
  void onDragStart(DragStartEvent event) {
    _isDragged = true;
  }

  /// The user has moved the pointer that initiated the drag gesture.
  ///
  /// This event will be delivered to the component(s) that captured the initial
  /// [onDragStart], even if the point of touch moves outside of the boundaries
  /// of the component. In the latter case `event.localPosition` will contain a
  /// NaN point.
  void onDragUpdate(DragUpdateEvent event) {}

  /// The drag event has ended.
  ///
  /// This event will be delivered to the component(s) that captured the initial
  /// [onDragStart], even if the point of touch moves outside of the boundaries
  /// of the component.
  @mustCallSuper
  void onDragEnd(DragEndEvent event) {
    _isDragged = false;
  }

  /// The drag was cancelled.
  ///
  /// This is a very rare event, so we provide a default implementation that
  /// converts it into an [onDragEnd] event.
  @mustCallSuper
  void onDragCancel(DragCancelEvent event) => onDragEnd(event.toDragEnd());

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final game = findRootGame()!;
    if (game.findByKey(const MultiDragDispatcherKey()) == null) {
      final dispatcher = MultiDragDispatcher();
      game.registerKey(const MultiDragDispatcherKey(), dispatcher);
      game.add(dispatcher);
    }
  }
}
