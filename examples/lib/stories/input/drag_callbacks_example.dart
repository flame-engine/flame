import 'package:examples/commons/ember.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:material_ui/material_ui.dart' show Colors;

class DragCallbacksExample({required final double zoom}) extends FlameGame {
  static const String description = '''
    In this example we show you can use the `DragCallbacks` mixin on
    `PositionComponent`s. Drag around the Embers and see their position
    changing.
  ''';

  late final DraggableEmber square;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.zoom = zoom;
    world.add(square = DraggableEmber());
    world.add(DraggableEmber()..y = 350);
  }
}

// Note: this component does not consider the possibility of multiple
// simultaneous drags with different pointerIds.
class DraggableEmber({super.position}) extends Ember with DragCallbacks {
  @override
  bool debugMode = true;

  this : super(size: Vector2.all(100));

  @override
  void update(double dt) {
    super.update(dt);
    debugColor = isDragged ? Colors.greenAccent : Colors.purple;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }
}
