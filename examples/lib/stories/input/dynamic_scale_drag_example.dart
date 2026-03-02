import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class DynamicScaleDragExample extends FlameGame {
  static const String description = '''
    Demonstrates dynamically adding draggable and scalable components at
    runtime. Use the buttons to spawn components with different interaction
    types: drag-only (green), scale-only (blue), or both (red).

    Drag components by touching and moving. Scale components by pinching
    with two fingers. Components with both mixins support either gesture.
    The system seamlessly handles mixing different interaction types.
  ''';

  late TextComponent dispatcherLabel;

  @override
  Future<void> onLoad() async {
    dispatcherLabel = TextComponent(
      text: 'Dispatcher: none',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 18, color: Colors.white),
      ),
      position: Vector2(10, 10),
    );
    camera.viewport.add(dispatcherLabel);

    camera.viewport.add(
      _Button(
        text: '+ Drag',
        position: Vector2(10, 40),
        color: Colors.green,
        onPressed: _addDragComponent,
      ),
    );
    camera.viewport.add(
      _Button(
        text: '+ Scale',
        position: Vector2(120, 40),
        color: Colors.blue,
        onPressed: _addScaleComponent,
      ),
    );
    camera.viewport.add(
      _Button(
        text: '+ Both',
        position: Vector2(230, 40),
        color: Colors.red,
        onPressed: _addBothComponent,
      ),
    );
    camera.viewport.add(
      _Button(
        text: 'Clear',
        position: Vector2(340, 40),
        color: Colors.grey,
        onPressed: _clearComponents,
      ),
    );
  }

  int _nextId = 1;

  void _addDragComponent() {
    final pos = _randomWorldPosition();
    world.add(
      _DragBox(
        label: 'Drag ${_nextId++}',
        position: pos,
        color: Colors.green,
      ),
    );
  }

  void _addScaleComponent() {
    final pos = _randomWorldPosition();
    world.add(
      _ScaleBox(
        label: 'Scale ${_nextId++}',
        position: pos,
        color: Colors.blue,
      ),
    );
  }

  void _addBothComponent() {
    final pos = _randomWorldPosition();
    world.add(
      _DragScaleBox(
        label: 'Both ${_nextId++}',
        position: pos,
        color: Colors.red,
      ),
    );
  }

  void _clearComponents() {
    world.removeAll(
      world.children.where(
        (c) => c is _DragBox || c is _ScaleBox || c is _DragScaleBox,
      ),
    );
  }

  Vector2 _randomWorldPosition() {
    final rng = Random();
    return Vector2(
      (rng.nextDouble() - 0.5) * 300,
      (rng.nextDouble() - 0.5) * 200,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    final dispatchers = <String>[];
    if (children.whereType<MultiDragScaleDispatcher>().isNotEmpty) {
      dispatchers.add('MultiDragScaleDispatcher');
    }
    if (children.whereType<MultiDragDispatcher>().isNotEmpty) {
      dispatchers.add('MultiDragDispatcher');
    }
    // ScaleDispatcher is not publicly exported, so detect it by exclusion.
    final otherDispatchers = children.where(
      (c) => c is! MultiDragScaleDispatcher && c is! MultiDragDispatcher,
    );
    for (final c in otherDispatchers) {
      final name = c.runtimeType.toString();
      if (name == 'ScaleDispatcher') {
        dispatchers.add('ScaleDispatcher');
      }
    }
    dispatcherLabel.text =
        'Dispatcher: ${dispatchers.isEmpty ? 'none' : dispatchers.join(', ')}';
  }
}

class _Button extends PositionComponent with TapCallbacks {
  _Button({
    required String text,
    required super.position,
    required Color color,
    required VoidCallback onPressed,
  }) : _color = color,
       _onPressed = onPressed,
       _text = text,
       super(size: Vector2(100, 30));

  final Color _color;
  final VoidCallback _onPressed;
  final String _text;

  @override
  Future<void> onLoad() async {
    add(
      TextComponent(
        text: _text,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        position: size / 2,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(6)),
      Paint()..color = _color,
    );
  }

  @override
  void onTapUp(TapUpEvent event) {
    _onPressed();
  }
}

/// A rectangle that only responds to drag.
class _DragBox extends RectangleComponent
    with DragCallbacks, HasGameReference<FlameGame> {
  _DragBox({
    required String label,
    required Vector2 position,
    required Color color,
  }) : _label = label,
       super(
         position: position,
         size: Vector2.all(120),
         anchor: Anchor.center,
         paint: Paint()..color = color,
       );

  final String _label;

  @override
  Future<void> onLoad() async {
    add(
      TextComponent(
        text: _label,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        position: size / 2,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }
}

/// A rectangle that only responds to scale (pinch/zoom).
class _ScaleBox extends RectangleComponent with ScaleCallbacks {
  _ScaleBox({
    required String label,
    required Vector2 position,
    required Color color,
  }) : _label = label,
       super(
         position: position,
         size: Vector2.all(120),
         anchor: Anchor.center,
         paint: Paint()..color = color,
       );

  final String _label;
  double _initialAngle = 0;
  double _lastScale = 1.0;

  @override
  Future<void> onLoad() async {
    add(
      TextComponent(
        text: _label,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        position: size / 2,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    _initialAngle = angle;
    _lastScale = 1.0;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    angle = _initialAngle + event.rotation;
    if (_lastScale != 0) {
      final delta = event.scale / _lastScale;
      scale *= sqrt(delta);
      scale.clamp(Vector2.all(0.5), Vector2.all(3));
    }
    _lastScale = event.scale;
  }
}

/// A rectangle that responds to both drag and scale.
class _DragScaleBox extends RectangleComponent
    with ScaleCallbacks, DragCallbacks, HasGameReference<FlameGame> {
  _DragScaleBox({
    required String label,
    required Vector2 position,
    required Color color,
  }) : _label = label,
       super(
         position: position,
         size: Vector2.all(120),
         anchor: Anchor.center,
         paint: Paint()..color = color,
       );

  final String _label;
  double _initialAngle = 0;
  double _lastScale = 1.0;

  @override
  Future<void> onLoad() async {
    add(
      TextComponent(
        text: _label,
        textRenderer: TextPaint(
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
        position: size / 2,
        anchor: Anchor.center,
      ),
    );
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    position += event.localDelta;
  }

  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    _initialAngle = angle;
    _lastScale = 1.0;
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    angle = _initialAngle + event.rotation;
    if (_lastScale != 0) {
      final delta = event.scale / _lastScale;
      scale *= sqrt(delta);
      scale.clamp(Vector2.all(0.5), Vector2.all(3));
    }
    _lastScale = event.scale;
  }
}
