import 'dart:ui' as ui;

import 'package:flame/extensions.dart' hide Matrix4;
import 'package:flame/game.dart' hide Matrix4;
import 'package:flame/src/components/widget_component.dart';
import 'package:flame/src/game/game_loop.dart';
import 'package:flame/src/game/proxy_canvas.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' hide WidgetBuilder;
import 'package:meta/meta.dart';

/// A [RenderObjectWidget] that renders the [GameRenderBox].
///
/// This is the widget that is used by the [GameWidget] to ACTUALLY
/// render the game.
///
/// Its [children] are the widgets hosted by the [WidgetComponent]s that are
/// currently mounted in the game, each wrapped in a
/// [WidgetComponentParentDataWidget].
class RenderGameWidget extends MultiChildRenderObjectWidget {
  const RenderGameWidget({
    required this.game,
    required this.addRepaintBoundary,
    required this.behavior,
    super.children,
    super.key,
  });

  final Game game;
  final bool addRepaintBoundary;
  final HitTestBehavior behavior;

  @override
  RenderBox createRenderObject(BuildContext context) {
    return GameRenderBox(
      game,
      context,
      isRepaintBoundary: addRepaintBoundary,
      behavior: behavior,
    );
  }

  @override
  void updateRenderObject(BuildContext context, GameRenderBox renderObject) {
    renderObject
      ..game = game
      ..buildContext = context
      ..isRepaintBoundary = addRepaintBoundary
      ..behavior = behavior;
  }
}

/// Parent data for the children of [GameRenderBox], linking each child render
/// box to the [WidgetComponent] that hosts it.
class WidgetComponentParentData extends ContainerBoxParentData<RenderBox> {
  WidgetComponent? component;

  /// The transform from the child's coordinates to the local coordinates of
  /// the [GameRenderBox], as of the last time the child was painted.
  Matrix4? paintTransform;
}

/// Wraps the widget of a [WidgetComponent] so that the [GameRenderBox] knows
/// which component a child render box belongs to.
@internal
class WidgetComponentParentDataWidget
    extends ParentDataWidget<WidgetComponentParentData> {
  const WidgetComponentParentDataWidget({
    required this.component,
    required super.child,
    super.key,
  });

  final WidgetComponent component;

  @override
  void applyParentData(RenderObject renderObject) {
    final parentData = renderObject.parentData! as WidgetComponentParentData;
    if (parentData.component != component) {
      parentData.component = component;
      renderObject.parent?.markNeedsLayout();
    }
  }

  @override
  Type get debugTypicalAncestorWidgetClass => RenderGameWidget;
}

class GameRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, WidgetComponentParentData>,
        WidgetsBindingObserver {
  GameRenderBox(
    this._game,
    this.buildContext, {
    required this._isRepaintBoundary,
    this.behavior = HitTestBehavior.opaque,
  });

  GameLoop? gameLoop;

  BuildContext buildContext;

  Game _game;

  Game get game => _game;

  set game(Game value) {
    // Identities are equal, no need to update.
    if (_game == value) {
      return;
    }

    if (attached) {
      _detachGame();
    }

    _game = value;

    if (attached) {
      _attachGame(owner!);
    }
  }

  bool _isRepaintBoundary;

  set isRepaintBoundary(bool value) {
    if (_isRepaintBoundary == value) {
      return;
    }
    _isRepaintBoundary = value;
    markNeedsCompositingBitsUpdate();
  }

  @override
  bool get isRepaintBoundary => _isRepaintBoundary;

  HitTestBehavior behavior;

  final Map<WidgetComponent, RenderBox> _childByComponent = {};

  /// The widgets that were painted during the last paint, in paint order.
  final List<_PaintedWidget> _paintedWidgets = [];

  PaintingContext? _paintingContext;
  ProxyCanvas? _canvas;

  /// The transform from this render box's local coordinates to the coordinate
  /// space of the canvas the game was rendered on during the last paint,
  /// inverted so that widget transforms can be brought back to local space.
  Matrix4? _inverseBaseTransform;
  Matrix4? _baseTransform;

  /// The components whose widgets were painted during the last paint, in
  /// paint order.
  @visibleForTesting
  List<WidgetComponent> get paintedWidgetComponents {
    return [for (final painted in _paintedWidgets) painted.component];
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! WidgetComponentParentData) {
      child.parentData = WidgetComponentParentData();
    }
  }

  @override
  void performLayout() {
    _childByComponent.clear();
    _paintedWidgets.clear();
    final gameSize = size.toVector2();
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as WidgetComponentParentData;
      final component = parentData.component;
      if (component == null) {
        child.layout(BoxConstraints.tight(Size.zero));
      } else {
        _childByComponent[component] = child;
        child.layout(component.constraintsFor(gameSize), parentUsesSize: true);
        component.adoptWidgetSize(child.size);
      }
      child = parentData.nextSibling;
    }
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _attachGame(owner);
  }

  void _attachGame(PipelineOwner owner) {
    game.attach(owner, this);

    final gameLoop = this.gameLoop = GameLoop(gameLoopCallback);

    if (!game.isPaused) {
      gameLoop.start();
    }

    _bindLifecycleListener();
  }

  @override
  void detach() {
    super.detach();
    _detachGame();
  }

  void _detachGame() {
    game.detach();
    gameLoop?.dispose();
    gameLoop = null;
    _unbindLifecycleListener();
  }

  void gameLoopCallback(double dt) {
    assert(attached);
    if (!attached) {
      return;
    }
    game.update(dt);
    markNeedsPaint();
  }

  @override
  bool hitTestSelf(Offset position) {
    if (behavior == HitTestBehavior.opaque) {
      return true;
    }
    return game.containsEventHandlerAt(position.toVector2());
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    final baseTransform = _baseTransform;
    if (baseTransform == null) {
      return false;
    }
    final canvasPosition = MatrixUtils.transformPoint(baseTransform, position);
    for (var i = _paintedWidgets.length - 1; i >= 0; i--) {
      final painted = _paintedWidgets[i];
      if (!painted.clip.contains(canvasPosition)) {
        continue;
      }
      final isHit = result.addWithPaintTransform(
        transform: painted.localTransform,
        position: position,
        hitTest: (result, transformed) {
          return painted.child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }

  @override
  void applyPaintTransform(RenderBox child, Matrix4 transform) {
    final paintTransform =
        (child.parentData! as WidgetComponentParentData).paintTransform;
    if (paintTransform != null) {
      transform.multiply(paintTransform);
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _paintedWidgets.clear();
    if (firstChild == null) {
      _baseTransform = null;
      _inverseBaseTransform = null;
      context.canvas.save();
      context.canvas.translate(offset.dx, offset.dy);
      game.render(context.canvas);
      context.canvas.restore();
      return;
    }

    final canvas = ProxyCanvas(context.canvas);
    _paintingContext = context;
    _canvas = canvas;
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    final baseTransform = Matrix4.fromFloat64List(canvas.getTransform());
    _baseTransform = baseTransform;
    _inverseBaseTransform = Matrix4.tryInvert(baseTransform);
    try {
      game.render(canvas);
    } finally {
      canvas.restore();
      _paintingContext = null;
      _canvas = null;
    }
  }

  /// Paints the widget hosted by [component] at the current transform of
  /// [canvas], as part of the game render pass.
  ///
  /// Does nothing when [canvas] is not the canvas of the current paint, which
  /// is the case when the component tree is being rendered somewhere else,
  /// for example into a snapshot.
  @internal
  void paintWidgetComponent(WidgetComponent component, ui.Canvas canvas) {
    final context = _paintingContext;
    final proxyCanvas = _canvas;
    final inverseBaseTransform = _inverseBaseTransform;
    if (context == null ||
        proxyCanvas == null ||
        inverseBaseTransform == null ||
        !identical(canvas, proxyCanvas)) {
      return;
    }
    final child = _childByComponent[component];
    if (child == null) {
      return;
    }

    final transform = Matrix4.fromFloat64List(canvas.getTransform());
    final clip = canvas.getDestinationClipBounds();
    final localTransform = inverseBaseTransform.multiplied(transform);
    (child.parentData! as WidgetComponentParentData).paintTransform =
        localTransform;
    _paintedWidgets.add(
      _PaintedWidget(
        component: component,
        child: child,
        clip: clip,
        localTransform: localTransform,
      ),
    );

    if (!child.needsCompositing) {
      context.paintChild(child, Offset.zero);
      return;
    }

    if (_isClippedByFlame(clip)) {
      context.pushClipRect(true, Offset.zero, clip, (context, offset) {
        context.pushTransform(true, offset, transform, _paintChildOf(child));
      });
    } else {
      context.pushTransform(true, Offset.zero, transform, _paintChildOf(child));
    }
    proxyCanvas.swap(context.canvas);
  }

  /// Whether [clip], given in the coordinate space of the canvas that the game
  /// is rendered on, cuts into the area of this render box.
  bool _isClippedByFlame(Rect clip) {
    final bounds = MatrixUtils.transformRect(
      _baseTransform!,
      Offset.zero & size,
    );
    const tolerance = 0.001;
    return clip.left > bounds.left + tolerance ||
        clip.top > bounds.top + tolerance ||
        clip.right < bounds.right - tolerance ||
        clip.bottom < bounds.bottom - tolerance;
  }

  static PaintingContextCallback _paintChildOf(RenderBox child) {
    return (context, offset) => context.paintChild(child, offset);
  }

  void _bindLifecycleListener() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _unbindLifecycleListener() {
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    game.lifecycleStateChange(state);
  }
}

class _PaintedWidget {
  _PaintedWidget({
    required this.component,
    required this.child,
    required this.clip,
    required this.localTransform,
  });

  final WidgetComponent component;
  final RenderBox child;

  /// The clip that was active when the widget was painted, in the coordinate
  /// space of the canvas the game was rendered on.
  final Rect clip;

  /// The transform from the widget's coordinates to the local coordinates of
  /// the [GameRenderBox].
  final Matrix4 localTransform;
}
