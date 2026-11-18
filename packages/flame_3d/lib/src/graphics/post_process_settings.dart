import 'dart:ui' show Color;

/// Tone-mapping operator applied during final scene composition in
/// [PostProcessSettings].
enum ToneMapMode() {
  /// Linear clamp with no tone-mapping curve.
  none,

  /// Simple Reinhard curve `c / (1 + c)`.
  reinhard,

  /// Narkowicz ACES Filmic approximation with rich highlight roll-off.
  acesFilmic,

  /// Punchy AgX-inspired log-sigmoid filmic curve preserving hue in highlights.
  agx,
}

/// {@template post_process_settings}
/// GPU color-grading, tone-mapping, vignette, and fast anti-aliasing
/// configuration for a `World3D` or `Scene3DComponent`.
///
/// When paired with `BloomSettings`, all post-processing operations execute
/// inside the final bloom composite shader with **zero extra GPU render
/// passes**.
/// {@endtemplate}
class PostProcessSettings({
  var ToneMapMode toneMap = ToneMapMode.none,
  var double exposure = 1.0,
  var double contrast = 1.0,
  var double saturation = 1.0,
  var double vignetteIntensity = 0.0,
  var double vignetteSmoothness = 0.5,
  var Color tint = const Color(0xFFFFFFFF),
  var bool fxaa = false,

  /// Screen-space ambient occlusion strength (`0` disables SSAO).
  var double ssaoIntensity = 0.0,

  /// Screen-space sampling radius multiplier for SSAO.
  var double ssaoRadius = 1.5,

  /// Normalized `[0..1]` clip-space focal depth for 3D Depth of Field.
  var double dofFocusDepth = 0.5,

  /// Clear-focus half-range around [dofFocusDepth] in normalized clip depth.
  var double dofFocusRange = 0.15,

  /// Bokeh blur strength outside [dofFocusRange] (`0` disables 3D DoF).
  var double dofBlurStrength = 0.0,
}) {
  /// Whether SSAO or 3D Depth of Field requires the half-res depth-normal pass.
  bool get needsDepthNormal => ssaoIntensity > 1e-4 || dofBlurStrength > 1e-4;

  /// Whether any non-identity post-process stage is enabled.
  bool get isActive =>
      toneMap != ToneMapMode.none ||
      (exposure - 1.0).abs() > 1e-4 ||
      (contrast - 1.0).abs() > 1e-4 ||
      (saturation - 1.0).abs() > 1e-4 ||
      vignetteIntensity > 1e-4 ||
      tint != const Color(0xFFFFFFFF) ||
      fxaa ||
      needsDepthNormal;
}
