import 'package:flame/src/components/component.dart';
import 'package:flame/src/components/route.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/widgets.dart' hide Route;
import 'package:meta/meta.dart';

class OverlayRoute extends Route {
  OverlayRoute(OverlayBuilder builder, {super.transparent = true})
      : _builder = builder,
        super(null);

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
    game.overlays.add(name);
  }

  @mustCallSuper
  @override
  void onPop(Route nextRoute) {
    game.overlays.remove(name);
  }
}

typedef OverlayBuilder = Widget Function(BuildContext context, Game game);
