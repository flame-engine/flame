import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_scene/scene.dart'
    show Camera, Node, PerspectiveCamera, Scene;

/// Renders a flutter_scene [Scene] as a regular Flame [PositionComponent].
///
/// The component draws [camera]'s view of [scene] into its own [size], so it
/// can be positioned, scaled, rotated, anchored, and layered with the other
/// components in the tree. Build the scene graph by adding [Node]s to [root]
/// or by working with [scene] directly.
///
/// The scene's clock is driven by Flame: the time passed to [update] is handed
/// to [Scene.update] right before the scene is rendered, so pausing the game
/// also pauses animations and node components inside the scene.
///
/// [onLoad] waits for [Scene.initializeStaticResources], which loads the
/// engine's shader libraries. Geometry and materials rely on those, so create
/// them after `super.onLoad()` in a subclass, or after awaiting
/// [Scene.initializeStaticResources] yourself.
///
/// Rendering goes through Flutter GPU, which has to be enabled on every
/// native platform (for example with `flutter run --enable-flutter-gpu`).
/// Frames are skipped while the engine is not ready to render.
class Component3D({
  var Scene? _scene,
  Camera? camera,

  /// The logical to physical pixel multiplier for the offscreen render
  /// target.
  ///
  /// When null, the device pixel ratio multiplied by the current zoom of the
  /// canvas is used, so the scene stays sharp when the Flame camera zooms in.
  /// Set a smaller value to trade fidelity for performance, or a larger one
  /// to render at a higher resolution than the screen.
  var double? pixelRatio,
  super.position,
  super.size,
  super.scale,
  super.angle,
  super.anchor,
  super.children,
  super.priority,
  super.key,
}) extends PositionComponent {
  /// The scene that is rendered by this component.
  ///
  /// Created on first access when no scene was passed to the constructor.
  Scene get scene => _scene ??= Scene();

  /// The camera whose view of [scene] is rendered.
  Camera camera = camera ?? PerspectiveCamera();

  /// The root [Node] of [scene].
  Node get root => scene.root;

  double _pendingDelta = 0;

  /// Whether the flutter_scene engine is ready to render.
  ///
  /// Rendering is skipped while this is false.
  @protected
  bool get isReadyToRender => Scene.isReadyToRender;

  @override
  Future<void> onLoad() async {
    await Scene.initializeStaticResources();
  }

  @override
  void update(double dt) {
    _pendingDelta += dt;
  }

  @override
  void render(Canvas canvas) {
    final viewport = size.toRect();
    if (viewport.isEmpty || !isReadyToRender) {
      return;
    }
    final dt = _pendingDelta;
    _pendingDelta = 0;
    updateScene(dt);
    renderScene(canvas, viewport, pixelRatio ?? _effectivePixelRatio(canvas));
  }

  /// Advances [scene] by [dt] seconds, the time that has passed in Flame
  /// since the scene was last rendered.
  @protected
  void updateScene(double dt) {
    scene.update(dt);
  }

  /// Renders [camera]'s view of [scene] into [viewport] on [canvas], with the
  /// offscreen render target sized by [pixelRatio].
  ///
  /// Override this to render the scene differently, for example with
  /// [Scene.renderViews] to draw several cameras into the viewport.
  @protected
  void renderScene(Canvas canvas, Rect viewport, double pixelRatio) {
    scene.render(camera, canvas, viewport: viewport, pixelRatio: pixelRatio);
  }

  /// Computes the pixel ratio from the device pixel ratio and how much the
  /// canvas is currently zoomed, so the offscreen target matches the
  /// resolution the scene is composited at.
  double _effectivePixelRatio(Canvas canvas) {
    final devicePixelRatio =
        PlatformDispatcher.instance.implicitView?.devicePixelRatio ?? 1.0;
    final destination = canvas.getDestinationClipBounds();
    final local = canvas.getLocalClipBounds();
    if (destination.isEmpty || local.isEmpty) {
      return devicePixelRatio;
    }
    final zoom = max(
      destination.width / local.width,
      destination.height / local.height,
    );
    if (!zoom.isFinite || zoom <= 0) {
      return devicePixelRatio;
    }
    return devicePixelRatio * zoom;
  }
}
