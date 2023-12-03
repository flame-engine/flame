import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/text.dart';
import 'package:flutter/painting.dart';

/// [ScrollTextBoxComponent] configures the layout and interactivity of a
/// scrollable text box.
/// It focuses on the box's size, scrolling mechanics, padding, and alignment,
/// contrasting with [TextRenderer],
/// which handles text appearance like font and color.
/// This component uses [TextBoxComponent] to provide
/// scrollable text capabilities.
class ScrollTextBoxComponent<T extends TextRenderer> extends PositionComponent {
  late final _ScrollTextBoxComponent<T> _scrollTextBoxComponent;

  /// Constructor for [ScrollTextBoxComponent].
  /// - [desiredFrameSize]: Specifies the size of the text box.
  /// Must have positive dimensions.
  /// - [text]: The text content to be displayed.
  /// - [textRenderer]: Handles the rendering of the text.
  /// - [boxConfig]: Configuration for the text box appearance.
  /// - Other parameters include alignment, pixel ratio, and
  /// positioning settings.
  /// An assertion ensures that the [desiredFrameSize] has
  /// positive dimensions.
  ScrollTextBoxComponent({
    required Vector2 desiredFrameSize,
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
  }) : assert(
          desiredFrameSize.x > 0 && desiredFrameSize.y > 0,
          'desiredFrameSize must have positive dimensions: $desiredFrameSize',
        ) {
    final marginTop = boxConfig?.margins.top ?? 0;
    final marginBottom = boxConfig?.margins.bottom ?? 0;
    final innerMargins = EdgeInsets.fromLTRB(0, marginTop, 0, marginBottom);

    boxConfig ??= TextBoxConfig();
    boxConfig = TextBoxConfig(
      timePerChar: boxConfig.timePerChar,
      dismissDelay: boxConfig.dismissDelay,
      growingBox: boxConfig.growingBox,
      maxWidth: desiredFrameSize.x,
      margins: EdgeInsets.fromLTRB(
        boxConfig.margins.left,
        0,
        boxConfig.margins.right,
        0,
      ),
    );

    _scrollTextBoxComponent = _ScrollTextBoxComponent<T>(
      desiredFrameSize: desiredFrameSize - Vector2(0, innerMargins.vertical),
      text: text,
      textRenderer: textRenderer,
      boxConfig: boxConfig,
      align: align,
      pixelRatio: pixelRatio,
      innerMargins: innerMargins,
    );
    _scrollTextBoxComponent.setOwnerComponent = this;
    // Integrates the [ClipComponent] for managing
    // the text box's scrollable area.
    add(
      ClipComponent.rectangle(
        size: desiredFrameSize - Vector2(0, innerMargins.vertical),
        position: Vector2(0, marginTop),
        angle: angle,
        scale: scale,
        anchor: anchor,
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
  void drawBackground(Canvas c) {}
}

/// Private class handling the internal workings of [ScrollTextBoxComponent].
///
/// Extends [TextBoxComponent] and incorporates
/// drag callbacks for text scrolling.
/// It manages the rendering and user interaction
/// for the text within the box.
class _ScrollTextBoxComponent<T extends TextRenderer> extends TextBoxComponent
    with DragCallbacks {
  final Vector2 desiredFrameSize;
  double scrollBoundsY = 0.0;
  int _linesScrolled = 0;
  final EdgeInsets innerMargins;

  late final ClipComponent clipComponent;
  late ScrollTextBoxComponent<TextRenderer> _owner;

  _ScrollTextBoxComponent({
    required this.desiredFrameSize,
    required this.innerMargins,
    String? text,
    T? textRenderer,
    TextBoxConfig? boxConfig,
    Anchor super.align = Anchor.topLeft,
    double super.pixelRatio = 1.0,
    super.position,
    super.scale,
    double super.angle = 0.0,
  }) : super(
          text: text ?? '',
          textRenderer: textRenderer ?? TextPaint(),
          boxConfig: boxConfig ?? TextBoxConfig(),
        );

  @override
  Future<void> onLoad() {
    clipComponent = parent! as ClipComponent;
    return super.onLoad();
  }

  @override
  Future<void> redraw() async {
    if ((currentLine + 1 - _linesScrolled) * lineHeight >
        clipComponent.size.y) {
      _linesScrolled++;
      position.y -= lineHeight;
      scrollBoundsY = -position.y;
    }
    await super.redraw();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (finished && _linesScrolled > 0) {
      position += Vector2(0, event.localDelta.y);
      position.y = position.y.clamp(-scrollBoundsY, 0);
    }
  }

  @override
  void drawBackground(Canvas c) {
    _owner.drawBackground(c);
  }

  set setOwnerComponent(ScrollTextBoxComponent scrollTextBoxComponent) {
    _owner = scrollTextBoxComponent;
  }
}
