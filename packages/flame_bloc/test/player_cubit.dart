import 'package:bloc/bloc.dart';

enum PlayerState { alive, dead, sad }

class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit() : super(PlayerState.alive);

  void kill() {
    emit(PlayerState.dead);
  }

  void makeSad() {
    emit(PlayerState.sad);
  }

  void riseFromTheDead() {
    emit(PlayerState.alive);
  }
}
