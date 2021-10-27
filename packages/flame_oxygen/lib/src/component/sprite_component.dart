import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:oxygen/oxygen.dart';

export 'package:flame/sprite.dart';

class SpriteInit {
  final Sprite sprite;

  const SpriteInit(this.sprite);

  factory SpriteInit.fromImage(
    Image image, {
    Vector2? srcPosition,
    Vector2? srcSize,
  }) {
    return SpriteInit(
      Sprite(
        image,
        srcPosition: srcPosition,
        srcSize: srcSize,
      ),
    );
  }
}

class SpriteComponent extends Component<SpriteInit> {
  Sprite? sprite;

  @override
  void init([SpriteInit? initValue]) => sprite = initValue?.sprite;

  @override
  void reset() => sprite = null;
}
