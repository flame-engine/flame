
import 'package:flame/src/components/component.dart';
import 'package:meta/meta.dart';

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
