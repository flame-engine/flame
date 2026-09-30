import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:material_ui/material_ui.dart';

class PartialSpriteWidgetExample extends StatelessWidget {
  const PartialSpriteWidgetExample({
    required this.width,
    required this.height,
    required this.srcPosition,
    required this.srcSize,
    required this.anchor,
    super.key,
  });

  final double width;
  final double height;
  final Vector2 srcPosition;
  final Vector2 srcSize;
  final Anchor anchor;

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
