import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/events/flame_game_mixins/has_draggable_components.dart';
import 'package:flame/src/events/flame_game_mixins/has_tappable_components.dart';
import 'package:meta/meta.dart';

/// [TaggedComponent] is a utility class that represents a pair of a component
/// and a pointer id.
///
/// This class is used by [HasTappableComponents] and [HasDraggableComponents]
/// to store information about which components were affected by which pointer
/// event, so that subsequent events can be reliably delivered to the same
/// components.
@internal
@immutable
class TaggedComponent<T extends Component> {
  const TaggedComponent(this.pointerId, this.component);
  final int pointerId;
  final T component;

  @override
  int get hashCode => Object.hash(pointerId, component);

  @override
  bool operator ==(Object other) {
    return other is TaggedComponent<T> &&
        other.pointerId == pointerId &&
        other.component == component;
  }
}
