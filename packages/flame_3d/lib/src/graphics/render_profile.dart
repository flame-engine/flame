import 'dart:typed_data';

/// Whether the renderer times its phases into [RenderProfile.active].
///
/// It is a compile-time constant, `false` unless the app is built or run with
/// `--dart-define=FLAME_3D_PROFILE=true`: without it the timing code is
/// compiled out and costs nothing.
// ignore: do_not_use_environment
const bool kProfileRender = bool.fromEnvironment('FLAME_3D_PROFILE');

/// A phase of the CPU work of rendering a 3D scene, see [RenderProfile].
enum RenderPhase() {
  /// The host's setup of a pass: the visible part of a `Scene3DComponent`,
  /// the camera matrices, beginning the frame.
  setup,

  /// Fitting the shadow map to the scene and the camera.
  shadowSetup,

  /// Walking the component tree.
  traversal,

  /// Testing objects against the frustum.
  culling,

  /// The objects' `draw` methods and recording their draws.
  recording,

  /// Sorting particles and writing their instances.
  particles,

  /// Classifying and sorting the recorded draws.
  sort,

  /// Splitting the sorted draws into batches.
  batch,

  /// Binding pipelines and setting the render state.
  state,

  /// `Material.apply`.
  materialApply,

  /// Writing the uniform blocks filled once per pass (camera, lights,
  /// shadows).
  uniformWrite,

  /// Copying uniform blocks and instances into the upload buffers.
  upload,

  /// Binding uniform blocks, textures and buffers.
  binding,

  /// Copying the instances of batches together.
  gather,

  /// Draw calls.
  draw,

  /// Releasing the recorded draws after a flush.
  release,

  /// Acquiring a render target and beginning a render pass.
  passBegin,

  /// Uploading the pass's data and submitting it.
  passEnd,

  /// Drawing the rendered image into the canvas.
  composite,
}

/// {@template render_profile}
/// CPU time spent rendering, by [RenderPhase], for profiling the renderer.
///
/// The renderer only times its phases when built with
/// `--dart-define=FLAME_3D_PROFILE=true` (see [kProfileRender]), into the
/// [active] profile; otherwise its marks ([start], [lap], [switchPass]) are
/// empty and inlined away:
///
/// ```dart
/// final profile = RenderProfile.active = RenderProfile();
/// // ... render frames ...
/// print(profile.microseconds(RenderPhase.sort));
/// ```
///
/// The time between two marks of the renderer goes to the phase of the
/// second one, separately for the shadow passes and the main passes. Timing
/// costs a little: compare totals with a build without the define.
/// {@endtemplate}
final class RenderProfile() {
  /// The profile the renderer times its phases into, when
  /// [kProfileRender] is `true`.
  static RenderProfile? active;

  final Stopwatch _clock = Stopwatch()..start();
  final Int64List _ticks = Int64List(_phases * 2);
  int _last = 0;
  bool _shadow = false;

  static final int _phases = RenderPhase.values.length;

  /// Whether the time goes to the shadow passes.
  bool get inShadowPass => _shadow;

  /// Starts timing from now: the time since the last mark is not counted.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:prefer-inline')
  static void start() {
    if (!kProfileRender) {
      return;
    }
    final profile = active;
    if (profile != null) {
      profile._last = profile._clock.elapsedTicks;
    }
  }

  /// Gives the time since the last mark to [phase].
  @pragma('vm:prefer-inline')
  @pragma('dart2js:prefer-inline')
  static void lap(RenderPhase phase) {
    if (!kProfileRender) {
      return;
    }
    final profile = active;
    if (profile == null) {
      return;
    }
    final now = profile._clock.elapsedTicks;
    profile._ticks[phase.index + (profile._shadow ? _phases : 0)] +=
        now - profile._last;
    profile._last = now;
  }

  /// Gives the time since the last mark to [phase], then sends the time
  /// that follows to the shadow passes when [shadow] is `true`, to the main
  /// passes otherwise.
  @pragma('vm:prefer-inline')
  @pragma('dart2js:prefer-inline')
  static void switchPass(RenderPhase phase, {required bool shadow}) {
    if (!kProfileRender) {
      return;
    }
    lap(phase);
    active?._shadow = shadow;
  }

  /// The time given to [phase], in microseconds, in the shadow passes when
  /// [shadow] is `true`, in the main passes otherwise.
  double microseconds(RenderPhase phase, {bool shadow = false}) {
    final ticks = _ticks[phase.index + (shadow ? _phases : 0)];
    return ticks * 1e6 / _clock.frequency;
  }

  /// The time given to every phase, in microseconds.
  double get totalMicroseconds {
    var ticks = 0;
    for (final value in _ticks) {
      ticks += value;
    }
    return ticks * 1e6 / _clock.frequency;
  }

  /// Sets every time back to zero.
  void reset() {
    _ticks.fillRange(0, _ticks.length, 0);
    _shadow = false;
  }
}
