part of 'game_stats_bloc.dart';

enum GameStatus() {
  initial,
  respawn,
  respawned,
  gameOver,
}

class const GameStatsState({
  required final int score,
  required final int lives,
  required final GameStatus status,
}) extends Equatable {
  const GameStatsState.empty()
    : this(
        score: 0,
        lives: 3,
        status: GameStatus.initial,
      );

  GameStatsState copyWith({
    int? score,
    int? lives,
    GameStatus? status,
  }) {
    return GameStatsState(
      score: score ?? this.score,
      lives: lives ?? this.lives,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [score, lives, status];
}
