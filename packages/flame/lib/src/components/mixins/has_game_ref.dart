import '../../game/game.dart';

mixin HasGameRef<T extends Game> {
  T? gameRef;
}
