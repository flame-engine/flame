import 'package:equatable/equatable.dart';

class GameStatsState extends Equatable {

  final int score;

  const GameStatsState({
    required this.score,
  });

  const GameStatsState.empty(): this(score: 0);

  GameStatsState copyWith({
    int? score,
  }) {
    return GameStatsState(score: score ?? this.score);
  }

  @override
  List<Object?> get props => [score];
}
