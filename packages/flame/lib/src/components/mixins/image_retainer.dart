import 'dart:ui';

import 'package:flame/src/cache/images.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/flame.dart';
import 'package:meta/meta.dart';

/// A mixin for components that render images from an [Images] cache.
///
/// While the component is mounted, the images returned by [retainedImages]
/// are retained in the cache that they were loaded into, which protects them
/// from being evicted. They are released again when the component is
/// removed.
///
/// Whenever the images that the component renders change after it was
/// mounted, call [updateRetainedImages] so that the old images are released
/// and the new ones retained.
///
/// Images that do not belong to any cache are ignored, so it is safe to return
/// images that were generated at runtime.
mixin ImageRetainer on Component {
  List<Image> _retainedImages = const [];
  bool _isRetaining = false;

  /// The images that this component currently renders.
  Iterable<Image> get retainedImages;

  /// Releases the previously retained images and retains the images that
  /// [retainedImages] currently returns.
  ///
  /// This only has an effect while the component is mounted, since the images
  /// are retained on mount anyway.
  @protected
  void updateRetainedImages() {
    if (_isRetaining) {
      _retain();
    }
  }

  @override
  @mustCallSuper
  void onMount() {
    super.onMount();
    _isRetaining = true;
    _retain();
  }

  @override
  @mustCallSuper
  void onRemove() {
    _isRetaining = false;
    _release();
    super.onRemove();
  }

  void _retain() {
    final retained = (Set<Image>.identity()..addAll(retainedImages)).toList(
      growable: false,
    );
    Images? fallback;
    for (final image in retained) {
      final cache = Images.ownerOf(image) ?? (fallback ??= _fallbackCache());
      cache.retain(image);
    }
    _release();
    _retainedImages = retained;
  }

  void _release() {
    Images? fallback;
    for (final image in _retainedImages) {
      final cache = Images.ownerOf(image) ?? (fallback ??= _fallbackCache());
      cache.release(image);
    }
    _retainedImages = const [];
  }

  /// The cache to use for images that are not recognized as belonging to any
  /// cache, which is the case for clones of cached images.
  Images _fallbackCache() => findGame()?.images ?? Flame.images;
}
