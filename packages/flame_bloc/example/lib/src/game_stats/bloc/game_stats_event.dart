part of 'game_stats_bloc.dart';

abstract class GameStatsEvent extends Equatable {
  const GameStatsEvent();
}

class ScoreEventAdded extends GameStatsEvent {
  const ScoreEventAdded(this.score);

  final int score;

  @override
  List<Object?> get props => [score];
}

class ScoreEventCleared extends GameStatsEvent {
  const ScoreEventCleared();

  @override
  List<Object?> get props => [];
}

class PlayerDied extends GameStatsEvent {
  const PlayerDied();

  @override
  List<Object?> get props => [];
}

class PlayerRespawned extends GameStatsEvent {
  const PlayerRespawned();

  @override
  List<Object?> get props => [];
}

class GameReset extends GameStatsEvent {
  const GameReset();

  @override
  List<Object?> get props => [];
}
