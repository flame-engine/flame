import 'package:flame/extensions.dart';
import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';

class const SpriteButtonExample({
  required final double width,
  required final double height,
  super.key,
}) extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SpriteButton.asset(
        path: 'assets/images/buttons.png',
        pressedPath: 'assets/images/buttons.png',
        srcPosition: Vector2(0, 0),
        srcSize: Vector2(60, 20),
        pressedSrcPosition: Vector2(0, 20),
        pressedSrcSize: Vector2(60, 20),
        onPressed: () {
          // Do something
        },
        label: const Text(
          'Sprite Button',
          style: TextStyle(color: Color(0xFF5D275D)),
        ),
        width: width,
        height: height,
      ),
    );
  }
}
