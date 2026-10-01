/// What a co-op game with a simulation of its own asks of the bridge:
/// several foci, a step whose reports survive the game's own logic, actors
/// that come and go with the simulation, bodies the game moves drawn between
/// their steps, a horde in one draw, a party framed by one camera, players who
/// join by pressing, and a level that becomes the next.
library;

import 'package:flame/game.dart';
import 'package:flame_flutter3d/flame_flutter3d.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/services.dart' show LogicalKeyboardKey;
import 'package:flutter/widgets.dart' show SizedBox, Widget;
import 'package:flutter3d/flutter3d.dart';
import 'package:flutter3d_cpu/flutter3d_cpu.dart';
import 'package:flutter3d_game/flutter3d_game.dart' show Bindings, InputSource;
import 'package:flutter3d_sim/flutter3d_sim.dart';
import 'package:flutter_test/flutter_test.dart';

/// Floor under everything, so bodies stand rather than fall.
ActorSystem _system() {
  final world = CollisionWorld()
    ..addBox(Vector3(0.0, -0.5, 0.0), Vector3(40.0, 1.0, 40.0))
    ..update();
  return ActorSystem(world: world, random: GameRandom(1));
}

/// Walks at whatever it was given and remembers who that was.
final class _Chase extends Brain {
  int attended = -1;

  @override
  void act(Mind it) {
    attended = it.focusIndex;
    it.steerTowardsFocus();
  }
}

/// A game that steps a simulation of its own in its fixed steps, and can be
/// told to do something in the middle of one.
final class _Game extends FlameGame with HasFixedStep {
  void Function(double step)? logic;

  @override
  void fixedUpdate(double step) => logic?.call(step);
}

CpuDevice _device() => CpuDevice(
  width: 8,
  height: 8,
  shaders: CpuShaderLibrary(builtinCpuShaders()),
);

InstancedMeshNode _batch() => InstancedMeshNode(
  CpuMesh(CuboidShape(size: Vector3.all(1.0)).build()),
  Material(),
  capacity: 4,
);

final class _World extends FlameGame with HasFlutter3d {}

void main() {
  test('several foci: each actor goes for the one it is nearest', () {
    final system = _system();
    final west = _Chase();
    final east = _Chase();
    system
      ..spawn(
        body: CharacterController(
          world: system.world,
          position: Vector3(-3.0, 0.9, 0.0),
        ),
        brain: west,
      )
      ..spawn(
        body: CharacterController(
          world: system.world,
          position: Vector3(3.0, 0.9, 0.0),
        ),
        brain: east,
      );
    final component = ActorSystemComponent(
      system: system,
      foci: () => <FocusPoint>[
        (at: Vector3(-8.0, 0.9, 0.0), body: null),
        (at: Vector3(8.0, 0.9, 0.0), body: null),
      ],
    );

    component.update(1 / 60);

    expect(west.attended, 0);
    expect(east.attended, 1);
  });

  test('a focus and foci together are refused', () {
    expect(
      () => ActorSystemComponent(
        system: _system(),
        focus: Vector3.zero,
        foci: () => const <FocusPoint>[],
      ),
      throwsA(isA<AssertionError>()),
    );
  });

  testWithGame<_Game>(
    "a death in the game's own logic survives the step it happened in",
    _Game.new,
    (game) async {
      // Mutation: open the system's step just before the actors, as it was.
      final system = _system();
      final victim = system.spawn(
        body: CharacterController(
          world: system.world,
          position: Vector3(0.0, 0.9, 0.0),
        ),
        health: Health(10.0),
      );
      game.add(
        ActorSystemComponent(system: system, focus: Vector3.zero),
      );
      await game.ready();
      game.logic = (double _) {
        if (victim.isAlive) {
          system.hurt(victim, 100.0);
        }
      };

      game.update(1 / 60);

      expect(system.died, <Actor>[victim]);
    },
  );

  testWithGame<_Game>(
    'an actor the simulation removes takes its component with it',
    _Game.new,
    (game) async {
      final system = _system();
      final actor = system.spawn(
        body: CharacterController(world: system.world),
      );
      final component = ActorComponent(
        actor: actor,
        node: SceneNode(),
        scene: Scene(),
        plane: BridgePlane.ground(),
      );
      game.add(component);
      await game.ready();

      system.remove(actor);
      game.update(1 / 60);
      await game.ready();

      expect(component.isMounted, isFalse);
    },
  );

  testWithGame<_Game>(
    'handed the system, removing the component removes the actor',
    _Game.new,
    (game) async {
      final system = _system();
      final actor = system.spawn(
        body: CharacterController(world: system.world),
      );
      final component = ActorComponent(
        actor: actor,
        node: SceneNode(),
        scene: Scene(),
        plane: BridgePlane.ground(),
        removesFrom: system,
      );
      game.add(component);
      await game.ready();

      component.removeFromParent();
      await game.ready();

      expect(actor.exists, isFalse);
      expect(system.actors, isEmpty);
    },
  );

  testWithGame<_Game>(
    'a body the game moves is drawn between where it was and where it is',
    _Game.new,
    (game) async {
      // Mutation: keep the place in the component's own step, after the
      // game's, as it was — then the drawn place is where the body is.
      final world = CollisionWorld();
      final body = CharacterController(
        world: world,
        position: Vector3(0.0, 0.9, 0.0),
      );
      final scene = Scene();
      final node = SceneNode();
      final component = CharacterBodyComponent(
        body: body,
        node: node,
        scene: scene,
        plane: BridgePlane.ground(),
        stepper: game,
      );
      game.add(component);
      await game.ready();
      game.logic = (double _) => body.position.x += 1.0;

      // One step and half of the next.
      game.update(1.5 / 60);

      expect(body.position.x, 1.0);
      expect(node.readPosition().x, closeTo(0.5, 1e-6));
    },
  );

  testWithGame<_Game>(
    'a horde is one batch: a slot per actor, given back when it goes',
    _Game.new,
    (game) async {
      final system = _system();
      final batch = _batch();
      final actors = <Actor>[
        for (var i = 0; i < 3; i++)
          system.spawn(
            body: CharacterController(
              world: system.world,
              position: Vector3(i * 2.0, 0.9, 0.0),
            ),
          ),
      ];
      for (final actor in actors) {
        game.add(InstancedActorComponent(actor: actor, batch: batch));
      }
      await game.ready();
      game.update(1 / 60);
      expect(batch.count, 3);
      final placed = Matrix4.zero();
      batch.readTransform(2, placed);
      expect(placed.getTranslation().x, closeTo(4.0, 1e-6));

      system.remove(actors[1]);
      game.update(1 / 60);
      await game.ready();

      expect(batch.count, 2);
    },
  );

  testWithGame<_Game>(
    'a pose component goes when its thing is gone',
    _Game.new,
    (game) async {
      final batch = _batch();
      var there = true;
      game.add(
        InstancedPoseComponent(
          batch: batch,
          place: (Vector3 at) {
            at.setValues(1.0, 2.0, 3.0);
            return there;
          },
        ),
      );
      await game.ready();
      game.update(1 / 60);
      expect(batch.count, 1);

      there = false;
      game.update(1 / 60);
      await game.ready();
      expect(batch.count, 0);
    },
  );

  test('a view camera goes where it is told, and stays when told nothing', () {
    final camera = CameraNode();
    var told = true;
    final view = ViewCamera(
      camera: camera,
      stiffness: 0.0,
      view: (Vector3 eye, Vector3 target) {
        if (!told) {
          return false;
        }
        eye.setValues(0.0, 10.0, 5.0);
        target.setValues(0.0, 0.0, 0.0);
        return true;
      },
    );

    view.advance(1 / 60);
    expect(camera.readPosition(), Vector3(0.0, 10.0, 5.0));

    told = false;
    camera.setPosition(9.0, 9.0, 9.0);
    view.advance(1 / 60);
    expect(camera.readPosition(), Vector3(9.0, 9.0, 9.0));
  });

  test('seats: the first to claim is player one, and four is the limit', () {
    FlameInputBridge bridge() => FlameInputBridge(
      bindings: Bindings(<InputSource, GameAction>{}),
      inputState: InputState(),
    );
    final candidates = List<FlameInputBridge>.generate(6, (_) => bridge());
    final seats = PlayerSeats(candidates);

    expect(seats.claim(candidates[3]), isTrue);
    expect(seats.claim(candidates[3]), isFalse, reason: 'already seated');
    expect(seats.claim(bridge()), isFalse, reason: 'not a candidate');
    seats
      ..claim(candidates[0])
      ..claim(candidates[5])
      ..claim(candidates[1]);
    expect(seats.claim(candidates[2]), isFalse, reason: 'four seated');
    expect(seats.seated, <FlameInputBridge>[
      candidates[3],
      candidates[0],
      candidates[5],
      candidates[1],
    ]);
    expect(seats.free, <FlameInputBridge>[candidates[2], candidates[4]]);

    seats.release(candidates[0]);
    expect(seats.seated.first, candidates[3]);
    expect(seats.seated[1], candidates[5]);
  });

  testWidgets('keys reach the bridge whatever has the focus', (
    WidgetTester tester,
  ) async {
    // Mutation: feed the bridge only from the game's focus.
    const fire = GameAction('fire');
    final input = FlameInputBridge(
      bindings: Bindings(<InputSource, GameAction>{
        InputSource.key(LogicalKeyboardKey.space.keyId): fire,
      }),
      inputState: InputState(),
    );
    final game = _Game();
    await tester.pumpWidget(GameWidget<_Game>(game: game) as Widget);
    game.add(input.listenToKeyboard());
    await tester.pump();
    // Nothing in the tree has the focus: a game with no `KeyboardEvents` and
    // nothing autofocused hears nothing through Flame.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(GameWidget<_Game>(game: game) as Widget);

    await simulateKeyDownEvent(LogicalKeyboardKey.space);
    expect(input.inputState.held(fire), isTrue);
    await simulateKeyUpEvent(LogicalKeyboardKey.space);
    expect(input.inputState.held(fire), isFalse);
  });

  test(
    'a level is a scene: the next one is drawn, through the same camera',
    () {
      final game = _World()..open3d(_device());
      final first = game.scene;
      final next = Scene();

      game.replaceScene3d(next);

      expect(game.scene, same(next));
      expect(next.cameras, contains(game.camera3d));
      expect(first.cameras, isNot(contains(game.camera3d)));
    },
  );
}
