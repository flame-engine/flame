import 'package:flame/components.dart';
import 'package:flame/game.dart';

import 'contact_callbacks.dart';
import 'forge2d_game.dart';

const _attachedErrorMessage = "Can't add callbacks to attached Blueprints";

/// A [Blueprint] that provides additional
/// structures specific to flame_forge2d
abstract class Forge2DBlueprint extends Blueprint {
  final List<ContactCallback> _callbacks = [];

  /// Adds a single [ContactCallback] to this blueprint
  void addContactCallback(ContactCallback callback) {
    assert(!isAttached, _attachedErrorMessage);
    _callbacks.add(callback);
  }

  /// Adds a collection of [ContactCallback]s to this blueprint
  void addAllContactCallback(List<ContactCallback> callbacks) {
    assert(!isAttached, _attachedErrorMessage);
    _callbacks.addAll(callbacks);
  }

  @override
  Future<void> attach(FlameGame game) async {
    await super.attach(game);

    assert(game is Forge2DGame, 'Forge2DBlueprint used outside a Forge2DGame');

    callbacks.forEach((game as Forge2DGame).addContactCallback);
  }

  /// Returns a copy of the callbacks built by this blueprint
  List<ContactCallback> get callbacks => List.unmodifiable(_callbacks);
}
