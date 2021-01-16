import '../base_game.dart';
import '../../components/mixins/collidable.dart';

mixin HasCollidables on BaseGame {
  final List<Collidable> collidables = [];
}
