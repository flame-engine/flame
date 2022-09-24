import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/route.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:meta/meta.dart';

/// [OverlayRoute] is a class that allows adding/removing game overlays as if
/// they were ordinary [Route]s.
///
/// There are several differences between an [OverlayRoute] and the regular
/// [Route]s:
/// - the overlays are always rendered on top of the game canvas, so if you push
///   a regular route on top of an overlay route, the overlay route would still
///   be displayed on top.
/// - the `builder` of an overlay route produces a widget instead of a
///   component.
class OverlayRoute extends Route {
  /// An overlay route that uses the specified [builder]. This builder will be
  /// registered with the Game's map of overlay builders when this route is
  /// first activated.
  OverlayRoute(OverlayBuilder builder, {super.transparent = true})
      : _builder = builder,
        super(null);

  /// An overlay route that corresponds to an overlay that was already declared
  /// within GameWidget's `overlayBuilderMap`.
  OverlayRoute.existing({super.transparent = true})
      : _builder = null,
        super(null);

  final OverlayBuilder? _builder;

  @internal
  Game get game => findGame()!;

  @override
  Component build() {
    if (_builder != null) {
      game.overlays.addEntry(name, _builder!);
    }
    return Component();
  }

  @mustCallSuper
  @override
  void onPush(Route? previousRoute) {
    final didAdd = game.overlays.add(name);
    assert(didAdd, 'An overlay $name was already added before');
  }

  @mustCallSuper
  @override
  void onPop(Route nextRoute) {
    final didRemove = game.overlays.remove(name);
    assert(didRemove, 'An overlay $name was already removed');
  }
}

typedef OverlayBuilder = Widget Function(BuildContext context, Game game);
