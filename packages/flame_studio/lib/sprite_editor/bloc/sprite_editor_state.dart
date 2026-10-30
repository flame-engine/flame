part of 'sprite_editor_cubit.dart';

/// The status of the [SpriteEditorCubit].
enum SpriteEditorStatus() {
  /// The images of the project are being listed.
  loading,

  /// The images were listed.
  ready,

  /// The images of the project couldn't be listed.
  failure,
}

/// {@template sprite_editor_state}
/// The state of the [SpriteEditorCubit].
/// {@endtemplate}
final class const SpriteEditorState({
  /// The sprite being edited.
  required final ComponentSprite sprite,

  /// The current status.
  final SpriteEditorStatus status = SpriteEditorStatus.loading,

  /// The asset paths of the images of the project.
  final List<String> images = const [],

  /// The contents of the image of the [sprite], once it is read.
  final Uint8List? bytes,

  /// The width of the image of the [sprite], once it is decoded.
  final int? imageWidth,

  /// The height of the image of the [sprite], once it is decoded.
  final int? imageHeight,

  /// Whether the image of the [sprite] can't be read or decoded.
  final bool isImageInvalid = false,

  /// The zoom of the canvas, relative to the scale that fits the image in
  /// it, around its center.
  final double zoom = 1,

  /// How far the canvas was scrolled horizontally, in canvas pixels.
  final double panX = 0,

  /// How far the canvas was scrolled vertically, in canvas pixels.
  final double panY = 0,
}) extends Equatable {
  /// {@macro sprite_editor_state}
  this;

  /// Whether the canvas can zoom in further.
  bool get canZoomIn => ZoomLevels.next(zoom) != null;

  /// Whether the canvas can zoom out further.
  bool get canZoomOut => ZoomLevels.previous(zoom) != null;

  /// Whether the [sprite] is ready to be applied: its image was decoded, so
  /// its region is known to be inside the image.
  bool get canApply => imageWidth != null && imageHeight != null;

  /// Returns a copy of this state with the given fields replaced. The
  /// fields set with a function can be cleared.
  SpriteEditorState copyWith({
    ComponentSprite? sprite,
    SpriteEditorStatus? status,
    List<String>? images,
    Uint8List? Function()? bytes,
    int? Function()? imageWidth,
    int? Function()? imageHeight,
    bool? isImageInvalid,
    double? zoom,
    double? panX,
    double? panY,
  }) {
    return SpriteEditorState(
      sprite: sprite ?? this.sprite,
      status: status ?? this.status,
      images: images ?? this.images,
      bytes: bytes != null ? bytes() : this.bytes,
      imageWidth: imageWidth != null ? imageWidth() : this.imageWidth,
      imageHeight: imageHeight != null ? imageHeight() : this.imageHeight,
      isImageInvalid: isImageInvalid ?? this.isImageInvalid,
      zoom: zoom ?? this.zoom,
      panX: panX ?? this.panX,
      panY: panY ?? this.panY,
    );
  }

  @override
  List<Object?> get props => [
    sprite,
    status,
    images,
    bytes,
    imageWidth,
    imageHeight,
    isImageInvalid,
    zoom,
    panX,
    panY,
  ];
}
