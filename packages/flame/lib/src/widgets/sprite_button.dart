import 'package:flutter/widgets.dart';

import '../extensions/size.dart';
import '../sprite.dart';

export '../sprite.dart';

class SpriteButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget label;
  final Sprite sprite;
  final Sprite pressedSprite;
  final double width;
  final double height;

  const SpriteButton({
    required this.onPressed,
    required this.label,
    required this.sprite,
    required this.pressedSprite,
    this.width = 200,
    this.height = 50,
  });

  @override
  State createState() => _ButtonState();
}

class _ButtonState extends State<SpriteButton> {
  bool _pressed = false;

  @override
  Widget build(_) {
    final width = widget.width;
    final height = widget.height;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);

        widget.onPressed.call();
      },
      child: Container(
        width: width,
        height: height,
        child: CustomPaint(
          painter:
              _ButtonPainter(_pressed ? widget.pressedSprite : widget.sprite),
          child: Center(
            child: Container(
              padding: _pressed ? const EdgeInsets.only(top: 5) : null,
              child: widget.label,
            ),
          ),
        ),
      ),
    );
  }
}

class _ButtonPainter extends CustomPainter {
  final Sprite _sprite;

  _ButtonPainter(this._sprite);

  @override
  bool shouldRepaint(_ButtonPainter old) => old._sprite != _sprite;

  @override
  void paint(Canvas canvas, Size size) {
    _sprite.render(canvas, size: size.toVector2());
  }
}
