import 'dart:ui' show Color;

import 'package:flame/components.dart';
import 'package:flame_3d_example/houses/houses_game.dart';
import 'package:flutter/painting.dart' show Shadow, TextStyle;

/// A readout of the 3D layer's render statistics and the frame time, for the
/// viewport of the [HousesGame].
class StatsReadout({required final HousesGame game}) extends TextComponent {
  this
    : super(
        position: Vector2.all(12),
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 13,
            height: 1.35,
            shadows: [Shadow(blurRadius: 2)],
          ),
        ),
      );

  double _frameTime = 1 / 60;
  double _sinceRefresh = double.infinity;

  @override
  void update(double dt) {
    super.update(dt);
    if (dt > 0) {
      _frameTime += (dt - _frameTime) * 0.1;
    }
    // Text layout is not free: refresh four times a second.
    _sinceRefresh += dt;
    if (_sinceRefresh < 0.25) {
      return;
    }
    _sinceRefresh = 0;
    final layer = game.layer;
    final stats = layer.renderStats;
    final layerMs = layer.lastRenderTime.inMicroseconds / 1000;
    text =
        '${game.houses.length} houses in one 3D layer\n'
        'draw calls ${stats.drawCalls}   instances ${stats.instances}   '
        'triangles ${stats.triangles}\n'
        '3D layer ${layerMs.toStringAsFixed(2)} ms (CPU)   '
        'frame ${(_frameTime * 1000).toStringAsFixed(1)} ms\n'
        'zoom ${game.camera.viewfinder.zoom.toStringAsFixed(2)}   '
        'drag to pan, pinch or scroll to zoom, tap a house';
  }
}
