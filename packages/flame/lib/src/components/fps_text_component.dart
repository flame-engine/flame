import '../../components.dart';

/// The [FpsTextComponent] is a [TextComponent] that writes out the current FPS.
/// It has a [FpsComponent] as a child which does the actual calculations.
class FpsTextComponent<T extends TextRenderer> extends TextComponent {
  FpsTextComponent({
    this.windowSize = 60,
    this.decimalPlaces = 0,
    T? textRenderer,
    Vector2? position,
    Vector2? size,
    Vector2? scale,
    double? angle,
    Anchor? anchor,
    int? priority,
  }) : super(
          textRenderer: textRenderer,
          position: position,
          size: size,
          scale: scale,
          angle: angle,
          anchor: anchor,
          priority: priority ?? double.maxFinite.toInt(),
        );

  final int windowSize;
  final int decimalPlaces;
  late final FpsComponent fpsComponent;

  @override
  Future<void> onLoad() async {
    positionType = PositionType.game;
    add(fpsComponent = FpsComponent(windowSize: windowSize));
  }

  @override
  void update(double dt) {
    text = '${fpsComponent.fps.toStringAsFixed(decimalPlaces)} FPS';
  }
}
