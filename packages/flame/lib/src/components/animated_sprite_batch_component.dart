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

  final List<_BatchItem> _items = [];

  // Reuse these objects to avoid allocations
  final _offset = Vector2.zero();

  void addToBatch(PositionComponent component) {
    final anchor = Vector2(
      component.anchor.x * component.size.x,
      component.anchor.y * component.size.y,
    );

    _items.add(
      _BatchItem(
        component: component,
        ticker: SpriteAnimationTicker(_animation),
        frameIndex: 0,
        anchor: anchor,
      ),
    );
  }

  void removeFromBatch(PositionComponent component) {
    _items.removeWhere((item) => item.component == component);
  }

  @override
  void update(double dt) {
    if (_items.isEmpty) {
      return;
    }

    spriteBatch.clear();

    for (var i = _items.length - 1; i >= 0; i--) {
      final item = _items[i];

      item.ticker.update(dt);
      item.frameIndex = item.ticker.currentIndex;

      _offset.setFrom(item.component.absolutePosition);

      spriteBatch.add(
        source: _sources[item.frameIndex],
        offset: _offset,
        rotation: item.component.angle,
        scale: (item.component.scale.x + item.component.scale.y) * 0.5,
        anchor: item.anchor,
      );
    }
  }
}

class _BatchItem {
  _BatchItem({
    required this.component,
    required this.ticker,
    required this.frameIndex,
    required this.anchor,
  });

  final PositionComponent component;
  final SpriteAnimationTicker ticker;
  int frameIndex;
  final Vector2 anchor;
}
