
import 'package:flame/src/game/game.dart';

/// A helper class used to control the visibility of overlays on a [Game]
/// instance. See [Game.overlays].
class OverlayManager {
  OverlayManager(this._game);

  final Game _game;
  final Set<String> _activeOverlays = {};

  /// Clear all active overlays.
  void clear() {
    _activeOverlays.clear();
    _game.refreshWidget();
  }

  /// Marks the [overlayName] to be rendered.
  bool add(String overlayName) {
    final setChanged = _activeOverlays.add(overlayName);
    if (setChanged) {
      _game.refreshWidget();
    }
    return setChanged;
  }

  /// Marks [overlayNames] to be rendered.
  void addAll(Iterable<String> overlayNames) {
    final overlayCountBeforeAdded = _activeOverlays.length;
    _activeOverlays.addAll(overlayNames);

    final overlayCountAfterAdded = _activeOverlays.length;
    if (overlayCountBeforeAdded != overlayCountAfterAdded) {
      _game.refreshWidget();
    }
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
    final overlayCountBeforeRemoved = _activeOverlays.length;
    _activeOverlays.removeAll(overlayNames);

    final overlayCountAfterRemoved = _activeOverlays.length;
    if (overlayCountBeforeRemoved != overlayCountAfterRemoved) {
      _game.refreshWidget();
    }
  }

  /// The names of all currently active overlays.
  Set<String> get value => _activeOverlays;

  /// Returns if the given [overlayName] is active
  bool isActive(String overlayName) => _activeOverlays.contains(overlayName);
}
