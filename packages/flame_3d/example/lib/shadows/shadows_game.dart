import 'dart:math' as math;
import 'dart:ui' show Color;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flame_3d_example/houses/board_grid.dart';
import 'package:flutter/painting.dart' show Shadow, TextStyle;

/// A 2D game whose 3D objects cast real-time shadows onto its 2D ground.
///
/// The ground is 2D art (a grid drawn with the canvas). The 3D layer above it
/// has a sun that casts shadows and circles slowly around the board, and an
/// invisible ground of [ShadowCatcherMaterial] that draws the shadows falling
/// on it over the 2D grid. The objects receive the shadows of each other.
/// Drag to pan, tap to switch the shadows on and off.
class ShadowsGame() extends FlameGame with DragCallbacks, TapCallbacks {
  static const int boardSize = 8;

  /// The same dimetric projection as the houses example: cells of 88 by 44
  /// pixels, z up.
  static final Scene3DProjection projection = Scene3DProjection.affine(
    origin: Vector2(0, -18),
    xAxis: Vector2(44, 22),
    yAxis: Vector2(-44, 22),
    zAxis: Vector2(0, -53.889),
    towardsViewer: Vector3(0.6124, 0.6124, 0.5),
    near: -20,
    far: 20,
  );

  late final Scene3DComponent layer;
  late final LightComponent sun;
  late final TextComponent _readout;

  /// Cool, slightly blue shadows: the sunlight is taken away in red and green
  /// more than in blue, and the hemisphere light stays.
  final ShadowSettings shadows = ShadowSettings(
    strength: 0.8,
    color: const Color(0xFF1E2A55),
  );

  double _time = 0;

  @override
  Color backgroundColor() => const Color(0xFF17221A);

  @override
  Future<void> onLoad() async {
    layer = Scene3DComponent(
      projection: projection,
      msaa: Msaa.sample4,
      priority: 1,
    );
    world.addAll([
      BoardGrid(cells: boardSize, projection: projection),
      layer,
    ]);

    sun = LightComponent.directional(
      direction: _sunDirection(0),
      intensity: 0.75,
      shadows: shadows,
    );
    final material = StylizedMaterial();
    final block = CuboidMesh(size: Vector3(0.6, 1, 0.6), material: material);
    final tower = CylinderMesh(
      radius: 0.25,
      height: 1.6,
      material: material,
    );
    final roof = ConeMesh(radius: 0.4, height: 0.5, material: material);
    // Every mesh is built with y up; the board has z up.
    final upright = Quaternion.axisAngle(Vector3(1, 0, 0), math.pi / 2);

    layer.world.addAll([
      LightComponent.hemisphere(
        skyColor: const Color(0xFFB4CCF0),
        groundColor: const Color(0xFF6E7A50),
        intensity: 0.55,
        up: Vector3(0, 0, 1),
      ),
      sun,
      MeshComponent(
        mesh: PlaneMesh(
          size: Vector2.all(boardSize.toDouble()),
          material: ShadowCatcherMaterial(color: const Color(0xB31B2440)),
        ),
        position: Vector3(boardSize / 2, boardSize / 2, 0),
        rotation: upright,
      ),
      for (final (i, j, color) in _blocks)
        MeshComponent(
          mesh: block,
          position: Vector3(i + 0.5, j + 0.5, 0.5),
          rotation: upright,
          color: color,
        ),
      for (final (i, j) in _towers) ...[
        MeshComponent(
          mesh: tower,
          position: Vector3(i + 0.5, j + 0.5, 0.8),
          rotation: upright,
          color: const Color(0xFFD9C3A0),
        ),
        MeshComponent(
          mesh: roof,
          position: Vector3(i + 0.5, j + 0.5, 1.6),
          rotation: upright,
          color: const Color(0xFFB0412E),
        ),
      ],
    ]);

    camera.viewfinder.position = layer.scenePointToLocal(
      Vector3(boardSize / 2, boardSize / 2, 0),
    );
    camera.viewport.add(
      _readout = TextComponent(
        position: Vector2.all(12),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 13,
            height: 1.35,
            shadows: [Shadow(blurRadius: 2)],
          ),
        ),
      ),
    );
  }

  static const _blocks = [
    (1, 1, Color(0xFFE8DCC4)),
    (2, 5, Color(0xFFC9D6DF)),
    (5, 2, Color(0xFFE4C9B6)),
    (6, 6, Color(0xFFF2E9D8)),
    (3, 3, Color(0xFFD9C3A0)),
  ];

  static const _towers = [(4, 5), (6, 3), (1, 4)];

  /// The direction of the sun at [time]: it circles slowly around the
  /// board, 40 degrees above the horizon, starting on the left of the viewer
  /// so that the shadows fall to the right.
  static Vector3 _sunDirection(double time) {
    final angle = time * 0.15 - 1.25;
    return Vector3(math.cos(angle), math.sin(angle), -0.84);
  }

  double _sinceRefresh = double.infinity;

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    (sun.source as DirectionalLight).direction = _sunDirection(_time);

    _sinceRefresh += dt;
    if (_sinceRefresh < 0.25) {
      return;
    }
    _sinceRefresh = 0;
    final stats = layer.renderStats;
    final layerMs = layer.lastRenderTime.inMicroseconds / 1000;
    final on = (sun.source as DirectionalLight).shadows != null;
    _readout.text =
        'shadows ${on ? 'on' : 'off'} (tap to switch), drag to pan\n'
        'passes ${stats.renderPasses} (shadow ${stats.shadowPasses})   '
        'draw calls ${stats.drawCalls} (shadow ${stats.shadowDrawCalls})\n'
        '3D layer ${layerMs.toStringAsFixed(2)} ms (CPU)';
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    camera.moveBy(-event.localDelta / camera.viewfinder.zoom);
  }

  @override
  void onTapUp(TapUpEvent event) {
    final light = sun.source as DirectionalLight;
    light.shadows = light.shadows == null ? shadows : null;
  }
}
