import 'package:equatable/equatable.dart';

abstract class GameStatsEvent extends Equatable {
  const GameStatsEvent();
}

class AddScoreEvent extends GameStatsEvent {
  const AddScoreEvent(this.score);

  final int score;

  @override
  List<Object?> get props => [score];
}

class ResetScoreEvent extends GameStatsEvent {
  const ResetScoreEvent();

  @override
  List<Object?> get props => [];
}
