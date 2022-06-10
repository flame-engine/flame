import 'package:flame/components.dart';
import 'package:flame/src/text/text_renderer.dart';

/// The [FpsTextComponent] is a [TextComponent] that writes out the current FPS.
/// It has a [FpsComponent] as a child which does the actual calculations.
class FpsTextComponent<T extends TextRenderer> extends TextComponent {
  FpsTextComponent({
    int windowSize = 60,
    this.decimalPlaces = 0,
    T? super.textRenderer,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    int? priority,
  })  : fpsComponent = FpsComponent(windowSize: windowSize),
        super(
          priority: priority ?? double.maxFinite.toInt(),
        ) {
    positionType = PositionType.viewport;
    add(fpsComponent);
  }

  final int decimalPlaces;
  final FpsComponent fpsComponent;

  @override
  void update(double dt) {
    text = '${fpsComponent.fps.toStringAsFixed(decimalPlaces)} FPS';
  }
}
