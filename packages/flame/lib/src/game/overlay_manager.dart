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
  final List<_OverlayData> _activeOverlays = [];
  final Map<String, OverlayBuilderFunction> _builders = {};

  /// The names of all currently active overlays.
  UnmodifiableListView<String> get activeOverlays {
    return UnmodifiableListView(_activeOverlays.map((overlay) => overlay.name));
  }

  /// The names of all registered overlays
  UnmodifiableListView<String> get registeredOverlays {
    return UnmodifiableListView(_builders.keys);
  }

  /// Returns if the given [overlayName] is active
  bool isActive(String overlayName) =>
      _activeOverlays.any((overlay) => overlay.name == overlayName);

  /// Clears all active overlays.
  void clear() {
    _activeOverlays.clear();
    _game.refreshWidget(isInternalRefresh: false);
  }

  /// Marks the [overlayName] to be rendered.
  /// [priority] is used to sort widgets for [buildCurrentOverlayWidgets]
  /// The smaller the priority, the sooner your component will be build.
  bool add(String overlayName, {int priority = 0}) {
    final setChanged = _addImpl(priority: priority, name: overlayName);
    if (setChanged) {
      _game.refreshWidget(isInternalRefresh: false);
    }
    return setChanged;
  }

  /// Marks [overlayNames] to be rendered.
  void addAll(Iterable<String> overlayNames) {
    final initialCount = _activeOverlays.length;
    overlayNames.forEach((overlayName) => _addImpl(name: overlayName));
    if (initialCount != _activeOverlays.length) {
      _game.refreshWidget(isInternalRefresh: false);
    }
  }

  bool _addImpl({required String name, int priority = 0}) {
    assert(
      _builders.containsKey(name),
      'Trying to add an unknown overlay "$name"',
    );
    if (isActive(name)) {
      return false;
    }
    _activeOverlays.add(_OverlayData(priority: priority, name: name));
    _activeOverlays.sort(_compare);
    return true;
  }

  _OverlayData? _getOverlay(String name) {
    return _activeOverlays.where((overlay) => overlay.name == name).firstOrNull;
  }

  /// Adds a named overlay builder
  void addEntry(String name, OverlayBuilderFunction builder) {
    _builders[name] = builder;
  }

  /// Hides the [overlayName].
  bool remove(String overlayName) {
    final overlay = _getOverlay(overlayName);
    final hasRemoved = _activeOverlays.remove(overlay);
    if (hasRemoved) {
      _game.refreshWidget(isInternalRefresh: false);
    }
    return hasRemoved;
  }

  /// Hides multiple overlays specified in [overlayNames].
  void removeAll(Iterable<String> overlayNames) {
    final initialCount = _activeOverlays.length;
    _activeOverlays.removeWhere(
      (overlay) => overlayNames.contains(overlay.name),
    );
    if (_activeOverlays.length != initialCount) {
      _game.refreshWidget(isInternalRefresh: false);
    }
  }

  /// Marks the [overlayName] to either be rendered or not, based on the
  /// current state.
  ///
  /// [priority] is used to sort widgets for [buildCurrentOverlayWidgets]
  /// The smaller the priority, the sooner your component will be build
  /// (see [add] for more details).
  bool toggle(String overlayName, {int priority = 0}) {
    if (isActive(overlayName)) {
      return remove(overlayName);
    } else {
      return add(overlayName, priority: priority);
    }
  }

  @internal
  List<Widget> buildCurrentOverlayWidgets(BuildContext context) {
    final widgets = <Widget>[];
    for (final overlay in _activeOverlays) {
      final builder = _builders[overlay.name]!;
      widgets.add(
        KeyedSubtree(
          key: ValueKey(overlay),
          child: builder(context, _game),
        ),
      );
    }
    return widgets;
  }

  /// Comparator function used to sort overlays.
  int _compare(_OverlayData a, _OverlayData b) {
    return a.priority - b.priority;
  }
}

typedef OverlayBuilderFunction =
    Widget Function(
      BuildContext context,
      Game game,
    );

@immutable
class _OverlayData {
  final int priority;
  final String name;

  const _OverlayData({required this.priority, required this.name});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _OverlayData &&
          runtimeType == other.runtimeType &&
          priority == other.priority &&
          name == other.name;

  @override
  int get hashCode => priority.hashCode ^ name.hashCode;
}
