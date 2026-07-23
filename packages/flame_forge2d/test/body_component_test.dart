import 'dart:math';

import 'package:flame/components.dart'
    show Anchor, ComponentKey, PositionComponent;
import 'package:flame/events.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _TestBodyComponent extends BodyComponent with TapCallbacks {
  int tapCount = 0;

  @override
  Body createBody() => body;

  @override
  void onTapDown(TapDownEvent _) {
    tapCount++;
  }
}

class _MockCanvas extends Mock implements Canvas {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('BodyComponent', () {
    group('renderBody', () {
      test('is true by default', () {
        final component = _TestBodyComponent();
        expect(component.renderBody, isTrue);
      });

      test('sets and gets', () {
        final component = _TestBodyComponent()..renderBody = false;
        expect(component.renderBody, isFalse);
      });
    });

    group('render', () {
      group('draws correctly', () {
        String goldenPath(String name) => 'goldens/body_component/$name.png';

        final flameTester = FlameTester(Forge2DGame.new);
        final testPaint = Paint()..color = const Color(0xffff0000);

        flameTester.testGameWidget(
          'a Circle',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            body.createShape(Circle(radius: 5));

            final component = _TestBodyComponent()
              ..body = body
              ..paint = testPaint;
            await game.world.add(component);

            game.camera.follow(component);
          },
          verify: (game, tester) async {
            await expectLater(
              find.byGame<Forge2DGame>(),
              matchesGoldenFile(goldenPath('circle_shape')),
            );
          },
        );

        flameTester.testGameWidget(
          'a Segment',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            body.createShape(
              Segment(point1: Vector2.zero(), point2: Vector2.all(10)),
            );

            final component = _TestBodyComponent()
              ..body = body
              ..paint = testPaint;
            await game.world.add(component);

            game.camera.follow(component);
          },
          verify: (game, tester) async {
            await expectLater(
              find.byGame<Forge2DGame>(),
              matchesGoldenFile(goldenPath('segment_shape')),
            );
          },
        );

        flameTester.testGameWidget(
          'a Capsule',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            body.createShape(
              Capsule(
                center1: Vector2.zero(),
                center2: Vector2.all(10),
                radius: 3,
              ),
            );

            final component = _TestBodyComponent()
              ..body = body
              ..paint = testPaint;
            await game.world.add(component);

            game.camera.follow(component);
          },
          verify: (game, tester) async {
            await expectLater(
              find.byGame<Forge2DGame>(),
              matchesGoldenFile(goldenPath('capsule_shape')),
            );
          },
        );

        flameTester.testGameWidget(
          'a Polygon',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            body.createShape(
              Polygon([
                Vector2.zero(),
                Vector2.all(10),
                Vector2(0, 10),
              ]),
            );

            final component = _TestBodyComponent()
              ..body = body
              ..paint = testPaint;
            await game.world.add(component);

            game.camera.follow(component);

            // a Polygon contains point
            expect(component.containsPoint(Vector2(2, 8)), isTrue);
          },
          verify: (game, tester) async {
            await expectLater(
              find.byGame<Forge2DGame>(),
              matchesGoldenFile(goldenPath('polygon_shape')),
            );
          },
        );

        flameTester.testGameWidget(
          'an open Chain',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            // The first and last points of an open chain are ghost anchors
            // and are not part of the collidable (and rendered) segments, so
            // these five points render as two connected segments.
            body.createChain(
              ChainDef(
                points: [
                  Vector2(-10, 10),
                  Vector2(-10, 0),
                  Vector2.zero(),
                  Vector2.all(10),
                  Vector2(20, 10),
                ],
              ),
            );

            final component = _TestBodyComponent()
              ..body = body
              ..paint = testPaint;
            await game.world.add(component);

            game.camera.follow(component);
          },
          verify: (game, tester) async {
            await expectLater(
              find.byGame<Forge2DGame>(),
              matchesGoldenFile(goldenPath('chain_shape_open')),
            );
          },
        );

        flameTester.testGameWidget(
          'a closed Chain',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            body.createChain(
              ChainDef(
                points: [
                  Vector2.zero(),
                  Vector2(10, 0),
                  Vector2.all(10),
                  Vector2(0, 10),
                ],
                isLoop: true,
              ),
            );

            final component = _TestBodyComponent()
              ..body = body
              ..paint = testPaint;
            await game.world.add(component);

            game.camera.follow(component);
          },
          verify: (game, tester) async {
            await expectLater(
              find.byGame<Forge2DGame>(),
              matchesGoldenFile(goldenPath('chain_shape_closed')),
            );
          },
        );
      });
    });

    group('rendering toggles', () {
      testWithGame(
        'render skips the shapes when renderBody is false and '
        'renderDebugMode always renders them',
        Forge2DGame.new,
        (game) async {
          final canvas = _MockCanvas();
          final component = _CountingBodyComponent(
            bodyDef: BodyDef(),
            shapeSpecs: [ShapeSpec(Circle(radius: 1))],
          );
          await game.world.ensureAdd(component);

          component.render(canvas);
          expect(component.renderedShapes, 1);

          component.renderBody = false;
          component.render(canvas);
          expect(component.renderedShapes, 1);

          component.renderDebugMode(canvas);
          expect(component.renderedShapes, 2);
        },
      );
    });

    group('renderShape', () {
      group('returns normally', () {
        late Canvas canvas;
        late World world;
        late Body body;

        setUp(() {
          canvas = _MockCanvas();
          world = World();
          body = world.createBody(BodyDef());
        });

        tearDown(() {
          world.destroy();
        });

        test('when rendering a Circle', () {
          final component = _TestBodyComponent();
          final shape = body.createShape(Circle(radius: 5));

          expect(
            () => component.renderShape(canvas, shape),
            returnsNormally,
          );
        });

        test('when rendering a Segment', () {
          final component = _TestBodyComponent();
          final shape = body.createShape(
            Segment(point1: Vector2.zero(), point2: Vector2.all(10)),
          );

          expect(
            () => component.renderShape(canvas, shape),
            returnsNormally,
          );
        });

        test('when rendering a Capsule', () {
          final component = _TestBodyComponent();
          final shape = body.createShape(
            Capsule(
              center1: Vector2.zero(),
              center2: Vector2.all(10),
              radius: 2,
            ),
          );

          expect(
            () => component.renderShape(canvas, shape),
            returnsNormally,
          );
        });

        test('when rendering a Polygon', () {
          final component = _TestBodyComponent();
          final shape = body.createShape(
            Polygon([
              Vector2.zero(),
              Vector2.all(10),
              Vector2(0, 10),
            ]),
          );

          expect(
            () => component.renderShape(canvas, shape),
            returnsNormally,
          );
        });

        test('when rendering a chain segment', () {
          final component = _TestBodyComponent();
          final chain = body.createChain(
            ChainDef(
              points: [
                Vector2(-10, 0),
                Vector2.zero(),
                Vector2.all(10),
                Vector2(10, 0),
              ],
            ),
          );

          expect(chain.segments, isNotEmpty);
          for (final shape in chain.segments) {
            expect(
              () => component.renderShape(canvas, shape),
              returnsNormally,
            );
          }
        });
      });
    });

    group('Add component to parent', () {
      final flameTester = FlameTester(Forge2DGame.new);
      final testPaint = Paint()..color = const Color(0xffff0000);

      flameTester.testGameWidget(
        'add and remove child to BodyComponent',
        setUp: (game, tester) async {
          final bodyDef = BodyDef();
          final body = game.world.createBody(bodyDef);
          body.createShape(
            Polygon([
              Vector2.zero(),
              Vector2.all(10),
              Vector2(0, 10),
            ]),
          );

          final component = _TestBodyComponent()
            ..body = body
            ..paint = testPaint;

          game.world.add(component);
          await game.ready();

          expect(game.world.contains(component), true);
          expect(component.isMounted, true);
          expect(game.world.children.length, 1);
          component.removeFromParent();
          await game.ready();

          expect(component.isMounted, false);
          expect(component.isLoaded, true);
          expect(game.world.children.length, 0);
        },
      );
    });

    group('PositionComponent parented by BodyComponent', () {
      final flameTester = FlameTester(Forge2DGame.new);

      flameTester.testGameWidget(
        'absoluteAngle',
        setUp: (game, tester) async {
          // Creates a body with an angle of 2 radians
          final body = game.world.createBody(
            BodyDef(rotation: Rot.fromAngle(2.0)),
          );
          body.createShape(
            Segment(point1: Vector2.zero(), point2: Vector2.all(10)),
          );
          final bodyComponent = _TestBodyComponent()..body = body;

          // Creates a positional component with an angle of 1 radians
          final positionComponent = PositionComponent(angle: 1.0);

          // Creates a hierarchy: game > bodyComponent > positionComponent
          game.world.add(bodyComponent);
          bodyComponent.add(positionComponent);

          await game.ready();

          // Checks the hierarchy
          expect(game.world.contains(bodyComponent), true);
          expect(bodyComponent.contains(positionComponent), true);
          expect(game.world.children.length, 1);
          expect(bodyComponent.children.length, 1);
          expect(positionComponent.children.length, 0);

          // Expects the absolute angle to be (2 + 1) radians, within the
          // precision that survives the round trip through the physics
          // engine's 32-bit floats.
          expect(positionComponent.absoluteAngle, closeTo(3.0, 1e-6));
        },
      );
    });

    group('createBody', () {
      test('should throw an error if bodyDef is null', () {
        final bodyComponent = BodyComponent();
        expect(bodyComponent.createBody, throwsAssertionError);
      });

      group('should create body', () {
        final flameTester = FlameTester(Forge2DGame.new);

        flameTester.testGameWidget(
          'with no shapes',
          setUp: (game, tester) async {
            final bodyComponent = BodyComponent(
              bodyDef: BodyDef(position: Vector2(33, 44)),
              key: ComponentKey.named('tested'),
            );
            game.world.add(bodyComponent);
          },
          verify: (game, tester) async {
            expect(
              game.findByKeyName<BodyComponent>('tested')!.body.position,
              Vector2(33, 44),
            );
          },
        );

        flameTester.testGameWidget(
          'with a set of shapes',
          setUp: (game, tester) async {
            final bodyComponent = BodyComponent(
              bodyDef: BodyDef(),
              shapeSpecs: [
                ShapeSpec(Circle(radius: 10)),
                ShapeSpec(Circle(radius: 20)),
                ShapeSpec(Circle(radius: 30)),
              ],
              key: ComponentKey.named('tested'),
            );
            game.world.add(bodyComponent);
          },
          verify: (game, tester) async {
            final bodyComponent = game.findByKeyName<BodyComponent>('tested')!;
            final radii = bodyComponent.body.shapes
                .map((shape) => (shape.geometry as Circle).radius)
                .toSet();
            expect(radii, {10.0, 20.0, 30.0});
          },
        );

        flameTester.testGameWidget(
          'without contact events enabled when no ContactCallbacks is used',
          setUp: (game, tester) async {
            final bodyComponent = BodyComponent(
              bodyDef: BodyDef(),
              shapeSpecs: [ShapeSpec(Circle(radius: 10))],
              key: ComponentKey.named('tested'),
            );
            game.world.add(bodyComponent);
          },
          verify: (game, tester) async {
            final bodyComponent = game.findByKeyName<BodyComponent>('tested')!;
            final shape = bodyComponent.body.shapes.single;
            expect(shape.contactEventsEnabled, isFalse);
            expect(shape.sensorEventsEnabled, isFalse);
          },
        );

        flameTester.testGameWidget(
          'with contact events enabled when the bodyDef userData is a '
          'ContactCallbacks',
          setUp: (game, tester) async {
            final bodyComponent = BodyComponent(
              bodyDef: BodyDef(userData: ContactCallbacks()),
              shapeSpecs: [ShapeSpec(Circle(radius: 10))],
              key: ComponentKey.named('tested'),
            );
            game.world.add(bodyComponent);
          },
          verify: (game, tester) async {
            final bodyComponent = game.findByKeyName<BodyComponent>('tested')!;
            final shape = bodyComponent.body.shapes.single;
            expect(shape.contactEventsEnabled, isTrue);
            expect(shape.sensorEventsEnabled, isTrue);
          },
        );

        flameTester.testGameWidget(
          'with contact events enabled when a ShapeDef userData is a '
          'ContactCallbacks',
          setUp: (game, tester) async {
            final bodyComponent = BodyComponent(
              bodyDef: BodyDef(),
              shapeSpecs: [
                ShapeSpec(
                  Circle(radius: 10),
                  ShapeDef(userData: ContactCallbacks()),
                ),
              ],
              key: ComponentKey.named('tested'),
            );
            game.world.add(bodyComponent);
          },
          verify: (game, tester) async {
            final bodyComponent = game.findByKeyName<BodyComponent>('tested')!;
            final shape = bodyComponent.body.shapes.single;
            expect(shape.contactEventsEnabled, isTrue);
            expect(shape.sensorEventsEnabled, isTrue);
          },
        );
      });
    });

    testWithGame(
      'the body is recreated when the component is added back',
      Forge2DGame.new,
      (game) async {
        final component = BodyComponent(
          bodyDef: BodyDef(type: BodyType.dynamic, position: Vector2(3, 4)),
          shapeSpecs: [ShapeSpec(Circle(radius: 1))],
        );
        await game.world.ensureAdd(component);
        final firstBody = component.body;

        component.removeFromParent();
        await game.ready();
        expect(firstBody.isValid, isFalse);

        await game.world.ensureAdd(component);

        // Reading a destroyed body reads freed native memory, so the
        // component must come back with a live one.
        expect(component.body.isValid, isTrue);
        expect(component.body.position, Vector2(3, 4));
        expect(component.body.shapes, hasLength(1));
        expect(() => game.update(0), returnsNormally);
      },
    );

    group('accessors', () {
      testWithGame('position, center and angle', Forge2DGame.new, (game) async {
        final component = BodyComponent(
          bodyDef: BodyDef(
            position: Vector2(3, 4),
            rotation: Rot.fromAngle(1),
          ),
          shapeSpecs: [ShapeSpec(Circle(radius: 2))],
        );
        await game.world.ensureAdd(component);

        expect(component.position, Vector2(3, 4));
        expect(component.center, Vector2(3, 4));
        expect(component.angle, closeTo(1, 1e-6));
        expect(component.camera, game.camera);
      });

      testWithGame(
        'parentToLocal and localToParent are inverses',
        Forge2DGame.new,
        (game) async {
          final component = BodyComponent(
            bodyDef: BodyDef(
              position: Vector2(3, 4),
              rotation: Rot.fromAngle(1),
            ),
            shapeSpecs: [ShapeSpec(Circle(radius: 2))],
          );
          await game.world.ensureAdd(component);
          game.update(0);

          final point = Vector2(1, 2);
          final roundTrip = component.parentToLocal(
            component.localToParent(point),
          );
          expect(roundTrip.x, closeTo(point.x, 1e-6));
          expect(roundTrip.y, closeTo(point.y, 1e-6));
        },
      );
    });

    group('containsLocalPoint', () {
      testWithGame('with rotation', Forge2DGame.new, (game) async {
        game.camera.viewfinder.anchor = Anchor.topLeft;
        final zoom = game.metersToPixels;
        final position = Vector2.all(10);
        final body = game.world.createBody(
          BodyDef(position: position, rotation: Rot.fromAngle(pi / 2)),
        );

        body.createShape(Circle(radius: 1, center: Vector2(3, 0)));
        body.createShape(Circle(radius: 1, center: Vector2(-3, 0)));
        final component = _TestBodyComponent()..body = body;

        await game.world.ensureAdd(component);
        game.update(0);
        final tapDispatcher = game.firstChild<MultiTapDispatcher>()!;

        tapDispatcher.handleTapDown(
          1,
          TapDownDetails(
            globalPosition: position.toOffset() * zoom + Offset(0, 3 * zoom),
          ),
        );
        expect(component.tapCount, 1);

        tapDispatcher.handleTapDown(
          1,
          TapDownDetails(
            globalPosition: position.toOffset() * zoom + Offset(3 * zoom, 0),
          ),
        );
        expect(component.tapCount, 1);

        tapDispatcher.handleTapDown(
          1,
          TapDownDetails(
            globalPosition: position.toOffset() * zoom + Offset(0, -3 * zoom),
          ),
        );
        expect(component.tapCount, 2);

        tapDispatcher.handleTapDown(
          1,
          TapDownDetails(
            globalPosition: position.toOffset() * zoom + Offset(-3 * zoom, 0),
          ),
        );
        expect(component.tapCount, 2);

        tapDispatcher.handleTapDown(
          1,
          TapDownDetails(
            globalPosition: position.toOffset() * zoom,
          ),
        );
        expect(component.tapCount, 2);
      });
    });

    testWithGame(
      'BodyComponent.world consistency in onRemove',
      Forge2DGame.new,
      (game) async {
        final component = _ConsistentBodyComponent(bodyDef: BodyDef());
        await game.world.add(component);
        await game.ready();
        component.removeFromParent();
        await game.ready();

        // Verify that the world is the same in onMount and onRemove
        expect(component.onMountWorld, equals(component.onRemoveWorld));
      },
    );

    testWithGame(
      'BodyComponent.world consistency in onRemove with world change',
      Forge2DGame.new,
      (game) async {
        final component = _ConsistentBodyComponent(bodyDef: BodyDef());
        await game.world.add(component);
        await game.ready();
        game.world = Forge2DWorld();
        await game.ready();

        // Verify that the world is the same in onMount and onRemove
        expect(component.onMountWorld, equals(component.onRemoveWorld));
      },
    );
  });
}

class _CountingBodyComponent extends BodyComponent {
  _CountingBodyComponent({super.bodyDef, super.shapeSpecs});

  int renderedShapes = 0;

  @override
  void renderShape(Canvas canvas, Shape shape) {
    renderedShapes++;
    super.renderShape(canvas, shape);
  }
}

class _ConsistentBodyComponent extends BodyComponent {
  _ConsistentBodyComponent({super.bodyDef});

  Forge2DWorld? onMountWorld;
  Forge2DWorld? onRemoveWorld;

  @override
  void onMount() {
    super.onMount();
    onMountWorld = world;
  }

  @override
  void onRemove() {
    super.onRemove();
    onRemoveWorld = world;
  }
}
