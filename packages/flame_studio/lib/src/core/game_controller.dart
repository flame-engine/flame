import 'package:flame/game.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final gameControllerProvider =
    StateNotifierProvider<_GameController, _GameState>(
      (ref) => _GameController(),
    );

@immutable
class _GameState {
  const _GameState({this.game, this.paused = false});

  final Game? game;
  final bool paused;

  _GameState copyWith({
    Game? game,
    bool? paused,
  }) {
    return _GameState(
      game: game ?? this.game,
      paused: paused ?? this.paused,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is _GameState && game == other.game && paused == other.paused;

  @override
  int get hashCode => Object.hash(game, paused);
}

class _GameController extends StateNotifier<_GameState> {
  _GameController() : super(const _GameState()) {
    WidgetsFlutterBinding.ensureInitialized();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final game = _findGame();
      useGame(game);
    });
  }

  bool get isPaused => state.paused;

  void useGame(Game? game) {
    state = state.copyWith(game: game);
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
