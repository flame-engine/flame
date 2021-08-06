import 'package:flame/components.dart';
import 'package:flame/game.dart';

import '../input/draggables.dart';
import 'composability.dart';

class GameInGame extends BaseGame with HasDraggableComponents {
  @override
  bool debugMode = true;

  @override
  Future<void> onLoad() async {
    add(Composability());
    add(DraggablesGame(zoom: 1.0));
  }
}
