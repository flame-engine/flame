// Visual reproduction: findPostProcessFromContext always returns null for
// components in the world when the post process is set as
// CameraComponent.postProcess.
//
// Run with: flutter run -t lib/camera_context_repro.dart -d windows
//
// SelectionHighlight outlines the selected character, like in a strategy
// game. The selection moves to the next character every second. It renders
// its subtree twice:
// 1. A mask, where only the selected character draws itself. Every other
//    component finds the post process in its render context, sees it is
//    drawing the mask, and draws nothing. The mask is turned into a yellow
//    outline.
// 2. The scene itself, on top of the outline.
//
// Left: camera.postProcess = SelectionHighlight(). The lookup returns null,
// so every component draws itself into the mask, and everything is outlined.
// Right: the same post process in a PostProcessComponent. The lookup works,
// and only the selected character is outlined.
import 'dart:ui';

import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/post_process.dart';
import 'package:flutter/material.dart' show Colors, TextStyle;
import 'package:flutter/widgets.dart' show runApp;

void main() {
  runApp(GameWidget(game: CameraContextReproGame()));
}

final _viewSize = Vector2(580, 400);
const _names = ['knight', 'mage', 'ranger'];

/// The index of the selected character, shared by both sides.
int _selected = 0;

class CameraContextReproGame extends FlameGame {
  CameraContextReproGame()
    : super(
        world: World(),
        camera: _camera(Vector2(20, 100)),
      );

  static CameraComponent _camera(Vector2 position) {
    return CameraComponent(
      viewport: FixedSizeViewport(_viewSize.x, _viewSize.y)
        ..position = position,
    )..viewfinder.anchor = Anchor.topLeft;
  }

  double _time = 0;

  @override
  Color backgroundColor() => const Color(0xFF202030);

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    _selected = _time.floor() % _names.length;
  }

  @override
  Future<void> onLoad() async {
    // Left: the highlight as the camera's post process.
    final leftProbe = _ContextProbe();
    camera.postProcess = SelectionHighlight();
    world.addAll([...await _scene(), leftProbe]);

    // Right: the same highlight as a PostProcessComponent, seen by a second
    // camera without a post process.
    final rightProbe = _ContextProbe();
    final rightWorld = World(
      children: [
        PostProcessComponent(
          size: _viewSize,
          postProcess: SelectionHighlight(),
          children: [...await _scene(), rightProbe],
        ),
      ],
    );
    final rightCamera = _camera(Vector2(620, 100))..world = rightWorld;

    addAll([
      rightWorld,
      rightCamera,
      _label(
        'camera.postProcess = SelectionHighlight()',
        Vector2(20, 20),
        size: 20,
      ),
      _ProbeText(leftProbe, Vector2(20, 55)),
      _label(
        'PostProcessComponent(SelectionHighlight()) (expected)',
        Vector2(620, 20),
        size: 20,
      ),
      _ProbeText(rightProbe, Vector2(620, 55)),
      _SelectionText(Vector2(20, 520)),
    ]);
  }

  /// Some ground and three characters.
  Future<List<Component>> _scene() async {
    return [
      _Ground(),
      for (final (index, name) in _names.indexed)
        _Character(
          index,
          sprite: await loadSprite('assets/images/$name.png'),
          position: Vector2(90 + index * 160.0, 190),
        ),
    ];
  }
}

/// Outlines the components that draw themselves while [drawingMask] is true.
class SelectionHighlight extends PostProcess {
  bool drawingMask = false;

  final _outlinePaint = Paint()
    ..colorFilter = const ColorFilter.mode(Color(0xFFFFD54F), BlendMode.srcIn)
    ..imageFilter = ImageFilter.dilate(radiusX: 6, radiusY: 6);

  @override
  void postProcess(Vector2 size, Canvas canvas) {
    drawingMask = true;
    canvas.saveLayer(null, _outlinePaint);
    renderSubtree(canvas);
    canvas.restore();
    drawingMask = false;

    renderSubtree(canvas);
  }
}

/// Whether [component] is being rendered into the highlight mask.
bool _isDrawingMask(Component component) {
  return component
          .findPostProcessFromContext<SelectionHighlight>()
          ?.drawingMask ??
      false;
}

class _Character extends SpriteComponent {
  _Character(this.index, {super.sprite, super.position})
    : super(size: Vector2.all(100));

  final int index;

  @override
  void render(Canvas canvas) {
    // Only the selected character draws itself into the mask.
    if (_isDrawingMask(this) && index != _selected) {
      return;
    }
    super.render(canvas);
  }
}

class _Ground extends Component {
  static final _paint = Paint()..color = const Color(0xFF3B6B47);

  @override
  void render(Canvas canvas) {
    if (_isDrawingMask(this)) {
      return;
    }
    canvas.drawRect(Rect.fromLTWH(30, 300, _viewSize.x - 60, 60), _paint);
  }
}

/// Records what findPostProcessFromContext returns while it renders.
class _ContextProbe extends Component {
  String found = '-';

  @override
  void render(Canvas canvas) {
    final highlight = findPostProcessFromContext<SelectionHighlight>();
    found = highlight == null ? 'null' : 'SelectionHighlight';
  }
}

class _ProbeText extends TextComponent {
  _ProbeText(this._probe, Vector2 position)
    : super(position: position, textRenderer: _textPaint(16));

  final _ContextProbe _probe;

  @override
  void update(double dt) {
    text =
        'findPostProcessFromContext<SelectionHighlight>() returns: '
        '${_probe.found}';
  }
}

class _SelectionText extends TextComponent {
  _SelectionText(Vector2 position)
    : super(position: position, textRenderer: _textPaint(20));

  @override
  void update(double dt) {
    text = 'Selected: the ${_names[_selected]}. Only it should be outlined.';
  }
}

TextComponent _label(String text, Vector2 position, {double size = 16}) {
  return TextComponent(
    text: text,
    position: position,
    textRenderer: _textPaint(size),
  );
}

TextPaint _textPaint(double size) {
  return TextPaint(
    style: TextStyle(fontSize: size, color: Colors.white),
  );
}
