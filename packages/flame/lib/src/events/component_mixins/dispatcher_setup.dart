import 'package:flame/src/events/flame_game_mixins/multi_drag_dispatcher.dart';
import 'package:flame/src/events/flame_game_mixins/scale_dispatcher.dart';
import 'package:flame/src/events/flame_game_mixins/scale_drag_dispatcher.dart';
import 'package:flame/src/game/flame_game.dart';

/// Ensures the correct event dispatcher is registered on [game] given which
/// callback types the mounting component needs.
///
/// Pass [hasDrag] / [hasScale] based on the component's actual mixin set.
/// When a component has both mixins this must be called exactly once; the
/// DragCallbacks side calls it and ScaleCallbacks guards with an early return.
///
/// Upgrade matrix:
///
/// | existing       | drag-only | scale-only | both  |
/// |----------------|-----------|------------|-------|
/// | nothing        | +MDrag    | +Scale     | +MDS  |
/// | MultiDragDisp. | done      | ->MDS      | ->MDS |
/// | ScaleDisp.     | ->MDS     | done       | ->MDS |
/// | MultiDragScale | done      | done       | done  |
void setupEventDispatcher(
  FlameGame game, {
  required bool hasDrag,
  required bool hasScale,
}) {
  final existingScale =
      game.findByKey(const ScaleDispatcherKey()) as ScaleDispatcher?;
  final existingDrag =
      game.findByKey(const MultiDragDispatcherKey()) as MultiDragDispatcher?;
  final existingBoth = game.findByKey(const MultiDragScaleDispatcherKey());

  // Already at the most capable dispatcher.
  if (existingBoth != null) {
    return;
  }

  if (hasDrag && hasScale) {
    final dispatcher = MultiDragScaleDispatcher();
    game.registerKey(const MultiDragScaleDispatcherKey(), dispatcher);
    game.add(dispatcher);
    existingDrag?.markForRemoval();
    existingScale?.markForRemoval();
    return;
  }

  if (hasDrag) {
    if (existingDrag != null) {
      return; // MultiDragDispatcher already present.
    }
    if (existingScale != null) {
      // A ScaleDispatcher is active: upgrade to handle drag too.
      final dispatcher = MultiDragScaleDispatcher();
      game.registerKey(const MultiDragScaleDispatcherKey(), dispatcher);
      game.add(dispatcher);
      existingScale.markForRemoval();
      return;
    }
    final dispatcher = MultiDragDispatcher();
    game.registerKey(const MultiDragDispatcherKey(), dispatcher);
    game.add(dispatcher);
    return;
  }

  // hasScale only (hasDrag is false here).
  if (existingScale != null) {
    return; // ScaleDispatcher already present.
  }
  if (existingDrag != null) {
    // A MultiDragDispatcher is active: upgrade to handle scale too.
    final dispatcher = MultiDragScaleDispatcher();
    game.registerKey(const MultiDragScaleDispatcherKey(), dispatcher);
    game.add(dispatcher);
    existingDrag.markForRemoval();
    return;
  }
  final dispatcher = ScaleDispatcher();
  game.registerKey(const ScaleDispatcherKey(), dispatcher);
  game.add(dispatcher);
}
