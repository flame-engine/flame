import 'package:flame/game.dart';

/// Brings a [FlameGame] to a fully loaded and mounted state without a
/// [GameWidget], mirroring what `flame_test`'s `initializeGame` does.
///
/// Without this, `hasLayout` stays false: components are placed directly into
/// the children containers without ever loading or mounting, `onLoad` never
/// runs, and lifecycle events bypass the queue. Benchmarks would then measure
/// a very different code path than a real game.
Future<void> mountGame(FlameGame game, {Vector2? size}) async {
  game.onGameResize(size ?? Vector2(800, 600));
  // ignore: invalid_use_of_internal_member
  await game.load();
  // ignore: invalid_use_of_internal_member
  game.mount();
  game.update(0);
}
