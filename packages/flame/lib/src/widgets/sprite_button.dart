import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/src/extensions/size.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/sprite.dart';
import 'package:flame/src/widgets/base_future_builder.dart';
import 'package:flutter/widgets.dart';

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

  final FutureOr<List<Sprite>> _buttonsFuture;

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
    Key? key,
  })  : _buttonsFuture = [
          sprite,
          pressedSprite,
        ],
        errorBuilder = null,
        loadingBuilder = null,
        super(key: key);

  SpriteButton.future({
    required Future<Sprite> sprite,
    required Future<Sprite> pressedSprite,
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
  })  : _buttonsFuture = Future.wait([
          sprite,
          pressedSprite,
        ]),
        super(key: key);

  /// Loads the images from the asset [path] and [pressedPath] and renders
  /// it as a widget.
  ///
  /// It will use the [loadingBuilder] while the image from [path] is loading.
  /// To render without loading, or when you want to have a gapless playback
  /// when the [path] value changes, consider loading the image beforehand
  /// and direct pass it to the default constructor.
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
  })  : _buttonsFuture = Future.wait([
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
        ]),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseFutureBuilder<List<Sprite>>(
      future: _buttonsFuture,
      builder: (_, list) {
        final sprite = list[0];
        final pressedSprite = list[1];

        return InternalSpriteButton(
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

@visibleForTesting
class InternalSpriteButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget label;
  final Sprite sprite;
  final Sprite pressedSprite;
  final double width;
  final double height;

  const InternalSpriteButton({
    required this.onPressed,
    required this.label,
    required this.sprite,
    required this.pressedSprite,
    this.width = 200,
    this.height = 50,
    Key? key,
  }) : super(key: key);

  @override
  State createState() => _ButtonState();
}

class _ButtonState extends State<InternalSpriteButton> {
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
