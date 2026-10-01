/// Taps on what a bridged component draws under a perspective camera, and
/// its hitboxes drawn in the scene where it is.
library;

import 'package:flame/collisions.dart';
import 'package:flame/components.dart' show Anchor, Component;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter3d/flutter3d.dart';
import 'package:flutter3d_cpu/flutter3d_cpu.dart';
import 'package:flutter_test/flutter_test.dart';

final class _World extends FlameGame with HasFlutter3d {
  @override
  CameraNode createCamera3d() =>
      CameraNode(
          projection: const PerspectiveProjection(fovYRadians: 0.9, far: 200.0),
        )
        ..setPosition(0.0, 6.0, 6.0)
        ..lookAt(Vector3(0.0, 0.0, -10.0));
}

final class _Crate extends Object3dComponent with Tap3dCallbacks {
  _Crate(GraphicsDevice device, Scene scene, Vector2 at, {required this.name})
    : super(
        node: MeshNode(
          DeviceMesh.upload(
            device,
            CuboidShape(size: Vector3.all(2.0)).build(),
          ),
          Material(),
        ),
        scene: scene,
        plane: BridgePlane.ground(),
        direction: SyncDirection.flameToScene,
        position: at,
      );

  final String name;
  int taps = 0;
  int ups = 0;
  int cancels = 0;
  int longs = 0;

  @override
  void onTap3d(Vector2 screen) => taps++;

  @override
  void onTapUp3d(Vector2 screen) => ups++;

  @override
  void onTapCancel3d() => cancels++;

  @override
  void onLongTap3d(Vector2 screen) => longs++;
}

Future<({_World game, CpuDevice device})> _open() async {
  final device = CpuDevice(
    width: 32,
    height: 24,
    shaders: CpuShaderLibrary(builtinCpuShaders()),
  );
  final game = await initializeGame(_World.new);
  game.open3d(device);
  return (game: game, device: device);
}

void main() {
  test('a tap on a crate drawn in perspective finds it, where Flame would '
      'not', () async {
    // Mutation: hit-test by the crate's Flame rectangle instead.
    final (:game, :device) = await _open();
    final crate = _Crate(device, game.scene, Vector2(0.0, -10.0), name: 'a');
    final taps = Taps3dComponent();
    game.addAll(<Component>[crate, taps]);
    await game.ready();
    game.update(0.0);

    final screen = game.projector.toScreen(crate.scenePosition)!;
    expect(taps.nearestAt(screen), same(crate));
    expect(
      crate.containsPoint(screen),
      isFalse,
      reason: "Flame's own test misses the crate the player can see",
    );
    expect(taps.nearestAt(Vector2(1.0, 1.0)), isNull);
  });

  test('of two crates under one finger, the nearer hears it', () async {
    final (:game, :device) = await _open();
    final far = _Crate(device, game.scene, Vector2(0.0, -12.5), name: 'far');
    final near = _Crate(device, game.scene, Vector2(0.0, -10.0), name: 'near');
    final taps = Taps3dComponent();
    game.addAll(<Component>[far, near, taps]);
    await game.ready();
    game.update(0.0);

    // A point both crates' screen boxes cover: the middle of their overlap.
    final a = game.projector.boundsOf(near.node.subtreeBounds!)!;
    final b = game.projector.boundsOf(far.node.subtreeBounds!)!;
    final left = a.left > b.left ? a.left : b.left;
    final right = a.right < b.right ? a.right : b.right;
    final top = a.top > b.top ? a.top : b.top;
    final bottom = a.bottom < b.bottom ? a.bottom : b.bottom;
    expect(left < right && top < bottom, isTrue, reason: 'no overlap to tap');
    final screen = Vector2((left + right) / 2.0, (top + bottom) / 2.0);
    expect(far.hitAt3d(screen, game.projector), isTrue);
    expect(taps.nearestAt(screen), same(near));
  });

  test('a hitbox is drawn in the scene, round its component, at its '
      'height', () async {
    final (:game, :device) = await _open();
    final crate = _Crate(device, game.scene, Vector2(3.0, -10.0), name: 'a')
      ..elevation = 1.5
      ..size = Vector2(2.0, 2.0)
      ..anchor = Anchor.center
      ..add(RectangleHitbox());
    game.add(crate);
    await game.ready();

    final lines = DebugDraw();
    addHitboxes3d(lines, game);
    expect(lines.lineCount, 4);
    // Every end of every edge: on the crate's plane at its height, within a
    // metre of its middle across.
    final data = lines.vertexBytes.buffer.asFloat32List(
      lines.vertexBytes.offsetInBytes,
      lines.vertexCount * DebugDraw.floatsPerVertex,
    );
    for (var v = 0; v < lines.vertexCount; v++) {
      final at = v * DebugDraw.floatsPerVertex;
      expect(data[at + 1], closeTo(1.5, 1e-6));
      expect((data[at] - 3.0).abs(), closeTo(1.0, 1e-6));
      expect((data[at + 2] + 10.0).abs(), closeTo(1.0, 1e-6));
    }
  });

  test('a crate on a wide field hears the tap, not the field', () async {
    // Measured to the middle of each box, the field's middle was nearer
    // the camera than the crate standing on it.
    //
    // Mutation: rank by the distance to each box's middle.
    final (:game, :device) = await _open();
    final field = _Slab(device, game.scene);
    final crate = _Crate(device, game.scene, Vector2(0.0, -14.0), name: 'c');
    final taps = Taps3dComponent();
    game.addAll(<Component>[field, crate, taps]);
    await game.ready();
    game.update(0.0);

    final screen = game.projector.toScreen(crate.scenePosition)!;
    expect(field.hitAt3d(screen, game.projector), isTrue);
    expect(taps.nearestAt(screen), same(crate));
  });

  test('one instance of a batch is tapped, and its hitbox is drawn', () async {
    // Mutation: look for taps and hitboxes on Object3dComponent alone.
    final (:game, :device) = await _open();
    final batch = InstancedMeshNode(
      DeviceMesh.upload(device, CuboidShape(size: Vector3.all(2.0)).build()),
      Material(),
      capacity: 4,
    );
    game.scene.add(batch);
    final invader = _Invader(batch)
      ..position = Vector2(0.0, -10.0)
      ..size = Vector2(2.0, 2.0)
      ..anchor = Anchor.center
      ..add(RectangleHitbox());
    final taps = Taps3dComponent();
    game.addAll(<Component>[invader, taps]);
    await game.ready();
    game.update(0.0);

    final screen = game.projector.toScreen(invader.scenePosition)!;
    expect(taps.nearestAt(screen), same(invader));
    final lines = DebugDraw();
    addHitboxes3d(lines, game);
    expect(lines.lineCount, 4);
  });

  test('a finger lifted, given up on or held still is told to what it went '
      'down on', () async {
    final (:game, :device) = await _open();
    final crate = _Crate(device, game.scene, Vector2(0.0, -10.0), name: 'a');
    final taps = Taps3dComponent();
    game.addAll(<Component>[crate, taps]);
    await game.ready();
    game.update(0.0);
    final screen = game.projector.toScreen(crate.scenePosition)!;
    final at = Offset(screen.x, screen.y);

    taps
      ..onTapDown(TapDownEvent(1, game, TapDownDetails(globalPosition: at)))
      ..onLongTapDown(TapDownEvent(1, game, TapDownDetails(globalPosition: at)))
      ..onTapUp(
        TapUpEvent(
          1,
          game,
          TapUpDetails(kind: PointerDeviceKind.touch, globalPosition: at),
        ),
      );
    expect(crate.taps, 1);
    expect(crate.longs, 1);
    expect(crate.ups, 1);

    taps
      ..onTapDown(TapDownEvent(2, game, TapDownDetails(globalPosition: at)))
      ..onTapCancel(TapCancelEvent(2));
    expect(crate.cancels, 1);
  });

  test(
    'a craft seen across the seam of a wrapped world is tapped there',
    () async {
      // The ghost was a drawing with no component, and a tap on it found
      // nothing.
      //
      // Mutation: test only the craft's own box.
      final (:game, :device) = await _open();
      final space = WrapSpace(
        min: Vector2(-6.0, -20.0),
        max: Vector2(6.0, 0.0),
        scene: game.scene,
      );
      final crate = _Crate(device, game.scene, Vector2(5.6, -10.0), name: 'a');
      final taps = Taps3dComponent();
      space.add(crate);
      game.addAll(<Component>[space, taps]);
      await game.ready();
      game.update(0.0);

      final ghost = space.ghostBoundsOf(crate).single;
      final screen = game.projector.toScreen(ghost.center)!;
      expect(
        game.projector.boundsOf(crate.node.subtreeBounds!)!.left,
        greaterThan(screen.x),
        reason: 'the tap is on the ghost, not on the craft',
      );
      expect(taps.nearestAt(screen), same(crate));
    },
  );
}

final class _Slab extends Object3dComponent with Tap3dCallbacks {
  _Slab(GraphicsDevice device, Scene scene)
    : super(
        node: MeshNode(
          DeviceMesh.upload(
            device,
            CuboidShape(size: Vector3(40.0, 0.2, 40.0)).build(),
          ),
          Material(),
        ),
        scene: scene,
        plane: BridgePlane.ground(),
        direction: SyncDirection.flameToScene,
        position: Vector2(0.0, -6.0),
      );
}

final class _Invader extends InstancedObject3dComponent with Tap3dCallbacks {
  _Invader(InstancedMeshNode batch)
    : super(batch: batch, plane: BridgePlane.ground());
}
