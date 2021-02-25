import '../../game/game.dart';

mixin HasGameRef<T extends Game> {
  late T gameRef;
}
