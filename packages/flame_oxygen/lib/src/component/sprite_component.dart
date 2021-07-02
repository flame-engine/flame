part of flame_oxygen.component;

class SpriteInit {
  Sprite sprite;

  SpriteInit(this.sprite);

  factory SpriteInit.fromImage(
    Image image, {
    Vector2? srcPosition,
    Vector2? srcSize,
  }) =>
      SpriteInit(Sprite(
        image,
        srcPosition: srcPosition,
        srcSize: srcSize,
      ));
}

class SpriteComponent extends Component<SpriteInit> {
  Sprite? sprite;

  @override
  void init([SpriteInit? initValue]) => sprite = initValue?.sprite;

  @override
  void reset() => sprite = null;
}
