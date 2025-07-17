import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';

class AnimatedBatchComponent extends SpriteBatchComponent {
  AnimatedBatchComponent({
    required super.spriteBatch,
    required List<Rect> sources,
    required SpriteAnimation animation,
    super.cullRect,
    super.blendMode,
    super.paint,
    super.key,
    super.priority,
    super.children,
  })  : _sources = sources,
        _animation = animation,
        assert(sources.isNotEmpty, 'Sources cannot be empty');

  final SpriteAnimation _animation;
  final List<Rect> _sources;
  final List<PositionComponent> _components = [];
  final List<SpriteAnimationTicker> _tickers = [];
  final List<int> _animationIndexes = [];

  // Reuse these objects to avoid allocations
  final _offset = Vector2.zero();
  final _anchor = Vector2.zero();
  final _componentScale = Vector2.zero();

  void addToBatch(PositionComponent component) {
    _components.add(component);
    _tickers.add(SpriteAnimationTicker(_animation));
    _animationIndexes.add(0);
    _anchor.setValues(
      component.anchor.x * component.size.x,
      component.anchor.y * component.size.y,
    );
  }

  void removeFromBatch(PositionComponent component) {
    final index = _components.indexOf(component);
    if (index >= 0) {
      _components.removeAt(index);
      _tickers.removeAt(index);
      _animationIndexes.removeAt(index);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update all tickers and animation indexes in one pass in reverse order
    // to guard against concurrent modifications to the _tickers list.
    for (var i = _tickers.length - 1; i >= 0; i--) {
      final ticker = _tickers[i];
      ticker.update(dt);
      _animationIndexes[i] = ticker.currentIndex;
    }

    // Clear the sprite batch to remove old sprites
    spriteBatch.clear();

    // Batch all sprites in one loop in reverse to guard against concurrent
    // modifications to the _components list.
    for (var i = _components.length - 1; i >= 0; i--) {
      final component = _components[i];

      _offset.setFrom(component.absolutePosition);

      _componentScale.setFrom(component.scale);
      final avgScale = (_componentScale.x + _componentScale.y) * 0.5;

      spriteBatch.add(
        source: _sources[_animationIndexes[i]],
        offset: _offset,
        rotation: component.angle,
        scale: avgScale,
        anchor: _anchor,
      );
    }
  }
}
