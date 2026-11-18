import 'dart:convert';
import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flame/flame.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d/src/resources/texture/mipmaps.dart';

// cSpell:ignore usemtl newmtl mtllib TEXCOORD CUBICSPLINE

/// Reference-counted GPU asset container for [Model]s, [Mesh]es, [Surface]s,
/// and [Texture]s.
///
/// Releasing the last reference to an asset (or calling [disposeAll]) calls
/// [Resource.dispose] on all owned [Surface] vertex/index buffers and
/// [Texture] handles (while preserving shared static singletons
/// [Texture.standard] and [Texture.empty]).
class AssetScope3D() {
  final Map<Object, int> _assetRefCounts = {};
  final Map<Resource<Object?>, int> _leafRefCounts = {};

  /// Number of top-level assets currently retained in this scope.
  int get retainedAssetCount => _assetRefCounts.length;

  /// Number of unique underlying GPU [Resource]s (`Surface`s and `Texture`s)
  /// currently tracked by this scope.
  int get trackedResourceCount => _leafRefCounts.length;

  /// Current reference count for [asset] (`0` if not retained).
  int refCountOf(Object asset) => _assetRefCounts[asset] ?? 0;

  /// Increments the reference count of [asset] (`Model`, `Mesh`, `Surface`,
  /// `Texture`, or arbitrary owner handle) and returns [asset].
  T retain<T extends Object>(T asset) {
    final prev = _assetRefCounts[asset] ?? 0;
    _assetRefCounts[asset] = prev + 1;
    if (prev == 0) {
      for (final res in _collectOwnedResources(asset)) {
        _leafRefCounts[res] = (_leafRefCounts[res] ?? 0) + 1;
      }
    }
    return asset;
  }

  /// Decrements the reference count of [asset]. When it reaches `0`, any owned
  /// [Surface]s and [Texture]s not shared with another retained asset are
  /// disposed via [Resource.dispose], and `true` is returned.
  bool release(Object asset) {
    final current = _assetRefCounts[asset];
    if (current == null || current <= 0) {
      return false;
    }
    if (current > 1) {
      _assetRefCounts[asset] = current - 1;
      return false;
    }
    _assetRefCounts.remove(asset);
    for (final res in _collectOwnedResources(asset)) {
      final leafCount = _leafRefCounts[res] ?? 0;
      if (leafCount <= 1) {
        _leafRefCounts.remove(res);
        res.dispose();
      } else {
        _leafRefCounts[res] = leafCount - 1;
      }
    }
    if (asset is Mesh) {
      asset.dispose();
    }
    return true;
  }

  /// Disposes every tracked [Surface], [Texture], and [Mesh] in this scope and
  /// resets all reference counts to `0`.
  void disposeAll() {
    for (final res in _leafRefCounts.keys) {
      res.dispose();
    }
    for (final asset in _assetRefCounts.keys) {
      if (asset is Mesh) {
        asset.dispose();
      } else if (asset is Model) {
        for (final node in asset.nodes.values) {
          node.mesh?.dispose();
        }
      }
    }
    _leafRefCounts.clear();
    _assetRefCounts.clear();
  }

  static Set<Resource<Object?>> _collectOwnedResources(Object asset) {
    final out = <Resource<Object?>>{};

    void addTexture(Texture? tex) {
      if (tex == null ||
          identical(tex, Texture.standard) ||
          identical(tex, Texture.empty)) {
        return;
      }
      out.add(tex);
    }

    void addSurface(Surface surface) {
      out.add(surface);
      final mat = surface.material;
      if (mat is SpatialMaterial) {
        addTexture(mat.albedoTexture);
        addTexture(mat.normalTexture);
        addTexture(mat.metallicRoughnessTexture);
        addTexture(mat.occlusionTexture);
        addTexture(mat.emissiveTexture);
        addTexture(mat.environmentTexture);
      } else if (mat is UnlitMaterial) {
        addTexture(mat.albedoTexture);
      }
    }

    if (asset is Texture) {
      addTexture(asset);
    } else if (asset is Surface) {
      addSurface(asset);
    } else if (asset is Mesh) {
      for (final s in asset.surfaces) {
        addSurface(s);
      }
    } else if (asset is Model) {
      for (final node in asset.nodes.values) {
        final mesh = node.mesh;
        if (mesh != null) {
          for (final s in mesh.surfaces) {
            addSurface(s);
          }
        }
      }
    }
    return out;
  }
}

/// Flat median-split Bounding Volume Hierarchy buffers prepared on a background
/// isolate by [AsyncModelLoader3D.buildSurfaceBvhsInIsolate].
class PreparedSurfaceBvh3D({
  required final int surfaceIndex,
  required final int nodeCount,
  required final int triangleCount,
  required final Float32List bounds,
  required final Int32List leftOrFirst,
  required final Int32List rightChild,
  required final Int32List counts,
  required final Int32List triangles,
});

/// Pure-CPU background isolate asset streamer (`Isolate.run` +
/// [TransferableTypedData]) for `.glb`, `.obj`, mipmap chains, and
/// [SurfaceBvh] acceleration structures.
abstract final class AsyncModelLoader3D() {
  static const int _standardStride = 20;
  static const int _maxJointsPerSurface = 64;

  /// Loads a `.glb` asset via `Flame.assets` and prepares all geometry,
  /// skinning, morph targets, and animations on a background isolate.
  static Future<Model> loadGlbAssetAsync(
    String filePath, {
    bool buildBvhs = true,
    AssetScope3D? scope,
  }) async {
    final bytes = await Flame.assets.readBinaryFile(filePath);
    final slash = filePath.lastIndexOf('/');
    final prefix = slash >= 0 ? filePath.substring(0, slash + 1) : '';
    return await parseGlbBytesAsync(
      bytes,
      prefix: prefix,
      buildBvhs: buildBvhs,
      scope: scope,
    );
  }

  /// Parses raw `.glb` [bytes] inside a background isolate using zero-copy
  /// [TransferableTypedData] buffers, decodes any embedded textures, and
  /// returns a ready-to-render [Model].
  static Future<Model> parseGlbBytesAsync(
    Uint8List bytes, {
    String prefix = '',
    bool buildBvhs = true,
    AssetScope3D? scope,
  }) async {
    final inputTransfer = TransferableTypedData.fromList([bytes]);
    final prepared = await Isolate.run(
      () => _prepareGlbInIsolate(inputTransfer, prefix),
    );
    final model = await _materializePreparedGlb(
      prepared,
      buildBvhs: buildBvhs,
    );
    scope?.retain(model);
    return model;
  }

  /// Parses Wavefront `.obj` UTF-8 [bytes] inside a background isolate into
  /// packed `VertexLayout.standard` buffers and returns a [Model].
  static Future<Model> parseObjBytesAsync(
    Uint8List bytes, {
    Map<String, String> mtlSources = const {},
    bool buildBvhs = true,
    AssetScope3D? scope,
  }) async {
    final inputTransfer = TransferableTypedData.fromList([bytes]);
    final prepared = await Isolate.run(() {
      final text = utf8.decode(inputTransfer.materialize().asUint8List());
      return _prepareObjInIsolate(text, mtlSources);
    });
    final model = _materializePreparedObj(prepared, buildBvhs: buildBvhs);
    scope?.retain(model);
    return model;
  }

  /// Parses Wavefront `.obj` source text inside a background isolate into
  /// packed `VertexLayout.standard` buffers and returns a [Model].
  static Future<Model> parseObjStringInIsolate(
    String objSource, {
    Map<String, String> mtlSources = const {},
    bool buildBvhs = true,
    AssetScope3D? scope,
  }) async {
    final prepared = await Isolate.run(
      () => _prepareObjInIsolate(objSource, mtlSources),
    );
    final model = _materializePreparedObj(prepared, buildBvhs: buildBvhs);
    scope?.retain(model);
    return model;
  }

  /// Builds flat median-split triangle BVHs for every [Surface] in [model] on a
  /// background isolate using [TransferableTypedData], warms `surface.bvh`, and
  /// returns the prepared BVH payloads.
  static Future<List<PreparedSurfaceBvh3D>> buildSurfaceBvhsInIsolate(
    Model model, {
    int maxLeafTriangles = 4,
  }) async {
    if (maxLeafTriangles < 1) {
      throw ArgumentError.value(
        maxLeafTriangles,
        'maxLeafTriangles',
        'Must be >= 1',
      );
    }
    final surfaces = <Surface>[];
    final seen = <Surface>{};
    for (final node in model.nodes.values) {
      final mesh = node.mesh;
      if (mesh == null) {
        continue;
      }
      for (final s in mesh.surfaces) {
        if (seen.add(s)) {
          surfaces.add(s);
        }
      }
    }
    if (surfaces.isEmpty) {
      return const [];
    }

    final inputs = <_BvhSurfaceInput>[];
    for (var i = 0; i < surfaces.length; i++) {
      final s = surfaces[i];
      final posOffset = s.layout.offsetOf(VertexLayout.positionAttribute) ?? 0;
      final idxList = s.indices;
      final isWide = idxList is Uint32List;
      final idxBytes = isWide
          ? idxList.buffer.asUint8List(
              idxList.offsetInBytes,
              idxList.lengthInBytes,
            )
          : (idxList as Uint16List).buffer.asUint8List(
              idxList.offsetInBytes,
              idxList.lengthInBytes,
            );
      final vertBytes = s.vertexData.buffer.asUint8List(
        s.vertexData.offsetInBytes,
        s.vertexData.lengthInBytes,
      );
      inputs.add(
        _BvhSurfaceInput(
          surfaceIndex: i,
          stride: s.layout.strideInFloats,
          posOffset: posOffset,
          wideIndices: isWide,
          vertices: TransferableTypedData.fromList([vertBytes]),
          indices: TransferableTypedData.fromList([idxBytes]),
        ),
      );
    }

    final rawOutputs = await Isolate.run(
      () => _buildBvhsWorker(inputs, maxLeafTriangles),
    );

    final results = <PreparedSurfaceBvh3D>[];
    for (var i = 0; i < rawOutputs.length; i++) {
      final r = rawOutputs[i];
      // Warm cached `surface.bvh` on the owning Surface for raycast parity.
      surfaces[r.surfaceIndex].bvh;
      results.add(
        PreparedSurfaceBvh3D(
          surfaceIndex: r.surfaceIndex,
          nodeCount: r.nodeCount,
          triangleCount: r.triangleCount,
          bounds: r.bounds.materialize().asFloat32List(),
          leftOrFirst: r.leftOrFirst.materialize().asInt32List(),
          rightChild: r.rightChild.materialize().asInt32List(),
          counts: r.counts.materialize().asInt32List(),
          triangles: r.triangles.materialize().asInt32List(),
        ),
      );
    }
    return results;
  }

  /// Generates a complete CPU box-filtered RGBA8888 mipmap chain (from level
  /// `0` `[width x height]` down to `1x1`) in a background isolate via
  /// [TransferableTypedData].
  static Future<List<Uint8List>> generateMipmapsInIsolate(
    Uint8List rgbaPixels, {
    required int width,
    required int height,
  }) async {
    if (width < 1 || height < 1) {
      throw ArgumentError('width and height must be >= 1');
    }
    if (rgbaPixels.length < width * height * 4) {
      throw ArgumentError('rgbaPixels smaller than width * height * 4');
    }
    final input = TransferableTypedData.fromList([rgbaPixels]);
    final transfers = await Isolate.run(() {
      final level0 = input.materialize().asUint8List();
      final out = <TransferableTypedData>[
        TransferableTypedData.fromList([level0]),
      ];
      var curData = ByteData.sublistView(level0, 0, width * height * 4);
      var curW = width;
      var curH = height;
      while (curW > 1 || curH > 1) {
        final next = Mipmaps.downsample(
          curData,
          curW,
          curH,
          ui.PixelFormat.rgba8888,
        );
        final (nw, nh) = Mipmaps.levelSize(curW, curH, 1);
        final bytes = next.buffer.asUint8List(
          next.offsetInBytes,
          next.lengthInBytes,
        );
        out.add(TransferableTypedData.fromList([bytes]));
        curData = next;
        curW = nw;
        curH = nh;
      }
      return out;
    });
    return [for (final t in transfers) t.materialize().asUint8List()];
  }

  // ---------------------------------------------------------------------------
  // Pure-Dart BVH worker
  // ---------------------------------------------------------------------------

  static List<_BvhSurfaceOutput> _buildBvhsWorker(
    List<_BvhSurfaceInput> inputs,
    int maxLeafTriangles,
  ) {
    final outputs = <_BvhSurfaceOutput>[];
    for (final input in inputs) {
      final verts = input.vertices.materialize().asFloat32List();
      final idxBuffer = input.indices.materialize();
      final List<int> indices = input.wideIndices
          ? idxBuffer.asUint32List()
          : idxBuffer.asUint16List();
      outputs.add(
        _buildSingleBvh(
          surfaceIndex: input.surfaceIndex,
          verts: verts,
          indices: indices,
          stride: input.stride,
          posOffset: input.posOffset,
          maxLeafTriangles: maxLeafTriangles,
        ),
      );
    }
    return outputs;
  }

  static _BvhSurfaceOutput _buildSingleBvh({
    required int surfaceIndex,
    required Float32List verts,
    required List<int> indices,
    required int stride,
    required int posOffset,
    required int maxLeafTriangles,
  }) {
    final triCount = indices.length ~/ 3;
    if (triCount == 0) {
      return _BvhSurfaceOutput(
        surfaceIndex: surfaceIndex,
        nodeCount: 0,
        triangleCount: 0,
        bounds: TransferableTypedData.fromList([Uint8List(0)]),
        leftOrFirst: TransferableTypedData.fromList([Uint8List(0)]),
        rightChild: TransferableTypedData.fromList([Uint8List(0)]),
        counts: TransferableTypedData.fromList([Uint8List(0)]),
        triangles: TransferableTypedData.fromList([Uint8List(0)]),
      );
    }

    final triIndices = Int32List(triCount);
    final triBounds = Float32List(triCount * 6);
    final centroids = Float32List(triCount * 3);

    for (var t = 0; t < triCount; t++) {
      triIndices[t] = t;
      final b = t * 3;
      final i0 = indices[b] * stride + posOffset;
      final i1 = indices[b + 1] * stride + posOffset;
      final i2 = indices[b + 2] * stride + posOffset;

      final x0 = verts[i0];
      final y0 = verts[i0 + 1];
      final z0 = verts[i0 + 2];
      final x1 = verts[i1];
      final y1 = verts[i1 + 1];
      final z1 = verts[i1 + 2];
      final x2 = verts[i2];
      final y2 = verts[i2 + 1];
      final z2 = verts[i2 + 2];

      final tb = t * 6;
      triBounds
        ..[tb] = math.min(x0, math.min(x1, x2))
        ..[tb + 1] = math.min(y0, math.min(y1, y2))
        ..[tb + 2] = math.min(z0, math.min(z1, z2))
        ..[tb + 3] = math.max(x0, math.max(x1, x2))
        ..[tb + 4] = math.max(y0, math.max(y1, y2))
        ..[tb + 5] = math.max(z0, math.max(z1, z2));

      final cb = t * 3;
      centroids
        ..[cb] = (x0 + x1 + x2) * (1.0 / 3.0)
        ..[cb + 1] = (y0 + y1 + y2) * (1.0 / 3.0)
        ..[cb + 2] = (z0 + z1 + z2) * (1.0 / 3.0);
    }

    final maxNodes = math.max(1, triCount * 2);
    final bounds = Float32List(maxNodes * 6);
    final leftOrFirst = Int32List(maxNodes);
    final rightChild = Int32List(maxNodes);
    final counts = Int32List(maxNodes);
    var nodeCount = 0;

    int buildNode(int start, int count) {
      final node = nodeCount++;
      var minX = double.infinity;
      var minY = double.infinity;
      var minZ = double.infinity;
      var maxX = double.negativeInfinity;
      var maxY = double.negativeInfinity;
      var maxZ = double.negativeInfinity;
      var cMinX = double.infinity;
      var cMinY = double.infinity;
      var cMinZ = double.infinity;
      var cMaxX = double.negativeInfinity;
      var cMaxY = double.negativeInfinity;
      var cMaxZ = double.negativeInfinity;

      for (var i = start; i < start + count; i++) {
        final t = triIndices[i];
        final tb = t * 6;
        minX = math.min(minX, triBounds[tb]);
        minY = math.min(minY, triBounds[tb + 1]);
        minZ = math.min(minZ, triBounds[tb + 2]);
        maxX = math.max(maxX, triBounds[tb + 3]);
        maxY = math.max(maxY, triBounds[tb + 4]);
        maxZ = math.max(maxZ, triBounds[tb + 5]);

        final cb = t * 3;
        final cx = centroids[cb];
        final cy = centroids[cb + 1];
        final cz = centroids[cb + 2];
        cMinX = math.min(cMinX, cx);
        cMinY = math.min(cMinY, cy);
        cMinZ = math.min(cMinZ, cz);
        cMaxX = math.max(cMaxX, cx);
        cMaxY = math.max(cMaxY, cy);
        cMaxZ = math.max(cMaxZ, cz);
      }

      final nb = node * 6;
      bounds
        ..[nb] = minX
        ..[nb + 1] = minY
        ..[nb + 2] = minZ
        ..[nb + 3] = maxX
        ..[nb + 4] = maxY
        ..[nb + 5] = maxZ;

      if (count <= maxLeafTriangles) {
        leftOrFirst[node] = start;
        counts[node] = count;
        return node;
      }

      final extX = cMaxX - cMinX;
      final extY = cMaxY - cMinY;
      final extZ = cMaxZ - cMinZ;
      var axis = 0;
      var split = 0.5 * (cMinX + cMaxX);
      var extent = extX;
      if (extY > extent) {
        axis = 1;
        split = 0.5 * (cMinY + cMaxY);
        extent = extY;
      }
      if (extZ > extent) {
        axis = 2;
        split = 0.5 * (cMinZ + cMaxZ);
        extent = extZ;
      }

      int mid;
      if (extent <= 1e-12) {
        mid = start + (count >> 1);
      } else {
        var i = start;
        var j = start + count - 1;
        while (i <= j) {
          if (centroids[triIndices[i] * 3 + axis] < split) {
            i++;
          } else {
            final tmp = triIndices[i];
            triIndices[i] = triIndices[j];
            triIndices[j] = tmp;
            j--;
          }
        }
        mid = i;
        if (mid == start || mid == start + count) {
          mid = start + (count >> 1);
        }
      }

      counts[node] = 0;
      leftOrFirst[node] = buildNode(start, mid - start);
      rightChild[node] = buildNode(mid, start + count - mid);
      return node;
    }

    buildNode(0, triCount);

    TransferableTypedData wrapTyped(TypedData data, int byteLen) {
      return TransferableTypedData.fromList([
        data.buffer.asUint8List(data.offsetInBytes, byteLen),
      ]);
    }

    return _BvhSurfaceOutput(
      surfaceIndex: surfaceIndex,
      nodeCount: nodeCount,
      triangleCount: triCount,
      bounds: wrapTyped(bounds, nodeCount * 6 * 4),
      leftOrFirst: wrapTyped(leftOrFirst, nodeCount * 4),
      rightChild: wrapTyped(rightChild, nodeCount * 4),
      counts: wrapTyped(counts, nodeCount * 4),
      triangles: wrapTyped(triIndices, triCount * 4),
    );
  }

  // ---------------------------------------------------------------------------
  // Pure-Dart OBJ worker & materializer
  // ---------------------------------------------------------------------------

  static _PreparedObj _prepareObjInIsolate(
    String objSource,
    Map<String, String> mtlSources,
  ) {
    final positions = <Vector3>[];
    final normals = <Vector3>[];
    final texCoords = <Vector2>[];
    final mtlColors = <String, List<double>>{};

    void parseMtl(String mtlText) {
      String? curName;
      for (final rawLine in mtlText.split('\n')) {
        final line = rawLine.trim();
        if (line.isEmpty || line.startsWith('#')) {
          continue;
        }
        final parts = line.split(RegExp(r'\s+'));
        if (parts.isEmpty) {
          continue;
        }
        if (parts[0] == 'newmtl' && parts.length >= 2) {
          curName = parts[1];
          mtlColors[curName] = const [1.0, 1.0, 1.0];
        } else if (parts[0] == 'Kd' && curName != null && parts.length >= 4) {
          mtlColors[curName] = [
            double.parse(parts[1]),
            double.parse(parts[2]),
            double.parse(parts[3]),
          ];
        }
      }
    }

    for (final mtlText in mtlSources.values) {
      parseMtl(mtlText);
    }

    final groups = <String, List<_ObjTriCorner>>{};
    var currentMat = '__default__';

    for (final rawLine in objSource.split('\n')) {
      final line = rawLine.trim();
      if (line.isEmpty || line.startsWith('#')) {
        continue;
      }
      final parts = line.split(RegExp(r'\s+'));
      switch (parts[0]) {
        case 'v':
          if (parts.length >= 4) {
            positions.add(
              Vector3(
                double.parse(parts[1]),
                double.parse(parts[2]),
                double.parse(parts[3]),
              ),
            );
          }
        case 'vn':
          if (parts.length >= 4) {
            normals.add(
              Vector3(
                double.parse(parts[1]),
                double.parse(parts[2]),
                double.parse(parts[3]),
              ),
            );
          }
        case 'vt':
          if (parts.length >= 3) {
            texCoords.add(
              Vector2(
                double.parse(parts[1]),
                double.parse(parts[2]),
              ),
            );
          }
        case 'mtllib':
          if (parts.length >= 2) {
            final src = mtlSources[parts[1]];
            if (src != null) {
              parseMtl(src);
            }
          }
        case 'usemtl':
          if (parts.length >= 2) {
            currentMat = parts[1];
          }
        case 'f':
          if (parts.length >= 4) {
            final corners = <_ObjTriCorner>[];
            for (var i = 1; i < parts.length; i++) {
              final tokens = parts[i].split('/');
              final vRaw = int.parse(tokens[0]);
              final vIdx = vRaw < 0 ? positions.length + vRaw : vRaw - 1;
              var vtIdx = -1;
              if (tokens.length > 1 && tokens[1].isNotEmpty) {
                final tRaw = int.parse(tokens[1]);
                vtIdx = tRaw < 0 ? texCoords.length + tRaw : tRaw - 1;
              }
              var vnIdx = -1;
              if (tokens.length > 2 && tokens[2].isNotEmpty) {
                final nRaw = int.parse(tokens[2]);
                vnIdx = nRaw < 0 ? normals.length + nRaw : nRaw - 1;
              }
              corners.add(_ObjTriCorner(vIdx, vtIdx, vnIdx));
            }
            final dst = groups.putIfAbsent(currentMat, () => []);
            for (var t = 1; t < corners.length - 1; t++) {
              dst
                ..add(corners[0])
                ..add(corners[t])
                ..add(corners[t + 1]);
            }
          }
      }
    }

    final preparedSurfaces = <_PreparedObjSurface>[];
    for (final entry in groups.entries) {
      final corners = entry.value;
      if (corners.isEmpty) {
        continue;
      }
      final dedup = <String, int>{};
      final uniqueCorners = <_ObjTriCorner>[];
      final triIndices = <int>[];
      var anyMissingNormal = false;

      for (var i = 0; i < corners.length; i++) {
        final c = corners[i];
        if (c.vn < 0 || c.vn >= normals.length) {
          anyMissingNormal = true;
        }
        final key = '${c.v}/${c.vt}/${c.vn}';
        final idx = dedup.putIfAbsent(key, () {
          final id = uniqueCorners.length;
          uniqueCorners.add(c);
          return id;
        });
        triIndices.add(idx);
      }

      final vCount = uniqueCorners.length;
      List<Vector3>? computedNormals;
      if (anyMissingNormal) {
        computedNormals = List<Vector3>.generate(
          vCount,
          (_) => Vector3.zero(),
          growable: false,
        );
        for (var t = 0; t + 2 < triIndices.length; t += 3) {
          final i0 = triIndices[t];
          final i1 = triIndices[t + 1];
          final i2 = triIndices[t + 2];
          final p0 = positions[uniqueCorners[i0].v];
          final p1 = positions[uniqueCorners[i1].v];
          final p2 = positions[uniqueCorners[i2].v];
          final fn = (p1 - p0).cross(p2 - p0);
          computedNormals[i0].add(fn);
          computedNormals[i1].add(fn);
          computedNormals[i2].add(fn);
        }
        for (final n in computedNormals) {
          if (n.length2 > 1e-12) {
            n.normalize();
          } else {
            n.setValues(0, 1, 0);
          }
        }
      }

      final packed = Float32List(vCount * _standardStride);
      for (var i = 0; i < vCount; i++) {
        final c = uniqueCorners[i];
        final p = positions[c.v];
        final o = i * _standardStride;
        packed[o] = p.x;
        packed[o + 1] = p.y;
        packed[o + 2] = p.z;
        if (c.vt >= 0 && c.vt < texCoords.length) {
          final uv = texCoords[c.vt];
          packed[o + 3] = uv.x;
          packed[o + 4] = uv.y;
        }
        packed[o + 5] = 1.0;
        packed[o + 6] = 1.0;
        packed[o + 7] = 1.0;
        packed[o + 8] = 1.0;

        final n = c.vn >= 0 && c.vn < normals.length
            ? normals[c.vn]
            : computedNormals![i];
        packed[o + 9] = n.x;
        packed[o + 10] = n.y;
        packed[o + 11] = n.z;
      }

      final wide = vCount > 0xFFFF;
      final TypedData idxTyped = wide
          ? Uint32List.fromList(triIndices)
          : Uint16List.fromList(triIndices);
      final kd = mtlColors[entry.key];

      preparedSurfaces.add(
        _PreparedObjSurface(
          vertices: TransferableTypedData.fromList([
            packed.buffer.asUint8List(),
          ]),
          indices: TransferableTypedData.fromList([
            idxTyped.buffer.asUint8List(),
          ]),
          wideIndices: wide,
          kdRgb: kd,
        ),
      );
    }

    return _PreparedObj(preparedSurfaces);
  }

  static Model _materializePreparedObj(
    _PreparedObj prepared, {
    required bool buildBvhs,
  }) {
    final mesh = Mesh();
    for (final s in prepared.surfaces) {
      final verts = s.vertices.materialize().asFloat32List();
      final idxBuf = s.indices.materialize();
      final List<int> indices = s.wideIndices
          ? idxBuf.asUint32List()
          : idxBuf.asUint16List();
      final kd = s.kdRgb;
      final mat = kd != null
          ? SpatialMaterial(
              albedoColor: ui.Color.from(
                alpha: 1.0,
                red: kd[0].clamp(0.0, 1.0),
                green: kd[1].clamp(0.0, 1.0),
                blue: kd[2].clamp(0.0, 1.0),
              ),
            )
          : Material.defaultMaterial;
      final surface = Surface.fromBuffers(
        vertices: verts,
        indices: indices,
        material: mat,
      );
      if (buildBvhs) {
        surface.bvh;
      }
      mesh.addSurface(surface);
    }
    return Model.simple(mesh: mesh);
  }

  // ---------------------------------------------------------------------------
  // Pure-Dart GLB worker & materializer
  // ---------------------------------------------------------------------------

  static _PreparedGlb _prepareGlbInIsolate(
    TransferableTypedData glbTransfer,
    String prefix,
  ) {
    final content = glbTransfer.materialize().asUint8List();
    if (content.length < 12) {
      throw FormatException('GLB buffer too short: ${content.length} bytes');
    }
    final headerView = ByteData.sublistView(content);
    final magic = String.fromCharCodes(Uint8List.sublistView(content, 0, 4));
    if (magic != 'glTF') {
      throw FormatException('Invalid GLB magic: $magic');
    }
    final version = headerView.getUint32(4, Endian.little);
    if (version != 2) {
      throw FormatException('Unsupported GLB version: $version');
    }

    Map<String, Object?>? jsonMap;
    final binChunks = <Uint8List>[];
    var cursor = 12;
    while (cursor + 8 <= content.length) {
      final chunkLen = headerView.getUint32(cursor, Endian.little);
      final chunkType = String.fromCharCodes(
        Uint8List.sublistView(content, cursor + 4, cursor + 8),
      );
      cursor += 8;
      final chunkData = Uint8List.sublistView(
        content,
        cursor,
        cursor + chunkLen,
      );
      cursor += chunkLen;
      if (chunkType == 'JSON') {
        jsonMap = jsonDecode(utf8.decode(chunkData)) as Map<String, Object?>;
      } else if (chunkType == 'BIN\x00') {
        binChunks.add(chunkData);
      }
    }
    if (jsonMap == null) {
      throw const FormatException('GLB missing JSON chunk');
    }

    Uint8List resolveUriBytes(String uri) {
      final commaIdx = uri.indexOf(';base64,');
      if (uri.startsWith('data:') && commaIdx != -1) {
        return base64Decode(uri.substring(commaIdx + 8));
      }
      throw UnsupportedError(
        'External URI "$prefix$uri" cannot be read inside pure isolate; '
        'pack buffers/images into GLB or data: URIs.',
      );
    }

    // Buffers & BufferViews
    final rawBuffers = (jsonMap['buffers'] as List<Object?>?) ?? const [];
    final resolvedBuffers = <Uint8List>[];
    for (var i = 0; i < rawBuffers.length; i++) {
      if (i < binChunks.length) {
        resolvedBuffers.add(binChunks[i]);
      } else {
        final bm = rawBuffers[i]! as Map<String, Object?>;
        resolvedBuffers.add(resolveUriBytes(bm['uri']! as String));
      }
    }

    final rawViews = (jsonMap['bufferViews'] as List<Object?>?) ?? const [];
    Uint8List sliceView(int viewIdx) {
      final vm = rawViews[viewIdx]! as Map<String, Object?>;
      final bufIdx = (vm['buffer']! as num).toInt();
      final offset = (vm['byteOffset'] as num?)?.toInt() ?? 0;
      final length = (vm['byteLength']! as num).toInt();
      return Uint8List.sublistView(
        resolvedBuffers[bufIdx],
        offset,
        offset + length,
      );
    }

    int? strideOfView(int viewIdx) {
      final vm = rawViews[viewIdx]! as Map<String, Object?>;
      return (vm['byteStride'] as num?)?.toInt();
    }

    // Accessors
    final rawAccessors = (jsonMap['accessors'] as List<Object?>?) ?? const [];
    List<double> readDoubles(int accIdx, int expectedComponents) {
      final am = rawAccessors[accIdx]! as Map<String, Object?>;
      final viewIdx = (am['bufferView']! as num).toInt();
      final byteOffset = (am['byteOffset'] as num?)?.toInt() ?? 0;
      final compType = (am['componentType']! as num).toInt();
      final normalized = (am['normalized'] as bool?) ?? false;
      final count = (am['count']! as num).toInt();
      final bytes = sliceView(viewIdx);
      final bd = ByteData.sublistView(bytes);
      final compSize = switch (compType) {
        5120 || 5121 => 1,
        5122 || 5123 => 2,
        5125 || 5126 => 4,
        _ => throw FormatException('Unknown componentType $compType'),
      };
      final stride = strideOfView(viewIdx) ?? (expectedComponents * compSize);
      final out = Float64List(count * expectedComponents);
      for (var elem = 0; elem < count; elem++) {
        final base = byteOffset + elem * stride;
        for (var c = 0; c < expectedComponents; c++) {
          final off = base + c * compSize;
          final raw = switch (compType) {
            5120 => bd.getInt8(off),
            5121 => bd.getUint8(off),
            5122 => bd.getInt16(off, Endian.little),
            5123 => bd.getUint16(off, Endian.little),
            5125 => bd.getUint32(off, Endian.little),
            _ => bd.getFloat32(off, Endian.little),
          };
          var v = raw.toDouble();
          if (normalized) {
            v = switch (compType) {
              5120 => math.max(v / 127.0, -1.0),
              5121 => v / 255.0,
              5122 => math.max(v / 32767.0, -1.0),
              5123 => v / 65535.0,
              _ => v,
            };
          }
          out[elem * expectedComponents + c] = v;
        }
      }
      return out;
    }

    List<int> readScalarInts(int accIdx) {
      final am = rawAccessors[accIdx]! as Map<String, Object?>;
      final viewIdx = (am['bufferView']! as num).toInt();
      final byteOffset = (am['byteOffset'] as num?)?.toInt() ?? 0;
      final compType = (am['componentType']! as num).toInt();
      final count = (am['count']! as num).toInt();
      final bytes = sliceView(viewIdx);
      final bd = ByteData.sublistView(bytes);
      final compSize = switch (compType) {
        5120 || 5121 => 1,
        5122 || 5123 => 2,
        _ => 4,
      };
      final stride = strideOfView(viewIdx) ?? compSize;
      return List<int>.generate(count, (elem) {
        final off = byteOffset + elem * stride;
        return switch (compType) {
          5120 => bd.getInt8(off),
          5121 => bd.getUint8(off),
          5122 => bd.getInt16(off, Endian.little),
          5123 => bd.getUint16(off, Endian.little),
          _ => bd.getUint32(off, Endian.little),
        };
      }, growable: false);
    }

    // Images, Samplers, Textures, Materials
    final rawImages = (jsonMap['images'] as List<Object?>?) ?? const [];
    final imageTransfers = <TransferableTypedData>[];
    for (final item in rawImages) {
      final im = item! as Map<String, Object?>;
      final Uint8List imgBytes;
      if (im['uri'] case final String uri) {
        imgBytes = resolveUriBytes(uri);
      } else {
        imgBytes = sliceView((im['bufferView']! as num).toInt());
      }
      imageTransfers.add(
        TransferableTypedData.fromList([Uint8List.fromList(imgBytes)]),
      );
    }

    final rawSamplers = (jsonMap['samplers'] as List<Object?>?) ?? const [];
    final samplers = <_PreparedSampler>[
      for (final item in rawSamplers)
        _PreparedSampler.fromMap(item! as Map<String, Object?>),
    ];

    final rawTextures = (jsonMap['textures'] as List<Object?>?) ?? const [];
    final textures = <({int source, int? sampler})>[
      for (final item in rawTextures)
        if (item case final Map<String, Object?> tm)
          (
            source: (tm['source']! as num).toInt(),
            sampler: (tm['sampler'] as num?)?.toInt(),
          ),
    ];

    final rawMaterials = (jsonMap['materials'] as List<Object?>?) ?? const [];
    final materials = <_PreparedMaterial>[
      for (final item in rawMaterials)
        _PreparedMaterial.fromMap(item! as Map<String, Object?>),
    ];

    // Meshes & Primitives
    final rawMeshes = (jsonMap['meshes'] as List<Object?>?) ?? const [];
    final preparedMeshes = <_PreparedMesh>[];
    for (final meshObj in rawMeshes) {
      final mm = meshObj! as Map<String, Object?>;
      final meshWeights = (mm['weights'] as List<Object?>?)
          ?.map((e) => (e! as num).toDouble())
          .toList(growable: false);
      final rawPrims = (mm['primitives'] as List<Object?>?) ?? const [];
      final surfaces = <_PreparedSurface>[];
      for (final primObj in rawPrims) {
        final pm = primObj! as Map<String, Object?>;
        surfaces.addAll(
          _packGlbPrimitive(
            pm: pm,
            rawAccessors: rawAccessors,
            readDoubles: readDoubles,
            readScalarInts: readScalarInts,
          ),
        );
      }
      preparedMeshes.add(_PreparedMesh(surfaces, meshWeights));
    }

    // Skins
    final rawSkins = (jsonMap['skins'] as List<Object?>?) ?? const [];
    final skins = <_PreparedSkin>[];
    for (final skinObj in rawSkins) {
      final sm = skinObj! as Map<String, Object?>;
      final joints = ((sm['joints'] as List<Object?>?) ?? const [])
          .map((e) => (e! as num).toInt())
          .toList(growable: false);
      final ibmIdx = (sm['inverseBindMatrices'] as num?)?.toInt();
      final ibms = ibmIdx != null
          ? Float64List.fromList(readDoubles(ibmIdx, 16))
          : null;
      skins.add(_PreparedSkin(joints, ibms));
    }

    // Nodes & Active Scene
    final rawNodes = (jsonMap['nodes'] as List<Object?>?) ?? const [];
    final rawScenes = (jsonMap['scenes'] as List<Object?>?) ?? const [];
    final sceneIdx = (jsonMap['scene'] as num?)?.toInt() ?? 0;
    final rootNodeIndices = rawScenes.isNotEmpty && sceneIdx < rawScenes.length
        ? (((rawScenes[sceneIdx]! as Map<String, Object?>)['nodes']
                      as List<Object?>?) ??
                  const [])
              .map((e) => (e! as num).toInt())
              .toList(growable: false)
        : <int>[for (var i = 0; i < rawNodes.length; i++) i];

    final preparedNodes = <_PreparedNode>[];
    void visitNode(int idx, int? parentIdx) {
      final nm = rawNodes[idx]! as Map<String, Object?>;
      final matFloats = (nm['matrix'] as List<Object?>?)
          ?.map((e) => (e! as num).toDouble())
          .toList(growable: false);
      final Matrix4 localMat;
      if (matFloats != null && matFloats.length == 16) {
        localMat = Matrix4.fromList(matFloats);
      } else {
        final tList = (nm['translation'] as List<Object?>?)
            ?.map((e) => (e! as num).toDouble())
            .toList(growable: false);
        final rList = (nm['rotation'] as List<Object?>?)
            ?.map((e) => (e! as num).toDouble())
            .toList(growable: false);
        final sList = (nm['scale'] as List<Object?>?)
            ?.map((e) => (e! as num).toDouble())
            .toList(growable: false);
        localMat = Matrix4.compose(
          tList != null
              ? Vector3(tList[0], tList[1], tList[2])
              : Vector3.zero(),
          rList != null
              ? Quaternion(rList[0], rList[1], rList[2], rList[3])
              : Quaternion.identity(),
          sList != null
              ? Vector3(sList[0], sList[1], sList[2])
              : Vector3.all(1),
        );
      }
      preparedNodes.add(
        _PreparedNode(
          nodeIndex: idx,
          parentNodeIndex: parentIdx,
          name: nm['name'] as String?,
          transformStorage: Float64List.fromList(localMat.storage),
          meshIndex: (nm['mesh'] as num?)?.toInt(),
          skinIndex: (nm['skin'] as num?)?.toInt(),
        ),
      );
      final children = (nm['children'] as List<Object?>?) ?? const [];
      for (final c in children) {
        visitNode((c! as num).toInt(), idx);
      }
    }

    for (final rIdx in rootNodeIndices) {
      visitNode(rIdx, null);
    }

    // Animations
    final rawAnimations = (jsonMap['animations'] as List<Object?>?) ?? const [];
    final animations = <_PreparedAnimation>[];
    for (final animObj in rawAnimations) {
      final am = animObj! as Map<String, Object?>;
      final animName = am['name'] as String?;
      final aSamplers = (am['samplers'] as List<Object?>?) ?? const [];
      final aChannels = (am['channels'] as List<Object?>?) ?? const [];
      final channels = <_PreparedAnimChannel>[];

      for (final chObj in aChannels) {
        final cm = chObj! as Map<String, Object?>;
        final target = cm['target']! as Map<String, Object?>;
        final targetNode = (target['node'] as num?)?.toInt();
        if (targetNode == null) {
          continue;
        }
        final path = target['path']! as String;
        final samp =
            aSamplers[(cm['sampler']! as num).toInt()]! as Map<String, Object?>;
        final interp = (samp['interpolation'] as String?) ?? 'LINEAR';
        final inAcc = (samp['input']! as num).toInt();
        final outAcc = (samp['output']! as num).toInt();
        final times = Float64List.fromList(readDoubles(inAcc, 1));
        final outComp = switch (path) {
          'translation' || 'scale' => 3,
          'rotation' => 4,
          _ => 1,
        };
        final values = Float64List.fromList(readDoubles(outAcc, outComp));
        channels.add(
          _PreparedAnimChannel(
            nodeIndex: targetNode,
            path: path,
            interpolation: interp,
            times: times,
            values: values,
          ),
        );
      }
      animations.add(_PreparedAnimation(animName, channels));
    }

    return _PreparedGlb(
      images: imageTransfers,
      samplers: samplers,
      textures: textures,
      materials: materials,
      meshes: preparedMeshes,
      skins: skins,
      nodes: preparedNodes,
      animations: animations,
    );
  }

  static List<_PreparedSurface> _packGlbPrimitive({
    required Map<String, Object?> pm,
    required List<Object?> rawAccessors,
    required List<double> Function(int accIdx, int components) readDoubles,
    required List<int> Function(int accIdx) readScalarInts,
  }) {
    final attrs = pm['attributes']! as Map<String, Object?>;
    final posAcc = (attrs['POSITION']! as num).toInt();
    final posData = readDoubles(posAcc, 3);
    final vertTotal = posData.length ~/ 3;

    final idxAcc = (pm['indices'] as num?)?.toInt();
    final rawIndices = idxAcc != null
        ? readScalarInts(idxAcc)
        : List<int>.generate(vertTotal, (i) => i, growable: false);

    final maxIdx = rawIndices.isEmpty ? -1 : rawIndices.reduce(math.max);
    final vertCount = maxIdx + 1;
    final matIdx = (pm['material'] as num?)?.toInt();

    if (vertCount <= 0) {
      return [
        _PreparedSurface(
          vertices: TransferableTypedData.fromList([Uint8List(0)]),
          indices: TransferableTypedData.fromList([Uint8List(0)]),
          wideIndices: false,
          materialIndex: matIdx,
          jointMap: null,
          morphTargets: const [],
        ),
      ];
    }

    final uvAcc = (attrs['TEXCOORD_0'] as num?)?.toInt();
    final uvData = uvAcc != null ? readDoubles(uvAcc, 2) : null;

    final nrmAcc = (attrs['NORMAL'] as num?)?.toInt();
    List<double> nrmData;
    if (nrmAcc != null) {
      nrmData = readDoubles(nrmAcc, 3);
    } else {
      final posVecs = List<Vector3>.generate(
        vertTotal,
        (i) => Vector3(posData[i * 3], posData[i * 3 + 1], posData[i * 3 + 2]),
        growable: false,
      );
      final calc = Vertex.calculateVertexNormals(posVecs, rawIndices);
      final flat = Float64List(calc.length * 3);
      for (var i = 0; i < calc.length; i++) {
        flat[i * 3] = calc[i].x;
        flat[i * 3 + 1] = calc[i].y;
        flat[i * 3 + 2] = calc[i].z;
      }
      nrmData = flat;
    }

    Float32List? colorData;
    final colAcc = (attrs['COLOR_0'] as num?)?.toInt();
    if (colAcc != null) {
      final colMap = rawAccessors[colAcc]! as Map<String, Object?>;
      final colType = colMap['type']! as String;
      final comps = colType == 'VEC4' ? 4 : 3;
      final rawCol = readDoubles(colAcc, comps);
      final count = rawCol.length ~/ comps;
      colorData = Float32List(vertCount * 4);
      for (var i = 0; i < vertCount && i < count; i++) {
        colorData[i * 4] = rawCol[i * comps].clamp(0.0, 1.0);
        colorData[i * 4 + 1] = rawCol[i * comps + 1].clamp(0.0, 1.0);
        colorData[i * 4 + 2] = rawCol[i * comps + 2].clamp(0.0, 1.0);
        colorData[i * 4 + 3] = comps == 4
            ? rawCol[i * 4 + 3].clamp(0.0, 1.0)
            : 1.0;
      }
    }

    final jointsAcc = (attrs['JOINTS_0'] as num?)?.toInt();
    final weightsAcc = (attrs['WEIGHTS_0'] as num?)?.toInt();
    final jointsData = jointsAcc != null ? readDoubles(jointsAcc, 4) : null;
    final weightsData = weightsAcc != null ? readDoubles(weightsAcc, 4) : null;

    // Morph targets
    final rawTargets = (pm['targets'] as List<Object?>?) ?? const [];
    final fullMorphs = <({Float32List pos, Float32List? nrm, String name})>[];
    for (var ti = 0; ti < rawTargets.length; ti++) {
      final tm = rawTargets[ti]! as Map<String, Object?>;
      final mpAcc = (tm['POSITION'] as num?)?.toInt();
      if (mpAcc == null) {
        continue;
      }
      final mp = readDoubles(mpAcc, 3);
      final pDeltas = Float32List(vertCount * 3);
      final pLimit = math.min(vertCount * 3, mp.length);
      for (var k = 0; k < pLimit; k++) {
        pDeltas[k] = mp[k];
      }
      Float32List? nDeltas;
      final mnAcc = (tm['NORMAL'] as num?)?.toInt();
      if (mnAcc != null) {
        final mn = readDoubles(mnAcc, 3);
        nDeltas = Float32List(vertCount * 3);
        final nLimit = math.min(vertCount * 3, mn.length);
        for (var k = 0; k < nLimit; k++) {
          nDeltas[k] = mn[k];
        }
      }
      fullMorphs.add((pos: pDeltas, nrm: nDeltas, name: 'target_$ti'));
    }

    _PreparedSurface packBatch(List<int>? vertRemap, List<int> triIndices) {
      final vLen = vertRemap?.length ?? vertCount;
      final packed = Float32List(vLen * _standardStride);
      final globalToLocal = <int, int>{};

      int mapJoint(double rawJ, double w) {
        if (w <= 0.0) {
          return 0;
        }
        final jIdx = rawJ.toInt();
        return globalToLocal.putIfAbsent(jIdx, () => globalToLocal.length);
      }

      for (var local = 0; local < vLen; local++) {
        final src = vertRemap != null ? vertRemap[local] : local;
        final o = local * _standardStride;
        packed[o] = posData[src * 3];
        packed[o + 1] = posData[src * 3 + 1];
        packed[o + 2] = posData[src * 3 + 2];

        if (uvData != null && src * 2 + 1 < uvData.length) {
          packed[o + 3] = uvData[src * 2];
          packed[o + 4] = uvData[src * 2 + 1];
        }
        if (colorData != null && src * 4 + 3 < colorData.length) {
          packed[o + 5] = colorData[src * 4];
          packed[o + 6] = colorData[src * 4 + 1];
          packed[o + 7] = colorData[src * 4 + 2];
          packed[o + 8] = colorData[src * 4 + 3];
        } else {
          packed[o + 5] = 1.0;
          packed[o + 6] = 1.0;
          packed[o + 7] = 1.0;
          packed[o + 8] = 1.0;
        }
        if (src * 3 + 2 < nrmData.length) {
          packed[o + 9] = nrmData[src * 3];
          packed[o + 10] = nrmData[src * 3 + 1];
          packed[o + 11] = nrmData[src * 3 + 2];
        } else {
          packed[o + 10] = 1.0;
        }
        if (jointsData != null &&
            weightsData != null &&
            src * 4 + 3 < jointsData.length &&
            src * 4 + 3 < weightsData.length) {
          final jb = src * 4;
          final w0 = weightsData[jb];
          final w1 = weightsData[jb + 1];
          final w2 = weightsData[jb + 2];
          final w3 = weightsData[jb + 3];
          packed[o + 12] = mapJoint(jointsData[jb], w0).toDouble();
          packed[o + 13] = mapJoint(jointsData[jb + 1], w1).toDouble();
          packed[o + 14] = mapJoint(jointsData[jb + 2], w2).toDouble();
          packed[o + 15] = mapJoint(jointsData[jb + 3], w3).toDouble();
          packed[o + 16] = w0;
          packed[o + 17] = w1;
          packed[o + 18] = w2;
          packed[o + 19] = w3;
        }
      }

      var wide = vLen > 0xFFFF;
      for (var i = 0; !wide && i < triIndices.length; i++) {
        wide = triIndices[i] >= 0xFFFF;
      }
      final TypedData idxTyped = wide
          ? Uint32List.fromList(triIndices)
          : Uint16List.fromList(triIndices);

      final morphPayloads = <_PreparedMorph>[];
      for (final m in fullMorphs) {
        final pOut = vertRemap == null
            ? m.pos
            : Float32List.fromList([
                for (var i = 0; i < vLen; i++) ...[
                  m.pos[vertRemap[i] * 3],
                  m.pos[vertRemap[i] * 3 + 1],
                  m.pos[vertRemap[i] * 3 + 2],
                ],
              ]);
        final nOut = m.nrm == null
            ? null
            : (vertRemap == null
                  ? m.nrm!
                  : Float32List.fromList([
                      for (var i = 0; i < vLen; i++) ...[
                        m.nrm![vertRemap[i] * 3],
                        m.nrm![vertRemap[i] * 3 + 1],
                        m.nrm![vertRemap[i] * 3 + 2],
                      ],
                    ]));
        morphPayloads.add(
          _PreparedMorph(
            name: m.name,
            posDeltas: TransferableTypedData.fromList([
              pOut.buffer.asUint8List(),
            ]),
            nrmDeltas: nOut == null
                ? null
                : TransferableTypedData.fromList([nOut.buffer.asUint8List()]),
          ),
        );
      }

      return _PreparedSurface(
        vertices: TransferableTypedData.fromList([packed.buffer.asUint8List()]),
        indices: TransferableTypedData.fromList([
          idxTyped.buffer.asUint8List(),
        ]),
        wideIndices: wide,
        materialIndex: matIdx,
        jointMap: globalToLocal.isEmpty ? null : globalToLocal,
        morphTargets: morphPayloads,
      );
    }

    final uniqueJoints = <int>{};
    if (jointsData != null && weightsData != null) {
      for (var v = 0; v < vertCount && v * 4 + 3 < jointsData.length; v++) {
        for (var k = 0; k < 4; k++) {
          if (weightsData[v * 4 + k] > 0.0) {
            uniqueJoints.add(jointsData[v * 4 + k].toInt());
          }
        }
      }
    }
    if (uniqueJoints.length <= _maxJointsPerSurface) {
      return [packBatch(null, rawIndices)];
    }

    final batches = <_PreparedSurface>[];
    final batchTris = <int>[];
    final batchJoints = <int>{};
    final triJoints = <int>{};

    void flush() {
      if (batchTris.isEmpty) {
        return;
      }
      final remap = <int, int>{};
      final used = <int>[];
      final localTris = <int>[];
      for (final oldV in batchTris) {
        final nextV = remap.putIfAbsent(oldV, () {
          final id = used.length;
          used.add(oldV);
          return id;
        });
        localTris.add(nextV);
      }
      batches.add(packBatch(used, localTris));
      batchTris.clear();
      batchJoints.clear();
    }

    for (var t = 0; t + 2 < rawIndices.length; t += 3) {
      triJoints.clear();
      for (var c = 0; c < 3; c++) {
        final v = rawIndices[t + c];
        if (jointsData != null &&
            weightsData != null &&
            v * 4 + 3 < jointsData.length) {
          for (var k = 0; k < 4; k++) {
            if (weightsData[v * 4 + k] > 0.0) {
              triJoints.add(jointsData[v * 4 + k].toInt());
            }
          }
        }
      }
      var added = 0;
      for (final j in triJoints) {
        if (!batchJoints.contains(j)) {
          added++;
        }
      }
      if (batchJoints.isNotEmpty &&
          batchJoints.length + added > _maxJointsPerSurface) {
        flush();
      }
      batchJoints.addAll(triJoints);
      batchTris
        ..add(rawIndices[t])
        ..add(rawIndices[t + 1])
        ..add(rawIndices[t + 2]);
    }
    flush();
    return batches;
  }

  static Future<ImageTexture> _decodeImageBytes(Uint8List bytes) async {
    // Support uncompressed 24/32-bit little-endian BMP directly on CPU as a
    // fast fallback, otherwise decode with `ui.instantiateImageCodec`.
    if (bytes.length >= 54 && bytes[0] == 0x42 && bytes[1] == 0x4D) {
      final bd = ByteData.sublistView(bytes);
      final dataOffset = bd.getUint32(10, Endian.little);
      final w = bd.getInt32(18, Endian.little).abs();
      final rawH = bd.getInt32(22, Endian.little);
      final topDown = rawH < 0;
      final h = rawH.abs();
      final bpp = bd.getUint16(28, Endian.little);
      final compression = bd.getUint32(30, Endian.little);
      if ((bpp == 24 || bpp == 32) && compression == 0 && w > 0 && h > 0) {
        final rowStride = ((bpp * w + 31) ~/ 32) * 4;
        if (dataOffset + rowStride * h <= bytes.length) {
          final rgba = Uint8List(w * h * 4);
          final pxBytes = bpp ~/ 8;
          for (var y = 0; y < h; y++) {
            final srcY = topDown ? y : (h - 1 - y);
            final srcRow = dataOffset + srcY * rowStride;
            for (var x = 0; x < w; x++) {
              final s = srcRow + x * pxBytes;
              final d = (y * w + x) * 4;
              rgba[d] = bytes[s + 2];
              rgba[d + 1] = bytes[s + 1];
              rgba[d + 2] = bytes[s];
              rgba[d + 3] = pxBytes == 4 ? bytes[s + 3] : 255;
            }
          }
          return ImageTexture(
            ByteData.sublistView(rgba),
            width: w,
            height: h,
          );
        }
      }
    }

    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    final tex = await ImageTexture.create(frame.image);
    frame.image.dispose();
    return tex;
  }

  static Future<Model> _materializePreparedGlb(
    _PreparedGlb prepared, {
    required bool buildBvhs,
  }) async {
    final decodedImages = <ImageTexture>[];
    for (final imgTransfer in prepared.images) {
      final imgBytes = imgTransfer.materialize().asUint8List();
      decodedImages.add(await _decodeImageBytes(imgBytes));
    }

    Texture? resolveTexture(int? texIdx) {
      if (texIdx == null || texIdx < 0 || texIdx >= prepared.textures.length) {
        return null;
      }
      final t = prepared.textures[texIdx];
      final baseImg = decodedImages[t.source];
      final sampIdx = t.sampler;
      if (sampIdx == null ||
          sampIdx < 0 ||
          sampIdx >= prepared.samplers.length) {
        return baseImg;
      }
      final flameSampler = prepared.samplers[sampIdx].toFlameSampler();
      return ImageTexture(
        baseImg.sourceData,
        width: baseImg.width,
        height: baseImg.height,
        sampler: flameSampler,
        mipmaps: baseImg.mipmaps,
        gpuTexture: baseImg.gpuTexture,
      );
    }

    final builtMaterials = <Material>[];
    for (final pm in prepared.materials) {
      final cullMode = pm.doubleSided ? CullMode.none : CullMode.backFace;
      if (pm.isUnlit) {
        final unlit = UnlitMaterial(
          albedoColor: pm.baseColor,
          albedoTexture: resolveTexture(pm.baseColorTex),
        );
        unlit.renderState = pm.alphaMode == 'BLEND'
            ? RenderState.alphaBlend.copyWith(cullMode: cullMode)
            : RenderState.opaque;
        builtMaterials.add(unlit);
      } else {
        final mat = SpatialMaterial(
          albedoColor: pm.baseColor,
          albedoTexture: resolveTexture(pm.baseColorTex),
          metallic: pm.metallic,
          roughness: pm.roughness,
          metallicRoughnessTexture: resolveTexture(pm.metallicRoughnessTex),
          normalTexture: resolveTexture(pm.normalTex),
          normalScale: pm.normalScale,
          occlusionTexture: resolveTexture(pm.occlusionTex),
          occlusionStrength: pm.occlusionStrength,
          emissiveTexture: resolveTexture(pm.emissiveTex),
          emissiveColor: pm.emissiveColor,
          emissiveStrength: pm.emissiveStrength,
          uvOffset: Vector2(pm.uvOffsetX, pm.uvOffsetY),
          uvScale: Vector2(pm.uvScaleX, pm.uvScaleY),
          alphaCutoff: pm.alphaMode == 'MASK' ? pm.alphaCutoff : 0.0,
          doubleSided: pm.doubleSided,
          translucent: pm.alphaMode == 'BLEND',
        );
        mat.renderState = mat.renderState.copyWith(cullMode: cullMode);
        builtMaterials.add(mat);
      }
    }

    Mesh buildMesh(_PreparedMesh pm) {
      final mesh = Mesh();
      for (final ps in pm.surfaces) {
        final verts = ps.vertices.materialize().asFloat32List();
        final idxBuf = ps.indices.materialize();
        final List<int> indices = ps.wideIndices
            ? idxBuf.asUint32List()
            : idxBuf.asUint16List();
        final mat =
            ps.materialIndex != null &&
                ps.materialIndex! < builtMaterials.length
            ? builtMaterials[ps.materialIndex!]
            : SpatialMaterial(albedoColor: const ui.Color(0xFFFF00FF));
        final morphs = <MorphTargetData>[
          for (final m in ps.morphTargets)
            MorphTargetData(
              name: m.name,
              positionDeltas: m.posDeltas.materialize().asFloat32List(),
              normalDeltas: m.nrmDeltas?.materialize().asFloat32List(),
            ),
        ];
        final surface = Surface.fromBuffers(
          vertices: verts,
          indices: indices,
          material: mat,
          jointMap: ps.jointMap,
          morphTargets: morphs,
        );
        if (pm.weights != null && pm.weights!.isNotEmpty) {
          surface.applyMorphWeights(pm.weights!);
        }
        if (buildBvhs) {
          surface.bvh;
        }
        mesh.addSurface(surface);
      }
      return mesh;
    }

    final nodes = <int, ModelNode>{};
    for (final pn in prepared.nodes) {
      final mesh = pn.meshIndex != null
          ? buildMesh(prepared.meshes[pn.meshIndex!])
          : null;
      final modelJoints = <int, ModelJoint>{};
      if (pn.skinIndex != null) {
        final skin = prepared.skins[pn.skinIndex!];
        for (var j = 0; j < skin.joints.length; j++) {
          final ibm = skin.ibms != null && (j + 1) * 16 <= skin.ibms!.length
              ? Matrix4.fromList(skin.ibms!.sublist(j * 16, (j + 1) * 16))
              : Matrix4.identity();
          modelJoints[j] = ModelJoint(
            nodeIndex: skin.joints[j],
            inverseBindMatrix: ibm,
          );
        }
      }
      nodes[pn.nodeIndex] = ModelNode(
        name: pn.name,
        nodeIndex: pn.nodeIndex,
        parentNodeIndex: pn.parentNodeIndex,
        transform: Matrix4.fromList(pn.transformStorage),
        mesh: mesh,
        joints: modelJoints,
      );
    }

    final animations = <ModelAnimation>[];
    for (final pa in prepared.animations) {
      final ctrls = <int, List<AnimationController>>{};
      final morphs = <int, MorphWeightsChannel>{};
      for (final ch in pa.channels) {
        final interp = AnimationInterpolation.valueOf(ch.interpolation);
        final times = ch.times.toList(growable: false);
        if (ch.path == 'weights') {
          final divisor = interp == AnimationInterpolation.cubicSpline
              ? times.length * 3
              : times.length;
          final targetCount = divisor > 0 ? ch.values.length ~/ divisor : 0;
          if (targetCount > 0) {
            morphs[ch.nodeIndex] = MorphWeightsChannel(
              interpolation: interp,
              times: times,
              weights: ch.values.toList(growable: false),
              targetCount: targetCount,
            );
          }
          continue;
        }
        if (ch.path == 'translation') {
          final vecs = List<Vector3>.generate(
            ch.values.length ~/ 3,
            (i) => Vector3(
              ch.values[i * 3],
              ch.values[i * 3 + 1],
              ch.values[i * 3 + 2],
            ),
            growable: false,
          );
          (ctrls[ch.nodeIndex] ??= []).add(
            AnimationController(
              animation: TranslationAnimationSpline.from(
                interpolation: interp,
                times: times,
                values: vecs,
              ),
            ),
          );
        } else if (ch.path == 'scale') {
          final vecs = List<Vector3>.generate(
            ch.values.length ~/ 3,
            (i) => Vector3(
              ch.values[i * 3],
              ch.values[i * 3 + 1],
              ch.values[i * 3 + 2],
            ),
            growable: false,
          );
          (ctrls[ch.nodeIndex] ??= []).add(
            AnimationController(
              animation: ScaleAnimationSpline.from(
                interpolation: interp,
                times: times,
                values: vecs,
              ),
            ),
          );
        } else if (ch.path == 'rotation') {
          final quats = List<Quaternion>.generate(
            ch.values.length ~/ 4,
            (i) => Quaternion(
              ch.values[i * 4],
              ch.values[i * 4 + 1],
              ch.values[i * 4 + 2],
              ch.values[i * 4 + 3],
            ),
            growable: false,
          );
          (ctrls[ch.nodeIndex] ??= []).add(
            AnimationController(
              animation: RotationAnimationSpline.from(
                interpolation: interp,
                times: times,
                values: quats,
              ),
            ),
          );
        }
      }
      final nodeKeys = <int>{...ctrls.keys, ...morphs.keys};
      animations.add(
        ModelAnimation(
          name: pa.name,
          nodes: {
            for (final k in nodeKeys)
              k: NodeAnimation(
                channels: ctrls[k] ?? const [],
                morphWeights: morphs[k],
              ),
          },
        ),
      );
    }

    return Model(nodes: nodes, animations: animations);
  }
}

// -----------------------------------------------------------------------------
// Isolate-transferable DTOs (no closures, no GPU/UI handles)
// -----------------------------------------------------------------------------

class _BvhSurfaceInput({
  required final int surfaceIndex,
  required final int stride,
  required final int posOffset,
  required final bool wideIndices,
  required final TransferableTypedData vertices,
  required final TransferableTypedData indices,
});

class _BvhSurfaceOutput({
  required final int surfaceIndex,
  required final int nodeCount,
  required final int triangleCount,
  required final TransferableTypedData bounds,
  required final TransferableTypedData leftOrFirst,
  required final TransferableTypedData rightChild,
  required final TransferableTypedData counts,
  required final TransferableTypedData triangles,
});

class _ObjTriCorner(final int v, final int vt, final int vn);

class _PreparedObjSurface({
  required final TransferableTypedData vertices,
  required final TransferableTypedData indices,
  required final bool wideIndices,
  required final List<double>? kdRgb,
});

class _PreparedObj(final List<_PreparedObjSurface> surfaces);

class _PreparedSampler({
  required final int? magFilter,
  required final int? minFilter,
  required final int wrapS,
  required final int wrapT,
}) {
  factory _PreparedSampler.fromMap(Map<String, Object?> map) {
    return _PreparedSampler(
      magFilter: (map['magFilter'] as num?)?.toInt(),
      minFilter: (map['minFilter'] as num?)?.toInt(),
      wrapS: (map['wrapS'] as num?)?.toInt() ?? 10497,
      wrapT: (map['wrapT'] as num?)?.toInt() ?? 10497,
    );
  }

  TextureSampler toFlameSampler() {
    TextureWrap wrapOf(int code) => switch (code) {
      33071 => TextureWrap.clamp,
      33648 => TextureWrap.mirror,
      _ => TextureWrap.repeat,
    };
    final mag = magFilter == 9728
        ? TextureFilter.nearest
        : TextureFilter.linear;
    final min = switch (minFilter) {
      9728 || 9984 || 9986 => TextureFilter.nearest,
      _ => TextureFilter.linear,
    };
    final mip = switch (minFilter) {
      9984 || 9985 => TextureFilter.nearest,
      _ => TextureFilter.linear,
    };
    return TextureSampler(
      minFilter: min,
      magFilter: mag,
      mipFilter: mip,
      wrapU: wrapOf(wrapS),
      wrapV: wrapOf(wrapT),
    );
  }
}

class _PreparedMaterial({
  required final ui.Color baseColor,
  required final int? baseColorTex,
  required final double metallic,
  required final double roughness,
  required final int? metallicRoughnessTex,
  required final int? normalTex,
  required final double normalScale,
  required final int? occlusionTex,
  required final double occlusionStrength,
  required final int? emissiveTex,
  required final ui.Color emissiveColor,
  required final double emissiveStrength,
  required final double uvOffsetX,
  required final double uvOffsetY,
  required final double uvScaleX,
  required final double uvScaleY,
  required final String alphaMode,
  required final double alphaCutoff,
  required final bool doubleSided,
  required final bool isUnlit,
}) {
  factory _PreparedMaterial.fromMap(Map<String, Object?> map) {
    final pbr = map['pbrMetallicRoughness'] as Map<String, Object?>?;
    final bcf = (pbr?['baseColorFactor'] as List<Object?>?)
        ?.map((e) => (e! as num).toDouble())
        .toList(growable: false);
    final baseColor = bcf != null && bcf.length >= 4
        ? ui.Color.fromARGB(
            (bcf[3].clamp(0.0, 1.0) * 255).round(),
            (bcf[0].clamp(0.0, 1.0) * 255).round(),
            (bcf[1].clamp(0.0, 1.0) * 255).round(),
            (bcf[2].clamp(0.0, 1.0) * 255).round(),
          )
        : const ui.Color(0xFFFFFFFF);

    int? texIdxOf(Object? info) =>
        info is Map<String, Object?> ? (info['index'] as num?)?.toInt() : null;

    final baseTexInfo = pbr?['baseColorTexture'];
    var uvOffX = 0.0;
    var uvOffY = 0.0;
    var uvSclX = 1.0;
    var uvSclY = 1.0;
    if (baseTexInfo is Map<String, Object?>) {
      final texExts = baseTexInfo['extensions'];
      if (texExts is Map<String, Object?>) {
        final kt = texExts['KHR_texture_transform'];
        if (kt is Map<String, Object?>) {
          final off = kt['offset'] as List<Object?>?;
          if (off != null && off.length >= 2) {
            uvOffX = (off[0]! as num).toDouble();
            uvOffY = (off[1]! as num).toDouble();
          }
          final scl = kt['scale'] as List<Object?>?;
          if (scl != null && scl.length >= 2) {
            uvSclX = (scl[0]! as num).toDouble();
            uvSclY = (scl[1]! as num).toDouble();
          }
        }
      }
    }

    final normInfo = map['normalTexture'] as Map<String, Object?>?;
    final occInfo = map['occlusionTexture'] as Map<String, Object?>?;
    final emiFactor = (map['emissiveFactor'] as List<Object?>?)
        ?.map((e) => (e! as num).toDouble())
        .toList(growable: false);
    final emiColor = emiFactor != null && emiFactor.length >= 3
        ? ui.Color.fromARGB(
            255,
            (emiFactor[0].clamp(0.0, 1.0) * 255).round(),
            (emiFactor[1].clamp(0.0, 1.0) * 255).round(),
            (emiFactor[2].clamp(0.0, 1.0) * 255).round(),
          )
        : const ui.Color(0xFF000000);

    final exts = map['extensions'] as Map<String, Object?>?;
    final isUnlit = exts?['KHR_materials_unlit'] != null;
    final emiExt = exts?['KHR_materials_emissive_strength'];
    final emiStrength = emiExt is Map<String, Object?>
        ? (emiExt['emissiveStrength'] as num?)?.toDouble() ?? 1.0
        : 1.0;

    return _PreparedMaterial(
      baseColor: baseColor,
      baseColorTex: texIdxOf(baseTexInfo),
      metallic: (pbr?['metallicFactor'] as num?)?.toDouble() ?? 1.0,
      roughness: (pbr?['roughnessFactor'] as num?)?.toDouble() ?? 1.0,
      metallicRoughnessTex: texIdxOf(pbr?['metallicRoughnessTexture']),
      normalTex: texIdxOf(normInfo),
      normalScale: (normInfo?['scale'] as num?)?.toDouble() ?? 1.0,
      occlusionTex: texIdxOf(occInfo),
      occlusionStrength: (occInfo?['strength'] as num?)?.toDouble() ?? 1.0,
      emissiveTex: texIdxOf(map['emissiveTexture']),
      emissiveColor: emiColor,
      emissiveStrength: emiStrength,
      uvOffsetX: uvOffX,
      uvOffsetY: uvOffY,
      uvScaleX: uvSclX,
      uvScaleY: uvSclY,
      alphaMode: (map['alphaMode'] as String?) ?? 'OPAQUE',
      alphaCutoff: (map['alphaCutoff'] as num?)?.toDouble() ?? 0.5,
      doubleSided: (map['doubleSided'] as bool?) ?? false,
      isUnlit: isUnlit,
    );
  }
}

class _PreparedMorph({
  required final String name,
  required final TransferableTypedData posDeltas,
  required final TransferableTypedData? nrmDeltas,
});

class _PreparedSurface({
  required final TransferableTypedData vertices,
  required final TransferableTypedData indices,
  required final bool wideIndices,
  required final int? materialIndex,
  required final Map<int, int>? jointMap,
  required final List<_PreparedMorph> morphTargets,
});

class _PreparedMesh(
  final List<_PreparedSurface> surfaces,
  final List<double>? weights,
);

class _PreparedSkin(final List<int> joints, final Float64List? ibms);

class _PreparedNode({
  required final int nodeIndex,
  required final int? parentNodeIndex,
  required final String? name,
  required final Float64List transformStorage,
  required final int? meshIndex,
  required final int? skinIndex,
});

class _PreparedAnimChannel({
  required final int nodeIndex,
  required final String path,
  required final String interpolation,
  required final Float64List times,
  required final Float64List values,
});

class _PreparedAnimation(
  final String? name,
  final List<_PreparedAnimChannel> channels,
);

class _PreparedGlb({
  required final List<TransferableTypedData> images,
  required final List<_PreparedSampler> samplers,
  required final List<({int source, int? sampler})> textures,
  required final List<_PreparedMaterial> materials,
  required final List<_PreparedMesh> meshes,
  required final List<_PreparedSkin> skins,
  required final List<_PreparedNode> nodes,
  required final List<_PreparedAnimation> animations,
});
