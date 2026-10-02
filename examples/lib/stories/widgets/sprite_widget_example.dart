import 'package:flame/widgets.dart';
import 'package:material_ui/material_ui.dart';

class const SpriteWidgetExample({
  required final double width,
  required final double height,
  required final double angle,
  required final Anchor anchor,
  required final Paint? paint,
  super.key,
}) extends StatelessWidget {
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

class const SizedSpriteWidgetExample({
  required final Size size,
  required final double angle,
  required final Anchor anchor,
  required final Paint? paint,
  super.key,
}) extends StatelessWidget {
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
