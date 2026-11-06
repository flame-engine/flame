import 'dart:math';
import 'dart:ui';

import 'package:examples/commons/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/post_process.dart';
import 'package:material_ui/material_ui.dart' hide Image;

class ShaderPlacementExample() extends FlameGame {
  static const String description = '''
    Shows every combination of a ShaderPostProcess whose shader does or
    doesn't sample the subtree through `uTexture`, with each ShaderPlacement.
    With `replace`, only the shader is drawn. With `over` and `under`, the
    subtree is drawn too, under or over the shader. Every cell draws the same
    subtree, the Flame logo with Ember flying around it, over a card that is
    not part of the post process. The uniforms of each shader are set by
    their names. Every post process passes `sampleSubtree`, since these
    examples also run on the web, where whether a shader samples the subtree
    can't be detected yet.
  ''';

  static const _columns = 3;
  static const _rows = 2;
  static const _padding = 16.0;
  static const _labelHeight = 44.0;

  @override
  Future<void> onLoad() async {
    final logo = await loadSprite('assets/images/flame.png');

    final cells = <(String, String, PostProcess)>[
      (
        'uTexture, replace',
        'Pixelates the subtree',
        PixelationPostProcess(),
      ),
      (
        'uTexture, over',
        'Glow around the subtree',
        GlowPostProcess(),
      ),
      (
        'uTexture, under',
        'Drop shadow of the subtree',
        DropShadowPostProcess(),
      ),
      (
        'No uTexture, replace',
        'Stripes instead of the subtree',
        ShaderPostProcess(
          'assets/shaders/stripes.frag',
          sampleSubtree: false,
        ),
      ),
      (
        'No uTexture, over',
        'Vignette over the subtree',
        VignettePostProcess(),
      ),
      (
        'No uTexture, under',
        'Stripes behind the subtree',
        ShaderPostProcess(
          'assets/shaders/stripes.frag',
          sampleSubtree: false,
          placement: ShaderPlacement.under,
        ),
      ),
    ];

    final title = TextPaint(
      style: const TextStyle(
        fontSize: 15,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    );
    final caption = TextPaint(
      style: const TextStyle(fontSize: 13, color: Color(0xFFAAB4C3)),
    );

    final cellSize = Vector2(size.x / _columns, size.y / _rows);
    final side = min(
      cellSize.x - 2 * _padding,
      cellSize.y - _labelHeight - 2 * _padding,
    );

    for (final (index, (name, explanation, postProcess)) in cells.indexed) {
      final cellPosition = Vector2(
        (index % _columns) * cellSize.x,
        (index ~/ _columns) * cellSize.y,
      );
      final boxPosition =
          cellPosition +
          Vector2((cellSize.x - side) / 2, _padding + _labelHeight);

      addAll([
        TextComponent(
          text: name,
          textRenderer: title,
          position: boxPosition - Vector2(0, _labelHeight),
        ),
        TextComponent(
          text: explanation,
          textRenderer: caption,
          position: boxPosition - Vector2(0, _labelHeight - 21),
        ),
        // The card is not part of the post process, so it's always drawn.
        RectangleComponent(
          position: boxPosition,
          size: Vector2.all(side),
          paint: Paint()..color = const Color(0xFF3A4454),
        ),
        PostProcessComponent(
          postProcess: postProcess,
          position: boxPosition,
          size: Vector2.all(side),
          children: _subtree(logo, side),
        ),
      ]);
    }
  }

  /// The subtree of every post process: the Flame logo with Ember flying
  /// around it, on a transparent background.
  List<Component> _subtree(Sprite logo, double side) {
    final center = Vector2.all(side / 2);
    final logoHeight = side * 0.5;
    final ember = Ember(size: Vector2.all(side * 0.18), position: center);
    return [
      SpriteComponent(
        sprite: logo,
        size: Vector2(logoHeight * logo.srcSize.x / logo.srcSize.y, logoHeight),
        position: center,
        anchor: Anchor.center,
      ),
      ember,
      _Orbit(target: ember, center: center, radius: side * 0.34),
    ];
  }
}

/// Moves [target] in a circle with [radius] around [center].
class _Orbit({
  required final PositionComponent target,
  required final Vector2 center,
  required final double radius,
}) extends Component {
  double _angle = 0;

  @override
  void update(double dt) {
    _angle += dt;
    target.position.setValues(
      center.x + cos(_angle) * radius,
      center.y + sin(_angle) * radius,
    );
  }
}

/// Samples the subtree with a number of pixels that changes over time.
class PixelationPostProcess() extends ShaderPostProcess {
  this : super('assets/shaders/pixelation.frag', sampleSubtree: true);

  late final UniformVec2Slot _pixels;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _pixels = shader.getUniformVec2('uPixels');
  }

  @override
  void updateUniforms(Vector2 size) {
    final pixelSize = 6 + 4 * sin(time).abs();
    _pixels.set(size.x / pixelSize, size.y / pixelSize);
  }
}

/// Finds the edges of the subtree in `uTexture`, and draws a glow around
/// them, over the subtree.
class GlowPostProcess() extends ShaderPostProcess {
  this
    : super(
        'assets/shaders/glow.frag',
        sampleSubtree: true,
        placement: ShaderPlacement.over,
      );

  Color color = Colors.cyanAccent;
  late final UniformVec4Slot _color;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _color = shader.getUniformVec4('uColor');
  }

  @override
  void updateUniforms(Vector2 size) => _color.setColor(color);
}

/// Draws the silhouette of the subtree from `uTexture`, moved a little, under
/// the subtree.
class DropShadowPostProcess() extends ShaderPostProcess {
  this
    : super(
        'assets/shaders/drop_shadow.frag',
        sampleSubtree: true,
        placement: ShaderPlacement.under,
      );

  Color color = Colors.black.withValues(alpha: 0.6);
  late final UniformVec2Slot _offset;
  late final UniformVec4Slot _color;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _offset = shader.getUniformVec2('uOffset');
    _color = shader.getUniformVec4('uColor');
  }

  @override
  void updateUniforms(Vector2 size) {
    // The light moves, so the shadow circles around the subtree.
    _offset.set(cos(time) * 8, sin(time) * 8);
    _color.setColor(color);
  }
}

/// Darkens the edges, over the subtree, without sampling it.
class VignettePostProcess() extends ShaderPostProcess {
  this
    : super(
        'assets/shaders/vignette.frag',
        sampleSubtree: false,
        placement: ShaderPlacement.over,
      );

  Color color = Colors.black;
  late final UniformVec4Slot _color;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _color = shader.getUniformVec4('uColor');
  }

  @override
  void updateUniforms(Vector2 size) => _color.setColor(color);
}
