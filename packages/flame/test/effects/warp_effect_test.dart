import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WarpEffect', () {
    final identity = WarpGrid.identity();
    // Moves the bottom-right corner by (0.5, 0.25).
    final offsets = [
      Vector2.zero(),
      Vector2.zero(),
      Vector2.zero(),
      Vector2(0.5, 0.25),
    ];

    testWithFlameGame('relative', (game) async {
      final component = _WarpedComponent()..warpGrid = identity;
      await game.ensureAdd(component);

      component.add(WarpEffect.by(offsets, EffectController(duration: 1)));
      game.update(0);
      expect(component.warpGrid, identity);
      expect(component.children.length, 1);

      game.update(0.5);
      expect(_destination(component, 3), closeToVector(Vector2(1.25, 1.125)));
      expect(_destination(component, 0), closeToVector(Vector2.zero()));

      game.update(0.5);
      expect(_destination(component, 3), closeToVector(Vector2(1.5, 1.25)));
      game.update(0);
      expect(component.children.length, 0);
      expect(component.warpGrid!.sourcePositions, identity.sourcePositions);
    });

    testWithFlameGame('relative with source offsets', (game) async {
      final component = _WarpedComponent()..warpGrid = identity;
      await game.ensureAdd(component);

      component.add(
        WarpEffect.by(
          List.generate(4, (_) => Vector2.zero()),
          EffectController(duration: 1),
          sourceOffsets: offsets.map((o) => -o).toList(),
        ),
      );
      game.update(0);
      game.update(0.5);
      expect(_source(component, 3), closeToVector(Vector2(0.75, 0.875)));
      expect(_destination(component, 3), closeToVector(Vector2(1, 1)));
    });

    testWithFlameGame('absolute', (game) async {
      final target = WarpGrid(
        columns: 1,
        rows: 1,
        sourcePositions: [
          Vector2(0.5, 0),
          Vector2(1, 0),
          Vector2(0, 1),
          Vector2(1, 1),
        ],
        destinationPositions: [
          Vector2(-1, 0),
          Vector2(1, 0),
          Vector2(0, 1),
          Vector2(2, 3),
        ],
      );
      final component = _WarpedComponent()..warpGrid = identity;
      await game.ensureAdd(component);

      component.add(WarpEffect.to(target, EffectController(duration: 1)));
      game.update(0);
      game.update(0.5);
      expect(_source(component, 0), closeToVector(Vector2(0.25, 0)));
      expect(_destination(component, 0), closeToVector(Vector2(-0.5, 0)));
      expect(_destination(component, 3), closeToVector(Vector2(1.5, 2)));

      game.update(0.5);
      for (var i = 0; i < target.vertexCount; i++) {
        expect(_source(component, i), closeToVector(target.sourcePosition(i)));
        expect(
          _destination(component, i),
          closeToVector(target.destinationPosition(i)),
        );
      }
    });

    testWithFlameGame('absolute without initial grid', (game) async {
      final target =
          WarpGrid.identity(
            columns: 2,
            rows: 3,
          ).replacingDestinationPositions(
            List.generate(12, (i) => Vector2(i.toDouble(), 0)),
          );
      final component = _WarpedComponent();
      await game.ensureAdd(component);

      component.add(WarpEffect.to(target, EffectController(duration: 1)));
      game.update(0);
      expect(component.warpGrid, WarpGrid.identity(columns: 2, rows: 3));

      game.update(1);
      expect(component.warpGrid!.columns, 2);
      expect(component.warpGrid!.rows, 3);
      expect(_destination(component, 5), closeToVector(Vector2(5, 0)));
    });

    testWithFlameGame('unchanged positions are shared', (game) async {
      final component = _WarpedComponent()..warpGrid = identity;
      await game.ensureAdd(component);

      component.add(
        WarpEffect.to(
          identity.replacingDestinationPositions(
            [
              for (var i = 0; i < 4; i++) identity.destinationPosition(i),
            ]..[3] = Vector2(2, 2),
          ),
          EffectController(duration: 1),
        ),
      );
      game.update(0);
      game.update(0.5);
      expect(
        identical(
          component.warpGrid!.rawSourcePositions,
          identity.rawSourcePositions,
        ),
        isTrue,
      );
    });

    testWithFlameGame('unchanged grid is kept', (game) async {
      final component = _WarpedComponent()..warpGrid = identity;
      await game.ensureAdd(component);

      component.add(
        WarpEffect.to(WarpGrid.identity(), EffectController(duration: 1)),
      );
      game.update(0);
      game.update(0.5);
      expect(identical(component.warpGrid, identity), isTrue);
      game.update(0.5);
      game.update(0);
      expect(component.children.length, 0);
      expect(identical(component.warpGrid, identity), isTrue);
    });

    testWithFlameGame('reversed', (game) async {
      final component = _WarpedComponent()..warpGrid = identity;
      await game.ensureAdd(component);

      component.add(
        WarpEffect.by(
          offsets,
          EffectController(duration: 1, reverseDuration: 1),
        ),
      );
      game.update(0);
      game.update(1);
      expect(_destination(component, 3), closeToVector(Vector2(1.5, 1.25)));
      game.update(0.5);
      expect(_destination(component, 3), closeToVector(Vector2(1.25, 1.125)));
      game.update(0.5);
      expect(_destination(component, 3), closeToVector(Vector2(1, 1)));
    });

    testWithFlameGame('combined effects', (game) async {
      final component = _WarpedComponent()..warpGrid = identity;
      await game.ensureAdd(component);

      component.addAll([
        WarpEffect.by(offsets, EffectController(duration: 1)),
        WarpEffect.by(
          offsets.map((o) => o * -2).toList(),
          EffectController(duration: 2),
        ),
      ]);
      game.update(0);
      game.update(1);
      expect(_destination(component, 3), closeToVector(Vector2(1, 1)));
      game.update(1);
      expect(_destination(component, 3), closeToVector(Vector2(0.5, 0.75)));
    });

    testWithFlameGame('sequence of grids', (game) async {
      final first = identity.replacingDestinationPositions(
        identity.destinationPositions..[0] = Vector2(-1, -1),
      );
      final component = _WarpedComponent()..warpGrid = identity;
      await game.ensureAdd(component);

      component.add(
        SequenceEffect([
          WarpEffect.to(first, EffectController(duration: 1)),
          WarpEffect.to(identity, EffectController(duration: 1)),
        ]),
      );
      game.update(0);
      game.update(1);
      expect(_destination(component, 0), closeToVector(Vector2(-1, -1)));
      game.update(0.5);
      expect(_destination(component, 0), closeToVector(Vector2(-0.5, -0.5)));
      game.update(0.5);
      expect(_destination(component, 0), closeToVector(Vector2.zero()));
    });

    testWithFlameGame('HasWarpGrid target', (game) async {
      final component = _WarpedSprite(sprite: Sprite(await generateImage()))
        ..warpGrid = identity;
      await game.ensureAdd(component);

      component.add(WarpEffect.by(offsets, EffectController(duration: 1)));
      game.update(0);
      game.update(1);
      expect(
        component.warpGrid!.destinationPosition(3),
        closeToVector(Vector2(1.5, 1.25)),
      );
    });

    testWithFlameGame('relative without grid', (game) async {
      final component = _WarpedComponent();
      await game.ensureAdd(component);

      component.add(WarpEffect.by(offsets, EffectController(duration: 1)));
      expect(() => game.update(0), throwsStateError);
    });

    testWithFlameGame('grid removed while running', (game) async {
      final component = _WarpedComponent()..warpGrid = identity;
      await game.ensureAdd(component);

      component.add(WarpEffect.by(offsets, EffectController(duration: 1)));
      game.update(0);
      component.warpGrid = null;
      expect(() => game.update(0.5), throwsStateError);
    });

    testWithFlameGame('relative with wrong number of offsets', (game) async {
      final component = _WarpedComponent()
        ..warpGrid = WarpGrid.identity(columns: 2);
      await game.ensureAdd(component);

      component.add(WarpEffect.by(offsets, EffectController(duration: 1)));
      expect(() => game.update(0), throwsArgumentError);
    });

    testWithFlameGame('absolute with different dimensions', (game) async {
      final component = _WarpedComponent()..warpGrid = identity;
      await game.ensureAdd(component);

      component.add(
        WarpEffect.to(
          WarpGrid.identity(rows: 2),
          EffectController(duration: 1),
        ),
      );
      expect(() => game.update(0), throwsArgumentError);
    });

    testWithFlameGame('explicit target', (game) async {
      final provider = _WarpedComponent()..warpGrid = identity;
      final component = Component();
      await game.ensureAdd(component);

      component.add(
        WarpEffect.by(
          offsets,
          EffectController(duration: 1),
          target: provider,
        ),
      );
      game.update(0);
      game.update(1);
      expect(_destination(provider, 3), closeToVector(Vector2(1.5, 1.25)));
    });
  });
}

Vector2 _source(WarpGridProvider provider, int index) =>
    provider.warpGrid!.sourcePosition(index);

Vector2 _destination(WarpGridProvider provider, int index) =>
    provider.warpGrid!.destinationPosition(index);

class _WarpedComponent() extends Component implements WarpGridProvider {
  @override
  WarpGrid? warpGrid;
}

class _WarpedSprite({super.sprite}) extends SpriteComponent with HasWarpGrid;
