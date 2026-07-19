import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter_test/flutter_test.dart';

ParticleEmitterComponent _component({
  required ParticleEmitter emitter,
  ParticleRenderer? renderer,
  bool removeOnFinish = true,
  bool worldSpace = false,
  bool emitting = true,
  Vector2? position,
}) {
  return ParticleEmitterComponent(
    emitter: emitter,
    renderer: renderer ?? CallbackParticleRenderer((_, _) {}),
    removeOnFinish: removeOnFinish,
    worldSpace: worldSpace,
    emitting: emitting,
    position: position,
    random: Random(42),
  );
}

void main() {
  group('ParticleEmitterComponent', () {
    testWithFlameGame('continuous emission follows the rate', (game) async {
      final component = _component(
        emitter: ParticleEmitter(rate: 100, lifespan: (10, 10)),
      );
      await game.ensureAdd(component);
      game.update(0.5);
      expect(component.particleCount, 50);
      game.update(0.5);
      expect(component.particleCount, 100);
    });

    testWithFlameGame('fractional spawns accumulate over frames', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(rate: 4, lifespan: (10, 10)),
      );
      await game.ensureAdd(component);
      game.update(0.125);
      expect(component.particleCount, 0);
      game.update(0.125);
      expect(component.particleCount, 1);
      for (var i = 0; i < 6; i++) {
        game.update(0.125);
      }
      expect(component.particleCount, 4);
    });

    testWithFlameGame('bursts fire at their time on the timeline', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(
          bursts: const [EmitterBurst(0, 5), EmitterBurst(0.5, 10)],
          lifespan: (10, 10),
        ),
      );
      await game.ensureAdd(component);
      game.update(0.1);
      expect(component.particleCount, 5);
      game.update(0.3);
      expect(component.particleCount, 5);
      game.update(0.2);
      expect(component.particleCount, 15);
    });

    testWithFlameGame('particles die when their lifespan ends', (game) async {
      final component = _component(
        emitter: ParticleEmitter(
          bursts: const [EmitterBurst(0, 8)],
          lifespan: (0.5, 0.5),
        ),
        removeOnFinish: false,
      );
      await game.ensureAdd(component);
      game.update(0.1);
      expect(component.particleCount, 8);
      game.update(0.5);
      expect(component.particleCount, 0);
      expect(component.isFinished, isTrue);
    });

    testWithFlameGame('removeOnFinish removes the finished component', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(
          bursts: const [EmitterBurst(0, 3)],
          lifespan: (0.2, 0.2),
        ),
      );
      await game.ensureAdd(component);
      game.update(0.1);
      expect(component.particleCount, 3);
      game.update(0.3);
      game.update(0);
      expect(game.children.contains(component), isFalse);
    });

    testWithFlameGame('an endless emitter is never auto-removed', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(rate: 1, lifespan: (0.1, 0.1)),
      );
      await game.ensureAdd(component);
      for (var i = 0; i < 20; i++) {
        game.update(0.5);
      }
      expect(game.children.contains(component), isTrue);
    });

    testWithFlameGame('maxParticles caps the number of live particles', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(maxParticles: 10, lifespan: (10, 10)),
        emitting: false,
      );
      await game.ensureAdd(component);
      component.emit(100);
      expect(component.particleCount, 10);
    });

    testWithFlameGame('emit spawns immediately regardless of the timeline', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(lifespan: (10, 10)),
        emitting: false,
      );
      await game.ensureAdd(component);
      expect(component.particleCount, 0);
      component.emit(7);
      expect(component.particleCount, 7);
    });

    testWithFlameGame('stop pauses emission and start resumes it', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(rate: 10, lifespan: (100, 100)),
      );
      await game.ensureAdd(component);
      game.update(1);
      expect(component.particleCount, 10);
      component.stop();
      game.update(1);
      expect(component.particleCount, 10);
      component.start();
      game.update(1);
      expect(component.particleCount, 20);
    });

    testWithFlameGame('start after a finished emission restarts it', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(
          bursts: const [EmitterBurst(0, 3)],
          lifespan: (10, 10),
        ),
        removeOnFinish: false,
      );
      await game.ensureAdd(component);
      game.update(0.1);
      expect(component.particleCount, 3);
      component.start();
      game.update(0.1);
      expect(component.particleCount, 6);
    });

    testWithFlameGame('loop restarts the emission timeline', (game) async {
      final component = _component(
        emitter: ParticleEmitter(
          bursts: const [EmitterBurst(0, 1)],
          duration: 1,
          loop: true,
          lifespan: (100, 100),
        ),
      );
      await game.ensureAdd(component);
      game.update(0.5);
      expect(component.particleCount, 1);
      game.update(0.6);
      game.update(0.1);
      expect(component.particleCount, 2);
    });

    testWithFlameGame('a rate-based emitter stops after its duration', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(
          rate: 10,
          duration: 1,
          lifespan: (100, 100),
        ),
        removeOnFinish: false,
      );
      await game.ensureAdd(component);
      game.update(1);
      expect(component.particleCount, 10);
      game.update(1);
      expect(component.particleCount, 10);
    });

    testWithFlameGame('worldSpace leaves live particles behind', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(lifespan: (10, 10)),
        emitting: false,
        worldSpace: true,
        position: Vector2.zero(),
      );
      await game.ensureAdd(component);
      game.update(0);
      component.emit(1);
      expect(component.particles.posX[0], 0);
      component.position.x += 10;
      game.update(0);
      expect(component.particles.posX[0], -10);
      expect(component.particles.posY[0], 0);
    });

    testWithFlameGame('gravity accelerates particles', (game) async {
      final component = _component(
        emitter: ParticleEmitter(
          gravity: Vector2(0, 100),
          lifespan: (10, 10),
        ),
        emitting: false,
      );
      await game.ensureAdd(component);
      component.emit(1);
      game.update(1);
      expect(component.particles.velY[0], closeTo(100, 1e-6));
      game.update(1);
      expect(component.particles.velY[0], closeTo(200, 1e-6));
    });

    testWithFlameGame('drag slows particles down', (game) async {
      final component = _component(
        emitter: ParticleEmitter(
          speed: (100, 100),
          spread: 0,
          drag: 1,
          lifespan: (10, 10),
        ),
        emitting: false,
      );
      await game.ensureAdd(component);
      component.emit(1);
      final initialSpeed = component.particles.velX[0];
      game.update(1);
      expect(component.particles.velX[0], lessThan(initialSpeed));
    });

    testWithFlameGame('scaleOverLife scales the particle size', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(
          size: (10, 10),
          scaleOverLife: ParticleCurve(1, 0),
        ),
        emitting: false,
      );
      await game.ensureAdd(component);
      component.emit(1);
      expect(component.particles.size[0], 10);
      game.update(0.5);
      expect(component.particles.size[0], closeTo(5, 1e-3));
    });

    testWithFlameGame('opacityOverLife fades the particle color', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(
          opacityOverLife: ParticleCurve(1, 0),
        ),
        emitting: false,
      );
      await game.ensureAdd(component);
      component.emit(1);
      expect((component.particles.color[0] >> 24) & 0xff, 0xff);
      game.update(0.5);
      expect((component.particles.color[0] >> 24) & 0xff, closeTo(128, 2));
    });

    testWithFlameGame('colorOverLife tints the particle color', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(
          colorOverLife: ColorRamp(
            const [Color(0xffff0000), Color(0xff0000ff)],
          ),
        ),
        emitting: false,
      );
      await game.ensureAdd(component);
      component.emit(1);
      expect(component.particles.color[0] & 0xffffffff, 0xffff0000);
      game.update(0.99);
      final color = component.particles.color[0];
      expect(color & 0xff, closeTo(0xfc, 4));
      expect((color >> 16) & 0xff, closeTo(0x03, 4));
    });

    testWithFlameGame('rotateToVelocity points particles along velocity', (
      game,
    ) async {
      final component = _component(
        emitter: ParticleEmitter(
          speed: (100, 100),
          direction: pi / 2,
          spread: 0,
          rotateToVelocity: true,
          lifespan: (10, 10),
        ),
        emitting: false,
      );
      await game.ensureAdd(component);
      component.emit(1);
      expect(component.particles.rotation[0], closeTo(pi / 2, 1e-6));
      game.update(0.1);
      expect(component.particles.rotation[0], closeTo(pi / 2, 1e-6));
    });

    testWithFlameGame('seeded components behave deterministically', (
      game,
    ) async {
      ParticleEmitterComponent build() {
        return ParticleEmitterComponent(
          emitter: ParticleEmitter(
            rate: 50,
            lifespan: (0.5, 2),
            shape: const CircleEmitterShape(20),
            speed: (10, 100),
          ),
          renderer: CallbackParticleRenderer((_, _) {}),
          random: Random(1337),
        );
      }

      final a = build();
      final b = build();
      await game.ensureAdd(a);
      await game.ensureAdd(b);
      game.update(0.7);
      expect(a.particleCount, b.particleCount);
      for (var i = 0; i < a.particleCount; i++) {
        expect(a.particles.posX[i], b.particles.posX[i]);
        expect(a.particles.posY[i], b.particles.posY[i]);
      }
    });

    testWithFlameGame('render delegates to the renderer', (game) async {
      var rendered = 0;
      final component = _component(
        emitter: ParticleEmitter(lifespan: (10, 10)),
        renderer: CallbackParticleRenderer((_, particles) {
          rendered = particles.length;
        }),
        emitting: false,
      );
      await game.ensureAdd(component);
      component.emit(4);
      final recorder = PictureRecorder();
      component.render(Canvas(recorder));
      expect(rendered, 4);
    });
  });
}
