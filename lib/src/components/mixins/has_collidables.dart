import 'package:flutter/cupertino.dart';

import '../../../game.dart';
import '../../components/mixins/collidable.dart';
import '../../geometry/collision_detection.dart';
import '../component.dart';

mixin HasCollidables on BaseGame {
  // final List<Collidable> _collidables = [];
  final List<Collidable> _activeCollidables = [];
  final List<Collidable> _noActiveCollidables = [];

  List<Collidable> showActiveCollidables() => [
        ..._activeCollidables,
      ];

  List<Collidable> showNoActiveCollidables() => [
        ..._noActiveCollidables,
      ];

  //Dirty Mark
  bool needReAssignConllidablesActive = false;

  void handleCollidables(Set<Component> removeLater, List<Component> addLater) {
    removeLater.whereType<Collidable>().forEach((element) {
      if (element.activeCollidable) {
        _activeCollidables.remove(element);
      } else {
        _noActiveCollidables.remove(element);
      }
    });
    addLater.whereType<Collidable>().forEach((element) {
      if (element.activeCollidable) {
        _activeCollidables.add(element);
      } else {
        _noActiveCollidables.add(element);
      }
    });

    /// auto [reAssignConllidablesActive]
    if (needReAssignConllidablesActive) {
      reAssignConllidablesActive();
      needReAssignConllidablesActive = false;
    }

    collisionsDetection(_activeCollidables, _noActiveCollidables);
  }

  void reAssignConllidablesActive() {
    final _waitAssignConllidables = <Collidable>[];

    /// update [_activeCollidables]
    _activeCollidables.removeWhere((element) {
      if (!element.activeCollidable) {
        _waitAssignConllidables.add(element);
      }
      return !element.activeCollidable;
    });

    /// update [_noActiveCollidables]
    _noActiveCollidables.removeWhere((element) {
      if (element.activeCollidable) {
        _activeCollidables.add(element);
      }
      return element.activeCollidable;
    });
    _noActiveCollidables.addAll(_waitAssignConllidables);
  }

  /// Update a [_activeCollidable] of [Collidable]
  void setActiveCollidable(Collidable updateCollidable, bool newActiveState) {
    if (newActiveState != updateCollidable.activeCollidable) {
      updateCollidable.manualSetActiveCollidable(newActiveState);
      needReAssignConllidablesActive = true;
    }
  }
}
