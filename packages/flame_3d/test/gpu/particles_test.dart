import 'dart:typed_data';
import 'dart:ui' show Color, Size;

import 'package:flame/components.dart' show World;
import 'package:flame/game.dart' show FlameGame, Game, GameWidget;
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' show GlobalKey, RepaintBoundary;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);
const _blue = Color(0xFF0000FF);
const _white = Color(0xFFFFFFFF);

/// A material drawing solid quads (no sprite), straight from the particle
/// colors.
ParticleMaterial _solid({
  RenderState renderState = RenderState.premultipliedAlphaBlend,
  Texture? texture,
  int columns = 1,
  int rows = 1,
}) {
  return ParticleMaterial(
    sprite: ParticleSprite.texture,
    texture: texture,
    flipbookColumns: columns,
    flipbookRows: rows,
    renderState: renderState,
  );
}

/// A texture of 2x2 pixels: red and green on the top row, blue and white on
/// the bottom one.
Texture _quadrants() {
  return Texture(
    ByteData.sublistView(
      Uint8List.fromList([
        for (final color in [_red, _green, _blue, _white]) ...[
          (color.r * 255).round(),
          (color.g * 255).round(),
          (color.b * 255).round(),
          (color.a * 255).round(),
        ],
      ]),
    ),
    width: 2,
    height: 2,
  );
}

(int, int, int, int) _rgba(Color color) => (
  (color.r * 255).round(),
  (color.g * 255).round(),
  (color.b * 255).round(),
  (color.a * 255).round(),
);

void main() {
  setUpGpu();

  group('particles', () {
    // An opaque blue box in front of the far particles, behind the near ones.
    final box = CuboidMesh(
      size: Vector3(1.8, 0.6, 1),
      material: opaqueUnlit(_blue),
    );
    final boxTransform = Matrix4.translationValues(0, 0, -5);

    testGpuEngine('are hidden behind opaque geometry', () async {
      final system = ParticleSystem3D(capacity: 4, material: _solid())
        // Behind the box.
        ..spawn(position: Vector3(-0.5, 0, -8), size: 0.4, color: _red)
        // Behind, above the box: nothing hides it.
        ..spawn(position: Vector3(0, 0.7, -8), size: 0.4, color: _red);
      final frame = await renderFrame(
        draw: (context) {
          context.drawMesh(box, transform: boxTransform);
          system.draw(context);
        },
      );
      final (hx, hy) = pixelAt(-0.5, 0);
      expect(frame.pixels.at(hx, hy), _rgba(_blue));
      final (vx, vy) = pixelAt(0, 0.7);
      expect(frame.pixels.at(vx, vy), _rgba(_red));
    });

    testGpuEngine('are visible in front of opaque geometry', () async {
      final system = ParticleSystem3D(capacity: 4, material: _solid())
        ..spawn(position: Vector3(0.5, 0, -2), size: 0.4, color: _red);
      final frame = await renderFrame(
        draw: (context) {
          system.draw(context);
          context.drawMesh(box, transform: boxTransform);
        },
      );
      final (x, y) = pixelAt(0.5, 0);
      expect(frame.pixels.at(x, y), _rgba(_red));
      final (bx, by) = pixelAt(-0.5, 0);
      expect(frame.pixels.at(bx, by), _rgba(_blue));
      expect(frame.stats.particles, 1);
    });

    testGpuEngine('add their color with additive blending', () async {
      final system =
          ParticleSystem3D(
              capacity: 4,
              material: _solid(renderState: RenderState.additive),
            )
            ..spawn(
              position: Vector3(0, 0, -2),
              size: 0.5,
              color: const Color(0xFF800000),
            )
            ..spawn(
              position: Vector3(0, 0, -3),
              size: 0.5,
              color: const Color(0xFF008000),
            )
            // Over the box.
            ..spawn(
              position: Vector3(-0.6, 0, -2),
              size: 0.3,
              color: const Color(0xFF800000),
            )
            // Half faded: adds half its color.
            ..spawn(
              position: Vector3(0.6, 0.6, -2),
              size: 0.3,
              color: const Color(0x80FF0000),
            );
      final frame = await renderFrame(
        draw: (context) {
          context.drawMesh(box, transform: boxTransform);
          system.draw(context);
        },
      );
      final (cx, cy) = pixelAt(0, 0);
      final center = frame.pixels.at(cx, cy);
      expect(center.$1, closeTo(128, 1));
      expect(center.$2, closeTo(128, 1));
      expect(center.$3, 255);
      final (bx, by) = pixelAt(-0.6, 0);
      final overBox = frame.pixels.at(bx, by);
      expect(overBox.$1, closeTo(128, 1));
      expect(overBox.$3, 255);
      expect(overBox.$4, 255);
      final (fx, fy) = pixelAt(0.6, 0.6);
      final faded = frame.pixels.at(fx, fy);
      expect(faded.$1, closeTo(128, 1));
      // Added light covers nothing.
      expect(faded.$4, 0);
    });

    testGpuEngine('show the flipbook frame of their life', () async {
      final material = _solid(texture: _quadrants(), columns: 2, rows: 2);
      final system =
          ParticleSystem3D(
              capacity: 4,
              material: material,
              flipbook: const ParticleFlipbook3D(),
            )
            ..spawn(position: Vector3(-0.5, 0, -2), size: 0.6)
            ..update(0.2)
            ..spawn(position: Vector3(0.5, 0, -2), size: 0.6)
            ..update(0.2)
            ..update(0.2);
      // 0.6 and 0.4 of their life: frames 2 (blue) and 1 (green).
      final frame = await renderFrame(draw: system.draw);
      final (lx, ly) = pixelAt(-0.5, 0);
      expect(frame.pixels.at(lx, ly), _rgba(_blue));
      final (rx, ry) = pixelAt(0.5, 0);
      expect(frame.pixels.at(rx, ry), _rgba(_green));
    });

    testGpuEngine('face the camera, upright on screen', () async {
      final system = ParticleSystem3D(
        capacity: 1,
        material: _solid(texture: _quadrants()),
      )..spawn(position: Vector3.zero(), size: 0.8);
      // Looking at the origin from up, right and in front.
      final view = Matrix4.identity()
        ..setAsViewMatrix(Vector3(4, 3, 5), Vector3.zero(), Vector3(0, 1, 0));
      final frame = await renderFrame(draw: system.draw, view: view);
      // An unforeshortened square of 0.8: its quadrants in their places.
      for (final ((x, y), color) in [
        ((-0.3, 0.3), _red),
        ((0.3, 0.3), _green),
        ((-0.3, -0.3), _blue),
        ((0.3, -0.3), _white),
      ]) {
        final (px, py) = pixelAt(x, y);
        expect(frame.pixels.at(px, py), _rgba(color), reason: '($x, $y)');
      }
      final (ox, oy) = pixelAt(0.5, 0);
      expect(frame.pixels.isClear(ox, oy), isTrue);
    });

    testGpuEngine('are not mirrored by a mirroring projection', () async {
      final system = ParticleSystem3D(
        capacity: 1,
        material: _solid(texture: _quadrants()),
      )..spawn(position: Vector3(0, 0, -5), size: 0.8);
      final frame = await renderFrame(
        draw: system.draw,
        projection: defaultProjection..setEntry(0, 0, -1),
      );
      final (px, py) = pixelAt(-0.3, 0.3);
      expect(frame.pixels.at(px, py), _rgba(_red));
    });

    testGpuEngine('draw soft circles without a texture', () async {
      final system = ParticleSystem3D(
        capacity: 1,
        material: ParticleMaterial(softness: 0.2),
      )..spawn(position: Vector3(0, 0, -5), size: 1.6, color: _red);
      final frame = await renderFrame(draw: system.draw);
      final (cx, cy) = pixelAt(0, 0);
      expect(frame.pixels.at(cx, cy), _rgba(_red));
      // The corner of the quad is outside the circle.
      final (kx, ky) = pixelAt(0.75, 0.75);
      expect(frame.pixels.isClear(kx, ky), isTrue);
    });

    testGpuEngine('mesh particles are one instanced draw', () async {
      final mesh = CuboidMesh(
        size: Vector3.all(1),
        material: opaqueUnlit(_green),
      );
      final system = ParticleSystem3D(capacity: 64, mesh: mesh);
      for (var i = 0; i < 50; i++) {
        system.spawn(
          position: Vector3(-0.9 + (i % 10) * 0.2, -0.5 + (i ~/ 10) * 0.2, -5),
          size: 0.12,
          rotation: i * 0.3,
        );
      }
      final frame = await renderFrame(draw: system.draw);
      expect(frame.stats.drawCalls, 1);
      expect(frame.stats.instances, 50);
      expect(frame.stats.particles, 50);
      final (x, y) = pixelAt(-0.9, -0.5);
      expect(frame.pixels.at(x, y), _rgba(_green));
    });

    testGpuEngine(
      'mesh particles pass behind and in front of models',
      () async {
        final mesh = CuboidMesh(
          size: Vector3.all(1),
          material: opaqueUnlit(_green),
        );
        final system = ParticleSystem3D(capacity: 4, mesh: mesh)
          ..spawn(position: Vector3(-0.5, 0, -8), size: 0.3)
          ..spawn(position: Vector3(0.5, 0, -2), size: 0.3);
        final frame = await renderFrame(
          draw: (context) {
            system.draw(context);
            context.drawMesh(box, transform: boxTransform);
          },
        );
        final (bx, by) = pixelAt(-0.5, 0);
        expect(frame.pixels.at(bx, by), _rgba(_blue));
        final (fx, fy) = pixelAt(0.5, 0);
        expect(frame.pixels.at(fx, fy), _rgba(_green));
      },
    );

    testGpu('in a Scene3DComponent, behind and in front of a cube', (
      tester,
    ) async {
      // A mirroring dimetric view of a scene with z up, as for 2D art.
      final projection = Scene3DProjection.affine(
        xAxis: Vector2(44, 22),
        yAxis: Vector2(-44, 22),
        zAxis: Vector2(0, -53.889),
        towardsViewer: Vector3(0.6124, 0.6124, 0.5),
        near: -20,
        far: 20,
      );
      final layer = Scene3DComponent(projection: projection);
      final towardsViewer = Vector3(0.6124, 0.6124, 0.5);
      final center = Vector3(1, 1, 0.5);
      final sparks = ParticleSystem3D(
        capacity: 8,
        material: _solid(texture: _quadrants()),
      );
      layer.world.addAll([
        MeshComponent(
          mesh: CuboidMesh(size: Vector3.all(1), material: opaqueUnlit(_blue)),
          position: center,
        ),
        sparks,
      ]);
      // In front of the cube, on the line of sight through its center; and
      // behind it, on the line of sight through its center and to the side.
      sparks
        ..spawn(position: center + towardsViewer * 2, size: 0.2)
        // About 21 pixels to the right of the cube's center on screen.
        ..spawn(
          position: center - towardsViewer * 2 + Vector3(0.24, -0.24, 0),
          size: 0.2,
          color: _red,
        );
      final at = layer.positionOf(layer.scenePointToLocal(center));
      final game = FlameGame(world: World(children: [layer]));
      game.camera.viewfinder.position = at;
      final pixels = await _render(tester, game);
      final screen = game.camera.localToGlobal(at);
      Color colorAt(double dx, double dy) {
        final (r, g, b, a) = pixels.at(
          (screen.x + dx).round(),
          (screen.y + dy).round(),
        );
        return Color.fromARGB(a, r, g, b);
      }

      // The near particle is drawn over the cube, upright and not mirrored.
      expect(colorAt(-3, -3), _red);
      expect(colorAt(3, -3), _green);
      expect(colorAt(-3, 3), _blue);
      expect(colorAt(3, 3), _white);
      // The far particle is hidden by the cube.
      expect(colorAt(21, 0), _blue);
      expect(layer.renderStats.particles, 2);
    });
  });
}

Future<Pixels> _render(
  WidgetTester tester,
  Game game, {
  double width = 160,
  double height = 120,
}) async {
  tester.view
    ..physicalSize = Size(width, height)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: GameWidget(game: game),
    ),
  );
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await tester.runAsync(() async {
    final image = await boundary.toImage();
    final pixels = await readImage(image);
    image.dispose();
    return pixels;
  }))!;
}
