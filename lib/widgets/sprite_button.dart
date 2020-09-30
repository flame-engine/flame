import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

import '../sprite.dart';

class SpriteButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget label;
  final Sprite sprite;
  final Sprite pressedSprite;
  final double width;
  final double height;

  SpriteButton({
    @required this.onPressed,
    @required this.label,
    @required this.sprite,
    @required this.pressedSprite,
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

        widget.onPressed?.call();
      },
      child: Container(
        width: width,
        height: height,
        child: CustomPaint(
          painter:
              _ButtonPainer(_pressed ? widget.pressedSprite : widget.sprite),
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

class _ButtonPainer extends CustomPainter {
  final Sprite _sprite;

  _ButtonPainer(this._sprite);

  @override
  bool shouldRepaint(_ButtonPainer old) => old._sprite != _sprite;

  @override
  void paint(Canvas canvas, Size size) {
    _sprite.renderRect(canvas, Rect.fromLTWH(0, 0, size.width, size.height));
  }
}
