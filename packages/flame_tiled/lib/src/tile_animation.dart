import 'dart:ui' show Rect;

import 'package:flame_tiled/src/mutable_rect.dart';

/// Records a single animation for tile on a layer.
///
/// This works because SpriteBatch holds a list of [Rect]. Those rectangles
/// are usually immutable, but flame_tile uses a mutable rectangle to update
/// the offsets in the image atlas.
class TileAnimation {
  /// Frames of the animation loop.
  final TileFrames frames;

  /// Rectangle that gets updated for each new frame in the animation.
  final MutableRect batchedSource;

  /// Current frame counter.
  int frame = 0;

  TileAnimation(
    this.batchedSource,
    this.frames,
  );

  void update(double dt) {
    if (frame != frames.frame) {
      frame = frames.frame;
      batchedSource.copy(frames.sources[frame]);
    }
  }
}

/// Records the list of frames for a tile so that it can be reused.
class TileFrames {
  /// Rectangles for each frame in the animation.
  final List<Rect> sources;

  /// Duration, in seconds, for each frame in the animation.
  final List<double> durations;

  /// Current frame lifetime.
  double frameTime = 0.0;

  /// Current frame counter for all frames sharing this animation.
  int frame = 0;

  TileFrames(this.sources, this.durations);

  void update(double dt) {
    frameTime += dt;

    // Track really long jank by skipping ahead.
    while (durations[frame] <= frameTime) {
      final currentFrameTime = durations[frame];
      frame = (frame + 1) % durations.length;
      // We still have time to add to this, even if we're late.
      frameTime = frameTime - currentFrameTime;
    }
  }
}
