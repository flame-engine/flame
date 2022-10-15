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
            await game.add(component);

            game.camera.followVector2(Vector2.zero());

            // a CircleShape contains point
            expect(component.containsPoint(Vector2.all(1.5)), isTrue);
          },
          verify: (game, tester) async {
            await expectLater(
              find.byGame<Forge2DGame>(),
              matchesGoldenFile(goldenPath('circle_shape')),
            );
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
            await game.add(component);

            game.camera.followVector2(Vector2.zero());
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
            await game.add(component);

            game.camera.followVector2(Vector2.zero());

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
            await game.add(component);

            game.camera.followVector2(Vector2.zero());
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
            await game.add(component);

            game.camera.followVector2(Vector2.zero());
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
      group('returs normally', () {
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
          final worldCenter =
              game.screenToWorld(game.size * game.camera.zoom / 2);

          final bodyDef = BodyDef(position: worldCenter.clone());
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

          component.addToParent(game);
          await game.ready();

          expect(game.contains(component), true);
          expect(component.isMounted, true);
          expect(game.children.length, 1);
          component.removeFromParent();
          await game.ready();

          expect(component.isMounted, false);
          expect(component.isLoaded, true);
          expect(game.children.length, 0);
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
  });
}
