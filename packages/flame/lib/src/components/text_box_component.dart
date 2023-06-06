import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/widgets.dart' hide Image;
import 'package:meta/meta.dart';

/// A set of configurations for the [TextBoxComponent] itself, as opposed to
/// the [TextRenderer], which contains the configuration for how to render the
/// text only (font size, color, family, etc).
class TextBoxConfig {
  /// Max width this paragraph can take. Lines will be broken trying to respect
  /// word boundaries in as many lines as necessary.
  final double maxWidth;

  /// Margins of the text box with respect to the [PositionComponent.size].
  final EdgeInsets margins;

  /// Defaults to 0. If not zero, the characters will appear one-by-one giving
  /// a typing effect to the text box, and this will be the delay in seconds
  /// between each character.
  final double timePerChar;

  /// Defaults to 0. If not zero, this component will disappear after this many
  /// seconds after being fully typed out.
  final double dismissDelay;

  /// Only relevant if [timePerChar] is set. If true, the box will start with
  /// the size to fit the first character and grow as more lines are typed.
  /// If false, the box will start with the full necessary size from the
  /// beginning (both width and height).
  final bool growingBox;

  TextBoxConfig({
    this.maxWidth = 200.0,
    this.margins = const EdgeInsets.all(8.0),
    this.timePerChar = 0.0,
    this.dismissDelay = 0.0,
    this.growingBox = false,
  });
}

class TextBoxComponent<T extends TextRenderer> extends TextComponent {
  static final Paint _imagePaint = BasicPalette.white.paint()
    ..filterQuality = FilterQuality.high;
  final TextBoxConfig _boxConfig;
  final double pixelRatio;

  @visibleForTesting
  final List<String> lines = [];
  double _maxLineWidth = 0.0;
  late double _lineHeight;
  late int _totalLines;

  double _lifeTime = 0.0;
  int? _previousChar;

  @visibleForTesting
  Image? cache;

  TextBoxConfig get boxConfig => _boxConfig;

  TextBoxComponent({
    super.text,
    T? super.textRenderer,
    TextBoxConfig? boxConfig,
    Anchor? align,
    double? pixelRatio,
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
  })  : _boxConfig = boxConfig ?? TextBoxConfig(),
        _fixedSize = size != null,
        align = align ?? Anchor.topLeft,
        pixelRatio = pixelRatio ??
            PlatformDispatcher.instance.views.first.devicePixelRatio;

  /// Alignment of the text within its bounding box.
  ///
  /// This property combines both the horizontal and vertical alignment. For
  /// example, setting this property to `Align.center` will make the text
  /// centered inside its box. Similarly, `Align.bottomRight` will render the
  /// text that's aligned to the right and to the bottom of the box.
  ///
  /// Custom alignment anchors are supported too. For example, if this property
  /// is set to `Anchor(0.1, 0)`, then the text would be positioned such that
  /// its every line will have 10% of whitespace on the left, and 90% on the
  /// right. You can use an `AnchorEffect` to make the text gradually transition
  /// between different alignment values.
  Anchor align;

  /// If true, the size of the component will remain fixed. If false, the size
  /// will expand or shrink to the fit the text.
  ///
  /// This property is set to true if the user has explicitly specified [size]
  /// in the constructor.
  final bool _fixedSize;

  @override
  set text(String value) {
    if (text != value) {
      super.text = value;
      // This ensures that the component will redraw on next update
      _previousChar = -1;
    }
  }

  @override
  @mustCallSuper
  Future<void> onLoad() {
    return redraw();
  }

  @override
  @mustCallSuper
  void onMount() {
    if (cache == null) {
      redraw();
    }
  }

  @override
  @internal
  void updateBounds() {
    lines.clear();
    double? lineHeight;
    final maxBoxWidth = _fixedSize ? width : _boxConfig.maxWidth;
    text.split(' ').forEach((word) {
      final wordLines = word.split('\n');
      final possibleLine =
          lines.isEmpty ? wordLines[0] : '${lines.last} ${wordLines[0]}';
      lineHeight ??= textRenderer.measureTextHeight(possibleLine);

      final textWidth = textRenderer.measureTextWidth(possibleLine);
      _updateMaxWidth(textWidth);
      var canAppend = false;
      if (textWidth <= maxBoxWidth - _boxConfig.margins.horizontal) {
        canAppend = lines.isNotEmpty;
      } else {
        canAppend = lines.isNotEmpty && lines.last == '';
      }

      if (canAppend) {
        lines.last = '${lines.last} ${wordLines[0]}';
        wordLines.removeAt(0);
        if (wordLines.isNotEmpty) {
          lines.addAll(wordLines);
        }
      } else {
        lines.addAll(wordLines);
      }
    });
    _totalLines = lines.length;
    _lineHeight = lineHeight ?? 0.0;
    size = _recomputeSize();
  }

  void _updateMaxWidth(double w) {
    if (w > _maxLineWidth) {
      _maxLineWidth = w;
    }
  }

  double get totalCharTime => text.length * _boxConfig.timePerChar;

  bool get finished => _lifeTime > totalCharTime + _boxConfig.dismissDelay;

  int get _actualTextLength {
    return lines.map((e) => e.length).sum;
  }

  int get currentChar => _boxConfig.timePerChar == 0.0
      ? _actualTextLength
      : math.min(_lifeTime ~/ _boxConfig.timePerChar, _actualTextLength);

  int get currentLine {
    var totalCharCount = 0;
    final cachedCurrentChar = currentChar;
    for (var i = 0; i < lines.length; i++) {
      totalCharCount += lines[i].length;
      if (totalCharCount > cachedCurrentChar) {
        return i;
      }
    }
    return lines.length - 1;
  }

  double getLineWidth(String line, int charCount) {
    return textRenderer.measureTextWidth(
      line.substring(0, math.min(charCount, line.length)),
    );
  }

  Vector2 _recomputeSize() {
    if (_fixedSize) {
      return size;
    } else if (_boxConfig.growingBox) {
      var i = 0;
      var totalCharCount = 0;
      final cachedCurrentChar = currentChar;
      final cachedCurrentLine = currentLine;
      final textWidth = lines.sublist(0, cachedCurrentLine + 1).map((line) {
        final charCount = (i < cachedCurrentLine)
            ? line.length
            : (cachedCurrentChar - totalCharCount);
        totalCharCount += line.length;
        i++;
        return getLineWidth(line, charCount);
      }).reduce(math.max);
      return Vector2(
        textWidth + _boxConfig.margins.horizontal,
        _lineHeight * lines.length + _boxConfig.margins.vertical,
      );
    } else {
      return Vector2(
        _boxConfig.maxWidth + _boxConfig.margins.horizontal,
        _lineHeight * _totalLines + _boxConfig.margins.vertical,
      );
    }
  }

  @override
  void render(Canvas canvas) {
    if (cache == null) {
      return;
    }
    canvas.save();
    canvas.scale(1 / pixelRatio);
    canvas.drawImage(cache!, Offset.zero, _imagePaint);
    canvas.restore();
  }

  Future<Image> _fullRenderAsImage(Vector2 size) {
    final recorder = PictureRecorder();
    final scaledSize = size * pixelRatio;
    final c = Canvas(recorder, scaledSize.toRect());
    c.scale(pixelRatio);
    _fullRender(c);
    return recorder.endRecording().toImageSafe(
          scaledSize.x.ceil(),
          scaledSize.y.ceil(),
        );
  }

  /// Override this method to provide a custom background to the text box.
  void drawBackground(Canvas c) {}

  void _fullRender(Canvas canvas) {
    drawBackground(canvas);

    final nLines = currentLine + 1;
    final boxWidth = size.x - boxConfig.margins.horizontal;
    final boxHeight = size.y - boxConfig.margins.vertical;
    var charCount = 0;
    for (var i = 0; i < nLines; i++) {
      var line = lines[i];
      if (i == nLines - 1) {
        final nChars = math.min(currentChar - charCount, line.length);
        line = line.substring(0, nChars);
      }
      textRenderer.render(
        canvas,
        line,
        Vector2(
          boxConfig.margins.left +
              (boxWidth - textRenderer.measureTextWidth(line)) * align.x,
          boxConfig.margins.top +
              (boxHeight - nLines * _lineHeight) * align.y +
              i * _lineHeight,
        ),
      );
      charCount += lines[i].length;
    }
  }

  final Set<Image> cachedToRemove = {};

  Future<void> redraw() async {
    final newSize = _recomputeSize();
    final cachedImage = cache;
    if (cachedImage != null && !cachedToRemove.contains(cachedImage)) {
      cachedToRemove.add(cachedImage);
      // Do not dispose of the cached image immediately, since it may have been
      // sent into the rendering pipeline where it is still pending to be used.
      // See issue #1618 for details.
      Future.delayed(const Duration(milliseconds: 100), () {
        cachedToRemove.remove(cachedImage);
        cachedImage.dispose();
      });
    }
    cache = await _fullRenderAsImage(newSize);
    size = newSize;
  }

  @override
  void update(double dt) {
    _lifeTime += dt;
    if (_previousChar != currentChar) {
      redraw();
    }
    _previousChar = currentChar;
  }

  @override
  @mustCallSuper
  void onRemove() {
    super.onRemove();
    cache?.dispose();
    cache = null;
  }
}
