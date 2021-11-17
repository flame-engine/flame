part of 'game_stats_bloc.dart';

enum GameStatus {
  initial,
  respawn,
  respawned,
  gameOver,
}

class GameStatsState extends Equatable {
  final int score;
  final int lives;
  final GameStatus status;

  const GameStatsState({
    required this.score,
    required this.lives,
    required this.status,
  });

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
