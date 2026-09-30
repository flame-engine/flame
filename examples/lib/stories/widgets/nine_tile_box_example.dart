import 'package:flame/widgets.dart';
import 'package:flutter/widgets.dart';

class NineTileBoxWidgetExample extends StatelessWidget {
  const NineTileBoxWidgetExample({
    required this.width,
    required this.height,
    super.key,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: NineTileBoxWidget.asset(
        path: 'assets/images/nine-box.png',
        tileSize: 22,
        destTileSize: 50,
        child: const Center(
          child: Text(
            'Cool label',
            style: TextStyle(
              color: Color(0xFF000000),
            ),
          ),
        ),
      ),
    );
  }
}
