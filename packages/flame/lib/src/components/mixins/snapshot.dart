import 'dart:ui';

import 'package:flame/components.dart';

/// A mixin that enables caching a component and all its children. If
/// [renderSnapshot] is set to `true`, the component and its children will be
/// rendered to a cache. Subsequent renders use the cache, dramatically
/// improving performance. This is only effective if the component and its
/// children do not change - i.e. they are not animated and they do not move
/// around relative to each other.
///
/// The [takeSnapshot] and [snapshotAsImage] methods can also be used to take
/// one-off snapshots for screen-grabs or other purposes.
mixin Snapshot on PositionComponent {
  bool _renderSnapshot = true;
  Picture? _picture;

  /// If [renderSnapshot] is `true` then this component and all its children
  /// will be rendered once and cached. If [renderSnapshot] is `false`
  /// then this component will render normally.
  bool get renderSnapshot => _renderSnapshot;
  set renderSnapshot(bool value) {
    if (_renderSnapshot != value) {
      _renderSnapshot = value;
      if (_renderSnapshot == true) {
        _picture = null;
      }
    }
  }

  /// Check if a snapshot exists.
  bool get hasSnapshot => _picture != null;

  /// Grab the current snapshot. Check it exists first using [hasSnapshot].
  Picture get snapshot {
    assert(_picture != null, 'No snapshot has been taken');
    return _picture!;
  }

  /// Convert the snapshot to an image with the given [width] and [height].
  /// Use [transform] to position the snapshot in the image, or to apply other
  /// transforms before the image is generated.
  Image snapshotAsImage(int width, int height, {Matrix4? transform}) {
    assert(_picture != null, 'No snapshot has been taken');
    if (transform == null) {
      return _picture!.toImageSync(width, height);
    } else {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.transform(transform.storage);
      canvas.drawPicture(_picture!);
      final picture = recorder.endRecording();
      return picture.toImageSync(width, height);
    }
  }

  /// Immediately take a snapshot and return it. If [renderSnapshot] is true
  /// then the snapshot is also used for rendering. A snapshot is always taken
  /// with no transformations (i.e. as if the Snapshot component is at position
  /// (0, 0) and has no scale or rotation applied).
  Picture takeSnapshot() {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final matrix = transformMatrix.clone();
    matrix.invert();
    canvas.transform(matrix.storage);
    super.renderTree(canvas);
    _picture = recorder.endRecording();
    return _picture!;
  }

  /// clear the current snapshot. will trigger the creation of a new snapshot 
  /// next time renderTree is called.
  void clearSnapshot() {
    _picture = null;
  }

  @override
  void renderTree(Canvas canvas) {
    if (renderSnapshot) {
      if (_picture == null) {
        takeSnapshot();
      }
      canvas.save();
      canvas.transform(
        transformMatrix.storage,
      );
      canvas.drawPicture(_picture!);
      canvas.restore();
    } else {
      super.renderTree(canvas);
    }
  }
}
