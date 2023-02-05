import 'package:flame/src/components/mixins/draggable.dart';
import 'package:flame/src/events/component_mixins/drag_callbacks.dart';

/// Mixin that can be added to a game to indicate that is has [Draggable]
/// components (in addition to components with [DragCallbacks]).
///
/// This is a temporary mixin to facilitate the transition between the old and
/// the new event system. In the future it will be deprecated.
@Deprecated('This mixin will be removed in 1.8.0')
mixin HasDraggablesBridge {}
