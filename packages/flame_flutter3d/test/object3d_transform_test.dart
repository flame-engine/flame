/// The rest of Flame's transform crossing into the scene: after the effects
/// that move it, from wherever in Flame's tree the component sits, off the
/// plane, scaled, shown or hidden, and with a node under it the bridge leaves
/// alone. Run in a mounted game, because effects and parents are what is
/// being tested and neither does anything outside one.
library;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter3d/flutter3d.dart' as engine show Material;
import 'package:flutter3d/flutter3d.dart' hide Material;
import 'package:flutter_test/flutter_test.dart';

Object3dComponent _bridged(
  Scene scene, {
  Vector2? position,
  BridgePlane? plane,
  double elevation = 0.0,
}) => Object3dComponent(
  node: SceneNode(name: 'bridged'),
  scene: scene,
  plane: plane ?? BridgePlane.ground(),
  direction: SyncDirection.flameToScene,
  elevation: elevation,
  position: position,
);

void main() {
  testWithGame<FlameGame>(
    "an effect's move reaches the scene in the frame it happens",
    FlameGame.new,
    (game) async {
      final scene = Scene();
      final component = _bridged(scene)
        ..add(
          MoveEffect.by(Vector2(10.0, 0.0), EffectController(duration: 1.0)),
        );
      game.add(component);
      await game.ready();

      game.update(0.5);
      // Synced in `update`, before the effect ran, this read 0.
      expect(component.position.x, closeTo(5.0, 1e-6));
      expect(component.node.readPosition().x, closeTo(5.0, 1e-6));
    },
  );

  testWithGame<FlameGame>(
    'a component nested in another lands where Flame draws it',
    FlameGame.new,
    (game) async {
      final scene = Scene();
      final log = PositionComponent(position: Vector2(10.0, 4.0));
      final frog = _bridged(scene, position: Vector2(1.0, 0.0));
      game.add(log);
      log.add(frog);
      await game.ready();

      game.update(0.0);
      expect(frog.node.readPosition(), Vector3(11.0, 0.0, 4.0));

      log.position.x = 20.0;
      game.update(0.0);
      expect(frog.node.readPosition().x, closeTo(21.0, 1e-6));
    },
  );

  testWithGame<FlameGame>(
    "flowing the other way, a nested component reads its parent's space",
    FlameGame.new,
    (game) async {
      final scene = Scene();
      final holder = PositionComponent(position: Vector2(10.0, 0.0));
      final node = SceneNode()..setPosition(12.0, 0.0, 3.0);
      final body = Object3dComponent(
        node: node,
        scene: scene,
        plane: BridgePlane.ground(),
      );
      game.add(holder);
      holder.add(body);
      await game.ready();

      game.update(0.0);
      expect(body.position, Vector2(2.0, 3.0));
      expect(body.absolutePosition, Vector2(12.0, 3.0));
    },
  );

  testWithGame<FlameGame>(
    'a flipped, turned component under a flipped, turned parent is drawn '
    'where Flame draws it',
    FlameGame.new,
    (game) async {
      // Flame's absolute angle is reflected for a flipped component, and
      // written beside the signed scale it mirrored twice.
      //
      // Mutation: write absoluteAngle with absoluteScale.
      final scene = Scene();
      final plane = BridgePlane.ground();
      final parent = PositionComponent(
        position: Vector2(3.0, 2.0),
        angle: 0.4,
        scale: Vector2(-1.0, 1.0),
      );
      final ship = _bridged(scene, position: Vector2(1.0, 1.0), plane: plane)
        ..angle = 0.3
        ..scale = Vector2(1.0, -1.0);
      game.add(parent);
      parent.add(ship);
      await game.ready();
      game.update(0.0);

      for (final local in <Vector2>[Vector2(1.0, 0.0), Vector2(0.0, 1.0)]) {
        final flame = ship.absolutePositionOf(local);
        final drawn = plane.to2d(
          ship.node.worldMatrix.transformed3(Vector3(local.x, 0.0, local.y)),
        );
        expect(drawn.x, closeTo(flame.x, 1e-5), reason: 'at $local');
        expect(drawn.y, closeTo(flame.y, 1e-5), reason: 'at $local');
      }
    },
  );

  testWithGame<FlameGame>(
    'a plain component between a frog and its log does not hide the log',
    FlameGame.new,
    (game) async {
      // Mutation: ask only the parent whether it is positioned.
      final scene = Scene();
      final log = PositionComponent(position: Vector2(10.0, 4.0));
      final layer = Component();
      final frog = _bridged(scene, position: Vector2(1.0, 0.0));
      game.add(log);
      log.add(layer);
      layer.add(frog);
      await game.ready();

      game.update(0.0);
      expect(frog.node.readPosition(), Vector3(11.0, 0.0, 4.0));
    },
  );

  testWithGame<FlameGame>(
    'read back under a flipped parent, the turn comes back as it went out',
    FlameGame.new,
    (game) async {
      // Mutation: subtract the parent's absoluteAngle and nothing else.
      final scene = Scene();
      final plane = BridgePlane.ground();
      final parent = PositionComponent(
        position: Vector2(3.0, 2.0),
        angle: 0.4,
        scale: Vector2(-1.0, 1.0),
      );
      final writer = _bridged(scene, position: Vector2(1.0, 1.0), plane: plane)
        ..angle = 0.3;
      final reader = Object3dComponent(
        node: writer.node,
        scene: scene,
        plane: plane,
      );
      game.add(parent);
      parent.addAll(<Component>[writer, reader]);
      await game.ready();
      game
        ..update(0.0)
        ..update(0.0);

      expect(reader.position.x, closeTo(1.0, 1e-5));
      expect(reader.position.y, closeTo(1.0, 1e-5));
      expect(reader.angle, closeTo(0.3, 1e-5));
    },
  );

  testWithGame<FlameGame>(
    'elevation lifts the node off the plane, and scenePosition says where',
    FlameGame.new,
    (game) async {
      final scene = Scene();
      final jet = _bridged(
        scene,
        position: Vector2(2.0, -5.0),
        plane: BridgePlane.ground(height: 0.5),
        elevation: 1.2,
      );
      game.add(jet);
      await game.ready();

      game.update(0.0);
      expect(jet.node.readPosition().y, closeTo(1.7, 1e-6));
      expect(jet.scenePosition, jet.node.readPosition());

      jet.elevation = 0.0;
      game.update(0.0);
      expect(jet.node.readPosition().y, closeTo(0.5, 1e-6));
    },
  );

  testWithGame<FlameGame>(
    "Flame's scale scales the node, the normal by the mean of the two",
    FlameGame.new,
    (game) async {
      final scene = Scene();
      final rock = _bridged(scene)..scale = Vector2(2.0, 3.0);
      final sign = _bridged(scene, plane: BridgePlane.backdrop())
        ..scale = Vector2(2.0, 4.0);
      game.addAll(<Component>[rock, sign]);
      await game.ready();

      game.update(0.0);
      expect(rock.node.readScale(), Vector3(2.0, 2.5, 3.0));
      expect(sign.node.readScale(), Vector3(2.0, 4.0, 3.0));
    },
  );

  testWithGame<FlameGame>(
    "Flame's visibility is written when it changes, and only then",
    FlameGame.new,
    (game) async {
      final scene = Scene();
      final ship = _bridged(scene);
      game.add(ship);
      await game.ready();

      ship.isVisible = false;
      game.update(0.0);
      expect(ship.node.visible, isFalse);

      ship.isVisible = true;
      game.update(0.0);
      expect(ship.node.visible, isTrue);

      // Blinking the node by hand, as a hit flash does, is left alone.
      ship.node.visible = false;
      game.update(0.0);
      expect(ship.node.visible, isFalse);
    },
  );

  testWithGame<FlameGame>(
    'a component let go stops being drawn at once',
    FlameGame.new,
    (game) async {
      final scene = Scene();
      final shot = _bridged(scene);
      game.add(shot);
      await game.ready();
      game.update(0.0);
      expect(shot.node.visible, isTrue);

      shot.removeFromParent();
      // Before Flame has processed the removal: already hidden.
      expect(shot.node.visible, isFalse);
      await game.ready();
      expect(shot.node.parent, isNull);
    },
  );

  testWithGame<FlameGame>(
    'the visual node is made on demand, under the node, and left alone',
    FlameGame.new,
    (game) async {
      final scene = Scene();
      final craft = _bridged(scene)..angle = 0.7;
      game.add(craft);
      await game.ready();

      final visual = craft.visual;
      expect(craft.visual, same(visual));
      expect(visual.parent, same(craft.node));

      final bank = Quaternion.axisAngle(Vector3(0.0, 0.0, 1.0), 0.4);
      visual.setRotation(bank);
      game.update(0.1);
      expect(visual.readRotation().z, closeTo(bank.z, 1e-6));
      expect(craft.node.readRotation().z, isNot(closeTo(bank.z, 1e-6)));
    },
  );

  testWithGame<FlameGame>(
    'a hidden parent hides its child in the scene, as Flame draws it',
    FlameGame.new,
    (game) async {
      // A frog on a log: the log blinks, and Flame stops drawing the frog
      // with it. The frog's node is not under the log's, so the bridge has
      // to ask the frog's ancestors, not only the frog.
      //
      // Mutation: write the child's own `isVisible` alone.
      final scene = Scene();
      final log = _bridged(scene);
      final frog = _bridged(scene);
      log.add(frog);
      game.add(log);
      await game.ready();

      log.isVisible = false;
      game.update(1 / 60);
      expect(frog.node.visible, isFalse);

      log.isVisible = true;
      game.update(1 / 60);
      expect(frog.node.visible, isTrue);
    },
  );

  testWithGame<FlameGame>(
    'a child under a scaled parent is scaled by both, as its place is',
    FlameGame.new,
    (game) async {
      // Its position already carries the parent's scale; its size has to
      // as well, or the model and the hitbox disagree about how big it is.
      //
      // Mutation: scale the node by the component's own `scale`.
      final scene = Scene();
      final parent = _bridged(scene)..scale = Vector2.all(2.0);
      final child = _bridged(scene, position: Vector2(1.0, 0.0))
        ..scale = Vector2.all(1.5);
      parent.add(child);
      game.add(parent);
      await game.ready();
      game.update(1 / 60);

      expect(child.node.readPosition().x, closeTo(2.0, 1e-6));
      expect(child.node.readScale().x, closeTo(3.0, 1e-6));
    },
  );

  testWithGame<FlameGame>(
    "Flame's opacity and a tint reach every mesh under the node",
    FlameGame.new,
    (game) async {
      // A wreck fading out with an OpacityEffect, over a material other
      // craft share; and a model dressed onto it later fades with it.
      //
      // Mutation: write the tint only when it changes, not while it holds.
      final scene = Scene();
      final wreck = _bridged(scene);
      final hull = MeshNode(
        CpuMesh(CuboidShape(size: Vector3.all(1.0)).build()),
        engine.Material(),
      );
      wreck.visual.add(hull);
      wreck.add(OpacityEffect.to(0.0, EffectController(duration: 1.0)));
      game.add(wreck);
      await game.ready();

      game.update(0.5);
      expect(hull.tint.w, closeTo(0.5, 1e-6));

      final model = MeshNode(
        CpuMesh(CuboidShape(size: Vector3.all(1.0)).build()),
        engine.Material(),
      );
      wreck.visual.add(model);
      game.update(0.25);
      expect(model.tint.w, closeTo(0.25, 1e-6), reason: 'dressed late');

      wreck
        ..opacity = 1.0
        ..tint.setValues(1.0, 0.2, 0.2, 1.0);
      game.update(0.0);
      expect(hull.tint, Vector4(1.0, 0.2, 0.2, 1.0));

      wreck.tint.setValues(1.0, 1.0, 1.0, 1.0);
      wreck.children.whereType<OpacityEffect>().toList().forEach(
        (e) => e.removeFromParent(),
      );
      await game.ready();
      wreck.opacity = 1.0;
      game.update(0.0);
      expect(hull.tint, Vector4.all(1.0), reason: 'back to plain');
    },
  );

  testWithGame<FlameGame>(
    'a bridged prop that does not move does not mark the scene changed',
    FlameGame.new,
    (game) async {
      // The engine keeps its shadow cascades and its tree of bounds for as
      // long as nothing changed, and a still tanker rewriting its place every
      // frame had every shadow redrawn every frame.
      //
      // Mutation: write the transform whether or not it moved.
      final scene = Scene();
      final tanker = _bridged(scene, position: Vector2(3.0, -8.0));
      game.add(tanker);
      await game.ready();
      game.update(1 / 60);

      final epoch = SceneNode.changeEpoch;
      for (var i = 0; i < 10; i++) {
        game.update(1 / 60);
      }
      expect(SceneNode.changeEpoch, epoch, reason: 'nothing moved');

      tanker.position.x = 4.0;
      game.update(1 / 60);
      expect(SceneNode.changeEpoch, greaterThan(epoch));
      expect(tanker.node.readPosition().x, closeTo(4.0, 1e-6));
    },
  );

  testWithGame<FlameGame>(
    'a tint effect colours what the component draws, as a colour effect '
    'would a sprite',
    FlameGame.new,
    (game) async {
      // Flame's ColorEffect wants a paint, and a bridged component has none.
      //
      // Mutation: leave the tint where it was.
      final scene = Scene();
      final hull = MeshNode(
        CpuMesh(CuboidShape(size: Vector3.all(1.0)).build()),
        engine.Material(),
      );
      final ship =
          Object3dComponent(
            node: hull,
            scene: scene,
            plane: BridgePlane.ground(),
            direction: SyncDirection.flameToScene,
          )..add(
            TintEffect(
              Vector4(1.0, 0.0, 0.0, 1.0),
              EffectController(duration: 1.0),
            ),
          );
      game.add(ship);
      await game.ready();

      game.update(0.5);
      expect(ship.tint.y, closeTo(0.5, 1e-6));
      expect(hull.tint.y, closeTo(0.5, 1e-6), reason: 'on the mesh drawn');
      game.update(0.5);
      expect(hull.tint.x, closeTo(1.0, 1e-6));
      expect(hull.tint.y, closeTo(0.0, 1e-6));
    },
  );
}
