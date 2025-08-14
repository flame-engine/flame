import 'dart:async';

import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/sprite.dart';
import 'package:flame/src/widgets/base_future_builder.dart';
import 'package:flutter/widgets.dart';

export '../sprite.dart';

/// A [StatelessWidget] that uses Sprites to render a pressable button.
class SpriteButton extends StatelessWidget {
  /// Holds the position of the sprite on the image.
  final Vector2? srcPosition;

  /// Holds the size of the sprite on the image.
  final Vector2? srcSize;

  /// Holds the position of the pressed sprite on the image.
  final Vector2? pressedSrcPosition;

  /// Holds the size of the pressed sprite on the image.
  final Vector2? pressedSrcSize;

  /// Holds the position of the disabled sprite on the image.
  final Vector2? disabledSrcPosition;

  /// Holds the size of the disabled sprite on the image.
  final Vector2? disabledSrcSize;

  /// The widget that will be rendered on top of the button.
  final Widget? label;

  /// The function that will be called when the button is pressed.
  ///
  /// If null, the button will not be clickable and render the disabled sprite,
  /// if provided.
  final void Function()? onPressed;

  /// The width of the button.
  final double width;

  /// The height of the button.
  final double height;

  /// The offset of the button when pressed.
  final EdgeInsets pressedInsets;

  /// A builder function that is called if the loading fails.
  final WidgetBuilder? errorBuilder;

  /// A builder function that is called while the loading is on the way.
  final WidgetBuilder? loadingBuilder;

  final FutureOr<List<Sprite>> _buttonsFuture;

  SpriteButton({
    required Sprite sprite,
    required Sprite pressedSprite,
    required this.onPressed,
    required this.width,
    required this.height,
    this.label,
    this.srcPosition,
    this.srcSize,
    this.pressedSrcPosition,
    this.pressedSrcSize,
    Sprite? disabledSprite,
    this.disabledSrcPosition,
    this.disabledSrcSize,
    this.pressedInsets = const EdgeInsets.only(top: 5),
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  }) : _buttonsFuture = [
         sprite,
         pressedSprite,
         if (disabledSprite != null) disabledSprite,
       ];

  SpriteButton.future({
    required Future<Sprite> sprite,
    required Future<Sprite> pressedSprite,
    required this.onPressed,
    required this.width,
    required this.height,
    this.label,
    this.srcPosition,
    this.srcSize,
    this.pressedSrcPosition,
    this.pressedSrcSize,
    Future<Sprite>? disabledSprite,
    this.disabledSrcPosition,
    this.disabledSrcSize,
    this.pressedInsets = const EdgeInsets.only(top: 5),
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  }) : _buttonsFuture = Future.wait([
         sprite,
         pressedSprite,
         if (disabledSprite != null) disabledSprite,
       ]);

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
    this.label,
    Images? images,
    this.srcPosition,
    this.srcSize,
    this.pressedSrcPosition,
    this.pressedSrcSize,
    String? disabledPath,
    this.disabledSrcPosition,
    this.disabledSrcSize,
    this.pressedInsets = const EdgeInsets.only(top: 5),
    this.errorBuilder,
    this.loadingBuilder,
    super.key,
  }) : _buttonsFuture =
           (images ?? Flame.images).containsKey(path) &&
               (images ?? Flame.images).containsKey(pressedPath) &&
               (disabledPath == null ||
                   (images ?? Flame.images).containsKey(disabledPath))
           ? [
               Sprite(
                 (images ?? Flame.images).fromCache(path),
                 srcPosition: srcPosition,
                 srcSize: srcSize,
               ),
               Sprite(
                 (images ?? Flame.images).fromCache(pressedPath),
                 srcPosition: pressedSrcPosition,
                 srcSize: pressedSrcSize,
               ),
               if (disabledPath != null)
                 Sprite(
                   (images ?? Flame.images).fromCache(disabledPath),
                   srcPosition: disabledSrcPosition,
                   srcSize: disabledSrcSize,
                 ),
             ]
           : Future.wait([
               Sprite.load(
                 path,
                 srcPosition: srcPosition,
                 srcSize: srcSize,
                 images: images,
               ),
               Sprite.load(
                 pressedPath,
                 srcPosition: pressedSrcPosition,
                 srcSize: pressedSrcSize,
                 images: images,
               ),
               if (disabledPath != null)
                 Sprite.load(
                   disabledPath,
                   srcPosition: disabledSrcPosition,
                   srcSize: disabledSrcSize,
                   images: images,
                 ),
             ]);

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
          disabledSprite: list.length > 2 ? list[2] : null,
        );
      },
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
    );
  }
}

@visibleForTesting
class InternalSpriteButton extends StatefulWidget {
  final void Function()? onPressed;
  final Widget? label;
  final Sprite sprite;
  final Sprite pressedSprite;
  final Sprite? disabledSprite;
  final EdgeInsets pressedInsets;
  final double width;
  final double height;

  const InternalSpriteButton({
    required this.onPressed,
    required this.sprite,
    required this.pressedSprite,
    this.disabledSprite,
    this.pressedInsets = const EdgeInsets.only(top: 5),
    this.label,
    this.width = 200,
    this.height = 50,
    super.key,
  });

  @override
  State createState() => _ButtonState();
}

class _ButtonState extends State<InternalSpriteButton> {
  bool _pressed = false;

  @override
  Widget build(_) {
    final width = widget.width;
    final height = widget.height;
    final Sprite sprite;
    if (widget.onPressed == null) {
      sprite = widget.disabledSprite ?? widget.sprite;
    } else if (_pressed) {
      sprite = widget.pressedSprite;
    } else {
      sprite = widget.sprite;
    }

    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed == null) {
          return;
        }
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        if (widget.onPressed == null) {
          return;
        }
        setState(() => _pressed = false);
        widget.onPressed?.call();
      },
      onTapCancel: () {
        if (widget.onPressed == null) {
          return;
        }
        setState(() => _pressed = false);
      },
      child: Container(
        width: width,
        height: height,
        child: CustomPaint(
          painter: _ButtonPainter(sprite),
          child: Center(
            child: Container(
              padding: _pressed ? widget.pressedInsets : null,
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

  final Vector2 _size = Vector2.zero();
  @override
  void paint(Canvas canvas, Size size) {
    _size.setValues(size.width, size.height);
    _sprite.render(canvas, size: _size);
  }
}
