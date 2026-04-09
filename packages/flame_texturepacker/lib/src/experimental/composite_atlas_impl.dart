import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_texturepacker/flame_texturepacker.dart';
import 'package:flame_texturepacker/src/experimental/bake_analyzer.dart';
import 'package:flame_texturepacker/src/experimental/bake_request.dart';
import 'package:flame_texturepacker/src/experimental/composite_atlas.dart';
import 'package:flame_texturepacker/src/experimental/packers.dart';
// ignore_for_file: implementation_imports
import 'package:flame_texturepacker/src/model/page.dart';
import 'package:flame_texturepacker/src/model/region.dart';

class CompositeAtlasImpl extends CompositeAtlas {
  @override
  final ui.Image image;
  final Map<String, TexturePackerSprite> _internalSpriteMap;
  final Set<String> _prefixes;

  /// External access for tests
  Map<String, TexturePackerSprite> get spriteMap => _internalSpriteMap;

  CompositeAtlasImpl._(this.image, this._internalSpriteMap, this._prefixes)
    : super(_internalSpriteMap.values.toSet().toList());

  static CompositeAtlas fromAtlas(TexturePackerAtlas atlas) {
    if (atlas.sprites.isEmpty) {
      throw StateError('Cannot create CompositeAtlas from an empty atlas.');
    }
    final spriteMap = <String, TexturePackerSprite>{};
    for (final s in atlas.sprites) {
      final name = s.region.index == -1
          ? s.region.name
          : '${s.region.name}#${s.region.index}';
      spriteMap[name] = s;

      if (s.region.name != name) {
        spriteMap[s.region.name] = s;
      }
    }
    final firstImage = atlas.sprites.first.region.page.texture!;
    return CompositeAtlasImpl._(firstImage, spriteMap, {});
  }

  static Future<CompositeAtlas> bake(
    List<BakeRequest> requests, {
    double maxAtlasWidth = 1024.0,
    bool allowRotation = true,
    bool forceSquare = false,
    bool trim = true,
    Images? images,
  }) async {
    final groupedTasks = <RegionFilterKey, List<PendingBake>>{};
    final animationLengths = <String, int>{};
    final prefixes = <String>{};

    // 1. Pre-calculate animation lengths for proper indexing
    for (final request in requests) {
      if (request.keyPrefix != null) {
        prefixes.add(request.keyPrefix!);
      }
      if (request is AtlasBakeRequest) {
        for (final sprite in request.atlas.sprites) {
          var name = sprite.region.name;
          if (sprite.region.index == -1) {
            final match = RegExp(r'^(.+)_(\d+)$').firstMatch(name);
            if (match != null) {
              name = match.group(1)!;
            }
          }
          animationLengths[name] = (animationLengths[name] ?? 0) + 1;
        }
      }
    }

    // 2. Group by visual identity
    // (Image + Rect + Filter + Decorator + rotation)
    final localIndices = <String, int>{};
    for (final request in requests) {
      final prefix = request.keyPrefix ?? '';
      switch (request) {
        case ImageBakeRequest():
          final bakeKey = RegionFilterKey(
            request.image,
            ui.Rect.fromLTWH(
              0,
              0,
              request.image.width.toDouble(),
              request.image.height.toDouble(),
            ),
            request.filter,
            request.decorator,
            -1,
            1,
            0,
            0,
            request.image.width.toDouble(),
            request.image.height.toDouble(),
          );

          final pending = PendingBake(
            Sprite(request.image),
            prefix,
            request.nameTransformer != null
                ? request.nameTransformer!(request.name)
                : request.name,
            request.filter,
            request.decorator,
            -1,
            1,
            bakeKey,
          );

          groupedTasks.putIfAbsent(bakeKey, () => []).add(pending);
        case AtlasBakeRequest():
          for (final sprite in request.atlas.sprites) {
            final region = sprite.region;
            if (request.whiteList != null) {
              if (!request.whiteList!.any(
                (w) => region.name == w || region.name.startsWith(w),
              )) {
                continue;
              }
            }

            var name = request.nameTransformer != null
                ? request.nameTransformer!(region.name)
                : region.name;
            final originalName = region.name;
            var baseItemIndex = region.index;

            if (baseItemIndex == -1) {
              final match = RegExp(r'^(.+)_(\d+)$').firstMatch(name);
              if (match != null) {
                name = match.group(1)!;
                baseItemIndex = int.parse(match.group(2)!);
              }
            }

            final finalIndex = (baseItemIndex != -1)
                ? baseItemIndex
                : (animationLengths[name] == 1
                      ? -1
                      : (localIndices[name] ?? 0));
            localIndices[name] = (localIndices[name] ?? 0) + 1;

            final itemCount = animationLengths[name] ?? 1;

            final bakeKey = RegionFilterKey(
              sprite.image,
              sprite.src,
              request.filter,
              request.decorator,
              finalIndex,
              itemCount,
              region.offsetX,
              region.offsetY,
              region.originalWidth,
              region.originalHeight,
              rotate: region.rotate,
            );

            final pending = PendingBake(
              sprite,
              prefix,
              name,
              request.filter,
              request.decorator,
              finalIndex,
              itemCount,
              bakeKey,
              originalName: originalName,
            );

            groupedTasks.putIfAbsent(bakeKey, () => []).add(pending);
          }
        case SpriteBakeRequest():
          final sr = request.sourceRegion;
          final actualSprite = request.sprite;

          final double offsetX;
          final double offsetY;
          final double originalWidth;
          final double originalHeight;

          if (sr != null) {
            offsetX = (sr.originalWidth - sr.width) / 2.0;
            offsetY = (sr.originalHeight - sr.height) / 2.0;
            originalWidth = sr.originalWidth;
            originalHeight = sr.originalHeight;
          } else if (actualSprite is TexturePackerSprite) {
            final region = actualSprite.region;
            offsetX = region.offsetX;
            offsetY = region.offsetY;
            originalWidth = region.originalWidth;
            originalHeight = region.originalHeight;
          } else {
            offsetX = 0;
            offsetY = 0;
            originalWidth = actualSprite.src.width;
            originalHeight = actualSprite.src.height;
          }

          var name = request.name;
          final originalName = request.name;
          var itemIndex = -1;

          final match = RegExp(r'^(.+)_(\d+)$').firstMatch(name);
          if (match != null) {
            name = match.group(1)!;
            itemIndex = int.parse(match.group(2)!);
          }

          final srcRect = sr?.toRect() ?? actualSprite.src;

          final bakeKey = RegionFilterKey(
            actualSprite.image,
            srcRect,
            request.filter,
            request.decorator,
            itemIndex,
            1,
            offsetX,
            offsetY,
            originalWidth,
            originalHeight,
            rotate: sr?.rotate ?? false,
          );

          final pending = PendingBake(
            actualSprite,
            request.keyPrefix ?? '',
            request.nameTransformer != null
                ? request.nameTransformer!(name)
                : name,
            request.filter,
            request.decorator,
            itemIndex,
            1,
            bakeKey,
            originalName: originalName,
            sourceRegion: sr,
          );

          groupedTasks.putIfAbsent(bakeKey, () => []).add(pending);
      }
    }

    if (groupedTasks.isEmpty) {
      throw StateError('No bake requests found.');
    }

    // 3. Analyze & trim each unique slot (scan alpha, crop tight bounds)
    final keyToInfo = <RegionFilterKey, BakeInfo>{};
    final spritesToBake = <PendingBake>[];

    for (final entry in groupedTasks.entries) {
      final key = entry.key;
      final pending = entry.value;
      final template = pending.first.sprite;
      final decorator = key.decorator;

      final isRotated = key.rotate;
      final hasExplicitRegion = pending.first.sourceRegion != null;
      final isRawSprite = template is! TexturePackerSprite;

      // Decide whether to run alpha analysis (trim)
      // - If trim is enabled AND (explicit GDX region OR raw sprite), analyze
      // - For AtlasBakeRequest (TexturePackerSprite), GDX already trimmed,
      //   so we use the source data directly unless a decorator is present
      final needsAlphaAnalysis =
          trim && (hasExplicitRegion || isRawSprite || decorator != null);

      BakeInfo info;

      // GDX atlas sources: use original trimmed bounds and offsets directly.
      // No alpha re-scanning needed — GDX already did optimal trimming.
      final isGdxSource = template is TexturePackerSprite && !hasExplicitRegion;

      if (isGdxSource && decorator == null) {
        // Use GDX metadata as-is, but with visual (un-rotated) dimensions
        // for packing. GDX stores rotated sprites with swapped w/h in src,
        // so the visual size is src.height × src.width.
        final visualW = isRotated ? key.src.height : key.src.width;
        final visualH = isRotated ? key.src.width : key.src.height;

        info = BakeInfo(
          key.src, // trimmed bounds from GDX (may be rotated)
          key.offsetX, // original GDX offset X
          key.offsetY, // original GDX offset Y
          key.originalWidth,
          key.originalHeight,
          rotate: isRotated,
          effectiveWidth: visualW,
          effectiveHeight: visualH,
        );
        // No bakedImage needed — we'll draw directly from the source atlas
      } else if (needsAlphaAnalysis) {
        // Use SpriteBakeInfo.analyze to scan alpha and crop
        final bakeInfo = await SpriteBakeInfo.analyze(
          key: key,
          sprite: template,
          filter: key.filter,
          decorator: key.decorator,
          prefix: pending.first.prefix,
          name: pending.first.name,
          itemIndex: key.itemIndex,
          itemCount: key.itemCount,
          sourceRegion: pending.first.sourceRegion,
        );

        final isSpritesheet = pending.first.sourceRegion != null;

        if (isSpritesheet) {
          // For spritesheets: pack at original frame size to avoid scaling.
          // Create a full-frame image with content positioned at the correct
          // offset.
          final ow = bakeInfo.originalWidth;
          final oh = bakeInfo.originalHeight;
          final recorder = ui.PictureRecorder();
          final canvas = ui.Canvas(recorder);
          canvas.drawImageRect(
            bakeInfo.bakedImage ?? template.image,
            bakeInfo.trimmedSrc,
            ui.Rect.fromLTWH(
              bakeInfo.offsetX,
              bakeInfo.offsetY,
              bakeInfo.trimmedSrc.width,
              bakeInfo.trimmedSrc.height,
            ),
            ui.Paint()..filterQuality = ui.FilterQuality.none,
          );
          final fullFrame = await recorder.endRecording().toImage(
            ow.ceil(),
            oh.ceil(),
          );

          info = BakeInfo(
            ui.Rect.fromLTWH(0, 0, ow, oh),
            0, // offset is 0 since content is already positioned
            0,
            ow,
            oh,
            rotate: isRotated,
            effectiveWidth: ow,
            effectiveHeight: oh,
          );
          info.bakedImage = fullFrame;
        } else {
          // For non-spritesheets: pack at trimmed size with offsets (GDX-style)
          info = BakeInfo(
            bakeInfo.trimmedSrc,
            bakeInfo.offsetX,
            bakeInfo.offsetY,
            bakeInfo.originalWidth,
            bakeInfo.originalHeight,
            rotate: isRotated,
            effectiveWidth: bakeInfo.trimmedSrc.width,
            effectiveHeight: bakeInfo.trimmedSrc.height,
          );
          info.bakedImage = bakeInfo.bakedImage;
        }
      } else {
        // Fallback: use sprite's src rect directly (no trim, no GDX metadata)
        info = BakeInfo(
          template.src,
          0,
          0,
          template.src.width,
          template.src.height,
          rotate: isRotated,
          effectiveWidth: template.src.width,
          effectiveHeight: template.src.height,
        );
      }

      keyToInfo[key] = info;
      spritesToBake.addAll(pending);
    }

    // 3.5. Deduplicate sprites with identical visual content
    // Compare actual pixel data from the source image, not just metadata.
    Future<String> computePixelHash(
      RegionFilterKey key,
      PendingBake pending,
    ) async {
      final info = keyToInfo[key]!;
      final sw = key.src.width.toInt();
      final sh = key.src.height.toInt();

      final ew = (info.effectiveWidth ?? sw).toInt();
      final eh = (info.effectiveHeight ?? sh).toInt();
      final ox = info.offsetX.toInt();
      final oy = info.offsetY.toInt();
      final ow = info.originalWidth.toInt();
      final oh = info.originalHeight.toInt();
      final rot = info.rotate ? 1 : 0;
      final metaSig = '${ew}_${eh}_${ox}_${oy}_${ow}_${oh}_${rot}_${sw}_$sh';

      // Pixel-level hash
      var pixelHash = 0;
      final targetImg = info.bakedImage ?? key.image;
      final targetRect = info.bakedImage != null ? info.trimmedSrc : key.src;

      final byteData = await targetImg.toByteData();
      if (byteData != null) {
        final buffer = byteData.buffer.asUint8List();
        final tw = targetImg.width;
        final tx = targetRect.left.toInt();
        final ty = targetRect.top.toInt();
        final tW = targetRect.width.toInt();
        final tH = targetRect.height.toInt();

        for (var y = 0; y < tH; y++) {
          for (var x = 0; x < tW; x++) {
            final idx = ((ty + y) * tw + (tx + x)) * 4;
            final r = buffer[idx];
            final g = buffer[idx + 1];
            final b = buffer[idx + 2];
            final a = buffer[idx + 3];
            pixelHash = (pixelHash * 31 + r) ^ (g * 37) ^ (b * 41) ^ (a * 43);
          }
        }
      }
      return '${metaSig}_ph${pixelHash}_img${targetImg.hashCode}';
    }

    // Build a map: bakeKey → first pending for that key
    final keyToPending = <RegionFilterKey, PendingBake>{};
    for (final pending in spritesToBake) {
      if (!keyToPending.containsKey(pending.bakeKey)) {
        keyToPending[pending.bakeKey] = pending;
      }
    }

    // Compute signatures for all keys
    final keySigs = <RegionFilterKey, String>{};
    for (final key in keyToInfo.keys) {
      keySigs[key] = await computePixelHash(key, keyToPending[key]!);
    }

    // Group duplicates
    final dedupMap = <RegionFilterKey, RegionFilterKey>{};
    final masterKeys = <RegionFilterKey>{};
    for (final key in keyToInfo.keys) {
      final sig = keySigs[key]!;
      final existing = masterKeys.where((m) => keySigs[m] == sig).firstOrNull;
      if (existing != null) {
        dedupMap[key] = existing;
      } else {
        masterKeys.add(key);
      }
    }

    // 4. Sort sprites for better packing density
    final sortedKeys = masterKeys.toList();
    if (allowRotation) {
      // For rotation: sort by shortest side (descending)
      // — better for mixed sizes
      sortedKeys.sort((a, b) {
        final infoA = keyToInfo[a]!;
        final infoB = keyToInfo[b]!;
        final shortA = math.min(
          infoA.effectiveWidth ?? infoA.trimmedSrc.width,
          infoA.effectiveHeight ?? infoA.trimmedSrc.height,
        );
        final shortB = math.min(
          infoB.effectiveWidth ?? infoB.trimmedSrc.height,
          infoB.effectiveHeight ?? infoB.trimmedSrc.height,
        );
        return shortB.compareTo(shortA);
      });
    } else {
      // Without rotation: sort by height (descending) — shelf packing
      sortedKeys.sort((a, b) {
        final infoA = keyToInfo[a]!;
        final infoB = keyToInfo[b]!;
        final hA = infoA.effectiveHeight ?? infoA.trimmedSrc.height;
        final hB = infoB.effectiveHeight ?? infoB.trimmedSrc.height;
        return hB.compareTo(hA);
      });
    }

    const padding = 2.0;

    // Calculate initial atlas size
    var maxSpriteDim = 64.0;
    double totalArea = 0;
    for (final key in sortedKeys) {
      final info = keyToInfo[key]!;
      final w = (info.effectiveWidth ?? info.trimmedSrc.width) + padding;
      final h = (info.effectiveHeight ?? info.trimmedSrc.height) + padding;
      maxSpriteDim = math.max(maxSpriteDim, math.max(w, h));
      totalArea += w * h;
    }

    final areaSide = math.sqrt(totalArea);
    double initialSide = math.max(maxSpriteDim, areaSide);
    initialSide = _nextPow2(initialSide.ceil()).toDouble();
    initialSide = math.max(initialSide, 64.0);

    final AtlasPacker packer = GuillotinePacker(initialSide);

    // 5. Pack all sprites
    final drawingPositions = <RegionFilterKey, ui.Offset>{};

    for (final key in sortedKeys) {
      final info = keyToInfo[key]!;
      final w = (info.effectiveWidth ?? info.trimmedSrc.width) + padding;
      final h = (info.effectiveHeight ?? info.trimmedSrc.height) + padding;

      var result = packer.pack(w, h, allowRotation: allowRotation);

      var growAttempts = 0;
      while (result == null && growAttempts < 20) {
        packer.growToFit(w, h, allowRotation: allowRotation);
        if (packer is GuillotinePacker) {
          packer.mergeFreeRects();
        }
        result = packer.pack(w, h, allowRotation: allowRotation);
        growAttempts++;
      }

      if (result == null) {
        continue;
      }

      drawingPositions[key] = result.offset;
      info.rotate = result.rotated;
    }

    // 6. Calculate actual bounds and round up to power-of-two
    double actualMaxY = 0;
    double actualMaxX = 0;
    for (final key in sortedKeys) {
      final pos = drawingPositions[key]!;
      final info = keyToInfo[key]!;
      final visualW = info.effectiveWidth ?? info.trimmedSrc.width;
      final visualH = info.effectiveHeight ?? info.trimmedSrc.height;
      final sheetW = info.rotate ? visualH : visualW;
      final sheetH = info.rotate ? visualW : visualH;

      actualMaxY = math.max(actualMaxY, pos.dy + sheetH + padding);
      actualMaxX = math.max(actualMaxX, pos.dx + sheetW + padding);
    }

    final texWidth = _nextPow2(actualMaxX.ceil());
    final texHeight = _nextPow2(actualMaxY.ceil());

    // 6. Render the final atlas
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final basePaint = ui.Paint()..filterQuality = ui.FilterQuality.none;

    for (final key in masterKeys) {
      final pos = drawingPositions[key]!;
      final info = keyToInfo[key]!;

      canvas.save();
      canvas.translate(pos.dx, pos.dy);

      final visualW = info.effectiveWidth ?? info.trimmedSrc.width;
      final visualH = info.effectiveHeight ?? info.trimmedSrc.height;

      if (info.rotate) {
        canvas.translate(0, visualW);
        canvas.rotate(-math.pi / 2);
      }

      final dst = ui.Rect.fromLTWH(0, 0, visualW, visualH);

      if (info.bakedImage != null) {
        canvas.drawImageRect(
          info.bakedImage!,
          info.trimmedSrc,
          dst,
          basePaint,
        );
      } else {
        if (key.rotate) {
          final unrotW = key.src.height;
          final unrotH = key.src.width;
          final unrotRecorder = ui.PictureRecorder();
          final unrotCanvas = ui.Canvas(unrotRecorder);
          unrotCanvas.translate(unrotW, 0);
          unrotCanvas.rotate(math.pi / 2);
          unrotCanvas.drawImageRect(
            key.image,
            key.src,
            ui.Rect.fromLTWH(0, 0, key.src.width, key.src.height),
            basePaint,
          );
          final unrotated = await unrotRecorder.endRecording().toImage(
            unrotW.ceil(),
            unrotH.ceil(),
          );

          canvas.drawImageRect(
            unrotated,
            ui.Rect.fromLTWH(0, 0, unrotW, unrotH),
            ui.Rect.fromLTWH(0, 0, unrotW, unrotH),
            basePaint,
          );
          unrotated.dispose();
        } else {
          canvas.drawImageRect(key.image, info.trimmedSrc, dst, basePaint);
        }
      }
      canvas.restore();
    }

    final megaImage = await recorder.endRecording().toImage(
      texWidth,
      texHeight,
    );

    for (final info in keyToInfo.values) {
      info.bakedImage?.dispose();
    }

    // 7. Build sprite map with GDX-compatible metadata
    final spriteMap = <String, TexturePackerSprite>{};
    final megaPage = Page()
      ..texture = megaImage
      ..width = megaImage.width
      ..height = megaImage.height;

    for (final pending in spritesToBake) {
      final effectiveKey = dedupMap[pending.bakeKey] ?? pending.bakeKey;
      final pos = drawingPositions[effectiveKey]!;
      final bakeInfo = keyToInfo[effectiveKey]!;

      final newRegion = Region(
        page: megaPage,
        name: '${pending.prefix}${pending.name}',
        left: pos.dx,
        top: pos.dy,
        width: bakeInfo.effectiveWidth ?? bakeInfo.trimmedSrc.width,
        height: bakeInfo.effectiveHeight ?? bakeInfo.trimmedSrc.height,
        offsetX: bakeInfo.offsetX,
        offsetY: bakeInfo.offsetY,
        originalWidth: bakeInfo.originalWidth,
        originalHeight: bakeInfo.originalHeight,
        rotate: bakeInfo.rotate,
        index:
            (pending.itemCount == 1 &&
                (pending.itemIndex == null || pending.itemIndex == -1) &&
                (pending.sprite is! TexturePackerSprite ||
                    (pending.sprite as TexturePackerSprite).region.index == -1))
            ? -1
            : (pending.itemIndex ?? -1),
      );

      final newSprite = TexturePackerSprite(newRegion);
      newSprite.srcSize = newSprite.originalSize;

      final primaryKey = newRegion.index == -1
          ? newRegion.name
          : '${newRegion.name}#${newRegion.index}';
      spriteMap[primaryKey] = newSprite;

      if (pending.originalName != null) {
        final prefOrig = '${pending.prefix}${pending.originalName}';
        if (prefOrig != primaryKey && prefOrig != newRegion.name) {
          spriteMap[prefOrig] = newSprite;
        }
      }
    }

    return CompositeAtlasImpl._(megaImage, spriteMap, prefixes);
  }

  @override
  List<String> get allSpriteNames => _internalSpriteMap.keys.toList();

  @override
  TexturePackerSprite? findSpriteByName(String name) {
    if (_internalSpriteMap.containsKey(name)) {
      return _internalSpriteMap[name];
    }

    for (final prefix in _prefixes) {
      final combined = '$prefix$name';
      if (_internalSpriteMap.containsKey(combined)) {
        return _internalSpriteMap[combined];
      }
    }

    final lookupNames = <String>{name, ..._prefixes.map((p) => '$p$name')};
    for (final lookup in lookupNames) {
      final indexedKey = '$lookup#0';
      if (_internalSpriteMap.containsKey(indexedKey)) {
        return _internalSpriteMap[indexedKey];
      }
    }

    return super.findSpriteByName(name);
  }

  @override
  List<TexturePackerSprite> findSpritesByName(String name) {
    final results = super.findSpritesByName(name);
    if (results.isNotEmpty) {
      return results.cast<TexturePackerSprite>().toList();
    }

    for (final prefix in _prefixes) {
      final combined = '$prefix$name';
      final prefixedResults = super.findSpritesByName(combined);
      if (prefixedResults.isNotEmpty) {
        return prefixedResults.cast<TexturePackerSprite>().toList();
      }
    }

    final found = <TexturePackerSprite>{};
    final lookupNames = <String>{name, ..._prefixes.map((p) => '$p$name')};

    for (final lookup in lookupNames) {
      if (_internalSpriteMap.containsKey(lookup)) {
        found.add(_internalSpriteMap[lookup]!);
      }

      final indexedPattern = RegExp('^${RegExp.escape(lookup)}#(\\d+)\$');
      for (final key in _internalSpriteMap.keys) {
        if (indexedPattern.hasMatch(key)) {
          found.add(_internalSpriteMap[key]!);
        }
      }

      if (found.isNotEmpty) {
        break;
      }
    }

    final casted = found.toList();

    casted.sort((a, b) => a.region.index.compareTo(b.region.index));
    return casted;
  }

  @override
  SpriteAnimation getAnimation(
    String name, {
    double stepTime = 0.1,
    bool loop = true,
    bool useIndexedSpritesOnly = false,
  }) {
    final animationSprites = findSpritesByName(name);
    if (animationSprites.isEmpty) {
      throw Exception('No sprites found with name "$name" in atlas');
    }

    var filtered = animationSprites;
    if (useIndexedSpritesOnly) {
      filtered = animationSprites.where((s) => s.region.index >= 0).toList();
      if (filtered.isEmpty) {
        filtered = animationSprites;
      }
    }

    return SpriteAnimation.spriteList(filtered, stepTime: stepTime, loop: loop);
  }

  @override
  void dispose() => image.dispose();

  @override
  String generateGDXAtlasContent(String imageName) {
    final sb = StringBuffer();
    sb.writeln(imageName);
    sb.writeln('size:${image.width},${image.height}');
    sb.writeln('filter:Nearest,Nearest');
    sb.writeln('repeat:none');

    final sortedSprites =
        List<TexturePackerSprite>.from(sprites.cast<TexturePackerSprite>())
          ..sort((a, b) {
            final nameComp = a.region.name.compareTo(b.region.name);
            if (nameComp != 0) {
              return nameComp;
            }
            return a.region.index.compareTo(b.region.index);
          });

    for (final sprite in sortedSprites) {
      final r = sprite.region;
      sb.writeln(r.name);
      sb.writeln('index:${r.index}');
      sb.writeln(
        'bounds:${r.left.toInt()},${r.top.toInt()},'
        '${r.width.toInt()},${r.height.toInt()}',
      );
      sb.writeln(
        'offsets:${r.offsetX.toInt()},${r.offsetY.toInt()},'
        '${r.originalWidth.toInt()},${r.originalHeight.toInt()}',
      );
    }

    return sb.toString();
  }

  static int _nextPow2(int value) {
    if (value <= 64) {
      return 64;
    }
    var pot = 64;
    while (pot < value) {
      pot <<= 1;
    }
    return pot;
  }
}
