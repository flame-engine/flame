import 'dart:typed_data';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

part 'sprite_editor_state.dart';

/// {@template sprite_editor_cubit}
/// Edits a working copy of a sprite, which the sprite editor dialog returns
/// when the user applies the changes: which image of the project it uses,
/// and the region of the image, in whole pixels inside the image.
///
/// Images are decoded by the canvas, which needs them to draw, and which
/// reports their size with [imageDecoded].
///
/// Also holds the zoom and the scroll of the canvas, which are not
/// remembered: the dialog opens fitting the image again every time.
/// {@endtemplate}
class SpriteEditorCubit({
  required final Project _project,
  required ComponentSprite sprite,
  required final ComponentRepository _componentRepository,
}) extends Cubit<SpriteEditorState> {
  /// {@macro sprite_editor_cubit}
  this : super(SpriteEditorState(sprite: sprite));

  /// Whether the region of the sprite is the one it opened with, which is
  /// kept if it fits the image, rather than a new image's.
  late bool _keepsRegion = state.sprite.image != null;

  /// Lists the images of the project, and reads the image of the sprite.
  Future<void> started() async {
    try {
      final images = await _componentRepository.getImages(_project.path);
      emit(state.copyWith(status: SpriteEditorStatus.ready, images: images));
    } on Exception {
      emit(state.copyWith(status: SpriteEditorStatus.failure));
    }
    if (state.sprite.image case final image?) {
      await _readImage(image);
    }
  }

  /// Uses the image at the asset path [image], with a region that covers
  /// all of it, unless it already is the image in use.
  Future<void> imageSelected(String image) async {
    if (image == state.sprite.image) {
      return;
    }
    _keepsRegion = false;
    emit(
      state.copyWith(
        sprite: ComponentSprite(image: image),
        bytes: () => null,
        imageWidth: () => null,
        imageHeight: () => null,
        isImageInvalid: false,
        zoom: 1,
        panX: 0,
        panY: 0,
      ),
    );
    await _readImage(image);
  }

  Future<void> _readImage(String image) async {
    try {
      final bytes = await _componentRepository.readImage(_project.path, image);
      // The user may have picked another one meanwhile.
      if (image == state.sprite.image) {
        emit(state.copyWith(bytes: () => bytes));
      }
    } on Exception {
      if (image == state.sprite.image) {
        emit(state.copyWith(isImageInvalid: true));
      }
    }
  }

  /// The canvas decoded the image, which is [width] by [height] pixels. The
  /// region is fitted inside it.
  void imageDecoded(int width, int height) {
    final sprite = state.sprite;
    final next = state.copyWith(
      imageWidth: () => width,
      imageHeight: () => height,
    );
    emit(
      next.copyWith(
        sprite: _keepsRegion
            ? _clamped(
                next,
                sprite.srcPosition.x,
                sprite.srcPosition.y,
                sprite.srcSize.width,
                sprite.srcSize.height,
              )
            : _clamped(next, 0, 0, width.toDouble(), height.toDouble()),
      ),
    );
  }

  /// The canvas can't decode the image.
  void imageFailed() => emit(state.copyWith(isImageInvalid: true));

  /// Sets the region of the sprite, fitted inside the image.
  void regionChanged(double x, double y, double width, double height) {
    if (state.canApply) {
      emit(state.copyWith(sprite: _clamped(state, x, y, width, height)));
    }
  }

  /// Moves the region of the sprite to [x], [y], keeping its size.
  void regionMoved(double x, double y) {
    final size = state.sprite.srcSize;
    regionChanged(x, y, size.width, size.height);
  }

  /// The sprite of [state] with the given region, rounded to whole pixels,
  /// at least one pixel big and inside the image, which must be decoded.
  static ComponentSprite _clamped(
    SpriteEditorState state,
    double x,
    double y,
    double width,
    double height,
  ) {
    final imageWidth = state.imageWidth!.toDouble();
    final imageHeight = state.imageHeight!.toDouble();
    final srcWidth = width.roundToDouble().clamp(1.0, imageWidth);
    final srcHeight = height.roundToDouble().clamp(1.0, imageHeight);
    return ComponentSprite(
      image: state.sprite.image,
      srcPosition: ComponentPosition(
        x: x.roundToDouble().clamp(0.0, imageWidth - srcWidth),
        y: y.roundToDouble().clamp(0.0, imageHeight - srcHeight),
      ),
      srcSize: ComponentSize(width: srcWidth, height: srcHeight),
    );
  }

  /// Scrolls the canvas by [dx], [dy] canvas pixels.
  void panned(double dx, double dy) {
    emit(state.copyWith(panX: state.panX + dx, panY: state.panY + dy));
  }

  /// Zooms the canvas in to the next of the [ZoomLevels], if any.
  void zoomedIn() {
    final zoom = ZoomLevels.next(state.zoom);
    if (zoom != null) {
      emit(state.copyWith(zoom: zoom));
    }
  }

  /// Zooms the canvas out to the previous of the [ZoomLevels], if any.
  void zoomedOut() {
    final zoom = ZoomLevels.previous(state.zoom);
    if (zoom != null) {
      emit(state.copyWith(zoom: zoom));
    }
  }

  /// Resets the zoom and the scroll of the canvas, showing the image as it
  /// was fitted when it opened.
  void zoomReset() => emit(state.copyWith(zoom: 1, panX: 0, panY: 0));
}
