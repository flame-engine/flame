import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/src/events/flame_game_mixins/scale_drag_dispatcher.dart';
import 'package:meta/meta.dart';

mixin ScaleDragCallbacks on Component {
  bool _isScaling = false;
  bool _isDragged = false;

  /// Returns true while the component is being scaled.
  bool get isScaling => _isScaling;

  bool get isDragged => _isDragged;

  @mustCallSuper
  void onScaleStart(ScaleStartEvent event) {
    _isScaling = true;
  }

  void onScaleUpdate(ScaleUpdateEvent event) {}

  @mustCallSuper
  void onScaleEnd(ScaleEndEvent event) {
    _isScaling = false;
  }

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

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    final game = findRootGame()!;
    if (game.findByKey(const MultiDragScaleDispatcherKey()) == null) {
      final dispatcher = MultiDragScaleDispatcher();
      game.registerKey(const MultiDragScaleDispatcherKey(), dispatcher);
      game.add(dispatcher);
    }
  }
}
