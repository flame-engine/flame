import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: ScaleExample()));
}

class ScaleExample extends FlameGame {
  late RectangleComponent rect;
  late TextComponent debugText;

  late InteractiveRectangle interect;
  Vector2 zoomCenter = Vector2.zero();
  double startingZoom = 1;

  final bool addScaleOnlyRectangle = true;
  final bool addDragOnlyRectangle = true;
  final bool addScaleDragRectangle = true;
  final bool addZoom = false;
  final bool addCameraRotation = false;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.zoom = 1;

    debugText = TextComponent(
      text: 'hello',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 25, color: Colors.white),
      ),
      position: Vector2(50, 50),
    );

    if (addScaleOnlyRectangle) {
      final interect2 = ScaleOnlyRectangle(
        position: Vector2(0, 0),
        size: Vector2.all(150),
      );
      world.add(interect2);
    }
    if (addDragOnlyRectangle) {
      final interect3 = DragOnlyRectangle(
        position: Vector2(-200, -200),
        size: Vector2.all(150),
        color: Colors.green,
      );
      world.add(interect3);
    }

    if (addScaleDragRectangle) {
      interect = InteractiveRectangle(
        position: Vector2(200, 200),
        size: Vector2.all(150),
        color: Colors.red,
      );
      world.add(interect);
    }

    camera.viewport.add(debugText);
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (addCameraRotation) {
      camera.viewfinder.angle += 0.001;
    }
    if (addZoom) {
      debugText.text = '${camera.viewfinder.zoom}';
      camera.viewfinder.zoom += 0.001;
    }
  }
}

/// A rectangle component that can respond to both drag and scale gestures.
class InteractiveRectangle extends RectangleComponent
    with ScaleCallbacks, DragCallbacks, HasGameReference<FlameGame> {
  InteractiveRectangle({
    required Vector2 position,
    required Vector2 size,
    Color color = Colors.blue,
    Anchor anchor = Anchor.center,
  }) : super(
         position: position,
         size: size,
         anchor: anchor,
         paint: Paint()..color = color,
       );

  bool isScaling = false;
  double initialAngle = 0;
  Vector2 initialScale = Vector2.all(1);
  double lastScale = 1.0;

  @override
  Future<void> onLoad() async {
    final text = TextComponent(
      text: 'drag + scale',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 25, color: Colors.white),
      ),
      position: size / 2,
      anchor: Anchor.center,
    );
    add(text);
  }

  /// DragCallbacks overrides
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    debugPrint('Drag started at ${event.devicePosition}');
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (isScaling) {
      return;
    }
    final rotated = event.canvasDelta.clone()
      ..rotate(game.camera.viewfinder.angle);
    position.add(rotated);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    debugPrint('Drag ended with velocity ${event.velocity}');
  }

  /// ScaleCallbacks overrides
  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    isScaling = true;
    initialAngle = angle;
    initialScale = scale;
    lastScale = 1.0;
    debugPrint('Scale started at ${event.devicePosition}');
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    super.onScaleUpdate(event);
    // scale rectangle size by pinch
    angle = initialAngle + event.rotation;

    // delta scale since last frame
    if (lastScale == 0) {
      return;
    }
    final scaleDelta = event.scale / lastScale;
    lastScale = event.scale; // update for next frame

    // apply delta gently
    scale *= sqrt(scaleDelta);

    // clamp
    scale.clamp(Vector2.all(0.8), Vector2.all(3));
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    isScaling = false;
    debugPrint('Scale ended with velocity ${event.velocity}');
  }
}

/// A rectangle that only responds to drag
class DragOnlyRectangle extends RectangleComponent
    with DragCallbacks, HasGameReference<FlameGame> {
  DragOnlyRectangle({
    required Vector2 position,
    required Vector2 size,
    Color color = Colors.blue,
    Anchor anchor = Anchor.center,
  }) : super(
         position: position,
         size: size,
         anchor: anchor,
         paint: Paint()..color = color,
       );

  @override
  Future<void> onLoad() async {
    final text = TextComponent(
      text: 'drag',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 25, color: Colors.white),
      ),
      position: size / 2,
      anchor: Anchor.center,
    );
    add(text);
  }

  /// DragCallbacks overrides
  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    debugPrint('Drag started at ${event.devicePosition}');
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    debugPrint('On Drag update');
    final rotated = event.canvasDelta.clone()
      ..rotate(game.camera.viewfinder.angle);
    position.add(rotated);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    debugPrint('Drag ended with velocity ${event.velocity}');
  }
}

/// A rectangle that only responds to scale
class ScaleOnlyRectangle extends RectangleComponent with ScaleCallbacks {
  ScaleOnlyRectangle({
    required Vector2 position,
    required Vector2 size,
    Color color = Colors.blue,
    Anchor anchor = Anchor.center,
  }) : super(
         position: position,
         size: size,
         anchor: anchor,
         paint: Paint()..color = color,
       );

  @override
  Future<void> onLoad() async {
    final text = TextComponent(
      text: 'scale',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 25, color: Colors.white),
      ),
      position: size / 2,
      anchor: Anchor.center,
    );
    add(text);
  }

  bool isScaling = false;
  double initialAngle = 0;
  Vector2 initialScale = Vector2.all(1);
  double lastScale = 1.0;

  /// ScaleCallbacks overrides
  @override
  void onScaleStart(ScaleStartEvent event) {
    super.onScaleStart(event);
    isScaling = true;
    initialAngle = angle;
    initialScale = scale;
    lastScale = 1.0;
    debugPrint('Scale started at ${event.devicePosition}');
  }

  @override
  void onScaleUpdate(ScaleUpdateEvent event) {
    super.onScaleUpdate(event);
    // scale rectangle size by pinch
    angle = initialAngle + event.rotation;
    // delta scale since last frame
    if (lastScale == 0) {
      return;
    }
    final scaleDelta = event.scale / lastScale;
    lastScale = event.scale; // update for next frame

    // apply delta gently
    scale *= sqrt(scaleDelta);

    // clamp
    scale.clamp(Vector2.all(0.8), Vector2.all(3));
  }

  @override
  void onScaleEnd(ScaleEndEvent event) {
    super.onScaleEnd(event);
    isScaling = false;
    debugPrint('Scale ended with velocity ${event.velocity}');
  }
}
