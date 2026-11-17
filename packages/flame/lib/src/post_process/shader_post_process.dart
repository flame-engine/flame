import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/post_process.dart';
import 'package:meta/meta.dart';

/// A [PostProcess] that draws a fragment shader over its whole size.
///
/// The shader is loaded from the asset given to [ShaderPostProcess.new], or
/// taken from the [FragmentProgram] given to [ShaderPostProcess.fromProgram],
/// when the post process is loaded.
///
/// Every frame, the post process sets these uniforms, if the shader declares
/// them:
///
/// - `uniform vec2 uSize`: the size of the post process, in logical pixels.
/// - `uniform float uTime`: the seconds passed since the post process was
///   loaded, see [time].
///
/// If the shader declares `uniform sampler2D uTexture`, as its first sampler,
/// the subtree is also rendered with [rasterizeSubtree] every frame and given
/// to it. Sample it with coordinates going from 0 to 1 across the size of the
/// post process, for example
/// `texture(uTexture, FlutterFragCoord().xy / uSize)`.
///
/// On the web, Flutter can't look up the samplers of a shader by name yet, so
/// whether the shader samples the subtree has to be given with
/// [sampleSubtree] there. Games that run on the web should always set it.
///
/// The [placement] decides where the shader is drawn relative to the subtree:
/// instead of it, which is the default, or over or under it. See
/// [ShaderPlacement].
///
/// If the shader samples the subtree and is placed over or under it, the image
/// rasterized for `uTexture` is also drawn as the subtree, instead of
/// rendering the subtree a second time, unless [reuseRasterizedSubtree] is
/// false.
///
/// Set any other uniforms in [updateUniforms]. Look their slots up once, in
/// [onLoad], with the name-based uniforms of [FragmentShader]:
///
/// ```dart
/// class OutlinePostProcess() extends ShaderPostProcess {
///   this : super('assets/shaders/outline.frag');
///
///   Color outlineColor = Colors.purpleAccent;
///   late final UniformVec4Slot _outlineColor;
///
///   @override
///   Future<void> onLoad() async {
///     await super.onLoad();
///     _outlineColor = shader.getUniformVec4('uOutlineColor');
///   }
///
///   @override
///   void updateUniforms(Vector2 size) {
///     _outlineColor.setColor(outlineColor);
///   }
/// }
/// ```
///
/// See also:
/// - [UniformVec2SlotExtension], [UniformVec4SlotExtension] and the other
///   extensions that set uniform slots from Flame's types.
class ShaderPostProcess extends PostProcess {
  /// Creates a post process that loads its shader from [assetPath], the path
  /// of the shader as it's listed under `flutter: shaders:` in `pubspec.yaml`.
  ShaderPostProcess(
    String assetPath, {
    this.sampleSubtree,
    this.placement = ShaderPlacement.replace,
    this.reuseRasterizedSubtree = true,
    this.filterQuality = FilterQuality.low,
    super.pixelRatio,
  }) : _assetPath = assetPath,
       _program = null;

  /// Creates a post process that uses a shader of [program], for example one
  /// that was loaded once and is shared by several post processes.
  ShaderPostProcess.fromProgram(
    FragmentProgram program, {
    this.sampleSubtree,
    this.placement = ShaderPlacement.replace,
    this.reuseRasterizedSubtree = true,
    this.filterQuality = FilterQuality.low,
    super.pixelRatio,
  }) : _assetPath = null,
       _program = program;

  /// Whether the shader samples the subtree through `uTexture`, its first
  /// sampler, or null to detect it from the shader.
  ///
  /// If the shader samples the subtree, the subtree is rasterized every
  /// frame, which is the expensive part of a post process.
  ///
  /// Detecting it needs the samplers of the shader to be looked up by name,
  /// which Flutter doesn't support on the web yet, so on the web this has to
  /// be set. Where the samplers can be looked up, a value that doesn't match
  /// the shader throws an error when the shader is loaded.
  final bool? sampleSubtree;

  /// Where the shader is drawn relative to the subtree.
  ShaderPlacement placement;

  /// Whether the image rasterized for `uTexture` is also drawn as the
  /// subtree, when the shader samples the subtree and is placed
  /// [ShaderPlacement.over] or [ShaderPlacement.under] it.
  ///
  /// Reusing the image renders the subtree once per frame instead of twice,
  /// but draws it at [pixelRatio]. That is as sharp as rendering it again,
  /// unless [pixelRatio] is lower than the pixel ratio of the screen, for
  /// example to make the shader cheaper. Set this to false then, so that the
  /// subtree is rendered again, at the full resolution of the screen.
  bool reuseRasterizedSubtree;

  /// The quality of the filter that the rasterized subtree is sampled with,
  /// both by the shader through `uTexture` and when it's drawn as the subtree.
  ///
  /// It only makes a difference when the pixels of the rasterized subtree
  /// don't line up with the pixels of the screen, for example when the post
  /// process is rotated or zoomed, or when [pixelRatio] is lower than the
  /// pixel ratio of the screen. In those cases, the default,
  /// [FilterQuality.low], keeps edges smooth at no noticeable cost, while
  /// [FilterQuality.none] keeps the pixels sharp, for example for pixel art.
  FilterQuality filterQuality;

  /// The name of the `vec2` uniform that is set to the size of the post
  /// process.
  static const sizeUniform = 'uSize';

  /// The name of the `float` uniform that is set to [time].
  static const timeUniform = 'uTime';

  /// The name of the `sampler2D` uniform that is set to the rasterized
  /// subtree of the post process, if the shader samples it.
  static const textureUniform = 'uTexture';

  final String? _assetPath;
  final FragmentProgram? _program;

  FragmentShader? _shader;
  final Paint _paint = Paint();
  final Paint _subtreePaint = Paint();
  UniformVec2Slot? _size;
  UniformFloatSlot? _time;
  bool _samplesSubtree = false;

  /// The shader that is drawn.
  ///
  /// It's only available once the post process is loaded.
  FragmentShader get shader {
    final shader = _shader;
    if (shader == null) {
      throw StateError(
        'The shader of a ShaderPostProcess is only available once it is '
        'loaded.',
      );
    }
    return shader;
  }

  /// The seconds passed since the post process was loaded, which the
  /// [timeUniform] is set to.
  double time = 0;

  @override
  @mustCallSuper
  Future<void> onLoad() async {
    if (_shader != null) {
      return;
    }
    final program = _program ?? await FragmentProgram.fromAsset(_assetPath!);
    final shader = program.fragmentShader();
    _shader = shader;
    _size = _findUniform(() => shader.getUniformVec2(sizeUniform));
    _time = _findUniform(() => shader.getUniformFloat(timeUniform));
    _samplesSubtree = _findWhetherShaderSamplesSubtree(shader);
  }

  /// Returns the slot that [find] looks up, or null if the shader doesn't
  /// declare that uniform, the compiler removed it because it's unused, or
  /// the platform can't look it up.
  static T? _findUniform<T>(T Function() find) {
    try {
      return find();
    } on ArgumentError {
      return null;
    } on UnsupportedError {
      return null;
    }
  }

  /// Returns whether [shader] samples the subtree, which is whether it
  /// declares `uTexture`, as its first sampler.
  ///
  /// Throws if [sampleSubtree] is set and doesn't match the shader, or if it
  /// isn't set and the samplers of the shader can't be looked up by name.
  bool _findWhetherShaderSamplesSubtree(FragmentShader shader) {
    ImageSamplerSlot? texture;
    var canLookUpSamplers = true;
    Object? lookUpError;
    try {
      texture = shader.getImageSampler(textureUniform);
    } on UnsupportedError {
      canLookUpSamplers = false;
    } on ArgumentError catch (error) {
      lookUpError = error.message;
    }

    final sampleSubtree = this.sampleSubtree;
    if (!canLookUpSamplers) {
      // TODO(ufrshubham): Samplers can't be looked up by name on the web yet,
      // so whether the shader samples the subtree can't be detected there.
      // Once `getImageSampler` is supported on the web in every Flutter
      // version that Flame supports, remove this error, so that
      // `sampleSubtree` is optional on the web too.
      if (sampleSubtree == null) {
        throw StateError(
          "Samplers can't be looked up by name on the web yet, so "
          "ShaderPostProcess can't detect whether its shader samples "
          '`$textureUniform`. Pass sampleSubtree: true or false.',
        );
      }
      return sampleSubtree;
    }
    if (texture == null) {
      if (sampleSubtree ?? false) {
        throw StateError(
          'ShaderPostProcess has sampleSubtree set to true, but its shader '
          "doesn't declare `uniform sampler2D $textureUniform`, or the "
          "shader compiler removed it because it's unused: $lookUpError",
        );
      }
      return false;
    }
    if (sampleSubtree == false) {
      throw StateError(
        'The shader of ShaderPostProcess declares `$textureUniform`, but '
        'sampleSubtree is false, so the subtree would never be given to it. '
        'Set sampleSubtree to true, or leave it out to detect it.',
      );
    }
    if (texture.shaderIndex != 0) {
      throw StateError(
        'The shader of ShaderPostProcess must declare `$textureUniform` as '
        'its first sampler, but it is sampler ${texture.shaderIndex}.',
      );
    }
    return true;
  }

  @override
  @mustCallSuper
  void update(double dt) {
    time += dt;
  }

  /// Sets the uniforms of the shader other than [sizeUniform], [timeUniform]
  /// and [textureUniform], before the shader is drawn every frame.
  void updateUniforms(Vector2 size) {}

  @override
  void postProcess(Vector2 size, Canvas canvas) {
    if (size.x <= 0 || size.y <= 0) {
      // There is no area to draw the shader on, and the subtree can't be
      // rasterized into an empty image.
      if (placement != ShaderPlacement.replace) {
        renderSubtree(canvas);
      }
      return;
    }

    Image? subtree;
    if (_samplesSubtree) {
      subtree = rasterizeSubtree();
      shader.setImageSampler(0, subtree, filterQuality: filterQuality);
    }

    _size?.setVector(size);
    _time?.set(time);
    updateUniforms(size);

    // A shader can only be given to a paint once all of its samplers are
    // set, so this is done every frame, after the uniforms.
    _paint.shader = shader;
    final rect = Offset.zero & size.toSize();
    final rasterizedSubtree = reuseRasterizedSubtree ? subtree : null;
    switch (placement) {
      case ShaderPlacement.replace:
        canvas.drawRect(rect, _paint);
      case ShaderPlacement.over:
        _drawSubtree(canvas, rasterizedSubtree, rect);
        canvas.drawRect(rect, _paint);
      case ShaderPlacement.under:
        canvas.drawRect(rect, _paint);
        _drawSubtree(canvas, rasterizedSubtree, rect);
    }
    subtree?.dispose();
  }

  /// Draws the subtree, using the image already rasterized for `uTexture` if
  /// there is one, so that the subtree isn't rendered twice.
  ///
  /// The image is drawn into [rect], which is where the shader is drawn, so
  /// that it covers the same area that the shader samples it over. Its size
  /// is rounded up to whole pixels, so its own size divided by the
  /// [pixelRatio] can be larger than that.
  void _drawSubtree(Canvas canvas, Image? rasterized, Rect rect) {
    if (rasterized == null) {
      renderSubtree(canvas);
      return;
    }
    canvas.drawImageRect(
      rasterized,
      Rect.fromLTWH(
        0,
        0,
        rasterized.width.toDouble(),
        rasterized.height.toDouble(),
      ),
      rect,
      _subtreePaint..filterQuality = filterQuality,
    );
  }
}

/// Where a [ShaderPostProcess] draws its shader, relative to its subtree.
///
/// Whether the shader samples the subtree through `uTexture` is independent
/// of its placement.
enum ShaderPlacement() {
  /// Only the shader is drawn, so it decides how the subtree looks, for
  /// example by sampling `uTexture`, like a pixelation or grayscale effect.
  replace,

  /// The subtree is drawn first and the shader on top of it, like fog, a
  /// vignette or a glow around the subtree.
  over,

  /// The shader is drawn first and the subtree on top of it, like a
  /// background or a drop shadow of the subtree.
  under,
}
