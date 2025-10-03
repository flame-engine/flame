import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame_behaviors/flame_behaviors.dart';

/// A mixin that adds behavioral functionality to any kind of [Component].
///
/// Use this mixin when you can't extend [PositionedEntity] or [Entity] and
/// still want to use behaviors. For example, if you want to add behaviors to
/// a [SpriteComponent], [TextComponent], or even a [FlameGame] itself.
mixin EntityMixin on Component {
  Iterable<Behavior>? _behaviors;

  /// Returns a list of behaviors with the given type, that are attached to
  /// this entity.
  ///
  /// This will only return behaviors that have a completed lifecycle, aka they
  /// are fully mounted.
  Iterable<T> findBehaviors<T extends Behavior>() {
    if (_behaviors == null) {
      children.register<Behavior>();
      _behaviors ??= children.query<Behavior>();
    }
    return _behaviors!.whereType<T>();
  }

  /// Returns the first found behavior with the given type, that is attached
  /// to this entity.
  ///
  /// This will only return a behavior that has a completed lifecycle, aka it
  /// is fully mounted. If no behavior is found, it will throw a [StateError].
  T findBehavior<T extends Behavior>() {
    final it = findBehaviors<T>().iterator;
    if (!it.moveNext()) {
      throw StateError('No behavior of type $T found.');
    }
    return it.current;
  }

  /// Checks if this entity has at least one behavior with the given type.
  ///
  ///
  /// This will only return true if the behavior with the type [T] has a
  /// completed lifecycle, aka it is fully mounted.
  bool hasBehavior<T extends Behavior>() {
    try {
      findBehavior<T>();
      return true;
    } catch (e) {
      if (e is StateError && e.message.startsWith('No behavior of type')) {
        return false;
      }
      rethrow;
    }
  }
}

/// {@template entity}
/// The entity is the building block of a game. It represents a game object
/// that can hold multiple `Behavior`s, which in turn define how the
/// entity behaves.
///
/// The visualization of the entity is defined by the [Component]s that are
/// attached to it.
/// {@endtemplate}
abstract class Entity extends Component with EntityMixin {
  /// {@macro entity}
  Entity({
    super.children,
    super.priority,
    super.key,
    Iterable<Behavior>? behaviors,
  }) : assert(
         children?.whereType<Behavior>().isEmpty ?? true,
         'Behaviors cannot be added to as a child directly.',
       ) {
    if (behaviors != null) {
      addAll(behaviors);
    }
  }
}

/// {@template positioned_entity}
/// {@macro entity}
///
/// This entity is based on the [PositionComponent] and can be positioned
/// on the screen.
/// {@endtemplate}
abstract class PositionedEntity extends PositionComponent with EntityMixin {
  /// {@macro positioned_entity}
  PositionedEntity({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
    Iterable<Behavior>? behaviors,
  }) : assert(
         children?.whereType<Behavior>().isEmpty ?? true,
         'Behaviors cannot be added to as a child directly.',
       ) {
    if (behaviors != null) {
      addAll(behaviors);
    }
  }
}
