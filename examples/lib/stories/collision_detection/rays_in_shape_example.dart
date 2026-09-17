import 'dart:async';
import 'dart:math';

import 'package:examples/commons/cancellable_button_component.dart';
import 'package:examples/commons/paths.dart';
import 'package:examples/commons/rounded_rect_component.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/geometry.dart';
import 'package:flame/palette.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

const side = 200.0;
const playArea = Rect.fromLTRB(-side, -side, side, side);
const fontSize = 9.0;

typedef ButtonColors = (Color, Color);

class RaysInShapeExample extends FlameGame<RaysInShapeWorld> {
  static const description = '''
In this example we showcase the raytrace functionality where you can see whether
the rays are inside the shapes or not. Double-click to change the shape that the rays
are casted against. The rays originates from small circles, and if the circle is
inside the shape it will be red, otherwise green. And if the ray doesn't hit any
shape it will be gray. Click once in all shapes but the circle to toggle
the ray casting/intersection behaviour between the (current) crossings approach
and the point-containment proposal, which should be used for concave polygons.
''';

  TextRenderer get textRenderer => TextPaint(
    style: const TextStyle(
      fontSize: fontSize - 1,
      color: Colors.white,
    ),
  );

  TextRenderer get textOffRenderer => TextPaint(
    style: const TextStyle(
      fontSize: fontSize - 1,
      color: Colors.white54,
    ),
  );

  Vector2 get buttonSize => Vector2(40, 16);

  late AdvancedButtonComponent _rotateButton;
  late AdvancedButtonComponent _shapeButton;
  late AdvancedButtonComponent _raysButton;

  RaysInShapeExample()
    : super(
        world: RaysInShapeWorld(),
        camera: CameraComponent.withFixedResolution(
          width: playArea.width,
          height: playArea.height,
        ),
      );

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();

    _rotateButton = _createRotateButton();
    _shapeButton = _createShapeButton();
    _raysButton = _createRaysButton();
    _rotateButton.isDisabled = isCircle;
    camera.viewport.addAll([_rotateButton, _raysButton, _shapeButton]);
  }

  Vector2 get halfSize => size * 0.5;
  bool get isCircle => world.isCircle;

  ButtonColors _getColorsFor(Color color) {
    final disabledColor = color.withValues(alpha: 0.5);
    Color downColor;
    if (color == BasicPalette.orange.color) {
      downColor = BasicPalette.lightOrange.color;
    } else if (color == BasicPalette.blue.color) {
      downColor = BasicPalette.lightBlue.color;
    } else if (color == BasicPalette.pink.color) {
      downColor = BasicPalette.lightPink.color;
    } else if (color == BasicPalette.purple.color) {
      downColor = BasicPalette.magenta.color;
    } else {
      downColor = color;
    }
    return (downColor, disabledColor);
  }

  AdvancedButtonComponent _createButton(
    String title,
    double x,
    Anchor anchor,
    Color color,
    void Function()? action, {
    double y = 2,
  }) {
    final colors = _getColorsFor(color);
    final disabledColor = colors.$2;
    final downColor = colors.$1;
    return CancellableButtonComponent(
      position: Vector2(x, y),
      size: buttonSize,
      anchor: anchor,
      priority: RaysInShapeWorld.hudPriority,
      defaultLabel: TextComponent(text: title, textRenderer: textRenderer),
      disabledLabel: TextComponent(text: title, textRenderer: textOffRenderer),
      defaultSkin: RoundedRectComponent()..setColor(color),
      disabledSkin: RoundedRectComponent()..setColor(disabledColor),
      downSkin: RoundedRectComponent()..setColor(downColor),
      onReleased: action,
    );
  }

  AdvancedButtonComponent _createRotateButton() {
    return _createButton(
      'Rotate',
      2,
      .topLeft,
      BasicPalette.orange.color,
      () => world.toggleRotate(),
    );
  }

  AdvancedButtonComponent _createShapeButton() {
    return _createButton(
      'Shape',
      size.x * 0.5,
      .topCenter,
      BasicPalette.blue.color,
      _changeShape,
    );
  }

  AdvancedButtonComponent _createRaysButton() {
    return _createButton(
      'Rays',
      size.x - 2,
      .topRight,
      BasicPalette.purple.color,
      () => world.changeRays(),
    );
  }

  void _changeShape() {
    world.changeShape();
    _rotateButton.isDisabled = isCircle;
  }
}

class RayCircleComponent extends CircleComponent
    with
        DragCallbacks,
        HoverCallbacks,
        TapCallbacks,
        HasWorldRef<RaysInShapeWorld> {
  RayCircleComponent(
    this.ray, {
    super.radius,
    super.position,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority,
    super.paint,
    super.paintLayers,
    super.key,
  });

  RaycastResult<ShapeHitbox>? _raycastResult;
  bool get _hitScreen {
    final hitbox = _raycastResult?.hitbox;
    if (hitbox != null) {
      return hitbox is ScreenHitbox ||
          (hitbox is RectangleHitbox && hitbox.parent is ScreenHitbox);
    }
    return false;
  }

  late final _rayLength = playArea.width * 0.1;
  late Offset _lineTarget;

  Offset get _lineOffset => Offset(radius, radius);

  @override
  void update(double dt) {
    super.update(dt);
    _raycastResult = worldRef.intersections(ray);
    if (_raycastResult == null) {
      paint = _lightPaint;
      _lineTarget = ray.direction.scaled(_rayLength).toOffset();
    } else {
      if (_hitScreen) {
        paint = _lightPaint;
      } else {
        paint = _raycastResult!.isInsideHitbox ? _greenPaint : _redPaint;
      }
      final origin = ray.origin.toOffset();
      _lineTarget = _raycastResult!.intersectionPoint!.toOffset() - origin;
    }
    _lineSegment = _segment();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final offset = _lineOffset;
    canvas.drawLine(offset, _lineTarget + offset, paint);
  }

  @override
  void onMouseMove(MouseMoveEvent event) {
    if (worldRef.hasHovering == false || worldRef.isHovering(this)) {
      super.onMouseMove(event);
    }
  }

  @override
  void onHoverEnter() {
    if (!isDragging) {
      _isHovering = true;
    }
    worldRef.addHovering(this);
  }

  @override
  void onHoverExit() {
    if (!isDragging) {
      _isHovering = false;
    }
    worldRef.removeHovering(this);
  }

  @override
  void onHoverCancel() {
    onHoverExit();
  }

  @override
  void onTapDown(TapDownEvent event) {
    _isDragging = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    _isDragging = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    _isDragging = false;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _isDragging = true;
    _updateFromDrag(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Guard against invalid local event positions.
    var local = event.localEndPosition;
    if (local.x.isNaN || local.y.isNaN) {
      local = absoluteToLocal(event.canvasEndPosition);
    }
    _updateFromDrag(local);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _isDragging = false;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _isDragging = false;
  }

  final _segmentFactor = pi * 10;

  @override
  bool containsLocalPoint(Vector2 point) {
    _lineDrag = false;
    final length = radius * 2;
    final taxiDistance = point.x.abs() + point.y.abs();
    var result = taxiDistance <= length || super.containsLocalPoint(point);
    if (!result) {
      // Why the enormous factor to pick correctly within the epsilon...?
      result = _lineSegment.containsPoint(
        point,
        epsilon: length * _segmentFactor,
      );
      _lineDrag = result;
    }
    return result;
  }

  late var _lineSegment = LineSegment.zero();
  var _lineDrag = false;

  LineSegment _segment([Vector2? offset]) {
    offset ??= _lineOffset.toVector2();
    return LineSegment(offset, offset + _lineTarget.toVector2());
  }

  void _updateFromDrag(Vector2 drag) {
    final delta = drag - Vector2(radius, radius);
    if (_lineDrag) {
      final dir = ray.direction + delta.normalized();
      ray.direction = dir.normalized();
    } else {
      position += delta;
      ray.origin += delta;
    }
  }

  final Ray2 ray;

  bool get isDragging => _isDragging || isDragged;
  bool get isHovering => _isHovering || isHovered;

  bool _isDragging = false;
  bool _isHovering = false;

  Paint get _lightPaint => isDragging
      ? activeLightStroke
      : (isHovering ? hoveredLightStroke : lightStroke);
  Paint get _redPaint => isDragging
      ? activeRedStroke
      : (isHovering ? hoveredRedStroke : redStroke);
  Paint get _greenPaint => isDragging
      ? activeGreenStroke
      : (isHovering ? hoveredGreenStroke : greenStroke);
}

class RaysInShapeWorld extends World
    with HasGameRef<RaysInShapeExample>, HasCollisionDetection {
  final _rng = Random();
  List<Ray2> _rays = [];
  final Map<Ray2, RayCircleComponent> _circles = {};
  Iterable<RayCircleComponent> get circleComponents => _circles.values;

  int get _numRays => 200;

  List<Ray2> randomRays(int count) => List<Ray2>.generate(
    count,
    (index) => Ray2(
      origin:
          (Vector2.random(_rng)) * playArea.size.width -
          playArea.size.toVector2() / 2,
      direction: (Vector2.random(_rng) - Vector2(0.5, 0.5)).normalized(),
    ),
  );

  void _createCircles() {
    _hovering.clear();
    removeAll(circleComponents);
    _circles.clear();
    for (final ray in _rays) {
      final circle = RayCircleComponent(
        ray,
        position: ray.origin.clone(),
        radius: 3,
        anchor: .center,
        paint: lightStroke,
      );
      _circles[ray] = circle;
    }
    addAll(circleComponents);
  }

  int _componentIndex = 0;
  static final _componentSize = Vector2(
    playArea.width * 0.5,
    playArea.height * 0.5,
  );

  static Effect createRotate() {
    return RotateEffect.by(
      rotateAmplitude,
      EffectController(duration: rotateDuration, infinite: true),
    );
  }

  static double get rotateAmplitude => pi * 2.0;
  static double get rotateDuration => 20.0;

  static int get hudPriority => 1000;

  static final _pathSize = Size(playArea.width * 0.5, playArea.height * 0.5);
  final _components = [
    CircleComponent(
      priority: shapePriority,
      radius: _componentSize.x * 0.6,
      anchor: Anchor.center,
      position: Vector2.zero(),
      paint: whiteStroke,
      children: [CircleHitbox()],
    ),
    RectangleComponent(
      priority: shapePriority,
      size: _componentSize,
      anchor: Anchor.center,
      position: Vector2.zero(),
      paint: whiteStroke,
      children: [RectangleHitbox()],
    ),
    PositionComponent(
      priority: shapePriority,
      position: Vector2.zero(),
      children: [
        PolygonHitbox.relative(
            [
              Vector2(-0.7, -1),
              Vector2(1, -0.4),
              Vector2(0.3, 1),
              Vector2(-1, 0.6),
            ],
            parentSize: _componentSize,
            anchor: Anchor.center,
            position: Vector2.zero(),
          )
          ..paint = whiteStroke
          ..renderShape = true,
      ],
    ),
    for (var index = 0; index < numTestPaths; ++index)
      pathComponent(index, _pathSize, renderHitboxes: true),
  ];

  final _ignoredHitboxes = <PolygonHitbox>[];

  late TextComponent _textComponent;
  TextPaint get _textRenderer => TextPaint(
    style: const TextStyle(
      color: Colors.white,
      fontSize: fontSize,
    ),
  );

  PositionComponent get current => _components[_componentIndex];

  bool addHovering(RayCircleComponent circle) {
    return _hovering.add(circle);
  }

  bool removeHovering(RayCircleComponent circle) {
    return _hovering.remove(circle);
  }

  bool isHovering(RayCircleComponent circle) {
    return _hovering.contains(circle);
  }

  int get numHovering => _hovering.length;
  bool get hasHovering => _hovering.isNotEmpty;

  final _hovering = <RayCircleComponent>{};
  bool useContainment = false;
  int? hoveredRay;
  Effect? rotate;
  bool isRotating = false;

  bool get isCircle => current is CircleComponent;

  var _doUpdate = false;
  void _forceUpdate() {
    _intersections.clear();
    _doUpdate = true;
    _resetTimer();
    _resetTotalTimer();
  }

  void toggleRotate() {
    if (_componentIndex == 0) {
      // Not available on the circle.
      return;
    }
    isRotating = !isRotating;
    if (isRotating) {
      _addRotate(current);
    } else {
      _removeRotate();
    }
    _forceUpdate();
  }

  void changeShape() {
    final angle = isRotating && !isCircle ? current.angle : null;
    remove(current);
    _componentIndex = (_componentIndex + 1) % _components.length;
    _addCurrent(current);
    if (isRotating && angle != null) {
      current.angle = angle;
    }
    _forceUpdate();
  }

  void changeRays() {
    _rays = randomRays(_numRays);
    _createCircles();
    _forceUpdate();
  }

  void _addRotate(Component component) {
    _removeRotate();
    final effect = current.firstChild();
    if (_componentIndex != 0 && effect == null) {
      rotate = createRotate();
      component.add(rotate!);
    }
  }

  void _removeRotate() {
    rotate?.removeFromParent();
    rotate = null;
  }

  void _addCurrent(PositionComponent component) {
    _removeRotate();
    if (isRotating && !isCircle) {
      _addRotate(component);
    }
    add(component);
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    _addCurrent(current);
    add(ScreenHitbox());
    _textComponent = TextComponent(
      text: 'Rays #${_rays.length}',
      priority: hudPriority,
      position: Vector2(
        (playArea.width * 0.5) - 2,
        (playArea.height * 0.5) - 6,
      ),
      anchor: .centerRight,
      textRenderer: _textRenderer,
    );
    addAll([
      FpsTextComponent(
        decimalPlaces: 1,
        windowSize: _updatesInterval,
        priority: hudPriority,
        position: Vector2(
          (-playArea.width * 0.5) + 2,
          (playArea.height * 0.5) - 6,
        ),
        anchor: .centerLeft,
        textRenderer: _textRenderer,
      ),
      _textComponent,
    ]);
    _rays = randomRays(_numRays);
    _createCircles();
  }

  final Map<Ray2, RaycastResult<ShapeHitbox>?> _intersections = {};
  final int _updatesInterval = 30;
  var _totalUpdates = 0;
  final _timings = <double>[];
  late Stopwatch _timer;

  RaycastResult<ShapeHitbox>? intersections(Ray2 ray) => _intersections[ray];

  double _totalElapsed = 0;

  void _startTimer() {
    _timer = Stopwatch()..start();
  }

  double? _advanceTimer() {
    _timer.stop();
    _timings.add(_timer.elapsedMicroseconds.toDouble());
    if (_doUpdate || _timings.length >= _updatesInterval) {
      if (_doUpdate) {
        _doUpdate = false;
        return 0;
      } else {
        _timings.sort();
        return _timings[_timings.length ~/ 2];
      }
    }
    return null;
  }

  void _updateTotalTimer(double elapsed) {
    _totalElapsed += elapsed;
    _totalUpdates++;
  }

  void _resetTimer() {
    _timings.clear();
  }

  void _resetTotalTimer() {
    _totalUpdates = 0;
    _totalElapsed = 0;
  }

  @override
  void update(double dt) {
    super.update(dt);

    _startTimer();
    for (final ray in _rays) {
      final result = collisionDetection.raycast(
        ray,
        ignoreHitboxes: _ignoredHitboxes,
      );
      _intersections[ray] = result;
    }
    final elapsed = _advanceTimer();
    if (elapsed != null) {
      _updateTimer(elapsed);
      _resetTimer();
    }
  }

  void _updateTimer(double elapsed) {
    _updateTotalTimer(elapsed);
    final total = _totalElapsed / _totalUpdates;
    _updateTimerText(elapsed, total);
  }

  void _updateTimerText(double elapsed, double total) {
    var message = '#${_rays.length} ';
    var shape = '';
    switch (_componentIndex) {
      case 0:
        shape = 'circle';
      case 1:
        shape = 'rectangle';
      case 2:
        shape = 'relative';
      default:
        shape = pathContourShapeNames[_componentIndex - 3];
    }
    message += '$shape ';
    message += elapsedString(elapsed).padLeft(7);
    message += '/${elapsedString(total).padLeft(7)}';
    _textComponent.text = message;
  }

  String elapsedString(double elapsed) {
    if (elapsed >= 1000) {
      return '${(elapsed / 1000).toStringAsFixed(1)}ms';
    } else {
      return '${elapsed.toStringAsFixed(1)}us';
    }
  }
}
