import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// [ScrollTextBoxComponent] configures the layout and interactivity of a
/// scrollable text box.
/// It focuses on the box's size, scrolling mechanics, padding, and alignment,
/// contrasting with [TextRenderer], which handles text appearance like font and
/// color.
///
/// This component uses [TextBoxComponent] to provide scrollable text
/// capabilities.
class ScrollTextBoxComponent<T extends TextRenderer> extends PositionComponent {
  late final _ScrollTextBoxComponent<T> _scrollTextBoxComponent;
  late final ValueNotifier<int> newLineNotifier;

  /// Constructor for [ScrollTextBoxComponent].
  /// - [size]: Specifies the size of the text box.
  ///   Must have positive dimensions.
  /// - [text]: The text content to be displayed.
  /// - [textRenderer]: Handles the rendering of the text.
  /// - [boxConfig]: Configuration for the text box appearance.
  /// - [onComplete]: Callback will be executed after all text is displayed.
  /// - Other parameters include alignment, pixel ratio, and positioning
  ///   settings.
  /// An assertion ensures that the [size] has positive dimensions.
  ScrollTextBoxComponent({
    required Vector2 size,
    String? text,
    T? textRenderer,
    TextBoxConfig? boxConfig,
    Anchor align = Anchor.topLeft,
    double pixelRatio = 1.0,
    super.position,
    super.scale,
    double angle = 0.0,
    super.anchor = Anchor.topLeft,
    super.priority,
    super.key,
    List<Component>? children,
    void Function()? onComplete,
  }) : assert(
         size.x > 0 && size.y > 0,
         'size must have positive dimensions: $size',
       ),
       super(size: size) {
    final marginTop = boxConfig?.margins.top ?? 0;
    final marginBottom = boxConfig?.margins.bottom ?? 0;
    final innerMargins = EdgeInsets.fromLTRB(0, marginTop, 0, marginBottom);

    boxConfig ??= const TextBoxConfig();
    boxConfig = TextBoxConfig(
      timePerChar: boxConfig.timePerChar,
      dismissDelay: boxConfig.dismissDelay,
      growingBox: boxConfig.growingBox,
      maxWidth: size.x,
      margins: EdgeInsets.fromLTRB(
        boxConfig.margins.left,
        0,
        boxConfig.margins.right,
        0,
      ),
    );
    _scrollTextBoxComponent = _ScrollTextBoxComponent<T>(
      text: text,
      textRenderer: textRenderer,
      boxConfig: boxConfig,
      align: align,
      pixelRatio: pixelRatio,
      onComplete: onComplete,
    );
    newLineNotifier = _scrollTextBoxComponent.newLineNotifier;

    _scrollTextBoxComponent.setOwnerComponent = this;
    // Integrates the [ClipComponent] for managing
    // the text box's scrollable area.
    add(
      ClipComponent.rectangle(
        size: size - Vector2(0, innerMargins.vertical),
        position: Vector2(0, innerMargins.top),
        angle: angle,
        scale: scale,
        priority: priority,
        children: children,
      )..add(_scrollTextBoxComponent),
    );
  }

  /// Override this method to provide a custom background to the text box.
  ///
  /// Note: The background is designed to stretch across the entire scrollable
  /// area of the text box. This ensures that as the user scrolls through the
  /// text, the background moves in sync with the text. As an alternative,
  /// consider adding [ScrollTextBoxComponent] to a [SpriteComponent].
  void drawBackground(Canvas canvas) {}
}

/// Private class handling the internal workings of [ScrollTextBoxComponent].
///
/// Extends [TextBoxComponent] and incorporates drag callbacks for text
/// scrolling. It manages the rendering and user interaction for the text within
/// the box.
class _ScrollTextBoxComponent<T extends TextRenderer> extends TextBoxComponent
    with DragCallbacks {
  double scrollBoundsY = 0.0;

  late final ClipComponent clipComponent;

  late ScrollTextBoxComponent<TextRenderer> _owner;

  bool _isOnCompleteExecuted = false;

  _ScrollTextBoxComponent({
    String? text,
    T? textRenderer,
    TextBoxConfig? boxConfig,
    Anchor super.align = Anchor.topLeft,
    double super.pixelRatio = 1.0,
    super.position,
    super.scale,
    double super.angle = 0.0,
    super.onComplete,
  }) : super(
         text: text ?? '',
         textRenderer: textRenderer ?? TextPaint(),
         boxConfig: boxConfig ?? const TextBoxConfig(),
       );

  @override
  Future<void> onLoad() {
    clipComponent = parent! as ClipComponent;
    newLinePositionNotifier.addListener(() {
      if (newLinePositionNotifier.value > clipComponent.size.y) {
        position.y = -newLinePositionNotifier.value + clipComponent.size.y;
      }
    });
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (!_isOnCompleteExecuted && finished) {
      _isOnCompleteExecuted = true;
      scrollBoundsY = clipComponent.size.y - size.y;
    }

    super.update(dt);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (finished && scrollBoundsY < 0) {
      position.y += event.localDelta.y;
      position.y = position.y.clamp(scrollBoundsY, 0);
    }
  }

  @override
  void drawBackground(Canvas canvas) {
    _owner.drawBackground(canvas);
  }

  set setOwnerComponent(ScrollTextBoxComponent scrollTextBoxComponent) {
    _owner = scrollTextBoxComponent;
  }
}
