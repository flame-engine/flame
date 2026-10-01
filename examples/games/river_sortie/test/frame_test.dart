/// The river, drawn: a frame through the game's own camera on a CPU device,
/// with no widget tree and no `GameWidget`, the way
/// `site/content/reference/testing.md` draws one frame of a game.
library;

import 'dart:typed_data';

import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter3d_cpu/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:river_sortie/src/models.dart';
import 'package:river_sortie/src/river_game.dart';
import 'package:vector_math/vector_math.dart' hide Plane;

const int _width = 160;
const int _height = 90;

/// The game's world and a frame of it, from where `RiverScreen` puts its
/// camera: behind the jet and above it, looking up the river. [stage] runs
/// once the game has its renderer, before the frame is drawn.
Future<({Uint8List rgba, int drawCalls})> _frame({
  void Function(RiverGame game)? stage,
}) async {
  final it = cpuTestDevice(width: _width, height: _height);
  final game = await initializeGame(RiverGame.new);
  final scene = Scene();
  game.open3d(it.device, scene: scene);
  await game.ready();

  final camera =
      CameraNode(
          projection: const PerspectiveProjection(
            fovYRadians: 0.85,
            far: 400.0,
          ),
        )
        ..setPosition(0.0, flightHeight + 11.0, -game.distance + 11.0)
        ..lookAt(Vector3(0.0, 0.0, -game.distance - 9.0));
  scene.add(camera);

  final renderer = Renderer.create(
    device: it.device,
    fallbackAlbedo: it.albedo,
    fallbackNormal: it.normal,
  );
  game.attachRenderer(renderer);
  stage?.call(game);
  final result = renderer.render(
    width: _width,
    height: _height,
    scene: scene,
    views: <RenderView>[
      RenderView(camera: camera, clearColor: Vector4(0.27, 0.48, 0.78, 1.0)),
    ],
  );
  final pixels = await it.device.readPixels(result.frame);
  return (rgba: pixels!.buffer.asUint8List(), drawCalls: result.drawCalls);
}

void main() {
  test('the valley, the water and the jet are all drawn', () async {
    final (:rgba, :drawCalls) = await _frame();
    expect(drawCalls, greaterThan(3));

    // Grass is green-dominant and water blue-dominant; a frame with both
    // has the land and the river where the camera expects them, and not
    // everything at the origin or the wrong colour.
    var grass = 0;
    var water = 0;
    for (var i = 0; i < rgba.length; i += 4) {
      final (r, g, b) = (rgba[i], rgba[i + 1], rgba[i + 2]);
      if (g > r + 20 && g > b + 20) {
        grass++;
      }
      if (b > r + 30 && b > g + 10) {
        water++;
      }
    }
    const pixels = _width * _height;
    expect(grass, greaterThan(pixels ~/ 10), reason: 'too little land');
    expect(water, greaterThan(pixels ~/ 20), reason: 'too little river');
  });

  test('a fireball is drawn, through the particle pool', () async {
    // The same few frames of flight either way, so the one difference
    // between the two pictures is the blast, its shards out of one point.
    Future<({Uint8List rgba, int drawCalls})> after({required bool blast}) =>
        _frame(
          stage: (game) {
            if (blast) {
              game.fireball(
                Vector3(game.jet.position.x, 1.5, -game.distance - 6.0),
                size: 1.6,
              );
            }
            for (var i = 0; i < 6; i++) {
              game.update(1 / 60);
            }
          },
        );

    final calm = await after(blast: false);
    final blast = await after(blast: true);
    expect(blast.drawCalls, calm.drawCalls + 1, reason: 'one draw for all');
    // Additive: every pixel a shard covers is brighter than without it.
    var lit = 0;
    for (var i = 0; i < calm.rgba.length; i += 4) {
      if (blast.rgba[i] > calm.rgba[i] + 40) {
        lit++;
      }
    }
    expect(lit, greaterThan(20));
  });

  test('smoke is drawn darkening what is behind it', () async {
    Future<({Uint8List rgba, int drawCalls})> after({required bool smoke}) =>
        _frame(
          stage: (game) {
            if (smoke) {
              // Several puffs, so the darkened patch is more than a pixel
              // or two at this size.
              for (var i = 0; i < 6; i++) {
                game.smoke(
                  Vector3(
                    game.jet.position.x - 1.5 + i * 0.6,
                    1.0,
                    -game.distance - 6.0,
                  ),
                );
              }
            }
            for (var i = 0; i < 20; i++) {
              game.update(1 / 60);
            }
          },
        );

    final clear = await after(smoke: false);
    final smoky = await after(smoke: true);
    expect(smoky.drawCalls, clear.drawCalls + 1, reason: 'one draw for all');
    var darker = 0;
    var brighter = 0;
    for (var i = 0; i < clear.rgba.length; i += 4) {
      final before = clear.rgba[i] + clear.rgba[i + 1] + clear.rgba[i + 2];
      final now = smoky.rgba[i] + smoky.rgba[i + 1] + smoky.rgba[i + 2];
      if (now < before - 25) {
        darker++;
      }
      if (now > before + 30) {
        brighter++;
      }
    }
    expect(darker, greaterThan(20));
    expect(brighter, 0, reason: 'smoke takes light away and adds none');
  });
}
