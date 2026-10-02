import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:material_ui/material_ui.dart';

class const PartialSpriteWidgetExample({
  required final double width,
  required final double height,
  required final Vector2 srcPosition,
  required final Vector2 srcSize,
  required final Anchor anchor,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(border: Border.all(color: Colors.amber)),
      child: SpriteWidget.asset(
        path: 'assets/images/bomb_ptero.png',
        srcPosition: srcPosition,
        srcSize: srcSize,
        anchor: anchor,
      ),
    );
  }
}
