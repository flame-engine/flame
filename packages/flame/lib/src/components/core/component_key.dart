import 'package:flame/game.dart';
import 'package:meta/meta.dart';

var _index = 0;

/// A key that can be used to identify a component and later
/// retrieve it from its [FlameGame] ancestor.
@immutable
class ComponentKey {
  /// Creates a key that is equal to keys with the same name.
  ComponentKey.named(String name) : _internalHash = name.hashCode;

  /// Creates a key that is unique, each instance will only
  /// be equal to itself.
  ComponentKey.unique() : _internalHash = _index++;

  final int _internalHash;

  @override
  int get hashCode => _internalHash;

  @override
  bool operator ==(Object other) =>
      other is ComponentKey && other._internalHash == _internalHash;
}
