import 'package:flame/components.dart';
import 'package:flame/text.dart';

/// The [FpsTextComponent] is a [TextComponent] that writes out the current FPS.
/// It has a [FpsComponent] as a child which does the actual calculations.
class FpsTextComponent<T extends TextRenderer>({
  int windowSize = 60,
  final int decimalPlaces = 0,
  T? super.textRenderer,
  super.position,
  super.size,
  super.scale,
  super.angle,
  super.anchor,
  int? priority,
}) extends TextComponent {
  this
    : super(
        priority: priority ?? double.maxFinite.toInt(),
      ) {
    add(fpsComponent);
  }

  final FpsComponent fpsComponent = FpsComponent(windowSize: windowSize);

  @override
  void update(double dt) {
    text = '${fpsComponent.fps.toStringAsFixed(decimalPlaces)} FPS';
  }
}
