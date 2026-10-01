/// [ActorSystemComponent] steps a real flutter3d_sim [ActorSystem] exactly
/// once per step, through the `beginStep`/`step` pair the system
/// requires.
library;

import 'package:flame_flutter3d/src/ecs/actor_system_component.dart';
import 'package:flutter3d_sim/flutter3d_sim.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vector_math/vector_math.dart';

ActorSystem _system() =>
    ActorSystem(world: CollisionWorld(), random: GameRandom(1));

void main() {
  test('update actually steps the system, advancing a body under gravity', () {
    final system = _system();
    final body = CharacterController(
      world: system.world,
      position: Vector3(0.0, 10.0, 0.0),
    );
    system.spawn(body: body);

    final component = ActorSystemComponent(
      system: system,
      focus: Vector3.zero,
    );

    final before = body.position.y;
    component.update(1 / 60);

    // Nothing below the body to stand on, so one step of gravity must have
    // moved it — proof that `step` actually ran, not just `beginStep`.
    expect(body.position.y, lessThan(before));
  });

  test(
    'update can be called every frame without tripping the beginStep contract',
    () {
      final system = _system();
      final component = ActorSystemComponent(
        system: system,
        focus: Vector3.zero,
      );

      // ActorSystem.step throws a StateError when called without a matching
      // beginStep first. Each ActorSystemComponent.update does both, in
      // order, so five frames in a row must be as unremarkable as one.
      expect(() {
        for (var i = 0; i < 5; i++) {
          component.update(1 / 60);
        }
      }, returnsNormally);
    },
  );

  test(
    'a bare step() right after update() still hits the beginStep contract',
    () {
      final system = _system();
      final component = ActorSystemComponent(
        system: system,
        focus: Vector3.zero,
      );

      // update() already consumed this frame's begin/step pair. A second,
      // independent call to step() must find the system exactly as any other
      // caller would: not yet begun for a step of its own.
      component.update(1 / 60);

      expect(
        () => system.step(1 / 60, focus: Vector3.zero()),
        throwsStateError,
      );
    },
  );

  test('focus and focusBody are read fresh every update, not cached', () {
    final system = _system();
    var focusCalls = 0;
    var focusBodyCalls = 0;
    final component = ActorSystemComponent(
      system: system,
      focus: () {
        focusCalls++;
        return Vector3(focusCalls.toDouble(), 0.0, 0.0);
      },
      focusBody: () {
        focusBodyCalls++;
        return null;
      },
    );

    component.update(1 / 60);
    component.update(1 / 60);

    expect(focusCalls, 2);
    expect(focusBodyCalls, 2);
    expect(system.focus, Vector3(2.0, 0.0, 0.0));
  });

  test('focusBody is optional', () {
    final system = _system();
    final component = ActorSystemComponent(
      system: system,
      focus: Vector3.zero,
    );

    expect(() => component.update(1 / 60), returnsNormally);
  });

  test('takes its priority at construction, like the physics stepper', () {
    // A game orders the actor step before the physics step and both before
    // their readers; a cascade after the constructor was the only way to
    // say so for this one.
    final component = ActorSystemComponent(
      system: _system(),
      focus: Vector3.zero,
      priority: -120,
    );

    expect(component.priority, -120);
  });

  test('a second of play moves an actor as far at any frame rate', () {
    // Mutation: step the system by the frame's own dt.
    double after(double frame) {
      final system = _system();
      final body = CharacterController(
        world: system.world,
        position: Vector3(0.0, 10.0, 0.0),
      );
      system.spawn(body: body);
      final component = ActorSystemComponent(
        system: system,
        focus: Vector3.zero,
      );
      for (var t = 0; t < (1.0 / frame).round(); t++) {
        component.update(frame);
      }
      return body.position.y;
    }

    final slow = after(1 / 30);
    expect(slow, lessThan(10.0), reason: 'it never fell');
    expect(after(1 / 120), closeTo(slow, 1e-9));
  });
}
