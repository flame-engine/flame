import 'dart:math' show max, min;
import 'dart:ui' show Rect;

import 'package:flame/cache.dart';
import 'package:flame_svg/svg_paths.dart';
import 'package:flame_svg/svg_paths_animation_ticker.dart';

/// Describes a frame of an [SvgPathsAnimation] to load, see
/// [SvgPathsAnimation.load].
class SvgPathsAnimationFrameData({
  /// The SVG file of the frame, as in [SvgPaths.fromFile].
  required final String fileName,

  /// When the frame appears, in seconds.
  required final double start,

  /// How long the frame lasts, in seconds.
  required final double duration,
}) {
  /// Create from the [fileName] of a frame, its [start] and [duration].
  this;
}

/// A frame of an [SvgPathsAnimation]: the [svg] shown from [start], for
/// [duration] seconds.
class SvgPathsAnimationFrame(
  final SvgPaths svg, {
  required final double start,
  required final double duration,
}) {
  /// Create from the [svg] of a frame, its [start] and [duration].
  this;

  /// When the frame disappears, in seconds.
  double get end => start + duration;
}

/// An animation made of [SvgPaths] frames, each with its own start time and
/// duration.
///
/// Overlapping frames are all shown, in the order of [frames]. During a gap
/// the frames shown last remain. Before the earliest start, the earliest
/// frames are shown in the first loop, and the latest ones in the next loops.
class SvgPathsAnimation(
  List<SvgPathsAnimationFrame> frames, {

  /// Whether the animation starts over after its [duration].
  final bool loop = true,
  double? duration,
}) {
  /// Create from the given [frames]. The [duration] of each loop is by default
  /// the latest end of the frames, and can only be longer than that.
  this
    : assert(frames.isNotEmpty, 'There must be at least one animation frame'),
      assert(
        frames.every((frame) => frame.start >= 0 && frame.duration > 0),
        'All frames must have non-negative starts and positive durations',
      ),
      assert(
        duration == null || duration >= _latestEnd(frames),
        'The duration can not be shorter than the latest end of the frames',
      );

  /// Load the SVG files of the [frames], each only once, via the [cache],
  /// see [SvgPaths.fromFile].
  static Future<SvgPathsAnimation> load(
    List<SvgPathsAnimationFrameData> frames, {
    AssetsCache? cache,
    String? package,
    bool merge = true,
    bool loop = true,
    double? duration,
  }) async {
    final files = <String, Future<SvgPaths>>{};
    for (final frame in frames) {
      files[frame.fileName] ??= SvgPaths.fromFile(
        frame.fileName,
        cache: cache,
        package: package,
        merge: merge,
      );
    }
    final svgs = Map.fromIterables(files.keys, await Future.wait(files.values));
    return SvgPathsAnimation(
      [
        for (final frame in frames)
          SvgPathsAnimationFrame(
            svgs[frame.fileName]!,
            start: frame.start,
            duration: frame.duration,
          ),
      ],
      loop: loop,
      duration: duration,
    );
  }

  /// The frames of the animation, which can not be modified.
  final List<SvgPathsAnimationFrame> frames = List.unmodifiable(frames);

  /// The duration of each loop, in seconds.
  final double duration = duration ?? _latestEnd(frames);

  /// The union of the bounds of all [frames], which is the common area that
  /// they are rendered from.
  late final Rect area = _computeArea();

  /// The indices of the frames that start first.
  late final List<int> earliestIndices = _indicesWhere(
    (frame) => frame.start == _earliestStart,
  );

  /// The indices of the frames that end last.
  late final List<int> latestIndices = _indicesWhere(
    (frame) => frame.end == _latestEnd(frames),
  );

  /// The indices of the frames shown at the given [time] within a loop, see
  /// [SvgPathsAnimation], in a list that can not be modified.
  List<int> indicesAt(double time, {bool firstLoop = true}) {
    // The ends of the frames are sums, which can be a little off: a frame
    // from 0.1 lasting 0.2 ends after a frame starting at 0.3. Moving the time
    // forward a little makes such frames follow each other.
    final t = time + _epsilon;
    final active = _indicesWhere(
      (frame) => frame.start <= t && t < frame.end,
    );
    if (active.isNotEmpty) {
      return active;
    }
    // In a gap, the frames shown last are those ending last before it.
    double? lastEnd;
    for (final frame in frames) {
      if (frame.end <= t) {
        lastEnd = max(lastEnd ?? frame.end, frame.end);
      }
    }
    if (lastEnd == null) {
      return firstLoop ? earliestIndices : latestIndices;
    }
    return _indicesWhere((frame) => frame.end == lastEnd);
  }

  /// Creates and returns a new [SvgPathsAnimationTicker].
  SvgPathsAnimationTicker createTicker() => SvgPathsAnimationTicker(this);

  static const _epsilon = 1e-9;

  late final double _earliestStart = frames
      .map((frame) => frame.start)
      .reduce(min);

  List<int> _indicesWhere(bool Function(SvgPathsAnimationFrame) test) {
    return List.unmodifiable([
      for (var i = 0; i < frames.length; i++)
        if (test(frames[i])) i,
    ]);
  }

  Rect _computeArea() {
    Rect? area;
    for (final frame in frames) {
      // An empty SVG has no bounds to add.
      if (frame.svg.length > 0) {
        area = area?.expandToInclude(frame.svg.bounds) ?? frame.svg.bounds;
      }
    }
    return area ?? Rect.zero;
  }

  static double _latestEnd(List<SvgPathsAnimationFrame> frames) {
    // Not reduce, since the assert on empty frames runs after this.
    return frames.fold(0.0, (end, frame) => max(end, frame.end));
  }
}
