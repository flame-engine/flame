import 'package:equatable/equatable.dart';
import 'package:flame_studio/repositories/repositories.dart';

/// {@template component_sprite}
/// The sprite property shared by every component that draws one: a region
/// of an image of the project, in pixels of the image.
/// {@endtemplate}
class const ComponentSprite({
  /// The asset path of the image, such as `assets/images/player.png`, or
  /// `null` until one is picked.
  final String? image,

  /// The top left corner of the region.
  final ComponentPosition srcPosition = const ComponentPosition(),

  /// The size of the region.
  final ComponentSize srcSize = const ComponentSize(),
}) extends Equatable {
  /// {@macro component_sprite}
  this;

  /// Creates a [ComponentSprite] from its JSON representation.
  ///
  /// Missing or invalid values fall back to their defaults.
  factory fromJson(Object? json) {
    final map = json is Map ? json : const <String, dynamic>{};
    final image = map['image'];
    return ComponentSprite(
      image: image is String ? image : null,
      srcPosition: ComponentPosition.fromJson(map['srcPosition']),
      srcSize: ComponentSize.fromJson(map['srcSize']),
    );
  }

  /// Converts this sprite to its JSON representation.
  Map<String, dynamic> toJson() => {
    if (image != null) 'image': image,
    'srcPosition': srcPosition.toJson(),
    'srcSize': srcSize.toJson(),
  };

  @override
  List<Object?> get props => [image, srcPosition, srcSize];
}
