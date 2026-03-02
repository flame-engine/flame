import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/widgets.dart' show IconData;
import 'package:meta/meta.dart';

/// A [PositionComponent] that renders a Flutter [IconData] as a Flame
/// component.
///
/// The icon is rasterized to a [Image] once during [onLoad] using a
/// [ParagraphBuilder], and then rendered each frame via
/// [Canvas.drawImageRect] with the component's [Paint]. This enables all
/// paint-based effects (ColorFilter, opacity, tint, glow, blend modes).
///
/// The icon is rasterized in white so that it can be tinted to any color
/// using [HasPaint.tint], [HasPaint.setColor], or a [ColorFilter].
///
/// Example usage:
/// ```dart
/// import 'package:flutter/material.dart';
///
/// final icon = IconComponent(
///   icon: Icons.star,
///   iconSize: 64,
///   position: Vector2(100, 100),
/// )..tint(const Color(0xFFFFD700)); // Gold tint
/// ```
class IconComponent extends PositionComponent with HasPaint {
  /// The icon to render.
  IconData? _icon;

  /// The size at which to rasterize the icon. This controls the resolution
  /// of the rasterized image, independent of the component's display [size].
  double _iconSize;

  /// The rasterized icon image (rendered in white for tinting).
  @visibleForTesting
  Image? image;

  /// Whether the icon needs to be re-rasterized on the next [update].
  bool _needsRasterize = false;

  /// Cached source rect (image dimensions), updated when the image changes.
  Rect _srcRect = Rect.zero;

  /// Cached destination rect (component size), updated via a size listener.
  Rect _dstRect = Rect.zero;

  /// Creates an [IconComponent] that renders [icon] as a Flame component.
  ///
  /// - [icon]: The [IconData] to render (e.g., `Icons.star`).
  /// - [iconSize]: The resolution at which to rasterize the icon (default 64).
  /// - [paint]: Optional paint for rendering effects.
  /// - [size]: The display size of the component. Defaults to
  ///   `Vector2.all(iconSize)` if not specified.
  IconComponent({
    IconData? icon,
    double iconSize = 64,
    Paint? paint,
    super.position,
    Vector2? size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : _icon = icon,
       _iconSize = iconSize,
       super(size: size ?? Vector2.all(iconSize)) {
    if (paint != null) {
      this.paint = paint;
    }
    _dstRect = this.size.toRect();
    this.size.addListener(_updateDstRect);
  }

  /// The icon to render.
  IconData? get icon => _icon;

  set icon(IconData? value) {
    if (_icon != value) {
      _icon = value;
      _needsRasterize = true;
    }
  }

  /// The rasterization resolution of the icon.
  double get iconSize => _iconSize;

  set iconSize(double value) {
    if (_iconSize != value) {
      _iconSize = value;
      _needsRasterize = true;
    }
  }

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    await super.onLoad();
    if (_icon != null) {
      image = await _rasterizeIcon();
      _updateSrcRect();
    }
  }

  @override
  @mustCallSuper
  void onMount() {
    assert(
      _icon != null,
      'You have to set the icon in either the constructor or in onLoad',
    );
    assert(
      image != null,
      'The icon image must be rasterized before mounting',
    );
  }

  @override
  @mustCallSuper
  void update(double dt) {
    if (_needsRasterize) {
      _needsRasterize = false;
      _rerasterize();
    }
  }

  @override
  void render(Canvas canvas) {
    final cachedImage = image;
    if (cachedImage == null) {
      return;
    }
    canvas.drawImageRect(
      cachedImage,
      _srcRect,
      _dstRect,
      paint,
    );
  }

  @override
  @mustCallSuper
  void onRemove() {
    super.onRemove();
    size.removeListener(_updateDstRect);
    image?.dispose();
    image = null;
  }

  /// Rasterizes the current [icon] to a white [Image].
  Future<Image> _rasterizeIcon() {
    final iconData = _icon!;
    final paragraphBuilder =
        ParagraphBuilder(
            ParagraphStyle(
              fontSize: _iconSize,
              fontFamily: iconData.fontFamily,
            ),
          )
          ..pushStyle(
            TextStyle(
              color: const Color(0xFFFFFFFF),
              fontSize: _iconSize,
              fontFamily: iconData.fontFamily,
              fontFamilyFallback: iconData.fontFamilyFallback,
            ),
          )
          ..addText(String.fromCharCode(iconData.codePoint))
          ..pop();

    final paragraph = paragraphBuilder.build()
      ..layout(ParagraphConstraints(width: _iconSize));

    final pictureWidth = paragraph.maxIntrinsicWidth.ceil();
    final pictureHeight = paragraph.height.ceil();

    final recorder = PictureRecorder();
    final bounds = Rect.fromLTWH(
      0,
      0,
      pictureWidth.toDouble(),
      pictureHeight.toDouble(),
    );
    Canvas(recorder, bounds).drawParagraph(paragraph, Offset.zero);

    return recorder.endRecording().toImageSafe(pictureWidth, pictureHeight);
  }

  /// Disposes the old image (with a delay) and creates a new one.
  void _rerasterize() {
    final oldImage = image;
    if (oldImage != null) {
      // Delay disposal to avoid using disposed images in the rendering
      // pipeline. See issue #1618 for details.
      Future.delayed(const Duration(milliseconds: 100), () {
        if (isMounted) {
          oldImage.dispose();
        }
      });
    }
    if (_icon != null) {
      _rasterizeIcon().then((newImage) {
        image = newImage;
        _updateSrcRect();
      });
    }
  }

  void _updateSrcRect() {
    final img = image;
    if (img != null) {
      _srcRect = Rect.fromLTWH(
        0,
        0,
        img.width.toDouble(),
        img.height.toDouble(),
      );
    }
  }

  void _updateDstRect() {
    _dstRect = size.toRect();
  }
}
