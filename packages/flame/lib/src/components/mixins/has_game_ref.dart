import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

mixin HasGameRef<T extends FlameGame> on Component {
  T? _gameRef;

  T get gameRef {
    if (_gameRef == null) {
      var c = parent;
      while (c != null) {
        if (c is HasGameRef<T>) {
          _gameRef = c.gameRef;
          return _gameRef!;
        } else if (c is T) {
          _gameRef = c;
          return c;
        } else {
          c = c.parent;
        }
      }
      throw StateError('Cannot find reference $T in the component tree');
    }
    return _gameRef!;
  }

  @override
  void onRemove() {
    super.onRemove();
    _gameRef = null;
  }

  /// Directly assigns (and override if one is already set) a [gameRef] to the
  /// component.
  ///
  /// This is meant to be used only for testing purposes.
  @visibleForTesting
  void mockGameRef(T gameRef) {
    _gameRef = gameRef;
  }
}
