import 'package:flame/components.dart' show PositionComponent;
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'helpers/mocks.dart';

class _TestBodyComponent extends BodyComponent {
  @override
  Body createBody() => body;

  @override
  void noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
  });
}
