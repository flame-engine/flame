import 'package:flame/camera.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:test/test.dart';

void main() {
  group('Forge2DViewfinder', () {
    test('scales the transform by metersToPixels', () {
      final viewfinder = Forge2DViewfinder(metersToPixels: 20);
      expect(viewfinder.zoom, 1);
      expect(viewfinder.transform.scale, Vector2.all(20));
    });

    test('keeps the zoom when metersToPixels changes', () {
      final viewfinder = Forge2DViewfinder(metersToPixels: 20)..zoom = 3;
      expect(viewfinder.transform.scale, Vector2.all(60));

      viewfinder.metersToPixels = 5;
      expect(viewfinder.zoom, 3);
      expect(viewfinder.transform.scale, Vector2.all(15));
    });

    test('scale is expressed in zoom levels', () {
      final viewfinder = Forge2DViewfinder(metersToPixels: 20)..zoom = 2;
      expect(viewfinder.scale, Vector2.all(2));

      viewfinder.scale = Vector2.all(4);
      expect(viewfinder.zoom, 4);
      expect(viewfinder.transform.scale, Vector2.all(80));
    });

    test('rejects non-positive values', () {
      final viewfinder = Forge2DViewfinder();
      expect(() => viewfinder.zoom = 0, throwsA(isA<AssertionError>()));
      expect(
        () => viewfinder.metersToPixels = -1,
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => viewfinder.scale = Vector2(1, 2),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Forge2DViewfinder(metersToPixels: 0),
        throwsA(isA<AssertionError>()),
      );
    });

    testWithGame(
      'visibleGameSize and visibleWorldRect are in meters',
      () => Forge2DGame(metersToPixels: 20),
      (game) async {
        game.onGameResize(Vector2.all(100));
        game.camera.viewfinder.visibleGameSize = Vector2.all(50);

        expect(game.camera.viewfinder.visibleGameSize, Vector2.all(50));
        expect(game.camera.viewfinder.zoom, 0.1);
        expect(game.camera.visibleWorldRect.width, 50);
        expect(game.camera.visibleWorldRect.height, 50);

        // Meters, not pixels: the size is unchanged by the rendering scale.
        game.metersToPixels = 40;
        expect(game.camera.viewfinder.visibleGameSize, Vector2.all(50));
        expect(game.camera.visibleWorldRect.width, 50);
      },
    );

    testWithGame(
      'a provided camera gets a Forge2DViewfinder',
      () => Forge2DGame(camera: CameraComponent(), metersToPixels: 15),
      (game) async {
        expect(game.camera.viewfinder, isA<Forge2DViewfinder>());
        expect(game.metersToPixels, 15);
        expect(game.camera.viewfinder.zoom, 1);
      },
    );

    testWithGame(
      'a provided Forge2DViewfinder is reused',
      () => Forge2DGame(
        camera: CameraComponent(viewfinder: Forge2DViewfinder()..zoom = 2),
        metersToPixels: 15,
      ),
      (game) async {
        expect(game.metersToPixels, 15);
        expect(game.camera.viewfinder.zoom, 2);
      },
    );

    testWithGame(
      'the zoom is applied on top of metersToPixels',
      () => Forge2DGame(metersToPixels: 20),
      (game) async {
        game.onGameResize(Vector2.all(100));
        game.camera.viewfinder.zoom = 2;

        // One meter covers 20 * 2 pixels, measured from the centre of the
        // screen, and the position stays in meters both ways.
        expect(game.worldToScreen(Vector2(1, 0)), Vector2(90, 50));
        expect(game.screenToWorld(Vector2(90, 50)), Vector2(1, 0));
        expect(game.camera.viewfinder.position, Vector2.zero());
      },
    );

    testWithGame(
      'the default renders one meter as ten pixels',
      Forge2DGame.new,
      (game) async {
        game.onGameResize(Vector2.all(100));
        expect(game.metersToPixels, 10);
        expect(game.camera.viewfinder.zoom, 1);
        expect(game.worldToScreen(Vector2.all(1)), Vector2.all(60));
      },
    );
  });
}
