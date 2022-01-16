import 'package:flutter/widgets.dart';

import '../../assets.dart';
import '../extensions/size.dart';
import '../extensions/vector2.dart';
import '../sprite.dart';
import 'base_future_builder.dart';

export '../sprite.dart';

/// A [StatelessWidget] that uses SpriteWidgets to render
/// a pressable button
class SpriteButton extends StatelessWidget {
  /// Holds the position of the sprite on the image
  final Vector2? srcPosition;

  /// Holds the size of the sprite on the image
  final Vector2? srcSize;

  /// Holds the position of the sprite on the image
  final Vector2? pressedSrcPosition;

  /// Holds the size of the sprite on the image
  final Vector2? pressedSrcSize;

  final Widget label;

  final VoidCallback onPressed;

  final double width;

  final double height;

  /// A builder function that is called if the loading fails
  final WidgetBuilder? errorBuilder;

  /// A builder function that is called while the loading is on the way
  final WidgetBuilder? loadingBuilder;

  final Future<List<Sprite>> Function() _buttonsFuture;

  SpriteButton({
    required Sprite sprite,
    required Sprite pressedSprite,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.label,
    this.srcPosition,
    this.srcSize,
    this.pressedSrcPosition,
    this.pressedSrcSize,
    this.errorBuilder,
    this.loadingBuilder,
    Key? key,
  })  : _buttonsFuture = (() => Future.wait([
              Future.value(sprite),
              Future.value(pressedSprite),
            ])),
        super(key: key);

  SpriteButton.asset({
    required String path,
    required String pressedPath,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.label,
    Images? images,
    this.srcPosition,
    this.srcSize,
    this.pressedSrcPosition,
    this.pressedSrcSize,
    this.errorBuilder,
    this.loadingBuilder,
    Key? key,
  })  : _buttonsFuture = (() => Future.wait([
              Sprite.load(
                path,
                srcSize: srcSize,
                srcPosition: srcPosition,
                images: images,
              ),
              Sprite.load(
                pressedPath,
                srcSize: pressedSrcSize,
                srcPosition: pressedSrcPosition,
                images: images,
              ),
            ])),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<List<Sprite>>(
      futureBuilder: _buttonsFuture,
      builder: (_, list) {
        final sprite = list[0];
        final pressedSprite = list[1];

        return _SpriteButton(
          onPressed: onPressed,
          label: label,
          width: width,
          height: height,
          sprite: sprite,
          pressedSprite: pressedSprite,
        );
      },
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
}

class _SpriteButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget label;
  final Sprite sprite;
  final Sprite pressedSprite;
  final double width;
  final double height;

  const _SpriteButton({
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

class _ButtonState extends State<_SpriteButton> {
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
