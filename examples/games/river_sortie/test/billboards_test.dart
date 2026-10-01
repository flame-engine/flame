/// The river's Flame sprites standing in the scene: reeds along the banks,
/// the same each time a stretch is built, and a blast's flash that plays
/// once and goes.
library;

import 'package:flame_flutter3d/flame_flutter3d.dart'
    show SpriteBillboardComponent;
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart'
    show CameraNode, PerspectiveProjection, RenderView, Renderer;
import 'package:flutter3d_cpu/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:river_sortie/src/course.dart' show TargetKind;
import 'package:river_sortie/src/river_game.dart';
import 'package:vector_math/vector_math.dart' show Vector3, Vector4;

Iterable<SpriteBillboardComponent> _billboards(RiverGame game) =>
    game.children.whereType<SpriteBillboardComponent>();

void main() {
  testWidgets('reeds stand on the land by the banks, where they stood the '
      'last time the stretch was built', (tester) async {
    // Mutation: place them with an unseeded random, or on the water.
    late final RiverGame game;
    await tester.runAsync(() async {
      game = await initializeGame(() => RiverGame(billboards: true));
      game.open3d(cpuTestDevice(width: 32, height: 24).device);
      await game.ready();
      await game.drawSprites();
      await game.ready();
    });

    final reeds = _billboards(game).toList();
    expect(reeds, isNotEmpty);
    for (final reed in reeds) {
      final row = game.course.rowAt(-reed.position.y);
      expect(row.isLand(reed.position.x), isTrue, reason: 'not on the water');
      final bank =
          (reed.position.x - row.left).abs() <
              (reed.position.x - row.right).abs()
          ? row.left
          : row.right;
      expect((reed.position.x - bank).abs(), lessThan(1.3), reason: 'by it');
    }

    final first = <(double, double)>{
      for (final reed in reeds) (reed.position.x, reed.position.y),
    };
    expect(first, hasLength(reeds.length), reason: 'each stood once');
    await tester.runAsync(() async {
      game.startOnLevel(0);
      await game.ready();
    });
    final again = <(double, double)>{
      for (final reed in _billboards(game)) (reed.position.x, reed.position.y),
    };
    expect(again, first);
  });

  testWidgets('every depot says FUEL, on a sign that goes up with it', (
    tester,
  ) async {
    // Mutation: sign only the depots built after the sprites were drawn, or
    // only those standing when they were; stand the sign away from its
    // depot; draw its lettering in squares.
    late final RiverGame game;
    await tester.runAsync(() async {
      game = await initializeGame(() => RiverGame(billboards: true));
      game.open3d(cpuTestDevice(width: 32, height: 24).device);
      await game.ready();
      await game.drawSprites();
      await game.ready();
    });

    void expectSigned() {
      final depots = game.targets
          .where((target) => target.plan.kind == TargetKind.depot)
          .toList();
      expect(depots, isNotEmpty);
      for (final depot in depots) {
        final sign = depot.children
            .whereType<SpriteBillboardComponent>()
            .single;
        expect(sign.currentSprite, same(game.sprites!.fuel));
        expect(sign.smooth, isTrue);
        expect(sign.absolutePosition.x, closeTo(depot.position.x, 1e-6));
        expect(
          sign.absolutePosition.y - depot.position.y,
          inInclusiveRange(depot.size.y / 2.0, depot.size.y),
          reason: 'on its near side',
        );
      }
    }

    // Dressed: the depots standing when the sprites were drawn.
    expectSigned();
    // Built with it: the depots of a stretch built after.
    await tester.runAsync(() async {
      game.startOnLevel(0);
      await game.ready();
    });
    expectSigned();

    final depot = game.targets.firstWhere(
      (target) => target.plan.kind == TargetKind.depot,
    );
    final sign = depot.children.whereType<SpriteBillboardComponent>().single;
    await tester.runAsync(() async {
      game.hitTarget(depot);
      for (var i = 0; i < 3; i++) {
        game.update(1 / 60);
        await game.ready();
      }
    });
    expect(sign.isMounted, isFalse, reason: 'gone up with its depot');
  });

  testWidgets("a blast's flash is drawn: orange where there was none", (
    tester,
  ) async {
    // Mutation: add the flash component and draw nothing.
    final it = cpuTestDevice(width: 160, height: 90);
    late final RiverGame game;
    final camera = CameraNode(
      projection: const PerspectiveProjection(fovYRadians: 0.85, far: 400.0),
    );
    await tester.runAsync(() async {
      game = await initializeGame(() => RiverGame(billboards: true));
      game.open3d(it.device);
      await game.ready();
      await game.drawSprites();
      await game.ready();
    });
    camera
      ..setPosition(0.0, 12.0, -game.distance + 11.0)
      ..lookAt(Vector3(0.0, 0.0, -game.distance - 9.0));
    game.scene.add(camera);
    final renderer = Renderer.create(
      device: it.device,
      fallbackAlbedo: it.albedo,
      fallbackNormal: it.normal,
    );
    game.attachRenderer(renderer);

    Future<int> orange({double after = 0.0}) async {
      game.update(after);
      final result = renderer.render(
        width: 160,
        height: 90,
        scene: game.scene,
        views: <RenderView>[
          RenderView(camera: camera, clearColor: Vector4(0.27, 0.48, 0.78, 1)),
        ],
      );
      final pixels = (await it.device.readPixels(result.frame))!;
      final rgba = pixels.buffer.asUint8List();
      var count = 0;
      for (var i = 0; i < rgba.length; i += 4) {
        final (r, g, b) = (rgba[i], rgba[i + 1], rgba[i + 2]);
        if (r > 200 && b < 140 && r > g + 20) {
          count++;
        }
      }
      return count;
    }

    final before = (await tester.runAsync(orange))!;
    await tester.runAsync(() async {
      game.blasts.system.clear();
      game.fireball(Vector3(0.0, 2.0, -game.distance - 6.0), size: 1.5);
      game.blasts.system.clear();
      await game.ready();
    });
    // Midway through the flash: its orange ball, not its first white core.
    final during = (await tester.runAsync(() => orange(after: 0.15)))!;
    expect(during, greaterThan(before + 40), reason: 'the flash, drawn');
  });

  testWidgets("a blast's flash plays where it happened, and goes", (
    tester,
  ) async {
    late final RiverGame game;
    await tester.runAsync(() async {
      game = await initializeGame(() => RiverGame(billboards: true));
      game.open3d(cpuTestDevice(width: 32, height: 24).device);
      await game.ready();
      await game.drawSprites();
      await game.ready();
    });
    final before = _billboards(game).length;

    await tester.runAsync(() async {
      game.fireball(Vector3(2.0, 1.0, -30.0));
      await game.ready();
    });
    final flash = _billboards(game).firstWhere((b) => b.ticker != null);
    expect(_billboards(game).length, before + 1);
    expect(flash.position.x, closeTo(2.0, 1e-6));
    expect(flash.position.y, closeTo(-30.0, 1e-6));
    expect(
      flash.elevation + flash.cardHeight / 2.0,
      closeTo(1.0, 1e-6),
      reason: 'the flash is centred on the blast',
    );

    await tester.runAsync(() async {
      for (var i = 0; i < 30; i++) {
        game.update(1 / 60);
        await game.ready();
      }
    });
    expect(flash.isMounted, isFalse, reason: 'played once, and gone');
  });
}
