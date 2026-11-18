import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:flame/components.dart' show Component;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/model.dart';
import 'package:flame_3d/resources.dart';

/// {@template debug_renderer_3d}
/// Batched 3D debug wireframe and gizmo overlay for a [World3D].
///
/// Packs all automatic scene inspection wireframes (world-space [Object3D]
/// AABBs, [ModelComponent] bone skeletons, [PointLight] range spheres,
/// [SpotLight] cones, and [SceneSpatialIndex3D] BVH bounds) plus custom
/// per-frame [drawLine], [drawAabb], [drawObb], [drawSphere], [drawCapsule],
/// [drawCone], [drawAxes], and [drawPolyline] segments into **1 single
/// instanced GPU draw call**.
/// {@endtemplate}
class DebugRenderer3D({
  var bool enabled = true,
  var bool showObjectBounds = true,
  var bool showSkeletons = true,
  var bool showLightVolumes = true,
  var bool xray = false,
  var double lineThickness = 0.022,
  super.cameraMask,
}) extends Object3D {
  /// {@macro debug_renderer_3d}
  this : super(castsShadows: false) {
    _material.castsShadows = false;
    _syncRenderState();
  }

  final UnlitMaterial _material = UnlitMaterial();

  late final CuboidMesh _unitBar = CuboidMesh(
    size: Vector3.all(1.0),
    material: _material,
  );

  Float32List _instanceBuffer = Float32List(256 * 24);
  int _queuedSegments = 0;
  int _lastFlushedSegments = 0;
  final Aabb3 _localBounds = Aabb3.minMax(
    Vector3.all(-1e5),
    Vector3.all(1e5),
  );

  /// Number of 3D line segments submitted in the last rendered pass.
  int get lastSegmentCount => _lastFlushedSegments;

  void _syncRenderState() {
    _material.renderState = xray
        ? const RenderState(
            depthTest: false,
            depthWrite: false,
          )
        : RenderState.opaque;
  }

  @override
  Aabb3? computeLocalAabb() => _localBounds;

  @override
  bool isVisible(Frustum frustum) => enabled;

  /// Clears custom immediate segments accumulated before the next pass.
  void clearCustomSegments() {
    _queuedSegments = 0;
  }

  /// Appends a colored 3D line segment `[start .. end]` for the upcoming pass.
  void drawLine(
    Vector3 start,
    Vector3 end, {
    Color color = const Color(0xFF38BDF8),
    double? thickness,
  }) {
    final dx = end.x - start.x;
    final dy = end.y - start.y;
    final dz = end.z - start.z;
    final len = math.sqrt(dx * dx + dy * dy + dz * dz);
    if (len < 1e-6) {
      return;
    }

    final ux = dx / len;
    final uy = dy / len;
    final uz = dz / len;

    // Orthonormal basis `(r, u, f)` with `u` aligned along the segment.
    double rx;
    double ry;
    double rz;
    if (uy.abs() < 0.92) {
      // cross((0, 1, 0), u) = (uz, 0, -ux)
      final rLen = math.sqrt(uz * uz + ux * ux);
      rx = uz / rLen;
      ry = 0.0;
      rz = -ux / rLen;
    } else {
      // cross((1, 0, 0), u) = (0, -uz, uy)
      final rLen = math.sqrt(uz * uz + uy * uy);
      rx = 0.0;
      ry = -uz / rLen;
      rz = uy / rLen;
    }
    // f = cross(r, u)
    final fx = ry * uz - rz * uy;
    final fy = rz * ux - rx * uz;
    final fz = rx * uy - ry * ux;

    final w = thickness ?? lineThickness;
    final mx = (start.x + end.x) * 0.5;
    final my = (start.y + end.y) * 0.5;
    final mz = (start.z + end.z) * 0.5;

    final needed = (_queuedSegments + 1) * 24;
    if (needed > _instanceBuffer.length) {
      final grown = Float32List(math.max(needed, _instanceBuffer.length * 2));
      grown.setRange(0, _queuedSegments * 24, _instanceBuffer);
      _instanceBuffer = grown;
    }

    final base = _queuedSegments * 24;
    final buf = _instanceBuffer;
    // Column 0: r * w
    buf[base] = rx * w;
    buf[base + 1] = ry * w;
    buf[base + 2] = rz * w;
    buf[base + 3] = 0.0;
    // Column 1: u * len
    buf[base + 4] = ux * len;
    buf[base + 5] = uy * len;
    buf[base + 6] = uz * len;
    buf[base + 7] = 0.0;
    // Column 2: f * w
    buf[base + 8] = fx * w;
    buf[base + 9] = fy * w;
    buf[base + 10] = fz * w;
    buf[base + 11] = 0.0;
    // Column 3: midpoint translation
    buf[base + 12] = mx;
    buf[base + 13] = my;
    buf[base + 14] = mz;
    buf[base + 15] = 1.0;
    // Instance RGBA color
    buf[base + 16] = color.r;
    buf[base + 17] = color.g;
    buf[base + 18] = color.b;
    buf[base + 19] = color.a;
    // Instance data
    buf[base + 20] = 0.0;
    buf[base + 21] = 0.0;
    buf[base + 22] = 0.0;
    buf[base + 23] = 0.0;

    _queuedSegments++;
  }

  /// Draws the 12 wireframe edges of world-space [box].
  void drawAabb(
    Aabb3 box, {
    Color color = const Color(0xFF22D3EE),
    double? thickness,
  }) {
    final x0 = box.min.x;
    final y0 = box.min.y;
    final z0 = box.min.z;
    final x1 = box.max.x;
    final y1 = box.max.y;
    final z1 = box.max.z;
    if ((x1 - x0).abs() > 1e4 || (y1 - y0).abs() > 1e4) {
      return;
    }

    final p000 = Vector3(x0, y0, z0);
    final p100 = Vector3(x1, y0, z0);
    final p010 = Vector3(x0, y1, z0);
    final p110 = Vector3(x1, y1, z0);
    final p001 = Vector3(x0, y0, z1);
    final p101 = Vector3(x1, y0, z1);
    final p011 = Vector3(x0, y1, z1);
    final p111 = Vector3(x1, y1, z1);

    drawLine(p000, p100, color: color, thickness: thickness);
    drawLine(p100, p110, color: color, thickness: thickness);
    drawLine(p110, p010, color: color, thickness: thickness);
    drawLine(p010, p000, color: color, thickness: thickness);

    drawLine(p001, p101, color: color, thickness: thickness);
    drawLine(p101, p111, color: color, thickness: thickness);
    drawLine(p111, p011, color: color, thickness: thickness);
    drawLine(p011, p001, color: color, thickness: thickness);

    drawLine(p000, p001, color: color, thickness: thickness);
    drawLine(p100, p101, color: color, thickness: thickness);
    drawLine(p110, p111, color: color, thickness: thickness);
    drawLine(p010, p011, color: color, thickness: thickness);
  }

  /// Draws an oriented bounding box defined by [halfExtents] transformed by
  /// [worldTransform].
  void drawObb(
    Vector3 halfExtents,
    Matrix4 worldTransform, {
    Color color = const Color(0xFFA855F7),
    double? thickness,
  }) {
    final hx = halfExtents.x;
    final hy = halfExtents.y;
    final hz = halfExtents.z;
    final corners = <Vector3>[
      worldTransform.transformed3(Vector3(-hx, -hy, -hz)),
      worldTransform.transformed3(Vector3(hx, -hy, -hz)),
      worldTransform.transformed3(Vector3(hx, hy, -hz)),
      worldTransform.transformed3(Vector3(-hx, hy, -hz)),
      worldTransform.transformed3(Vector3(-hx, -hy, hz)),
      worldTransform.transformed3(Vector3(hx, -hy, hz)),
      worldTransform.transformed3(Vector3(hx, hy, hz)),
      worldTransform.transformed3(Vector3(-hx, hy, hz)),
    ];
    for (var i = 0; i < 4; i++) {
      final next = (i + 1) & 3;
      drawLine(corners[i], corners[next], color: color, thickness: thickness);
      drawLine(
        corners[i + 4],
        corners[next + 4],
        color: color,
        thickness: thickness,
      );
      drawLine(corners[i], corners[i + 4], color: color, thickness: thickness);
    }
  }

  /// Draws 3 orthogonal wireframe rings representing a sphere at [center].
  void drawSphere(
    Vector3 center,
    double radius, {
    Color color = const Color(0xFFFBBF24),
    int segments = 16,
    double? thickness,
  }) {
    final a = Vector3.zero();
    final b = Vector3.zero();
    for (var i = 0; i < segments; i++) {
      final t0 = (i / segments) * 2.0 * math.pi;
      final t1 = ((i + 1) / segments) * 2.0 * math.pi;
      final c0 = math.cos(t0) * radius;
      final s0 = math.sin(t0) * radius;
      final c1 = math.cos(t1) * radius;
      final s1 = math.sin(t1) * radius;

      a.setValues(center.x + c0, center.y + s0, center.z);
      b.setValues(center.x + c1, center.y + s1, center.z);
      drawLine(a, b, color: color, thickness: thickness);

      a.setValues(center.x + c0, center.y, center.z + s0);
      b.setValues(center.x + c1, center.y, center.z + s1);
      drawLine(a, b, color: color, thickness: thickness);

      a.setValues(center.x, center.y + c0, center.z + s0);
      b.setValues(center.x, center.y + c1, center.z + s1);
      drawLine(a, b, color: color, thickness: thickness);
    }
  }

  /// Draws a wireframe capsule between segment endpoints [p0] and [p1].
  void drawCapsule(
    Vector3 p0,
    Vector3 p1,
    double radius, {
    Color color = const Color(0xFF34D399),
    double? thickness,
  }) {
    drawSphere(p0, radius, color: color, segments: 12, thickness: thickness);
    drawSphere(p1, radius, color: color, segments: 12, thickness: thickness);
    drawLine(p0, p1, color: color, thickness: thickness);
  }

  /// Draws a wireframe spotlight cone from [apex] along [direction].
  void drawCone(
    Vector3 apex,
    Vector3 direction, {
    required double length,
    required double halfAngleRad,
    Color color = const Color(0xFFF472B6),
    int segments = 12,
    double? thickness,
  }) {
    final dir = direction.normalized();
    final ref = dir.y.abs() < 0.9 ? Vector3(0, 1, 0) : Vector3(1, 0, 0);
    final right = ref.cross(dir)..normalize();
    final up = dir.cross(right)..normalize();
    final baseCenter = apex + dir * length;
    final r = math.tan(halfAngleRad.clamp(0.02, 1.45)) * length;

    Vector3 ringPoint(int idx) {
      final t = (idx / segments) * 2.0 * math.pi;
      return baseCenter + right * (math.cos(t) * r) + up * (math.sin(t) * r);
    }

    for (var i = 0; i < segments; i++) {
      final p0 = ringPoint(i);
      final p1 = ringPoint(i + 1);
      drawLine(p0, p1, color: color, thickness: thickness);
      if (i % 3 == 0) {
        drawLine(apex, p0, color: color, thickness: thickness);
      }
    }
  }

  /// Draws RGB (`+X`, `+Y`, `+Z`) coordinate triad axes at [transform].
  void drawAxes(
    Matrix4 transform, {
    double size = 0.5,
    double? thickness,
  }) {
    final o = transform.getTranslation();
    final xEnd = transform.transformed3(Vector3(size, 0, 0));
    final yEnd = transform.transformed3(Vector3(0, size, 0));
    final zEnd = transform.transformed3(Vector3(0, 0, size));
    drawLine(o, xEnd, color: const Color(0xFFEF4444), thickness: thickness);
    drawLine(o, yEnd, color: const Color(0xFF22C55E), thickness: thickness);
    drawLine(o, zEnd, color: const Color(0xFF3B82F6), thickness: thickness);
  }

  /// Draws connected polyline segments across [points].
  void drawPolyline(
    List<Vector3> points, {
    Color color = const Color(0xFFFACC15),
    bool closed = false,
    double? thickness,
  }) {
    for (var i = 0; i + 1 < points.length; i++) {
      drawLine(points[i], points[i + 1], color: color, thickness: thickness);
    }
    if (closed && points.length >= 3) {
      drawLine(points.last, points.first, color: color, thickness: thickness);
    }
  }

  void _gatherSceneDebug(World3D world) {
    void visit(Component comp) {
      if (identical(comp, this)) {
        return;
      }
      if (comp is ModelComponent && showSkeletons) {
        final pose = comp.evaluatePose();
        final wm = comp.worldTransformMatrix;
        for (final posedNode in pose.orderedNodes) {
          final parentIdx = posedNode.node.parentNodeIndex;
          if (parentIdx != null) {
            final parentPose = pose.nodesByIndex[parentIdx];
            if (parentPose != null) {
              final p0 = wm.transformed3(
                parentPose.combinedTransform.getTranslation(),
              );
              final p1 = wm.transformed3(
                posedNode.combinedTransform.getTranslation(),
              );
              drawLine(p0, p1, color: const Color(0xFFFDE047));
            }
          }
        }
      }
      if (comp is Object3D && showObjectBounds && comp is! SkyboxComponent3D) {
        drawAabb(comp.aabb, color: const Color(0xFF38BDF8));
      } else if (comp is LightComponent && showLightVolumes) {
        final pos = comp.worldTransformMatrix.getTranslation();
        switch (comp.source) {
          case final PointLight pt:
            drawSphere(
              pos,
              pt.range ?? 1.2,
              color: pt.color,
              segments: 12,
            );
          case final SpotLight sp:
            final dir =
                sp.direction ??
                (Vector3(
                  -comp.worldTransformMatrix.storage[8],
                  -comp.worldTransformMatrix.storage[9],
                  -comp.worldTransformMatrix.storage[10],
                ));
            drawCone(
              pos,
              dir,
              length: sp.range ?? 4.0,
              halfAngleRad: sp.outerConeAngle,
              color: sp.color,
            );
          default:
            break;
        }
      }
      for (final child in comp.children) {
        visit(child);
      }
    }

    for (final child in world.children) {
      visit(child);
    }
  }

  @override
  void draw(covariant RenderContext3D context) {
    if (!enabled || context.isShadowPass || context.isDepthNormalPass) {
      return;
    }
    _syncRenderState();
    final savedCustomCount = _queuedSegments;
    final world = worldOrNull;
    if (world != null) {
      _gatherSceneDebug(world);
    }
    _lastFlushedSegments = _queuedSegments;
    if (_queuedSegments > 0) {
      final surface = _unitBar.surfaces.single;
      context.drawInstances(
        surface,
        instances: Float32List.sublistView(
          _instanceBuffer,
          0,
          _queuedSegments * 24,
        ),
        count: _queuedSegments,
        material: _material,
      );
    }
    _queuedSegments = savedCustomCount;
  }
}
