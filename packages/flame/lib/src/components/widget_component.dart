import 'package:flame/src/components/position_component.dart';
import 'package:flame/src/extensions/vector2.dart';
import 'package:flame/src/game/game.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

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
/// size. When it is omitted, the component adopts whatever size the widget
/// ends up with after being laid out with [constraints], which default to
/// loose constraints bounded by the size of the game canvas expressed in the
/// local units of the component, so the scale of the component and of its
/// ancestors is taken into account but the camera zoom is not.
///
/// Limitations:
/// - The widget is only rendered by the `GameWidget` render pass. It is not
///   included when the component tree is rendered to a `Picture` or `Image`
///   elsewhere, for example by the `Snapshot` mixin, `PostProcess`es or the
///   devtools component snapshot.
/// - Flame paints are not applied to the widget. Paint based effects such as
///   `OpacityEffect` or `ColorEffect` on this component or its ancestors do
///   not affect the widget, only transforms and rectangular clips (such as the
///   camera viewport) do.
/// - A widget that needs its own compositing layer (for example one that
///   contains a `RepaintBoundary`) splits the game's picture, which means that
///   any `saveLayer` an ancestor component has active at that point is closed
///   and reopened around it.
/// - A widget can only be painted once per frame. When the same
///   [WidgetComponent] is rendered several times in one frame, for example
///   because its world is viewed by several cameras, only the first render
///   paints the widget.
class WidgetComponent extends PositionComponent {
  // ignore: use_super_parameters
  WidgetComponent({
    required Widget widget,
    Vector2? size,
    this.constraints,
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
  bool _isPainted = false;
  Game? _game;
  final _HostNotifier _hostNotifier = _HostNotifier();

  /// The constraints that the widget is laid out with when no [size] was
  /// given. When this is null too, the widget is laid out with loose
  /// constraints bounded by the size of the game canvas in local units.
  ///
  /// Ignored when a [size] was given, since the widget then always gets tight
  /// constraints of that size.
  final BoxConstraints? constraints;

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
    _hostNotifier.notify();
  }

  /// Whether the component takes its [size] from the laid out widget, which is
  /// the case when no size was passed to the constructor.
  bool get adoptsWidgetSize => _adoptsWidgetSize;

  /// Whether the widget was painted during the last game render pass.
  ///
  /// This is false while the component is not rendered, for example because
  /// an ancestor is hidden, in which case the hosted widget is also excluded
  /// from focus and semantics.
  bool get isPainted => _isPainted;

  /// Notifies when [widget] or [isPainted] change, so that the host of the
  /// widget in the Flutter tree can rebuild.
  @internal
  Listenable get hostListenable => _hostNotifier;

  /// The [BoxConstraints] that the widget is laid out with.
  @internal
  BoxConstraints constraintsFor(Vector2 gameSize) {
    if (!_adoptsWidgetSize) {
      return BoxConstraints.tightFor(width: size.x, height: size.y);
    }
    final constraints = this.constraints;
    if (constraints != null) {
      return constraints;
    }
    final absoluteScale = this.absoluteScale;
    final scaleX = absoluteScale.x.abs();
    final scaleY = absoluteScale.y.abs();
    return BoxConstraints.loose(
      Size(
        scaleX == 0 ? 0 : gameSize.x / scaleX,
        scaleY == 0 ? 0 : gameSize.y / scaleY,
      ),
    );
  }

  /// Called by the `GameRenderBox` after the widget has been laid out, so that
  /// the component can adopt the widget's size without triggering a relayout.
  @internal
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

  /// Called by the `GameRenderBox` after each render pass with whether the
  /// widget was painted in it.
  @internal
  void markPainted({required bool isPainted}) {
    if (_isPainted == isPainted) {
      return;
    }
    _isPainted = isPainted;
    _hostNotifier.notify();
  }

  void _onSizeChanged() {
    if (_isAdoptingSize) {
      return;
    }
    final game = _game;
    if (game != null && game.isAttached) {
      game.renderBox.markNeedsWidgetLayout();
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
    _isPainted = false;
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

class _HostNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}
