import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:test/test.dart';

class _TestForge2dGame extends Forge2DGame {
  _TestForge2dGame() : super(zoom: 4.0, gravity: Vector2(0, -10.0));
}

void main() {
  group(
    'Test corresponding position on screen and in the Forge2D world',
    () {
      test('Zero positioned camera should be zero in world', () {
        expect(
          _TestForge2dGame().screenToWorld(Vector2.zero()),
          Vector2.zero(),
        );
      });

      test('Zero positioned camera should be zero in FlameWorld', () {
        expect(
          _TestForge2dGame().screenToFlameWorld(Vector2.zero()),
          Vector2.zero(),
        );
      });

      test('Converts a vector in the world space to the screen space', () {
        expect(
          _TestForge2dGame().worldToScreen(Vector2(5, 6)),
          Vector2(20.0, 24.0),
        );
      });

      test('Converts a vector in the screen space to the world space', () {
        expect(
          _TestForge2dGame().screenToFlameWorld(Vector2(5, 6)),
          Vector2(1.25, -1.5),
        );
      });
    },
  );

  group(
    'Test input vector does not get modified while function call',
    () {
      test('Camera should not modify the input vector while projecting it', () {
        final vec = Vector2(5, 6);
        _TestForge2dGame().camera.projectVector(vec);
        expect(vec, Vector2(5, 6));
      });
    },
  );
}
