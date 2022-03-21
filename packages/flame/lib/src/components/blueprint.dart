import 'package:flutter/foundation.dart';

import '../../components.dart';
import '../game/flame_game.dart';

const _attachedErrorMessage = "Can't add to attached Blueprints";

/// A [Blueprint] is a virtual way of grouping [Component]s
/// that are related, but they need to be added directly on
/// the [FlameGame] level.
abstract class Blueprint {
  final List<Component> _components = [];
  bool _isAttached = false;

  /// Called before the the [Component]s managed
  /// by this blueprint is added to the [FlameGame]
  void build();

  /// Attach the [Component]s built on [build] to the [game]
  /// instance
  @mustCallSuper
  Future<void> attach(FlameGame game) async {
    build();
    await game.addAll(_components);
    _isAttached = true;
  }

  /// Adds a list of [Component]s to this blueprint.
  void addAll(List<Component> components) {
    assert(!_isAttached, _attachedErrorMessage);
    _components.addAll(components);
  }

  /// Adds a single [Component] to this blueprint.
  void add(Component component) {
    assert(!_isAttached, _attachedErrorMessage);
    _components.add(component);
  }

  /// Returns a copy of the components built by this blueprint
  List<Component> get components => List.unmodifiable(_components);

  /// [bool] that indicates if this [Blueprint] instance is already
  /// attached to a [FlameGame], attached [Blueprint]s can't have
  /// more additions to it.
  bool get isAttached => _isAttached;
}
