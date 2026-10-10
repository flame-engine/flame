import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart' show KeyEventResult;

class CullingExample({
  final bool culled = true,
  final int amount = 10000,
}) extends FlameGame with KeyboardEvents {
  static const description = '''
The camera slowly moves over a big field of animated sprites. Only a few of
them are on-screen at any time. Press C, or use the "Culled" knob, to turn
`CullWhenOffscreen` on and off. Compare the frame rate and the number of
sprites that are drawn on each frame.
  ''';

  static const _fieldSize = 4000.0;

  /// How many components were rendered in the previous frame.
  static int renderedThisFrame = 0;

  late bool _culled = culled;
  late final CullingStatusText _statusText;
  late final TextComponent _renderedText;
  double _time = 0;

  @override
  Future<void> onLoad() async {
    final animations = await loadCullingAnimations(this);
    final random = Random(1);
    world.addAll([
      for (var i = 0; i < amount; i++)
        _AnimatedSprite(
          animation: animations[random.nextInt(animations.length)],
          position: Vector2(
            (random.nextDouble() - 0.5) * _fieldSize,
            (random.nextDouble() - 0.5) * _fieldSize,
          ),
        )..cullingEnabled = _culled,
    ]);
    camera.viewport.add(
      PositionComponent(
        position: Vector2.all(10),
        size: Vector2(400, 130),
        children: [
          RectangleComponent(
            size: Vector2(400, 130),
            paint: BasicPalette.black.withAlpha(140).paint(),
          ),
          FpsTextComponent(
            position: Vector2(10, 8),
            textRenderer: cullingHudText,
          ),
          _statusText = CullingStatusText(
            culled: _culled,
            position: Vector2(10, 36),
          ),
          _renderedText = TextComponent(
            position: Vector2(10, 70),
            textRenderer: cullingHudText,
          ),
          TextComponent(
            text: 'Press C to turn culling on or off',
            position: Vector2(10, 98),
            textRenderer: cullingHudText,
          ),
        ],
      ),
    );
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.keyC) {
      _culled = !_culled;
      _statusText.culled = _culled;
      for (final box in world.children.query<_AnimatedSprite>()) {
        box.cullingEnabled = _culled;
      }
      return KeyEventResult.handled;
    }
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    camera.viewfinder.position = Vector2(
      cos(_time * 0.3) * _fieldSize * 0.2,
      sin(_time * 0.2) * _fieldSize * 0.2,
    );
    _renderedText.text = 'Drawn: $renderedThisFrame/$amount sprites';
  }

  @override
  void render(Canvas canvas) {
    renderedThisFrame = 0;
    super.render(canvas);
  }
}

/// The text style of the HUD of the culling examples.
final TextPaint cullingHudText = TextPaint(
  style: const TextStyle(color: Color(0xFFFFFFFF), fontSize: 20),
);

/// Shows if culling is on (green) or off (red).
class CullingStatusText({
  bool culled = true,
  super.position,
}) extends TextComponent {
  static final _onText = TextPaint(
    style: const TextStyle(
      color: Color(0xFF4DFF6A),
      fontSize: 26,
      fontWeight: FontWeight.bold,
    ),
  );
  static final _offText = TextPaint(
    style: const TextStyle(
      color: Color(0xFFFF5252),
      fontSize: 26,
      fontWeight: FontWeight.bold,
    ),
  );

  this : super(text: _label(culled), textRenderer: _style(culled));

  static String _label(bool culled) => culled ? 'Culling: ON' : 'Culling: OFF';

  static TextPaint _style(bool culled) => culled ? _onText : _offText;

  set culled(bool value) {
    text = _label(value);
    textRenderer = _style(value);
  }
}

/// Loads the animations that the culling examples draw.
Future<List<SpriteAnimation>> loadCullingAnimations(FlameGame game) async {
  return [
    await game.loadSpriteAnimation(
      'assets/images/animations/ember.png',
      SpriteAnimationData.sequenced(
        amount: 3,
        textureSize: Vector2.all(16),
        stepTime: 0.15,
      ),
    ),
    await game.loadSpriteAnimation(
      'assets/images/animations/chopper.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.15,
      ),
    ),
    await game.loadSpriteAnimation(
      'assets/images/animations/robot.png',
      SpriteAnimationData.sequenced(
        amount: 8,
        textureSize: Vector2(16, 18),
        stepTime: 0.2,
      ),
    ),
    await game.loadSpriteAnimation(
      'assets/images/bomb_ptero.png',
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.2,
      ),
    ),
  ];
}

class _AnimatedSprite({
  required SpriteAnimation super.animation,
  super.position,
}) extends SpriteAnimationComponent with CullWhenOffscreen {
  this : super(size: Vector2.all(48), anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    CullingExample.renderedThisFrame++;
    super.render(canvas);
  }
}
