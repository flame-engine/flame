import 'package:flutter/widgets.dart';

import '../../assets.dart';
import '../extensions/size.dart';
import '../extensions/vector2.dart';
import '../sprite.dart';

export '../sprite.dart';

/// A [StatefulWidget] which loads a SpriteButton from metadata
/// and renders a [SpriteButton]
class SpriteButtonBuilder extends StatefulWidget {
  /// Image [path] used to build the sprite button
  final String path;

  /// Holds the position of the sprite on the image
  final Vector2? srcPosition;

  /// Holds the size of the sprite on the image
  final Vector2? srcSize;

  /// Image [pressedPath] used to build the sprite button
  final String pressedPath;

  /// Holds the position of the sprite on the image
  final Vector2? pressedSrcPosition;

  /// Holds the size of the sprite on the image
  final Vector2? pressedSrcSize;

  final Widget label;

  final VoidCallback onPressed;

  final double width;

  final double height;

  /// Images instance used to load the image, uses Flame.images when
  /// omitted
  final Images? images;

  const SpriteButtonBuilder({
    required this.path,
    required this.pressedPath,
    required this.onPressed,
    required this.width,
    required this.height,
    required this.label,
    this.srcPosition,
    this.srcSize,
    this.pressedSrcPosition,
    this.pressedSrcSize,
    this.images,
  });

  @override
  State createState() {
    return _SpriteButtonBuilderState();
  }
}

class _SpriteButtonBuilderState extends State<SpriteButtonBuilder> {
  late Future<Sprite> _spriteFuture;
  late Future<Sprite> _pressedSpriteFuture;

  @override
  void initState() {
    super.initState();

    _spriteFuture = Sprite.load(
      widget.path,
      srcSize: widget.srcSize,
      srcPosition: widget.srcPosition,
      images: widget.images,
    );

    _pressedSpriteFuture = Sprite.load(
      widget.pressedPath,
      srcSize: widget.pressedSrcSize,
      srcPosition: widget.pressedSrcPosition,
      images: widget.images,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Sprite>>(
      future: Future.wait([
        _spriteFuture,
        _pressedSpriteFuture,
      ]),
      builder: (_, snapshot) {
        if (snapshot.hasData) {
          final data = snapshot.data;

          if (data != null) {
            final sprite = data[0];
            final pressedSprite = data[1];

            return SpriteButton(
              onPressed: widget.onPressed,
              label: widget.label,
              width: widget.width,
              height: widget.height,
              sprite: sprite,
              pressedSprite: pressedSprite,
            );
          }
        }

        return Container();
      },
    );
  }
}

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
