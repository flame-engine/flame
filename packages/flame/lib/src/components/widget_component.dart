import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/widgets.dart';

/// A [PositionComponent] that hosts a Flutter [widget] inside the Flame
/// component tree.
///
/// The widget becomes a real part of the Flutter element tree under the
/// `GameWidget`, so it is laid out, painted, hit tested and focused like any
/// other widget: buttons respond to taps, text fields receive keyboard input,
/// and inherited widgets such as `Theme`, `MediaQuery` and `Directionality`
/// are available to it. At the same time it is rendered in the middle of the
/// Flame render pass, so it respects the component [priority], the camera
/// transform and the position, angle, scale and anchor of this component and
/// all of its ancestors.
///
/// ```dart
/// world.add(
///   WidgetComponent(
///     position: Vector2(100, 100),
///     size: Vector2(200, 60),
///     anchor: Anchor.center,
///     widget: ElevatedButton(
///       onPressed: () => print('pressed'),
///       child: const Text('Play'),
///     ),
///   ),
/// );
/// ```
///
/// When [size] is given, the widget is laid out with tight constraints of that
/// size. When it is omitted, the widget is laid out with loose constraints
/// bounded by the size of the game canvas, and the component adopts whatever
/// size the widget ends up with.
///
/// Limitations:
/// - The widget is only rendered by the `GameWidget` render pass. It is not
///   included when the component tree is rendered to a `Picture` or `Image`
///   elsewhere, for example by the `Snapshot` mixin, `PostProcess`es or the
///   devtools component snapshot.
/// - Flame paints and clips are not applied to the widget. Paint based effects
///   such as `OpacityEffect` or `ColorEffect` on this component or its
///   ancestors do not affect the widget, only transforms do.
/// - A widget that needs its own compositing layer (for example one that
///   contains a `RepaintBoundary`) splits the game's picture, which means that
///   any `saveLayer` an ancestor component has active at that point is closed
///   and reopened around it.
class WidgetComponent extends PositionComponent {
  // ignore: use_super_parameters
  WidgetComponent({
    required Widget widget,
    Vector2? size,
    super.position,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
    super.key,
  }) : _widget = widget, // ignore: prefer_initializing_formals
       _adoptsWidgetSize = size == null,
       super(size: size) {
    this.size.addListener(_onSizeChanged);
  }

  Widget _widget;
  final bool _adoptsWidgetSize;
  bool _isAdoptingSize = false;
  Game? _game;

  /// The Flutter widget hosted by this component.
  ///
  /// Assigning a new widget rebuilds the hosted subtree, in the same way as
  /// returning a new widget from a `build` method would.
  Widget get widget => _widget;
  set widget(Widget value) {
    if (identical(_widget, value)) {
      return;
    }
    _widget = value;
    _game?.refreshWidget(isInternalRefresh: false);
  }

  /// Whether the component takes its [size] from the laid out widget, which is
  /// the case when no size was passed to the constructor.
  bool get adoptsWidgetSize => _adoptsWidgetSize;

  /// The [BoxConstraints] that the widget is laid out with.
  BoxConstraints constraintsFor(Vector2 gameSize) {
    if (_adoptsWidgetSize) {
      return BoxConstraints.loose(Size(gameSize.x, gameSize.y));
    }
    return BoxConstraints.tightFor(width: size.x, height: size.y);
  }

  /// Called by the `GameRenderBox` after the widget has been laid out, so that
  /// the component can adopt the widget's size without triggering a relayout.
  void adoptWidgetSize(Size widgetSize) {
    if (!_adoptsWidgetSize) {
      return;
    }
    if (size.x == widgetSize.width && size.y == widgetSize.height) {
      return;
    }
    _isAdoptingSize = true;
    size = Vector2(widgetSize.width, widgetSize.height);
    _isAdoptingSize = false;
  }

  void _onSizeChanged() {
    if (_isAdoptingSize) {
      return;
    }
    final game = _game;
    if (game != null && game.isAttached) {
      game.renderBox.markNeedsLayout();
    }
  }

  @override
  void onMount() {
    super.onMount();
    final game = findRootGame()!;
    _game = game;
    game.registerWidgetComponent(this);
  }

  @override
  void onRemove() {
    _game?.unregisterWidgetComponent(this);
    _game = null;
    super.onRemove();
  }

  @override
  void render(Canvas canvas) {
    final game = _game;
    if (game == null || !game.isAttached) {
      return;
    }
    game.renderBox.paintWidgetComponent(this, canvas);
  }
}
