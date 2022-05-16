library flame_fire_atlas;

import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:flame/cache.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

/// Adds FireAtlas loading methods to Flame [Game].
extension FireAtlasExtensions on Game {
  /// Load a [FireAtlas] instances from the given [asset]
  Future<FireAtlas> loadFireAtlas(String asset) async {
    return FireAtlas.loadAsset(
      asset,
      assets: assets,
      images: images,
    );
  }
}

/// {@template _selection}
/// Represents the basic information of a selection inside a fire atlas file,
/// containing its [id] and its coordinates and dimensions.
/// {@endtemplate}
class Selection {
  /// The id of the selection.
  String id;

  /// The horizontal coordinate of the selection.
  int x;

  /// The vertical coordinate of the selection.
  int y;

  /// The width of the selection.
  int w;

  /// The height of the selection.
  int h;

  /// {@macro _selection}
  Selection({
    required this.id,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  /// Creates a [Selection] from [json].
  factory Selection.fromJson(Map<String, dynamic> json) {
    return Selection(
      id: json['id'] as String,
      x: json['x'] as int,
      y: json['y'] as int,
      w: json['w'] as int,
      h: json['h'] as int,
    );
  }
}

/// {@template _base_selection}
/// Base class for all FireAtlas selections, containing information for a
/// section of the image.
///
/// Check [SpriteSelection] for [Sprite] based selections, and
/// [AnimationSelection] for [SpriteAnimation] based selections.
/// {@endtemplate}
abstract class BaseSelection {
  final Selection _info;

  /// {@macro _base_selection}
  BaseSelection(this._info);

  /// The id of the selection.
  String get id => _info.id;

  /// The horizontal coordinate of the selection.
  int get x => _info.x;

  /// The vertical coordinate of the selection.
  int get y => _info.y;

  /// The width of the selection.
  int get w => _info.w;

  /// The height of the selection.
  int get h => _info.h;

  /// Returns this instance as a json.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{}
      ..['id'] = id
      ..['x'] = x
      ..['y'] = y
      ..['w'] = w
      ..['h'] = h;

    return json;
  }
}

/// {@template _sprite_selection}
/// Represents a specific selection of Flame [Sprite]s.
/// {@endtemplate}
class SpriteSelection extends BaseSelection {
  /// {@macro _sprite_selection}
  SpriteSelection({
    required Selection info,
  }) : super(info);

  /// Creates a [SpriteSelection] from [json].
  @override
  factory SpriteSelection.fromJson(Map<String, dynamic> json) {
    final info = Selection.fromJson(json);
    return SpriteSelection(info: info);
  }

  /// Returns this instance as a json.
  @override
  Map<String, dynamic> toJson() {
    return super.toJson()..['type'] = 'sprite';
  }
}

/// {@template _animation_selection}
/// Represents a specific selection of Flame [Sprite]s as an animation.
/// {@endtemplate}
class AnimationSelection extends BaseSelection {
  /// The number of frames of this animation.
  int frameCount;

  /// The time between each frame.
  double stepTime;

  /// If the animation is looping or not.
  bool loop;

  /// {@macro _animation_selection}
  AnimationSelection({
    required Selection info,
    required this.frameCount,
    required this.stepTime,
    required this.loop,
  }) : super(info);

  /// Creates a [AnimationSelection] from [json].
  @override
  factory AnimationSelection.fromJson(Map<String, dynamic> json) {
    final info = Selection.fromJson(json);

    return AnimationSelection(
      info: info,
      frameCount: json['frameCount'] as int,
      stepTime: json['stepTime'] as double,
      loop: json['loop'] as bool,
    );
  }

  /// Returns this instance as json.
  @override
  Map<String, dynamic> toJson() {
    return super.toJson()
      ..['frameCount'] = frameCount
      ..['stepTime'] = stepTime
      ..['loop'] = loop
      ..['type'] = 'animation';
  }
}

/// FireAtlas is a mapping file that can hold several [Sprite]s and
/// [SpriteAnimation]s.
///
/// Use [getSprite] and [getAnimation] to retrieve mapped assets.
class FireAtlas {
  /// Id of the FireAtlas, mainly used by the Fire Atlas Editor for file
  /// identification.
  String id;

  /// The width of the tile.
  double tileWidth;

  /// The height of the tile.
  double tileHeight;

  /// Stores the asset data once this instance has loaded.
  String? imageData;
  Image? _image;

  /// Creates a FireAtlas instance.
  ///
  /// This constructor is often used internally; to load a FireAtlas instance
  /// into you game, check [loadAsset].
  FireAtlas({
    required this.id,
    required this.tileWidth,
    required this.tileHeight,
    required this.imageData,
  });

  /// Holds all the selections of this file.
  Map<String, BaseSelection> selections = {};

  /// Loads the atlas image into memory so it can be used, this method
  /// is used internally by [loadAsset], prefer that method unless
  /// there is a very specific use case for it.
  ///
  /// [clearImageData] Can be set to false to avoid clearing the stored
  /// information about the image on this object, this is true by default, its
  /// use is intended to enable serializing this object
  /// [images] The images cache to be used, falls back to [Flame.images] when
  /// omitted.
  ///
  Future<void> loadImage({bool clearImageData = true, Images? images}) async {
    if (imageData == null) {
      throw 'Attempting on calling load on an already loaded Image';
    }
    final _images = images ?? Flame.images;
    _image = await _images.fromBase64(id, imageData!);

    // Clear memory
    if (clearImageData) {
      imageData = null;
    }
  }

  /// Serializes the mappings on this Atlas in a json format.
  Map<String, dynamic> toJson() {
    final selectionsJson = <String, dynamic>{};
    selections.entries.forEach((entry) {
      selectionsJson[entry.key] = entry.value.toJson();
    });

    final json = <String, dynamic>{}
      ..['id'] = id
      ..['imageData'] = imageData
      ..['selections'] = selectionsJson
      ..['tileWidth'] = tileWidth.toDouble()
      ..['tileHeight'] = tileHeight.toDouble();

    return json;
  }

  static FireAtlas _fromJson(Map<String, dynamic> json) {
    final tileHeight = json['tileHeight'] as num?;
    final tileWidth = json['tileWidth'] as num?;
    final tileSize = json['tileSize'] as num? ?? 0;

    final atlas = FireAtlas(
      id: json['id'] as String,
      imageData: json['imageData'] as String?,
      tileHeight: (tileHeight ?? tileSize).toDouble(),
      tileWidth: (tileWidth ?? tileSize).toDouble(),
    );

    final selections = json['selections'] as Map<String, dynamic>;
    selections.entries.forEach((entry) {
      final value = entry.value as Map<String, dynamic>;
      final selection = value['type'] == 'animation'
          ? AnimationSelection.fromJson(value)
          : SpriteSelection.fromJson(value);

      atlas.selections[entry.key] = selection;
    });

    return atlas;
  }

  /// Loads the [FireAtlas] from an asset.
  static Future<FireAtlas> loadAsset(
    String fileName, {
    AssetsCache? assets,
    Images? images,
  }) async {
    final _assets = assets ?? Flame.assets;

    final bytes = await _assets.readBinaryFile(fileName);
    final atlas = FireAtlas.deserialize(bytes);
    await atlas.loadImage(images: images);
    return atlas;
  }

  /// Serializes this instances into a byte array.
  List<int> serialize() {
    final raw = jsonEncode(toJson());

    final stringBytes = utf8.encode(raw);
    final gzipBytes = GZipEncoder().encode(stringBytes);

    if (gzipBytes == null) {
      throw 'Generated an empty file';
    }
    return gzipBytes;
  }

  /// Reads a [FireAtlas] instance from a byte array.
  static FireAtlas deserialize(List<int> bytes) {
    final unzippedBytes = GZipDecoder().decodeBytes(bytes);
    final unzippedString = utf8.decode(unzippedBytes);
    return _fromJson(jsonDecode(unzippedString) as Map<String, dynamic>);
  }

  Image _assertImageLoaded() {
    if (_image == null) {
      throw 'Atlas is not loaded yet, call "load" before using it';
    }

    return _image!;
  }

  /// Returns a Sprite with the given [selectionId].
  Sprite getSprite(String selectionId) {
    final selection = selections[selectionId];

    if (selection == null) {
      throw 'There is no selection with the id "$selectionId" on this atlas';
    }

    if (selection is! SpriteSelection) {
      throw 'Selection "$selectionId" is not a Sprite';
    }

    final image = _assertImageLoaded();

    return Sprite(
      image,
      srcPosition: Vector2(
        selection.x.toDouble() * tileWidth,
        selection.y.toDouble() * tileHeight,
      ),
      srcSize: Vector2(
        (1 + selection.w.toDouble()) * tileWidth,
        (1 + selection.h.toDouble()) * tileHeight,
      ),
    );
  }

  /// Returns a SpriteAnimation with the given [selectionId].
  SpriteAnimation getAnimation(String selectionId) {
    final selection = selections[selectionId];

    final image = _assertImageLoaded();

    if (selection == null) {
      throw 'There is no selection with the id "$selectionId" on this atlas';
    }
    if (selection is! AnimationSelection) {
      throw 'Selection "$selectionId" is not an Animation';
    }

    final initialX = selection.x.toDouble();

    final frameSize = (1 + selection.w.toDouble()) / selection.frameCount;

    final width = frameSize * tileWidth;
    final height = (1 + selection.h.toDouble()) * tileHeight;

    final sprites = List.generate(selection.frameCount, (i) {
      final x = (initialX + i) * frameSize;
      return Sprite(
        image,
        srcPosition: Vector2(
          x * tileWidth,
          selection.y.toDouble() * tileHeight,
        ),
        srcSize: Vector2(width, height),
      );
    });

    return SpriteAnimation.spriteList(
      sprites,
      stepTime: selection.stepTime,
      loop: selection.loop,
    );
  }
}
