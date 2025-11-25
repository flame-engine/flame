// ignore_for_file: invalid_use_of_internal_member

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

import 'helpers/mocks.dart';

class _TestBodyComponent extends BodyComponent with TapCallbacks {
  int tapCount = 0;

  @override
  Body createBody() => body;

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

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
          'a CircleShape',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            final shape = CircleShape()..radius = 5;
            body.createFixture(FixtureDef(shape));

            final component = _TestBodyComponent()
              ..body = body
              ..paint = testPaint;
            await game.world.add(component);

            game.camera.follow(component);
          },
        );

        flameTester.testGameWidget(
          'an EdgeShape',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            final shape = EdgeShape()
              ..set(
                Vector2.zero(),
                Vector2.all(10),
              );
            body.createFixture(FixtureDef(shape));

            final component = _TestBodyComponent()
              ..body = body
              ..paint = testPaint;
            await game.world.add(component);

            game.camera.follow(component);
          },
          verify: (game, tester) async {
            await expectLater(
              find.byGame<Forge2DGame>(),
              matchesGoldenFile(goldenPath('edge_shape')),
            );
          },
        );

        flameTester.testGameWidget(
          'a PolygonShape',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            final shape = PolygonShape()
              ..set(
                [
                  Vector2.zero(),
                  Vector2.all(10),
                  Vector2(0, 10),
                ],
              );
            body.createFixture(FixtureDef(shape));

            final component = _TestBodyComponent()
              ..body = body
              ..paint = testPaint;
            await game.world.add(component);

            game.camera.follow(component);

            // a PolygonShape contains point
            expect(component.containsPoint(Vector2.all(10)), isTrue);
          },
          verify: (game, tester) async {
            await expectLater(
              find.byGame<Forge2DGame>(),
              matchesGoldenFile(goldenPath('polygon_shape')),
            );
          },
        );

        flameTester.testGameWidget(
          'an open ChainShape',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            final shape = ChainShape()
              ..createChain(
                [
                  Vector2.zero(),
                  Vector2.all(10),
                  Vector2(10, 0),
                ],
              );
            body.createFixture(FixtureDef(shape));

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
          'a closed ChainShape',
          setUp: (game, tester) async {
            final body = game.world.createBody(BodyDef());
            final shape = ChainShape()
              ..createLoop(
                [
                  Vector2.zero(),
                  Vector2.all(10),
                  Vector2(10, 0),
                ],
              );
            body.createFixture(FixtureDef(shape));

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

    group('renderFixture', () {
      group('returns normally', () {
        late Canvas canvas;
        late Body body;

        setUp(() {
          canvas = _MockCanvas();
          final world = World();
          body = world.createBody(BodyDef());
        });

        test('when rendering a CircleShape', () {
          final component = _TestBodyComponent();
          final shape = CircleShape()..radius = 5;
          final fixture = body.createFixture(
            FixtureDef(shape),
          );

          expect(
            () => component.renderFixture(canvas, fixture),
            returnsNormally,
          );
        });

        test('when rendering an EdgeShape', () {
          final component = _TestBodyComponent();
          final shape = EdgeShape()
            ..set(
              Vector2.zero(),
              Vector2.all(10),
            );
          final fixture = body.createFixture(
            FixtureDef(shape),
          );

          expect(
            () => component.renderFixture(canvas, fixture),
            returnsNormally,
          );
        });

        test('when rendering a PolygonShape', () {
          final component = _TestBodyComponent();
          final shape = PolygonShape()
            ..set(
              [
                Vector2.zero(),
                Vector2.all(10),
                Vector2(0, 10),
              ],
            );
          final fixture = body.createFixture(
            FixtureDef(shape),
          );

          expect(
            () => component.renderFixture(canvas, fixture),
            returnsNormally,
          );
        });

        test('when rendering a ChainShape', () {
          final component = _TestBodyComponent();
          final shape = ChainShape()
            ..createChain(
              [
                Vector2.zero(),
                Vector2.all(10),
                Vector2(10, 0),
              ],
            );
          final fixture = body.createFixture(
            FixtureDef(shape),
          );

          expect(
            () => component.renderFixture(canvas, fixture),
            returnsNormally,
          );
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
          final shape = PolygonShape()
            ..set(
              [
                Vector2.zero(),
                Vector2.all(10),
                Vector2(0, 10),
              ],
            );
          body.createFixture(FixtureDef(shape));

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

    group('BodyComponent contact events', () {
      test('beginContact called', () {
        final contactCallback = MockContactCallback();
        final contact = MockContact();
        final bodyA = MockBody()..angularDamping = 1.0;
        final fixtureA = MockFixture();
        when(() => bodyA.userData).thenReturn(contactCallback);
        when(() => fixtureA.userData).thenReturn(Object());
        contactCallback.beginContact(fixtureA.userData!, contact);

        verify(
          () => contactCallback.beginContact(fixtureA.userData!, contact),
        ).called(1);
      });
    });

    group('PositionComponent parented by BodyComponent', () {
      final flameTester = FlameTester(Forge2DGame.new);

      flameTester.testGameWidget(
        'absoluteAngle',
        setUp: (game, tester) async {
          // Creates a body with an angle of 2 radians
          final body = game.world.createBody(BodyDef(angle: 2.0));
          final shape = EdgeShape()
            ..set(
              Vector2.zero(),
              Vector2.all(10),
            );
          body.createFixture(FixtureDef(shape));
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

          // Expects the absolute angle to be (2 + 1) radians
          expect(positionComponent.absoluteAngle, 3.0);
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
          'with no fixtures',
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
          'with a set of fixtures',
          setUp: (game, tester) async {
            final bodyComponent = BodyComponent(
              bodyDef: BodyDef(),
              fixtureDefs: [
                FixtureDef(CircleShape()..radius = 10),
                FixtureDef(CircleShape()..radius = 20),
                FixtureDef(CircleShape()..radius = 30),
              ],
              key: ComponentKey.named('tested'),
            );
            game.world.add(bodyComponent);
          },
          verify: (game, tester) async {
            final bodyComponent = game.findByKeyName<BodyComponent>('tested')!;
            expect(bodyComponent.body.fixtures[0].shape.radius, 10);
            expect(bodyComponent.body.fixtures[1].shape.radius, 20);
            expect(bodyComponent.body.fixtures[2].shape.radius, 30);
          },
        );
      });
    });

    group('containsLocalPoint', () {
      testWithGame('with rotation', Forge2DGame.new, (game) async {
        game.camera.viewfinder.anchor = Anchor.topLeft;
        final zoom = game.camera.viewfinder.zoom;
        final position = Vector2.all(10);
        final body = game.world.createBody(
          BodyDef(position: position, angle: pi / 2),
        );

        body.createFixtureFromShape(
          CircleShape()
            ..radius = 1
            ..position.setFrom(Vector2(3, 0)),
        );
        body.createFixtureFromShape(
          CircleShape()
            ..radius = 1
            ..position.setFrom(Vector2(-3, 0)),
        );
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
        final bodyDef = BodyDef();
        final body = game.world.createBody(bodyDef);
        final shape = CircleShape()..radius = 5;
        body.createFixture(FixtureDef(shape));

        final component = _ConsistentBodyComponent(bodyDef: bodyDef);
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
        final bodyDef = BodyDef();
        final body = game.world.createBody(bodyDef);
        final shape = CircleShape()..radius = 5;
        body.createFixture(FixtureDef(shape));

        final component = _ConsistentBodyComponent(bodyDef: bodyDef);
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
