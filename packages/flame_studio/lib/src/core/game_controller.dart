import 'dart:async';

import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameControllerProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);

@immutable
class const GameState({final Game? game, final bool paused = false}) {
  GameState copyWith({
    Game? game,
    bool? paused,
  }) {
    return GameState(
      game: game ?? this.game,
      paused: paused ?? this.paused,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GameState && game == other.game && paused == other.paused;

  @override
  int get hashCode => Object.hash(game, paused);
}

/// Keeps track of the [Game] running inside the studio, and allows to pause,
/// resume and step it.
///
/// The game is discovered by searching the widget tree for a [GameWidget],
/// which is repeated periodically so that games which are attached later (for
/// example after a menu screen) or replaced are picked up as well.
class GameController() extends Notifier<GameState> {
  static const Duration pollFrequency = Duration(milliseconds: 500);

  @override
  GameState build() {
    WidgetsFlutterBinding.ensureInitialized();
    final timer = Timer.periodic(pollFrequency, (_) => _poll());
    ref.onDispose(timer.cancel);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.mounted) {
        _poll();
      }
    });
    return const GameState();
  }

  bool get isPaused => state.paused;

  void useGame(Game? game) {
    state = GameState(game: game, paused: game?.isPaused ?? false);
  }

  void pauseGame() {
    state.game!.pauseEngine();
    state = state.copyWith(paused: true);
  }

  void resumeGame() {
    state.game!.resumeEngine();
    state = state.copyWith(paused: false);
  }

  void stepGame() {
    state.game!.stepEngine();
  }

  /// Repaints the game, so that changes made from the studio are visible even
  /// while the game is paused.
  void repaint() {
    final game = state.game;
    if (game != null && game.isAttached) {
      game.renderBox.markNeedsPaint();
    }
  }

  void _poll() {
    final game = state.game;
    if (game == null || !game.isAttached) {
      final newGame = _findGame();
      if (newGame != game) {
        useGame(newGame);
      }
    } else if (game.isPaused != state.paused) {
      // The game may pause or resume itself.
      state = state.copyWith(paused: game.isPaused);
    }
  }

  static Game? _findGame() {
    Game? game;
    void visitor(Element element) {
      if (element.widget is GameWidget) {
        final dynamic state = (element as StatefulElement).state;
        // ignore: avoid_dynamic_calls
        game = state.currentGame as Game;
      } else {
        element.visitChildElements(visitor);
      }
    }

    WidgetsBinding.instance.rootElement?.visitChildElements(visitor);
    return game;
  }
}
