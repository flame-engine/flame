import 'package:flame/components.dart';
import 'package:flame/extensions.dart';

class AnimatedBatchComponent extends SpriteBatchComponent {
  AnimatedBatchComponent({
    required super.spriteBatch,
    required this.sources,
    required double stepTime,
    super.cullRect,
    super.blendMode,
    super.paint,
    super.key,
    super.priority,
    super.children,
  })  : _stepTime = stepTime,
        assert(sources.isNotEmpty, 'Sources cannot be empty'),
        assert(stepTime > 0, 'Step time must be greater than zero');

  final double _stepTime;
  final List<Rect> sources;
  final List<PositionComponent> _components = [];
  final _offset = Vector2.zero();
  final _anchor = Vector2.zero();
  double _animationTimer = 0;
  int _animationIndex = 0;

  void addToBatch(PositionComponent component) {
    _components.add(component);
    _anchor.setValues(
      component.anchor.x * component.size.x,
      component.anchor.y * component.size.y,
    );
  }

  void removeFromBatch(PositionComponent component) {
    _components.remove(component);
  }

  @override
  void update(double dt) {
    super.update(dt);

    _animationTimer += dt;

    if (_animationTimer >= _stepTime) {
      _animationTimer = 0;
      _animationIndex = (_animationIndex + 1) % sources.length;
    }

    // Clear the sprite batch to remove old bullets
    spriteBatch.clear();

    for (final component in _components) {
      _offset.setFrom(component.absolutePosition);
      spriteBatch.add(
        source: sources.elementAt(_animationIndex),
        offset: _offset,
        rotation: component.angle,
        scale: (component.scale.x + component.scale.y) / 2,
        anchor: _anchor,
      );
    }
  }
}
