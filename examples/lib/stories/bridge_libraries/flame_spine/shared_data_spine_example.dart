import 'dart:math';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_spine/flame_spine.dart';

class SharedDataSpineExample extends FlameGame with TapCallbacks {
  static const String description = '''
    This example shows how to preload assets and share data between Spine
    components.
  ''';

  late final SkeletonDataFlutter cachedSkeletonData;
  late final AtlasFlutter cachedAtlas;
  late final List<SpineComponent> spineboys = [];

  @override
  Future<void> onLoad() async {
    await initSpineFlutter();
    // Pre-load the atlas and skeleton data once.
    cachedAtlas = await AtlasFlutter.fromAsset('assets/spine/spineboy.atlas');
    cachedSkeletonData = await SkeletonDataFlutter.fromAsset(
      cachedAtlas,
      'assets/spine/spineboy-pro.skel',
    );

    // Instantiate many spineboys from the pre-loaded data. Each SpineComponent
    // gets their own SkeletonDrawable copy derived from the cached data. The
    // SkeletonDrawable copies do not own the underlying skeleton data and
    // atlas.
    final rng = Random();
    for (var i = 0; i < 100; i++) {
      final drawable = SkeletonDrawableFlutter(
        cachedAtlas,
        cachedSkeletonData,
        false,
      );
      final scale = 0.1 + rng.nextDouble() * 0.2;
      final position = Vector2.random(rng)..multiply(size);
      final spineboy = SpineComponent(
        drawable,
        scale: Vector2.all(scale),
        position: position,
      );
      spineboy.animationState.setAnimation(0, 'walk', true);
      spineboys.add(spineboy);
    }
    await addAll(spineboys);
  }

  @override
  void onTapDown(_) {
    for (final spineboy in spineboys) {
      spineboy.animationState.setAnimation(0, 'jump', false);
      spineboy.animationState.setListener((type, track, event) {
        if (type == EventType.complete) {
          spineboy.animationState.setAnimation(0, 'walk', true);
        }
      });
    }
  }

  @override
  void onDetach() {
    // Dispose the pre-loaded atlas and skeleton data when the game/scene is
    // removed.
    cachedAtlas.dispose();
    cachedSkeletonData.dispose();

    // Dispose each spineboy and its internal SkeletonDrawable.
    for (final spineboy in spineboys) {
      spineboy.dispose();
    }
  }
}
