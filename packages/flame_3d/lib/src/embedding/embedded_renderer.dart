import 'package:flame_3d/graphics.dart';
import 'package:flutter/scheduler.dart';

/// The device and render context shared by the `Scene3DComponent`s of a game
/// that is not a `Game3D`, and the device frames around their render passes.
///
/// A device frame is opened by the first pass of a Flutter frame and closed
/// once the frame is painted, so that the passes of all the components of a
/// game share one frame: their render targets stay pooled from frame to
/// frame and the device's statistics cover all of them. A pass rendered
/// outside the painting of a frame (an offscreen capture, for example) gets a
/// device frame of its own.
class EmbeddedRenderer._() {
  /// The shared device.
  final GraphicsDevice device = GraphicsDevice();

  /// The shared render context.
  late final RenderContext3D context = RenderContext3D(device);

  bool _inFrame = false;

  static final Expando<EmbeddedRenderer> _renderers = Expando(
    'EmbeddedRenderer',
  );

  /// The renderer shared by everything that passes the same [key], usually a
  /// game.
  factory EmbeddedRenderer.of(Object key) {
    return _renderers[key] ??= EmbeddedRenderer._();
  }

  /// Makes sure a device frame is open for a render pass.
  ///
  /// Returns whether the caller must [close] the frame right after its pass,
  /// which is the case outside the painting of a Flutter frame.
  bool open() {
    if (_inFrame) {
      return false;
    }
    device.begin();
    _inFrame = true;
    final binding = SchedulerBinding.instance;
    if (binding.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      binding.addPostFrameCallback(
        (_) => close(),
        debugLabel: 'EmbeddedRenderer.close',
      );
      return false;
    }
    return true;
  }

  /// Closes the open device frame, if any.
  void close() {
    if (_inFrame) {
      _inFrame = false;
      device.end();
    }
  }
}
