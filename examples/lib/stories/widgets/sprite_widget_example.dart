import 'package:flame/widgets.dart';
import 'package:material_ui/material_ui.dart';

class SpriteWidgetExample extends StatelessWidget {
  const SpriteWidgetExample({
    required this.width,
    required this.height,
    required this.angle,
    required this.anchor,
    required this.paint,
    super.key,
  });

  final double width;
  final double height;
  final double angle;
  final Anchor anchor;
  final Paint? paint;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(border: Border.all(color: Colors.amber)),
      child: SpriteWidget.asset(
        path: 'assets/images/shield.png',
        angle: angle,
        anchor: anchor,
        paint: paint,
      ),
    );
  }
}

class SizedSpriteWidgetExample extends StatelessWidget {
  const SizedSpriteWidgetExample({
    required this.size,
    required this.angle,
    required this.anchor,
    required this.paint,
    super.key,
  });

  final Size size;
  final double angle;
  final Anchor anchor;
  final Paint? paint;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(border: Border.all(color: Colors.amber)),
      child: SpriteWidget.asset(
        size: size,
        path: 'assets/images/shield.png',
        angle: angle,
        anchor: anchor,
        paint: paint,
      ),
    );
  }
}
