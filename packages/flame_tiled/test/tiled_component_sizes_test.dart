import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TiledComponent.computeSize', () {
    test('orthogonal', () {
      expect(
        TiledComponent.computeSize(
          MapOrientation.orthogonal,
          Vector2(16, 16),
          16,
          16,
          5,
          5,
          null,
        ),
        Vector2(80, 80),
        reason: 'full sized tiles',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.orthogonal,
          Vector2(8, 8),
          16,
          16,
          5,
          4,
          null,
        ),
        Vector2(40, 32),
        reason: 'half sized tiles',
      );
      expect(
        TiledComponent.computeSize(
          MapOrientation.orthogonal,
          Vector2(8, 32),
          16,
          16,
          4,
          5,
          null,
        ),
        Vector2(32, 160),
        reason: 'odd sized tiles',
      );
    });

    test('isometric', () {
      expect(
        TiledComponent.computeSize(
          MapOrientation.isometric,
          Vector2(16, 16),
          16,
          16,
          5,
          4,
          null,
        ),
        Vector2(72, 72),
        reason: 'full sized tiles',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.isometric,
          Vector2(8, 8),
          16,
          16,
          4,
          5,
          null,
        ),
        Vector2(36, 36),
        reason: 'full sized tiles',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.isometric,
          Vector2(8, 32),
          16,
          16,
          7,
          5,
          null,
        ),
        Vector2(48, 192),
        reason: 'odd sized tiles',
      );
    });

    test('isometric', () {
      expect(
        TiledComponent.computeSize(
          MapOrientation.isometric,
          Vector2(16, 16),
          16,
          16,
          5,
          4,
          null,
        ),
        Vector2(72, 72),
        reason: 'full sized tiles',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.isometric,
          Vector2(8, 8),
          16,
          16,
          4,
          5,
          null,
        ),
        Vector2(36, 36),
        reason: 'full sized tiles',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.isometric,
          Vector2(8, 32),
          16,
          16,
          7,
          5,
          null,
        ),
        Vector2(48, 192),
        reason: 'odd sized tiles',
      );
    });

    test('hexagonal', () {
      expect(
        TiledComponent.computeSize(
          MapOrientation.hexagonal,
          Vector2(16, 16),
          16,
          16,
          4,
          5,
          StaggerAxis.x,
        ),
        Vector2(52, 88),
        reason: 'full sized tiles, stagger x',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.hexagonal,
          Vector2(16, 16),
          16,
          16,
          4,
          5,
          StaggerAxis.y,
        ),
        Vector2(72, 64),
        reason: 'full sized tiles, stagger y',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.hexagonal,
          Vector2(8, 8),
          16,
          16,
          4,
          5,
          StaggerAxis.x,
        ),
        Vector2(26, 44),
        reason: 'half sized tiles, stagger x',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.hexagonal,
          Vector2(8, 8),
          16,
          16,
          4,
          5,
          StaggerAxis.y,
        ),
        Vector2(36, 32),
        reason: 'full sized tiles, stagger y',
      );
    });

    test('staggered', () {
      expect(
        TiledComponent.computeSize(
          MapOrientation.staggered,
          Vector2(16, 16),
          16,
          16,
          4,
          5,
          StaggerAxis.x,
        ),
        Vector2(40, 88),
        reason: 'full sized tiles, stagger x',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.staggered,
          Vector2(16, 16),
          16,
          16,
          4,
          5,
          StaggerAxis.y,
        ),
        Vector2(72, 48),
        reason: 'full sized tiles, stagger y',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.staggered,
          Vector2(8, 8),
          16,
          16,
          4,
          5,
          StaggerAxis.x,
        ),
        Vector2(20, 44),
        reason: 'half sized tiles, stagger x',
      );

      expect(
        TiledComponent.computeSize(
          MapOrientation.staggered,
          Vector2(8, 8),
          16,
          16,
          4,
          5,
          StaggerAxis.y,
        ),
        Vector2(36, 24),
        reason: 'half sized tiles, stagger y',
      );
    });
  });
}
