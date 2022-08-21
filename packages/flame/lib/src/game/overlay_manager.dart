import 'dart:collection';

import 'package:flame/src/game/game.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

/// A helper class used to control the visibility of overlays on a [Game]
/// instance. See [Game.overlays].
@internal
class OverlayManager {
  OverlayManager(this._game);

  final Game _game;
  final List<String> _activeOverlays = [];
  final Map<String, _OverlayBuilderFunction> _builders = {};

  /// The names of all currently active overlays.
  UnmodifiableListView<String> get activeOverlays {
    return UnmodifiableListView(_activeOverlays);
  }

  @Deprecated('Use .activeOverlays instead. Will be removed in 1.4.0')
  Set<String> get value => _activeOverlays.toSet();

  /// Returns if the given [overlayName] is active
  bool isActive(String overlayName) => _activeOverlays.contains(overlayName);

  /// Clears all active overlays.
  void clear() {
    _activeOverlays.clear();
    _game.refreshWidget();
  }

  /// Marks the [overlayName] to be rendered.
  bool add(String overlayName) {
    final setChanged = _addImpl(overlayName);
    if (setChanged) {
      _game.refreshWidget();
    }
    return setChanged;
  }

  /// Marks [overlayNames] to be rendered.
  void addAll(Iterable<String> overlayNames) {
    final initialCount = _activeOverlays.length;
    overlayNames.forEach(_addImpl);
    if (initialCount != _activeOverlays.length) {
      _game.refreshWidget();
    }
  }

  bool _addImpl(String name) {
    assert(
      _builders.containsKey(name),
      'Trying to add an unknown overlay "$name"',
    );
    if (_activeOverlays.contains(name)) {
      return false;
    }
    _activeOverlays.add(name);
    return true;
  }

  /// Adds a named overlay builder
  void addEntry(String name, _OverlayBuilderFunction builder) {
    _builders[name] = builder;
  }

  /// Hides the [overlayName].
  bool remove(String overlayName) {
    final hasRemoved = _activeOverlays.remove(overlayName);
    if (hasRemoved) {
      _game.refreshWidget();
    }
    return hasRemoved;
  }

  /// Hides multiple overlays specified in [overlayNames].
  void removeAll(Iterable<String> overlayNames) {
    final initialCount = _activeOverlays.length;
    overlayNames.forEach(_activeOverlays.remove);
    if (_activeOverlays.length != initialCount) {
      _game.refreshWidget();
    }
  }

  @internal
  List<Widget> buildCurrentOverlayWidgets(BuildContext context) {
    final widgets = <Widget>[];
    for (final overlayName in _activeOverlays) {
      final builder = _builders[overlayName]!;
      widgets.add(
        KeyedSubtree(
          key: ValueKey(overlayName),
          child: builder(context, _game),
        ),
      );
    }
    return widgets;
  }
}

typedef _OverlayBuilderFunction = Widget Function(
  BuildContext context,
  Game game,
);
