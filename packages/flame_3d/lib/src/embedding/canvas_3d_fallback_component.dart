import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show BlendMode, Canvas, Color, Paint, VertexMode, Vertices;

import 'package:flame/components.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart' as f3d;
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';

/// {@template canvas_3d_fallback_component}
/// Cross-platform software-projected 2D [Canvas] fallback renderer for a
/// [World3D] using [Canvas.drawVertices].
///
/// Use this component on platforms or environments where Flutter GPU / WebGPU
/// is unavailable (`!GpuBackend.isAvailable`, such as desktop or legacy OpenGL
/// ES devices without `FLTEnableFlutterGPU`), allowing [MeshComponent],
/// [InstancedGroup3D], [ModelComponent], and [LightComponent] scenes in a
/// [World3D] to project, shade, depth-sort, and render cleanly via `dart:ui`.
/// {@endtemplate}
class Canvas3DFallbackComponent({
  required final World3D world,
  CameraComponent3D? camera,
  var bool cullBackFaces = true,
  super.position,
  super.size,
  super.scale,
  super.angle,
  super.anchor,
  super.priority,
}) extends PositionComponent {
  /// {@macro canvas_3d_fallback_component}
  this {
    if (!world.isMounted) {
      add(world);
    }
  }

  /// Camera driving the 3D-to-2D software projection.
  final CameraComponent3D camera =
      camera ??
      CameraComponent3D(
        position: f3d.Vector3(6, 5, 6),
        target: f3d.Vector3(0, 0.5, 0),
        up: f3d.Vector3(0, 1, 0),
        fovY: 50,
      );

  final f3d.Matrix4 _viewProj = f3d.Matrix4.identity();
  final f3d.Matrix4 _scratchModel = f3d.Matrix4.identity();
  final Paint _paint = Paint();

  Float32List _triPositions = Float32List(512 * 6);
  Int32List _triColors = Int32List(512 * 3);
  Float32List _triDepths = Float32List(512);
  Int32List _triOrder = Int32List(512);

  int _lastTrianglesSubmitted = 0;

  /// Total visible triangles projected and submitted in the most recent
  /// [render] pass.
  int get lastTrianglesSubmitted => _lastTrianglesSubmitted;

  void _ensureTriangleCapacity(int neededTris) {
    if (neededTris <= _triDepths.length) {
      return;
    }
    var nextCap = _triDepths.length;
    while (nextCap < neededTris) {
      nextCap *= 2;
    }
    final nextPos = Float32List(nextCap * 6)
      ..setRange(0, _triPositions.length, _triPositions);
    final nextCol = Int32List(nextCap * 3)
      ..setRange(0, _triColors.length, _triColors);
    final nextDep = Float32List(nextCap)
      ..setRange(0, _triDepths.length, _triDepths);
    _triPositions = nextPos;
    _triColors = nextCol;
    _triDepths = nextDep;
    _triOrder = Int32List(nextCap);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    final vpW = size.x > 0 ? size.x : 320.0;
    final vpH = size.y > 0 ? size.y : 200.0;
    final halfW = vpW * 0.5;
    final halfH = vpH * 0.5;

    final view = f3d.Matrix4.zero()
      ..setAsViewMatrix(camera.position, camera.target, camera.up);
    final proj = f3d.Matrix4.zero();
    if (camera.projection == CameraProjection.orthographic) {
      final h = (camera.orthographicHeight ?? 10.0) * 0.5;
      final w = h * (vpW / vpH);
      proj.setAsOrthographicOffCenter(-w, w, -h, h, camera.near, camera.far);
    } else {
      proj.setAsPerspective(camera.fovY, vpW / vpH, camera.near, camera.far);
    }
    _viewProj
      ..setFrom(proj)
      ..multiply(view);

    // Gather primary directional & ambient lighting from `world`.
    var sunX = 0.4;
    var sunY = 0.8;
    var sunZ = 0.45;
    var sunIntensity = 0.85;
    var ambient = 0.28;

    void scanLights(Component node) {
      if (node is LightComponent) {
        final src = node.source;
        if (src is DirectionalLight) {
          final d = src.direction;
          if (d != null && d.length2 > 1e-9) {
            final len = math.sqrt(d.length2);
            sunX = -d.x / len;
            sunY = -d.y / len;
            sunZ = -d.z / len;
          }
          sunIntensity = (src.intensity * 0.45).clamp(0.1, 1.5);
        } else if (src is AmbientLight) {
          ambient = src.intensity.clamp(0.05, 1.0);
        }
      }
      for (final child in node.children) {
        scanLights(child);
      }
    }

    scanLights(world);
    final sunLen = math.sqrt(sunX * sunX + sunY * sunY + sunZ * sunZ);
    if (sunLen > 1e-9) {
      sunX /= sunLen;
      sunY /= sunLen;
      sunZ /= sunLen;
    }

    var triCount = 0;

    void submitMesh(Mesh mesh, f3d.Matrix4 modelMatrix, Color instanceTint) {
      final m = modelMatrix.storage;
      final vp = _viewProj.storage;

      for (final surface in mesh.surfaces) {
        final stride = surface.layout.strideInFloats;
        final vCount = surface.vertexCount;
        final posOff = surface.layout.offsetOf(VertexLayout.positionAttribute);
        if (vCount == 0 || posOff == null) {
          continue;
        }
        final normOff = surface.layout.offsetOf('vertexNormal');
        final colOff = surface.layout.offsetOf('vertexColor');
        final vData = surface.vertexData;
        final indices = surface.indices;
        final baseTint = switch (surface.material) {
          final SpatialMaterial mat => mat.albedoColor,
          final StylizedMaterial mat => mat.albedoColor,
          final UnlitMaterial mat => mat.albedoColor,
          _ => const Color(0xFFFFFFFF),
        };
        final unlit = surface.material is UnlitMaterial;

        final surfTris = indices.length ~/ 3;
        _ensureTriangleCapacity(triCount + surfTris);

        for (var t = 0; t < surfTris; t++) {
          final i0 = indices[t * 3];
          final i1 = indices[t * 3 + 1];
          final i2 = indices[t * 3 + 2];

          double sx0 = 0;
          double sy0 = 0;
          double sx1 = 0;
          double sy1 = 0;
          double sx2 = 0;
          double sy2 = 0;
          double zSum = 0;
          var clipped = false;
          var c0 = 0;
          var c1 = 0;
          var c2 = 0;

          for (var corner = 0; corner < 3; corner++) {
            final vi = corner == 0
                ? i0
                : corner == 1
                ? i1
                : i2;
            final b = vi * stride;
            final lx = vData[b + posOff];
            final ly = vData[b + posOff + 1];
            final lz = vData[b + posOff + 2];

            final wx = m[0] * lx + m[4] * ly + m[8] * lz + m[12];
            final wy = m[1] * lx + m[5] * ly + m[9] * lz + m[13];
            final wz = m[2] * lx + m[6] * ly + m[10] * lz + m[14];

            final cx = vp[0] * wx + vp[4] * wy + vp[8] * wz + vp[12];
            final cy = vp[1] * wx + vp[5] * wy + vp[9] * wz + vp[13];
            final cz = vp[2] * wx + vp[6] * wy + vp[10] * wz + vp[14];
            final cw = vp[3] * wx + vp[7] * wy + vp[11] * wz + vp[15];

            if (cw <= 1e-4) {
              clipped = true;
              break;
            }
            final invW = 1.0 / cw;
            final ndcX = cx * invW;
            final ndcY = cy * invW;
            final ndcZ = cz * invW;
            if (ndcZ < -1.0 || ndcZ > 1.5) {
              clipped = true;
              break;
            }
            final px = halfW + ndcX * halfW;
            final py = halfH - ndcY * halfH;
            zSum += ndcZ;

            var cr = baseTint.r * instanceTint.r;
            var cg = baseTint.g * instanceTint.g;
            var cb = baseTint.b * instanceTint.b;
            var ca = baseTint.a * instanceTint.a;
            if (colOff != null) {
              cr *= vData[b + colOff];
              cg *= vData[b + colOff + 1];
              cb *= vData[b + colOff + 2];
              ca *= vData[b + colOff + 3];
            }

            var shade = 1.0;
            if (!unlit && normOff != null) {
              final nx = vData[b + normOff];
              final ny = vData[b + normOff + 1];
              final nz = vData[b + normOff + 2];
              var wnx = m[0] * nx + m[4] * ny + m[8] * nz;
              var wny = m[1] * nx + m[5] * ny + m[9] * nz;
              var wnz = m[2] * nx + m[6] * ny + m[10] * nz;
              final nLen = math.sqrt(wnx * wnx + wny * wny + wnz * wnz);
              if (nLen > 1e-9) {
                wnx /= nLen;
                wny /= nLen;
                wnz /= nLen;
              }
              final ndotl = math.max(
                0.0,
                wnx * sunX + wny * sunY + wnz * sunZ,
              );
              shade = (ambient + ndotl * sunIntensity).clamp(0.0, 1.35);
            }

            final argb =
                ((ca.clamp(0.0, 1.0) * 255).round() << 24) |
                (((cr * shade).clamp(0.0, 1.0) * 255).round() << 16) |
                (((cg * shade).clamp(0.0, 1.0) * 255).round() << 8) |
                ((cb * shade).clamp(0.0, 1.0) * 255).round();

            if (corner == 0) {
              sx0 = px;
              sy0 = py;
              c0 = argb;
            } else if (corner == 1) {
              sx1 = px;
              sy1 = py;
              c1 = argb;
            } else {
              sx2 = px;
              sy2 = py;
              c2 = argb;
            }
          }

          if (clipped) {
            continue;
          }

          if (cullBackFaces) {
            // Screen Y points downward, so CCW in clip space has negative
            // signed area `(sx1 - sx0)*(sy2 - sy0) - (sy1 - sy0)*(sx2 - sx0)`.
            final area2 = (sx1 - sx0) * (sy2 - sy0) - (sy1 - sy0) * (sx2 - sx0);
            if (area2 >= 0) {
              continue;
            }
          }

          final baseP = triCount * 6;
          _triPositions
            ..[baseP] = sx0
            ..[baseP + 1] = sy0
            ..[baseP + 2] = sx1
            ..[baseP + 3] = sy1
            ..[baseP + 4] = sx2
            ..[baseP + 5] = sy2;
          final baseC = triCount * 3;
          _triColors
            ..[baseC] = c0
            ..[baseC + 1] = c1
            ..[baseC + 2] = c2;
          _triDepths[triCount] = zSum;
          triCount++;
        }
      }
    }

    void visitScene(Component comp) {
      if (comp is MeshComponent) {
        submitMesh(comp.mesh, comp.worldTransformMatrix, comp.color);
      } else if (comp is InstancedGroup3D) {
        final groupWorld = comp.worldTransformMatrix;
        for (var i = 0; i < comp.length; i++) {
          _scratchModel
            ..setFrom(groupWorld)
            ..multiply(comp.instanceTransform(i));
          submitMesh(comp.mesh, _scratchModel, const Color(0xFFFFFFFF));
        }
      } else if (comp is ModelComponent) {
        final workspace = comp.evaluatePose();
        final modelWorld = comp.worldTransformMatrix;
        for (final posedNode in workspace.orderedNodes) {
          final mesh = posedNode.node.mesh;
          if (mesh != null) {
            _scratchModel
              ..setFrom(modelWorld)
              ..multiply(posedNode.combinedTransform);
            submitMesh(mesh, _scratchModel, comp.color);
          }
        }
      }
      for (final child in comp.children) {
        visitScene(child);
      }
    }

    visitScene(world);
    _lastTrianglesSubmitted = triCount;
    if (triCount == 0) {
      return;
    }

    // Back-to-front painter's sort by average clip depth (`zSum`).
    for (var i = 0; i < triCount; i++) {
      _triOrder[i] = i;
    }
    final orderSlice = _triOrder.sublist(0, triCount)
      ..sort((a, b) => _triDepths[b].compareTo(_triDepths[a]));

    final sortedPos = Float32List(triCount * 6);
    final sortedCol = Int32List(triCount * 3);
    for (var i = 0; i < triCount; i++) {
      final src = orderSlice[i];
      final sp = src * 6;
      final dp = i * 6;
      sortedPos
        ..[dp] = _triPositions[sp]
        ..[dp + 1] = _triPositions[sp + 1]
        ..[dp + 2] = _triPositions[sp + 2]
        ..[dp + 3] = _triPositions[sp + 3]
        ..[dp + 4] = _triPositions[sp + 4]
        ..[dp + 5] = _triPositions[sp + 5];
      final sc = src * 3;
      final dc = i * 3;
      sortedCol
        ..[dc] = _triColors[sc]
        ..[dc + 1] = _triColors[sc + 1]
        ..[dc + 2] = _triColors[sc + 2];
    }

    final vertices = Vertices.raw(
      VertexMode.triangles,
      sortedPos,
      colors: sortedCol,
    );
    canvas.drawVertices(vertices, BlendMode.dst, _paint);
    vertices.dispose();
  }
}
