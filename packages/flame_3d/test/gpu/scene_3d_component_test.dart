import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart' show Anchor, RectangleComponent;
import 'package:flame/game.dart';
import 'package:flame_3d/camera.dart';
import 'package:flame_3d/components.dart';
import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter/widgets.dart' show GlobalKey, RepaintBoundary;
import 'package:flutter_test/flutter_test.dart';

import 'gpu_test_helpers.dart';

void main() {
  setUpGpu();

  group('Scene3DComponent', () {
    group('lines up with the 2D world', () {
      // The zoom, the scene point to measure, and where it should appear on
      // screen, relative to the center of the view (in logical pixels).
      final cases = <String, (double, Vector3, Vector2)>{
        'zoom 0.5': (0.5, Vector3(2.3, 1.6, 0.4), Vector2(17.3, -11.1)),
        'zoom 1': (1, Vector3(2.3, 1.6, 0.4), Vector2(17.3, -11.1)),
        'zoom 2.4': (2.4, Vector3(2.3, 1.6, 0.4), Vector2(17.3, -11.1)),
        'zoom 0.5 panned': (0.5, Vector3(61.7, 23.2, 1.3), Vector2(-71, 43)),
        'zoom 1 panned': (1, Vector3(37.3, 81.6, 0.4), Vector2(-61.7, 33.2)),
        'zoom 2.4 panned': (2.4, Vector3(-17.7, 41.4, 2.1), Vector2(43.9, 19)),
      };
      for (final MapEntry(key: name, value: (zoom, center, offset))
          in cases.entries) {
        testGpu(name, (tester) async {
          final error = await _registrationError(
            tester,
            zoom: zoom,
            center: center,
            screenOffset: offset,
          );
          debugPrint(
            'registration $name: object ${_format(error.object)} px, '
            'marker ${_format(error.marker)} px, '
            'object to marker ${_format(error.objectToMarker)} px',
          );
          expect(error.object, lessThan(1));
          expect(error.marker, lessThan(1));
          expect(error.objectToMarker, lessThan(1));
        });
      }

      testGpu('with a rotated camera and a scaled, rotated layer', (
        tester,
      ) async {
        final error = await _registrationError(
          tester,
          zoom: 1.7,
          center: Vector3(13.1, 7.9, 0.8),
          screenOffset: Vector2(-21, 13),
          cameraAngle: 0.3,
          layerScale: Vector2(1.25, 0.8),
          layerAngle: -0.2,
        );
        debugPrint(
          'registration rotated: object ${_format(error.object)} px, '
          'marker ${_format(error.marker)} px, '
          'object to marker ${_format(error.objectToMarker)} px',
        );
        expect(error.object, lessThan(1));
        expect(error.marker, lessThan(1));
        expect(error.objectToMarker, lessThan(1));
      });
    });

    testGpu('lines up with a perspective projection', (tester) async {
      const pixelRatio = 2.0;
      final layer = Scene3DComponent(
        projection: Scene3DProjection.perspective(
          eye: Vector3(0.4, -0.3, 6),
          target: Vector3(0.4, -0.3, 0),
          up: Vector3(0, 1, 0),
          fovY: 50,
          rect: const Rect.fromLTWH(0, 0, 160, 120),
        ),
        position: Vector2(-71.3, -48.6),
        msaa: Msaa.sample4,
      );
      // A square facing the eye squarely: its picture is a square around
      // the picture of its center.
      final center = Vector3(1.37, 0.81, 0);
      layer.world.add(
        MeshComponent(
          mesh: Mesh()..addSurface(quad(opaqueUnlit(_red), halfSize: 0.4)),
          position: center,
        ),
      );
      final game = FlameGame(world: World(children: [layer]));
      game.camera.viewfinder.zoom = 1.3;
      final pixels = await _render(tester, game, pixelRatio: pixelRatio);

      final expected = game.camera.localToGlobal(
        layer.positionOf(layer.scenePointToLocal(center)),
      )..scale(pixelRatio);
      final error = _centroid(
        pixels,
        (r, g, b) => r.toDouble(),
      ).distanceTo(expected);
      debugPrint('registration perspective: object ${_format(error)} px');
      expect(error, lessThan(1));
    });

    group('is drawn at its priority', () {
      Future<(Pixels, Vector2)> render(
        WidgetTester tester, {
        required int layerPriority,
      }) async {
        final layer = Scene3DComponent(
          projection: _boardProjection(),
          priority: layerPriority,
        );
        final center = Vector3(1, 1, 0.5);
        layer.world.add(
          MeshComponent(
            mesh: CuboidMesh(
              size: Vector3.all(1),
              material: opaqueUnlit(_red),
            ),
            position: center,
          ),
        );
        final centerPosition = layer.positionOf(
          layer.scenePointToLocal(center),
        );
        final game = FlameGame(
          world: World(
            children: [
              RectangleComponent(
                position: Vector2.all(-5000),
                size: Vector2.all(10000),
                paint: Paint()..color = _blue,
              ),
              layer,
              RectangleComponent(
                position: centerPosition - Vector2(40, 40),
                size: Vector2(40, 80),
                paint: Paint()..color = _white,
                priority: 2,
              ),
            ],
          ),
        );
        game.camera.viewfinder.position = centerPosition;
        final pixels = await _render(tester, game);
        return (pixels, game.camera.localToGlobal(centerPosition));
      }

      testGpu('above the components with a lower priority, below those '
          'with a higher one', (tester) async {
        final (pixels, center) = await render(tester, layerPriority: 1);
        // The left half of the cube is under the white rectangle.
        expect(_colorAt(pixels, center + Vector2(-10, 0)), _white);
        expect(_colorAt(pixels, center + Vector2(10, 0)), _red);
        expect(_colorAt(pixels, center + Vector2(0, 55)), _blue);
      });

      testGpu('below the components with a higher priority', (tester) async {
        final (pixels, center) = await render(tester, layerPriority: -1);
        expect(_colorAt(pixels, center + Vector2(-10, 0)), _white);
        expect(_colorAt(pixels, center + Vector2(10, 0)), _blue);
      });
    });

    group('culls back faces', () {
      /// Renders a red square facing away from the viewer in front of a green
      /// square facing the viewer, and returns the color where they are.
      Future<Color> render(
        WidgetTester tester, {
        required bool mirrored,
        required CullMode cullMode,
      }) async {
        final projection = Scene3DProjection.affine(
          origin: Vector2(0, -18),
          // Swapping the x and y axes undoes the mirroring.
          xAxis: mirrored ? Vector2(44, 22) : Vector2(-44, 22),
          yAxis: mirrored ? Vector2(-44, 22) : Vector2(44, 22),
          zAxis: Vector2(0, -53.889),
          towardsViewer: Vector3(0.6124, 0.6124, 0.5),
          near: -100,
          far: 100,
        );
        UnlitMaterial material(Color color) {
          return UnlitMaterial(albedoColor: color)
            ..renderState = RenderState(cullMode: cullMode);
        }

        final layer = Scene3DComponent(projection: projection);
        final center = Vector3(2, 1, 0);
        final towardsViewer = Vector3(0.6124, 0.6124, 0.5);
        layer.world.addAll([
          // In the z = 0 plane, facing +z: towards the viewer, who looks
          // down at the scene.
          MeshComponent(
            mesh: Mesh()..addSurface(quad(material(_green))),
            position: center,
          ),
          // Nearer to the viewer on the same line of sight, turned over.
          MeshComponent(
            mesh: Mesh()..addSurface(quad(material(_red))),
            position: center + towardsViewer * 1.5,
            rotation: Quaternion.axisAngle(Vector3(1, 0, 0), math.pi),
          ),
        ]);
        final centerPosition = layer.positionOf(
          layer.scenePointToLocal(center),
        );
        final game = FlameGame(world: World(children: [layer]));
        game.camera.viewfinder.position = centerPosition;
        final pixels = await _render(tester, game);

        expect(layer.context.isMirrored, mirrored);
        return _colorAt(pixels, game.camera.localToGlobal(centerPosition));
      }

      for (final mirrored in [true, false]) {
        final mapping = mirrored ? 'a mirrored' : 'a standard';
        testGpu('with $mapping mapping', (tester) async {
          expect(
            await render(
              tester,
              mirrored: mirrored,
              cullMode: CullMode.backFace,
            ),
            _green,
          );
          // Without culling, the nearer square hides the farther one.
          expect(
            await render(tester, mirrored: mirrored, cullMode: CullMode.none),
            _red,
          );
        });
      }
    });

    group('renders the visible part', () {
      testGpu('of an unbounded layer, culling what is outside', (
        tester,
      ) async {
        const pixelRatio = 2.0;
        final layer = Scene3DComponent(projection: _boardProjection());
        final mesh = CuboidMesh(
          size: Vector3.all(0.2),
          material: opaqueUnlit(_red),
        );
        final cubes = [
          for (var i = 0; i < 30; i++)
            for (var j = 0; j < 30; j++)
              MeshComponent(mesh: mesh, position: Vector3(i + 0.5, j + 0.5, 0)),
        ];
        layer.world.addAll(cubes);
        final game = FlameGame(world: World(children: [layer]));
        game.camera.viewfinder
          ..zoom = 2.4
          ..position = layer.positionOf(
            layer.scenePointToLocal(Vector3(13.2, 15.7, 0)),
          );
        await _render(
          tester,
          game,
          width: 240,
          height: 180,
          pixelRatio: pixelRatio,
        );

        expect(layer.renderedRect, const Rect.fromLTWH(0, 0, 240, 180));
        // 480 by 360 pixels, rounded up to multiples of 64.
        final target = layer.device.renderTarget;
        expect((target.width, target.height), (512, 384));

        // The cubes whose picture is inside the view must be drawn, and only
        // those whose picture touches the render target may be.
        const view = Rect.fromLTWH(0, 0, 240, 180);
        final targetRect = Rect.fromLTWH(
          0,
          0,
          target.width / pixelRatio,
          target.height / pixelRatio,
        );
        var inside = 0;
        var touching = 0;
        for (final cube in cubes) {
          final bounds = _screenBounds(game, layer, cube.aabb);
          if (view.contains(bounds.topLeft) &&
              view.contains(bounds.bottomRight)) {
            inside++;
          }
          if (bounds.overlaps(targetRect)) {
            touching++;
          }
        }
        debugPrint(
          'culling: ${layer.renderStats.instances} of ${cubes.length} cubes '
          'drawn, $inside inside the view, $touching touching the target',
        );
        expect(inside, greaterThan(0));
        expect(touching, lessThan(cubes.length ~/ 10));
        expect(layer.renderStats.instances, inInclusiveRange(inside, touching));
        expect(layer.renderStats.drawCalls, 1);
        expect(layer.renderStats.renderPasses, 1);
      });

      testGpu('of a bounded layer that is partly on screen', (tester) async {
        final layer = Scene3DComponent(
          projection: _boardProjection(),
          position: Vector2(-250, -100),
          size: Vector2(200, 150),
        );
        layer.world.addAll([
          // A cube across the right edge of the layer (x = -50 in the world).
          MeshComponent(
            mesh: CuboidMesh(
              size: Vector3.all(1),
              material: opaqueUnlit(_red),
            ),
            position: Vector3(4.95, 0.41, 0),
          ),
          // Ground under the whole layer.
          MeshComponent(
            mesh: CuboidMesh(
              size: Vector3(20, 20, 0.01),
              material: opaqueUnlit(_gray),
            ),
            position: Vector3(2, 1, -0.6),
          ),
        ]);
        final game = FlameGame(
          world: World(
            children: [
              RectangleComponent(
                position: Vector2.all(-5000),
                size: Vector2.all(10000),
                paint: Paint()..color = _blue,
              ),
              layer,
            ],
          ),
        );
        final pixels = await _render(tester, game);

        // The view shows the world from (-80, -60) to (80, 60).
        expect(layer.renderedRect, const Rect.fromLTRB(0, 0, 30, 110));
        final cube = layer.positionOf(
          layer.scenePointToLocal(Vector3(4.95, 0.41, 0)),
        );
        final y = game.camera.localToGlobal(cube).y;
        expect(_colorAt(pixels, Vector2(27, y)), _red);
        expect(_colorAt(pixels, Vector2(33, y)), _blue);
      });

      testGpu('of the picture of the scene, not of the whole screen', (
        tester,
      ) async {
        final layer = Scene3DComponent(projection: _boardProjection());
        final cube = MeshComponent(
          mesh: CuboidMesh(size: Vector3.all(1), material: opaqueUnlit(_red)),
          position: Vector3(1, 0.5, 0.5),
        );
        layer.world.addAll([
          cube,
          // Lights do not draw anything: they do not widen the picture.
          LightComponent.point(position: Vector3(40, 40, 40)),
        ]);
        final game = FlameGame(world: World(children: [layer]));
        game.camera.viewfinder.position = layer.positionOf(
          layer.scenePointToLocal(cube.position),
        );
        await _render(tester, game);

        // The bounds of the cube's picture, rounded out to whole pixels.
        final bounds = _screenBounds(game, layer, cube.aabb);
        final rendered = layer.renderedRect;
        expect(rendered.left, inInclusiveRange(bounds.left - 1, bounds.left));
        expect(rendered.top, inInclusiveRange(bounds.top - 1, bounds.top));
        expect(
          rendered.right,
          inInclusiveRange(bounds.right, bounds.right + 1),
        );
        expect(
          rendered.bottom,
          inInclusiveRange(bounds.bottom, bounds.bottom + 1),
        );

        // Once the scene is off screen, nothing is rendered.
        game.camera.viewfinder.position = Vector2(5000, 0);
        await tester.pump(const Duration(milliseconds: 16));
        expect(layer.renderStats.renderPasses, 0);
        expect(layer.renderedRect, Rect.zero);
      });

      testGpu('of the picture of the scene as its objects move', (
        tester,
      ) async {
        final layer = Scene3DComponent(projection: _boardProjection());
        final still = MeshComponent(
          mesh: CuboidMesh(size: Vector3.all(1), material: opaqueUnlit(_red)),
          position: Vector3(1, 0.5, 0.5),
        );
        final inner = MeshComponent(
          mesh: CuboidMesh(size: Vector3.all(1), material: opaqueUnlit(_red)),
        );
        // A nested object: moving it changes the bounds of its parent.
        final moving = _Holder(position: Vector3(2, 0.5, 0.5), child: inner);
        layer.world.addAll([still, moving]);
        final game = FlameGame(world: World(children: [layer]));
        game.camera.viewfinder.position = layer.positionOf(
          layer.scenePointToLocal(Vector3(1.5, 0.5, 0.5)),
        );
        await _render(tester, game);

        void expectTrimmedTo(Aabb3 box) {
          // Within the view.
          final bounds = _screenBounds(
            game,
            layer,
            box,
          ).intersect(const Rect.fromLTWH(0, 0, 160, 120));
          final rendered = layer.renderedRect;
          expect(rendered.left, inInclusiveRange(bounds.left - 1, bounds.left));
          expect(rendered.top, inInclusiveRange(bounds.top - 1, bounds.top));
          expect(
            rendered.right,
            inInclusiveRange(bounds.right, bounds.right + 1),
          );
          expect(
            rendered.bottom,
            inInclusiveRange(bounds.bottom, bounds.bottom + 1),
          );
        }

        expectTrimmedTo(Aabb3.copy(still.aabb)..hull(moving.aabb));

        // The nested object moves away, then back next to the other.
        inner.position.setValues(1.5, 0, 0);
        await tester.pump(const Duration(milliseconds: 16));
        expectTrimmedTo(Aabb3.copy(still.aabb)..hull(moving.aabb));

        inner.position.setValues(-1, 0, 0);
        await tester.pump(const Duration(milliseconds: 16));
        expectTrimmedTo(Aabb3.copy(still.aabb)..hull(moving.aabb));

        // Without it, the picture is that of the remaining object.
        moving.removeFromParent();
        await tester.pump(const Duration(milliseconds: 16));
        expectTrimmedTo(still.aabb);
      });

      testGpu('of nothing when the layer is off screen', (tester) async {
        final layer = Scene3DComponent(
          projection: _boardProjection(),
          position: Vector2(500, 0),
          size: Vector2(200, 150),
        );
        layer.world.add(
          MeshComponent(
            mesh: CuboidMesh(
              size: Vector3.all(1),
              material: opaqueUnlit(_red),
            ),
            position: Vector3(1, 1, 0),
          ),
        );
        final game = FlameGame(world: World(children: [layer]));
        final pixels = await _render(tester, game);

        expect(layer.renderedRect, Rect.zero);
        expect(layer.renderStats.renderPasses, 0);
        expect(layer.device.lastFrameStats.renderPasses, 0);
        expect(pixels.count((r, g, b, a) => r > 0), 0);
      });
    });

    testGpu('adds additive glows to the 2D components behind it', (
      tester,
    ) async {
      final layer = Scene3DComponent(projection: _boardProjection());
      final center = Vector3(1, 1, 0.5);
      layer.world.add(
        MeshComponent(
          mesh: CuboidMesh(
            size: Vector3.all(1),
            // Only the faces towards the viewer, each pixel added once.
            material: UnlitMaterial(albedoColor: const Color(0xFF006000))
              ..renderState = RenderState.additive.copyWith(
                cullMode: CullMode.backFace,
              ),
          ),
          position: center,
        ),
      );
      final centerPosition = layer.positionOf(
        layer.scenePointToLocal(center),
      );
      final game = FlameGame(
        world: World(
          children: [
            RectangleComponent(
              position: Vector2.all(-5000),
              size: Vector2.all(10000),
              paint: Paint()..color = _blue,
              priority: -1,
            ),
            layer,
          ],
        ),
      );
      game.camera.viewfinder.position = centerPosition;
      final pixels = await _render(tester, game);
      final at = game.camera.localToGlobal(centerPosition);
      // The glow over the blue rectangle, not over an opaque black.
      expect(_colorAt(pixels, at), const Color(0xFF0060FF));
      expect(_colorAt(pixels, at + Vector2(0, 55)), _blue);
    });

    testGpu('renders several layers in one game, one pass each', (
      tester,
    ) async {
      final board = Scene3DComponent(projection: _boardProjection());
      board.world.add(
        MeshComponent(
          mesh: CuboidMesh(size: Vector3.all(1), material: opaqueUnlit(_red)),
          position: Vector3(1, 0, 0),
        ),
      );
      final inset = Scene3DComponent(
        projection: Scene3DProjection.perspective(
          eye: Vector3(0, 0, 5),
          target: Vector3.zero(),
          up: Vector3(0, 1, 0),
          rect: const Rect.fromLTWH(0, 0, 40, 30),
        ),
        position: Vector2(-75, -55),
        size: Vector2(40, 30),
        priority: 1,
      );
      inset.world.add(
        MeshComponent(
          mesh: Mesh()..addSurface(quad(opaqueUnlit(_green), halfSize: 1)),
        ),
      );
      final game = FlameGame(world: World(children: [board, inset]));
      final pixels = await _render(tester, game);

      final boardCenter = game.camera.localToGlobal(
        board.positionOf(board.scenePointToLocal(Vector3(1, 0, 0))),
      );
      final insetCenter = game.camera.localToGlobal(
        inset.positionOf(inset.scenePointToLocal(Vector3.zero())),
      );
      expect(_colorAt(pixels, boardCenter), _red);
      expect(_colorAt(pixels, insetCenter), _green);
      expect(identical(board.device, inset.device), isTrue);
      expect(board.renderStats.renderPasses, 1);
      expect(inset.renderStats.renderPasses, 1);
      expect(board.device.lastFrameStats.renderPasses, 2);
    });

    testGpu('renders with the device of a Game3D game', (tester) async {
      final layer = Scene3DComponent(projection: _boardProjection());
      layer.world.add(
        MeshComponent(
          mesh: CuboidMesh(size: Vector3.all(1), material: opaqueUnlit(_red)),
          position: Vector3(1, 0, 0),
        ),
      );
      final game = _FlameGameWith3D(world: World(children: [layer]));
      final pixels = await _render(tester, game);

      expect(identical(layer.device, game.device), isTrue);
      expect(identical(layer.world.host, layer), isTrue);
      expect(game.renderStats.renderPasses, 1);
      expect(game.renderStats.drawCalls, 1);
      final center = game.camera.localToGlobal(
        layer.positionOf(layer.scenePointToLocal(Vector3(1, 0, 0))),
      );
      expect(_colorAt(pixels, center), _red);
    });
  });

  group('FlameGame3D', () {
    testGpu('still renders its world through its camera', (tester) async {
      final game = FlameGame3D(
        world: World3D(
          children: [
            MeshComponent(
              mesh: Mesh()..addSurface(quad(opaqueUnlit(_green))),
            ),
          ],
        ),
        camera: CameraComponent3D(
          position: Vector3(0, 0, 5),
          target: Vector3.zero(),
        ),
      );
      final pixels = await _render(tester, game, pixelRatio: 2);

      expect(identical(game.world.host, game), isTrue);
      expect(game.renderStats.renderPasses, 1);
      expect(game.device.renderTarget.width, 320);
      expect(_colorAt(pixels, Vector2(80, 60), pixelRatio: 2), _green);
      // The game's background, around the world's image.
      expect(_colorAt(pixels, Vector2(4, 4), pixelRatio: 2), _black);
    });
  });
}

class _FlameGameWith3D({super.world}) extends FlameGame with Game3D;

/// The projection of a board of cells seen as dimetric 2D art: a cell is 88
/// by 44 pixels, a unit of height 53.889 pixels, z is up. It mirrors the
/// scene compared with a standard camera.
Scene3DProjection _boardProjection() {
  return Scene3DProjection.affine(
    origin: Vector2(0, -18),
    xAxis: Vector2(44, 22),
    yAxis: Vector2(-44, 22),
    zAxis: Vector2(0, -53.889),
    towardsViewer: Vector3(0.6124, 0.6124, 0.5),
    near: -100,
    far: 100,
  );
}

const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);
const _blue = Color(0xFF0000FF);
const _white = Color(0xFFFFFFFF);
const _black = Color(0xFF000000);
const _gray = Color(0xFF404040);

class _Registration(
  /// Distance from the rendered object's center to where the mapping says
  /// it lands, in physical pixels.
  final double object,

  /// Distance from the 2D marker's center to where the mapping says the
  /// object lands, in physical pixels.
  final double marker,

  /// Distance between the rendered object's center and the 2D marker's
  /// center, in physical pixels.
  final double objectToMarker,
);

String _format(double value) => value.toStringAsFixed(3);

/// Renders a red cube in a [Scene3DComponent] and a green 2D square drawn
/// where the mapping says the cube's center lands, and measures how far apart
/// their centers are.
Future<_Registration> _registrationError(
  WidgetTester tester, {
  required double zoom,
  required Vector3 center,
  required Vector2 screenOffset,
  double cameraAngle = 0,
  Vector2? layerScale,
  double layerAngle = 0,
}) async {
  const pixelRatio = 2.0;
  final layer = Scene3DComponent(
    projection: _boardProjection(),
    position: Vector2(37.5, -12.25),
    scale: layerScale,
    angle: layerAngle,
    msaa: Msaa.sample4,
    priority: 1,
  );
  layer.world.add(
    MeshComponent(
      mesh: CuboidMesh(size: Vector3.all(0.6), material: opaqueUnlit(_red)),
      position: center,
    ),
  );
  final markerPosition = layer.positionOf(layer.scenePointToLocal(center));
  final game = FlameGame(
    world: World(
      children: [
        RectangleComponent(
          position: Vector2.all(-5000),
          size: Vector2.all(10000),
          paint: Paint()..color = _blue,
        ),
        layer,
        // Added to what is below it, so that it does not hide the object:
        // only the green channel measures the marker, only the red one the
        // object.
        RectangleComponent(
          size: Vector2.all(16 / zoom),
          position: markerPosition,
          anchor: Anchor.center,
          paint: Paint()
            ..color = _green
            ..blendMode = BlendMode.plus,
          priority: 2,
        ),
      ],
    ),
  );
  game.camera.viewfinder
    ..zoom = zoom
    ..position = markerPosition - screenOffset / zoom
    ..angle = cameraAngle;
  final pixels = await _render(
    tester,
    game,
    width: 240,
    height: 180,
    pixelRatio: pixelRatio,
  );

  final expected = game.camera.localToGlobal(markerPosition)..scale(pixelRatio);
  final object = _centroid(pixels, (r, g, b) => r.toDouble());
  final marker = _centroid(pixels, (r, g, b) => g.toDouble());
  return _Registration(
    object.distanceTo(expected),
    marker.distanceTo(expected),
    object.distanceTo(marker),
  );
}

/// The centroid, in pixels, of [weight] over the pixel centers of [pixels].
Vector2 _centroid(
  Pixels pixels,
  double Function(int r, int g, int b) weight,
) {
  var sum = 0.0;
  var sumX = 0.0;
  var sumY = 0.0;
  for (var y = 0; y < pixels.height; y++) {
    for (var x = 0; x < pixels.width; x++) {
      final (r, g, b, _) = pixels.at(x, y);
      final w = weight(r, g, b);
      sum += w;
      sumX += w * (x + 0.5);
      sumY += w * (y + 0.5);
    }
  }
  expect(sum, greaterThan(0), reason: 'Nothing to measure');
  return Vector2(sumX / sum, sumY / sum);
}

/// The color of the pixel under the logical point [point] of the view.
Color _colorAt(Pixels pixels, Vector2 point, {double pixelRatio = 1}) {
  final (r, g, b, a) = pixels.at(
    (point.x * pixelRatio).floor(),
    (point.y * pixelRatio).floor(),
  );
  return Color.fromARGB(a, r, g, b);
}

/// The bounding box, in logical pixels of the view, of the picture of the
/// scene box [aabb] of [layer].
Rect _screenBounds(FlameGame game, Scene3DComponent layer, Aabb3 aabb) {
  var left = double.infinity;
  var top = double.infinity;
  var right = double.negativeInfinity;
  var bottom = double.negativeInfinity;
  for (var corner = 0; corner < 8; corner++) {
    final point = Vector3(
      corner & 1 == 0 ? aabb.min.x : aabb.max.x,
      corner & 2 == 0 ? aabb.min.y : aabb.max.y,
      corner & 4 == 0 ? aabb.min.z : aabb.max.z,
    );
    final screen = game.camera.localToGlobal(
      layer.positionOf(layer.scenePointToLocal(point)),
    );
    left = math.min(left, screen.x);
    top = math.min(top, screen.y);
    right = math.max(right, screen.x);
    bottom = math.max(bottom, screen.y);
  }
  return Rect.fromLTRB(left, top, right, bottom);
}

/// Pumps [game] in a [width]x[height] logical-pixel view for [frames] frames
/// and returns the physical pixels of the last frame.
Future<Pixels> _render(
  WidgetTester tester,
  Game game, {
  double width = 160,
  double height = 120,
  double pixelRatio = 1,
  int frames = 3,
}) async {
  tester.view
    ..physicalSize = Size(width * pixelRatio, height * pixelRatio)
    ..devicePixelRatio = pixelRatio;
  addTearDown(tester.view.reset);

  final key = GlobalKey();
  await tester.pumpWidget(
    RepaintBoundary(
      key: key,
      child: GameWidget(game: game),
    ),
  );
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  return (await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final pixels = await readImage(image);
    image.dispose();
    return pixels;
  }))!;
}

/// A group holding one child object.
class _Holder({required Component3D child, super.position})
    extends Component3D {
  this : super(children: [child]);
}
