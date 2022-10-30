import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';

class NineTileBoxExample extends FlameGame with TapDetector, DoubleTapDetector {
  static const String description = '''
    If you want to create a background for something that can stretch you can
    use the `NineTileBox` which is showcased here.\n\n
    Tap to make the box bigger and double tap to make it smaller.
  ''';

  late NineTileBoxComponent nineTileBoxComponent;

  @override
  Future<void> onLoad() async {
    final sprite = Sprite(await images.load('nine-box.png'));
    final boxSize = Vector2.all(300);
    final nineTileBox = NineTileBox(sprite, destTileSize: 148);
    add(
      nineTileBoxComponent = NineTileBoxComponent(
        nineTileBox: nineTileBox,
        position: size / 2,
        size: boxSize,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void onTap() {
    nineTileBoxComponent.scale.scale(1.2);
  }

  @override
  void onDoubleTap() {
    nineTileBoxComponent.scale.scale(0.8);
  }
}
