import 'dart:ui';

import 'package:example/example_game_3d.dart';
import 'package:flame/components.dart';
import 'package:flame/text.dart';
import 'package:flame_3d/camera.dart';

const _width = 1.2;
const _color = Color(0xFFFFFFFF);

final _style = TextStyle(
  color: const Color(0xFF000000),
  shadows: [
    for (var x = 1; x < _width + 5; x++)
      for (var y = 1; y < _width + 5; y++) ...[
        Shadow(offset: Offset(-_width / x, -_width / y), color: _color),
        Shadow(offset: Offset(-_width / x, _width / y), color: _color),
        Shadow(offset: Offset(_width / x, -_width / y), color: _color),
        Shadow(offset: Offset(_width / x, _width / y), color: _color),
      ],
  ],
);

class SimpleHud extends Component with HasGameReference<ExampleGame3D> {
  SimpleHud() : super(children: [FpsComponent()]);

  String get fps =>
      children.query<FpsComponent>().firstOrNull?.fps.toStringAsFixed(2) ?? '0';

  final _textLeft = TextPaint(style: _style);

  final _textCenter = TextPaint(style: _style.copyWith(fontSize: 20));

  final _textRight = TextPaint(style: _style, textDirection: TextDirection.rtl);

  @override
  void render(Canvas canvas) {
    final CameraComponent3D(:position, :target, :up) = game.camera;

    _textLeft.render(
      canvas,
      '''
Camera controls:
- Move using W, A, S, D, Space, Left-Ctrl
- Look around with arrow keys or mouse
- Change camera mode with 1, 2, 3 or 4
- Change camera projection with P
- Zoom in and out with scroll
''',
      Vector2.all(8),
    );

    _textCenter.render(
      canvas,
      'Welcome to the 3D world',
      Vector2(game.size.x / 2, game.size.y - 8),
      anchor: Anchor.bottomCenter,
    );

    _textRight.render(
      canvas,
      '''
FPS: $fps
Projection: ${game.camera.projection.name}
Culled: ${game.world.culled}

Position: ${position.x.toStringAsFixed(2)}, ${position.y.toStringAsFixed(2)}, ${position.z.toStringAsFixed(2)}
Target: ${target.x.toStringAsFixed(2)}, ${target.y.toStringAsFixed(2)}, ${target.z.toStringAsFixed(2)}
Up: ${up.x.toStringAsFixed(2)}, ${up.y.toStringAsFixed(2)}, ${up.z.toStringAsFixed(2)}
''',
      Vector2(game.size.x - 8, 8),
      anchor: Anchor.topRight,
    );
  }
}
