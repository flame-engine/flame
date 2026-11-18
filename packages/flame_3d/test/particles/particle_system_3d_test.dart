import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/particles.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

void main() {
  ParticleSystem3D billboards({
    int capacity = 256,
    List<ParticleEmitter3D> emitters = const [],
    int seed = 1,
    Vector3? gravity,
    ParticleGround3D? ground,
    ParticleMaterial? material,
    ParticleSpace space = ParticleSpace.world,
  }) {
    return ParticleSystem3D(
      capacity: capacity,
      material: material ?? ParticleMaterial(),
      emitters: emitters,
      seed: seed,
      gravity: gravity,
      ground: ground,
      space: space,
    );
  }

  void run(ParticleSystem3D system, double seconds, {double dt = 1 / 64}) {
    var remaining = seconds;
    while (remaining > 1e-9) {
      final step = math.min(dt, remaining);
      system.update(step);
      remaining -= step;
    }
  }

  group('emission', () {
    test('a rate spawns that many particles per second', () {
      final system = billboards(
        emitters: [ParticleEmitter3D(rate: 128, lifespan: (10, 10))],
      );
      run(system, 1);
      expect(system.particleCount, 128);
    });

    test('bursts fire at their time on the timeline', () {
      final system = billboards(
        emitters: [
          ParticleEmitter3D(
            bursts: const [EmitterBurst(0, 10), EmitterBurst(0.5, 5)],
            lifespan: (10, 10),
          ),
        ],
      );
      system.update(1 / 60);
      expect(system.particleCount, 10);
      run(system, 0.4);
      expect(system.particleCount, 10);
      run(system, 0.2);
      expect(system.particleCount, 15);
    });

    test('a looping emitter restarts its timeline', () {
      final system = billboards(
        emitters: [
          ParticleEmitter3D(
            bursts: const [EmitterBurst(0, 3)],
            duration: 1,
            loop: true,
            lifespan: (10, 10),
          ),
        ],
      );
      run(system, 2.5);
      expect(system.particleCount, 9);
    });

    test('density scales rates and bursts', () {
      final system = billboards(
        emitters: [
          ParticleEmitter3D(
            rate: 128,
            bursts: const [EmitterBurst(0, 10)],
            lifespan: (10, 10),
          ),
        ],
      )..density = 0.5;
      run(system, 1);
      expect(system.particleCount, 69);
    });

    test('a system emits along the way it travels', () {
      final system = billboards(
        emitters: [ParticleEmitter3D(ratePerDistance: 10, lifespan: (10, 10))],
      );
      system.update(1 / 60);
      expect(system.particleCount, 0);
      system.position.setValues(2, 0, 0);
      system.update(1 / 60);
      expect(system.particleCount, 20);
      final xs = [
        for (var i = 0; i < 20; i++) system.particles.posX[i],
      ]..sort();
      // Spread along the way from x = 0 to x = 2.
      expect(xs.first, closeTo(0.05, 1e-6));
      expect(xs.last, closeTo(1.95, 1e-6));
    });

    test('particles inherit the velocity of the system', () {
      final system = billboards(
        emitters: [
          ParticleEmitter3D(
            ratePerDistance: 1,
            inheritVelocity: 0.5,
            lifespan: (10, 10),
          ),
        ],
      )..maxStep = 1;
      system.update(0.1);
      system.position.setValues(1, 0, 0);
      system.update(0.1);
      expect(system.particleCount, 1);
      expect(system.particles.velX[0], closeTo(5, 1e-4));
    });

    test('stop and start control the timelines, not bursts', () {
      final system = billboards(
        emitters: [ParticleEmitter3D(rate: 64, lifespan: (10, 10))],
      )..stop();
      run(system, 1);
      expect(system.particleCount, 0);
      expect(system.burst(7), 7);
      system.start();
      run(system, 0.5);
      expect(system.particleCount, 39);
    });

    test('a full system drops or recycles particles', () {
      final dropping = billboards(capacity: 8)..burst(20);
      expect(dropping.particleCount, 8);
      final recycling = billboards(capacity: 8)
        ..overflow = ParticleOverflow.recycle;
      expect(recycling.burst(20), 20);
      expect(recycling.particleCount, 8);
    });

    test('bursts take the color and position asked for', () {
      final system = billboards(
        emitters: [ParticleEmitter3D()],
      )..burst(4, at: Vector3(1, 2, 3), color: const Color(0x80FF0000));
      for (var i = 0; i < 4; i++) {
        expect(system.particles.posX[i], 1);
        expect(system.particles.posY[i], 2);
        expect(system.particles.posZ[i], 3);
        expect(system.particles.color[i], 0x80FF0000);
      }
    });

    test('emitters are oriented and placed by the system transform', () {
      final system = billboards(
        emitters: [
          ParticleEmitter3D(
            shape: const BoxEmitterShape3D(0, 0, 0),
            offset: Vector3(0, 1, 0),
            speed: (2, 2),
          ),
        ],
      );
      system
        ..position.setValues(5, 0, 0)
        ..rotation.setFrom(
          Quaternion.axisAngle(Vector3(0, 0, 1), -math.pi / 2),
        )
        ..emit(1);
      // +y turned to +x.
      expect(system.particles.posX[0], closeTo(6, 1e-6));
      expect(system.particles.posY[0], closeTo(0, 1e-6));
      expect(system.particles.velX[0], closeTo(2, 1e-6));
      expect(system.particles.velY[0], closeTo(0, 1e-6));
    });
  });

  group('determinism', () {
    List<Float32List> snapshot(ParticleSystem3D system) {
      final b = system.particles;
      final n = b.length;
      return [
        for (final list in [
          b.posX,
          b.posY,
          b.posZ,
          b.velX,
          b.velY,
          b.velZ,
          b.age,
          b.width,
          b.rotation,
          b.seed,
        ])
          Float32List.sublistView(list, 0, n),
      ];
    }

    ParticleSystem3D make(int seed) {
      return ParticleSystem3D(
        material: ParticleMaterial(),
        seed: seed,
        emitters: [
          ParticleEmitter3D(
            rate: 50,
            bursts: const [EmitterBurst(0.2, 30)],
            shape: const SphereEmitterShape3D(1),
            speed: (1, 3),
            spread: 0.3,
            lifespan: (0.5, 1.5),
            size: (0.1, 0.3),
            spin: (-2, 2),
          ),
        ],
        gravity: Vector3(0, -9.8, 0),
        drag: 0.5,
        turbulence: const ParticleTurbulence3D(strength: 2),
        ground: ParticleGround3D(height: -1),
      );
    }

    test('the same seed gives the same particles', () {
      final a = make(42);
      final b = make(42);
      for (var i = 0; i < 120; i++) {
        final dt = 1 / 60 + (i % 3) / 600;
        a.update(dt);
        b.update(dt);
      }
      expect(a.particleCount, greaterThan(0));
      expect(a.particleCount, b.particleCount);
      expect(snapshot(a), snapshot(b));
    });

    test('another seed gives other particles', () {
      final a = make(42);
      final b = make(43);
      run(a, 1);
      run(b, 1);
      expect(snapshot(a), isNot(snapshot(b)));
    });
  });

  group('lifetimes', () {
    test('particles die at the end of their lifespan', () {
      final system = billboards(
        emitters: [
          ParticleEmitter3D(
            bursts: const [EmitterBurst(0, 10)],
            lifespan: (0.5, 0.5),
          ),
        ],
      );
      system.update(0.01);
      run(system, 0.47);
      expect(system.particleCount, 10);
      run(system, 0.04);
      expect(system.particleCount, 0);
    });

    test('a burst-only system finishes', () {
      final system = billboards(
        emitters: [
          ParticleEmitter3D(
            bursts: const [EmitterBurst(0, 5)],
            lifespan: (0.2, 0.2),
          ),
        ],
      );
      expect(system.isFinished, isFalse);
      system.update(0.01);
      expect(system.isFinished, isFalse);
      run(system, 0.3);
      expect(system.isFinished, isTrue);
    });

    test('a system with an endless rate never finishes', () {
      final system = billboards(
        emitters: [ParticleEmitter3D(rate: 10, lifespan: (0.1, 0.1))],
      )..stop();
      run(system, 1);
      expect(system.isFinished, isFalse);
    });
  });

  group('pause, clear and prewarm', () {
    test('a paused system does not change', () {
      final system = billboards(
        emitters: [
          ParticleEmitter3D(rate: 60, speed: (1, 1), lifespan: (5, 5)),
        ],
      );
      run(system, 0.5);
      final count = system.particleCount;
      final x = system.particles.posY[0];
      system.paused = true;
      run(system, 1);
      expect(system.particleCount, count);
      expect(system.particles.posY[0], x);
    });

    test('clear removes every particle', () {
      final system = billboards()..burst(30);
      expect(system.particleCount, 30);
      system.clear();
      expect(system.particleCount, 0);
      expect(system.particleBounds, isNull);
    });

    test('reset restarts the timelines', () {
      final system = billboards(
        emitters: [
          ParticleEmitter3D(
            bursts: const [EmitterBurst(0, 4)],
            lifespan: (10, 10),
          ),
        ],
      );
      run(system, 0.5);
      expect(system.particleCount, 4);
      system.reset();
      expect(system.particleCount, 0);
      system.update(0.01);
      expect(system.particleCount, 4);
    });

    test('prewarm simulates time at once, without events', () {
      var hits = 0;
      final system = billboards(
        emitters: [ParticleEmitter3D(rate: 10, lifespan: (5, 5))],
        gravity: Vector3(0, -10, 0),
        ground: ParticleGround3D(height: -1, killOnHit: true),
      )..onGroundHit = (_, _) => hits++;
      system.prewarm(2);
      expect(system.time, closeTo(2, 1e-9));
      // Particles fall a metre in under half a second: those older than
      // that were killed by the ground, silently.
      expect(system.particleCount, inInclusiveRange(3, 6));
      expect(hits, 0);
      run(system, 1);
      expect(hits, greaterThan(0));
    });
  });

  group('forces', () {
    test('gravity, wind and drag', () {
      final system = billboards(gravity: Vector3(0, -10, 0))
        ..maxStep = 1
        ..wind.setValues(2, 0, 0)
        ..spawn(position: Vector3.zero(), lifespan: 10);
      system.update(0.25);
      // One step of semi-implicit Euler: v = a t, x = v t.
      expect(system.particles.velY[0], closeTo(-2.5, 1e-5));
      expect(system.particles.velX[0], closeTo(0.5, 1e-5));
      expect(system.particles.posY[0], closeTo(-0.625, 1e-5));

      final dragged = billboards()
        ..maxStep = 1
        ..drag = 1
        ..spawn(position: Vector3.zero(), velocity: Vector3(4, 0, 0));
      dragged.update(0.25);
      expect(dragged.particles.velX[0], closeTo(4 / 1.25, 1e-5));
    });

    test('the gravity scale of each particle', () {
      final system = billboards(gravity: Vector3(0, -10, 0))
        ..spawn(position: Vector3.zero(), gravityScale: 0.5);
      system.update(0.1);
      expect(system.particles.velY[0], closeTo(-0.5, 1e-5));
    });

    test('turbulence moves particles around', () {
      final system = billboards()
        ..turbulence = const ParticleTurbulence3D(strength: 3);
      for (var i = 0; i < 10; i++) {
        system.spawn(position: Vector3(i * 0.7, 0, 0), lifespan: 10);
      }
      run(system, 0.5);
      var moved = 0;
      for (var i = 0; i < 10; i++) {
        final b = system.particles;
        if (b.velX[i].abs() + b.velY[i].abs() + b.velZ[i].abs() > 0.1) {
          moved++;
        }
      }
      expect(moved, 10);
    });

    test('attractors pull particles in and consume them', () {
      var arrived = 0;
      final attractor = ParticleAttractor3D(
        target: Vector3(3, 0, 0),
        strength: 30,
        arrivalRadius: 0.3,
        onArrived: (count) => arrived += count,
      );
      final system = billboards()
        ..attractors.add(attractor)
        ..drag = 2;
      for (var i = 0; i < 6; i++) {
        system.spawn(position: Vector3(0, i * 0.1, 0), lifespan: 10);
      }
      run(system, 3);
      expect(system.particleCount, 0);
      expect(arrived, 6);
    });
  });

  group('ground', () {
    test('particles bounce, report the hit, then come to rest', () {
      final hits = <(Vector3, double)>[];
      final system =
          billboards(
              gravity: Vector3(0, -10, 0),
              ground: ParticleGround3D(restitution: 0.5, friction: 0.5),
            )
            ..onGroundHit = ((position, speed) {
              hits.add((position.clone(), speed));
            })
            ..spawn(
              position: Vector3(0, 1.25, 0),
              velocity: Vector3(1, 0, 0),
              lifespan: 20,
            );
      // Falls 1.25 m: hits at sqrt(2 * 10 * 1.25) = 5 m/s.
      var bounced = false;
      for (var i = 0; i < 120 && !bounced; i++) {
        system.update(1 / 120);
        bounced = system.particles.velY[0] > 0;
      }
      expect(bounced, isTrue);
      expect(hits, hasLength(1));
      expect(hits.single.$1.y, 0);
      expect(hits.single.$2, closeTo(5, 0.1));
      expect(system.particles.posY[0], 0);
      expect(system.particles.velY[0], closeTo(2.5, 0.1));
      expect(system.particles.velX[0], closeTo(0.5, 1e-5));

      run(system, 5, dt: 1 / 30);
      // Settled: no more hits, at rest on the ground.
      final count = hits.length;
      run(system, 2, dt: 1 / 20);
      expect(hits.length, count);
      expect(system.particles.posY[0], 0);
      expect(system.particles.velY[0], 0);
    });

    test('a tilted ground and a size offset', () {
      final normal = Vector3(0, 0, 1);
      final system = billboards(
        gravity: Vector3(0, 0, -10),
        ground: ParticleGround3D(height: 2, normal: normal, sizeOffset: 0.5),
      )..spawn(position: Vector3(0, 0, 3), size: 0.4, lifespan: 10);
      run(system, 2);
      // The edge of the particle (half its size) rests on the plane z = 2.
      expect(system.particles.posZ[0], closeTo(2.2, 1e-5));
    });

    test('kill on hit removes the particle after reporting it', () {
      var hits = 0;
      final system = billboards(
        gravity: Vector3(0, -10, 0),
        ground: ParticleGround3D(killOnHit: true),
      )..onGroundHit = (_, _) => hits++;
      for (var i = 0; i < 5; i++) {
        system.spawn(position: Vector3(i.toDouble(), 0.5, 0), lifespan: 10);
      }
      run(system, 1);
      expect(system.particleCount, 0);
      expect(hits, 5);
    });

    test('resting particles settle their rotation', () {
      final system =
          billboards(
            gravity: Vector3(0, -10, 0),
            ground: ParticleGround3D(settleRotation: true),
          )..spawn(
            position: Vector3.zero(),
            rotation: 2 * math.pi + 0.8,
            spin: 5,
            lifespan: 10,
          );
      run(system, 1);
      expect(system.particles.rotation[0], closeTo(2 * math.pi, 1e-3));
      expect(system.particles.spin[0], 0);
    });
  });

  group('space and bounds', () {
    test('world particles stay behind, local ones follow', () {
      final world = billboards()..spawn(position: Vector3.zero());
      final local = billboards(space: ParticleSpace.local)
        ..spawn(position: Vector3.zero());
      for (final system in [world, local]) {
        system
          ..update(1 / 60)
          ..position.setValues(4, 0, 0)
          ..update(1 / 60);
      }
      expect(world.aabb.center.x, closeTo(0, 1e-6));
      expect(local.aabb.center.x, closeTo(4, 1e-6));
    });

    test('the bounds cover the particles and their size', () {
      final system = billboards(
        emitters: [
          ParticleEmitter3D(
            shape: const SphereEmitterShape3D(3),
            size: (0.5, 0.5),
            lifespan: (10, 10),
          ),
        ],
      )..burst(200);
      final box = system.aabb;
      final b = system.particles;
      for (var i = 0; i < b.length; i++) {
        for (final (x, y) in [(-0.25, -0.25), (0.25, 0.25)]) {
          expect(
            box.containsVector3(
              Vector3(b.posX[i] + x, b.posY[i] + y, b.posZ[i]),
            ),
            isTrue,
          );
        }
      }
      expect(box.max.x - box.min.x, lessThan(6.8));
    });

    test('the bounds follow the particles as they move', () {
      final system = billboards(gravity: Vector3(0, -10, 0))
        ..spawn(position: Vector3.zero(), size: 0.2, lifespan: 10);
      final before = system.aabb.center.y;
      run(system, 1);
      expect(system.aabb.center.y, closeTo(before - 5, 0.2));
    });

    test('a system with no particles has the bounds of a point', () {
      final system = billboards()..position.setValues(1, 2, 3);
      expect(system.aabb.min, Vector3(1, 2, 3));
      expect(system.aabb.max, Vector3(1, 2, 3));
    });
  });

  group('repaint', () {
    test('a system with particles asks for frames, an empty one does not', () {
      final system = billboards();
      final before = GraphicsDevice.visualMutationCount;
      run(system, 0.5);
      expect(GraphicsDevice.visualMutationCount, before);
      system.burst(3);
      final afterBurst = GraphicsDevice.visualMutationCount;
      expect(afterBurst, greaterThan(before));
      system.update(1 / 60);
      expect(GraphicsDevice.visualMutationCount, greaterThan(afterBurst));
    });
  });

  group('allocations', () {
    test('storage is allocated once and reused', () {
      final system = ParticleSystem3D(
        capacity: 300,
        material: ParticleMaterial(),
        emitters: [ParticleEmitter3D(rate: 400, lifespan: (0.6, 0.9))],
        gravity: Vector3(0, -10, 0),
        ground: ParticleGround3D(),
        attractors: [
          ParticleAttractor3D(target: Vector3(0, 5, 0), strength: 1),
        ],
        turbulence: const ParticleTurbulence3D(),
        position: Vector3(0, 1, 0),
      );
      final b = system.particles;
      final lists = <TypedData>[
        b.posX,
        b.velX,
        b.age,
        b.color,
        b.attractorFlags,
        system.instanceBuffer,
        system.drawOrder,
      ];
      final hitVectors = Set<Vector3>.identity();
      system.onGroundHit = (position, _) => hitVectors.add(position);
      run(system, 3);
      expect(system.particleCount, greaterThan(100));
      expect(identical(system.particles, b), isTrue);
      final after = <TypedData>[
        b.posX,
        b.velX,
        b.age,
        b.color,
        b.attractorFlags,
        system.instanceBuffer,
        system.drawOrder,
      ];
      for (var i = 0; i < lists.length; i++) {
        expect(identical(lists[i], after[i]), isTrue);
      }
      expect(b.posX.length, 300);
      expect(
        system.instanceBuffer.length,
        300 * VertexLayout.instanceStrideInFloats,
      );
      // Ground hits are reported with one reused vector.
      expect(hitVectors, hasLength(1));
    });
  });

  group('instances', () {
    late FakeGpuBackend backend;
    late GraphicsDevice device;
    late RenderContext3D context;

    setUp(() {
      backend = FakeGpuBackend();
      device = GraphicsDevice(backend: backend);
      context = RenderContext3D(device);
    });

    /// Draws [system] in a pass looking down -z from the origin.
    void frame(ParticleSystem3D system, {Matrix4? view}) {
      device.begin();
      context.setCamera(
        view ?? Matrix4.identity(),
        Matrix4.identity()..setAsPerspective(60, 1, 0.1, 100),
      );
      device.beginPass(const Size(16, 16), frontFace: context.frontFace);
      system.draw(context);
      context.flush();
      device
        ..endPass()
        ..end();
    }

    Float32List instance(ParticleSystem3D system, int k) {
      const stride = VertexLayout.instanceStrideInFloats;
      return Float32List.sublistView(
        system.instanceBuffer,
        k * stride,
        k * stride + stride,
      );
    }

    test('all the particles are one instanced draw', () {
      final system = billboards()..burst(100);
      frame(system);
      expect(backend.countCommands('drawIndexed'), 1);
      expect(backend.commands, contains('drawIndexed 6 x100'));
      expect(device.lastFrameStats.particles, 100);
      expect(device.lastFrameStats.instances, 100);
    });

    test('curves over the life shape size, color and rotation', () {
      final system = billboards()
        ..sizeOverLife = ParticleCurve(1, 3)
        ..colorOverLife = ColorRamp(const [
          Color(0xFFFFFFFF),
          Color(0xFF0000FF),
        ])
        ..opacityOverLife = ParticleCurve(1, 0)
        ..rotationOverLife = ParticleCurve(0, 1)
        ..spawn(
          position: Vector3(1, 2, 3),
          size: 0.5,
          aspect: 2,
          color: const Color(0xFFFF0000),
          lifespan: 2,
        );
      run(system, 1);
      frame(system);
      final data = instance(system, 0);
      expect(data.sublist(0, 3), [1, 2, 3]);
      // Half way: size x2, color halfway to blue, opacity halved.
      expect(data[3], closeTo(1, 0.01));
      expect(data[7], closeTo(2, 0.02));
      expect(data[8], closeTo(0.5, 0.01));
      expect(data[12], closeTo(0.5, 1e-6));
      expect(data[16], closeTo(0.5, 0.01));
      expect(data[17], 0);
      expect(data[18], 0);
      expect(data[19], closeTo(0.5, 0.01));
    });

    test('velocity billboards stretch with speed', () {
      final system =
          billboards(
              material: ParticleMaterial(billboard: ParticleBillboard.velocity),
            )
            ..velocityStretch = 0.5
            ..maxStretch = 3
            ..spawn(position: Vector3.zero(), velocity: Vector3(2, 0, 0))
            ..spawn(position: Vector3.zero(), velocity: Vector3(20, 0, 0));
      frame(system);
      expect(instance(system, 0)[11], closeTo(2, 1e-6));
      expect(instance(system, 0)[4], 2);
      expect(instance(system, 1)[11], 3);
    });

    test('flipbook frames over the life, at a frame rate, at random', () {
      final material = ParticleMaterial(flipbookColumns: 4, flipbookRows: 2);
      final system = billboards(material: material)
        ..flipbook = const ParticleFlipbook3D()
        ..spawn(position: Vector3.zero());
      run(system, 0.5);
      frame(system);
      expect(instance(system, 0)[9], 4);

      system
        ..flipbook = const ParticleFlipbook3D(
          mode: ParticleFrameMode.fps,
          fps: 10,
        )
        ..update(0.25);
      frame(system);
      // 0.75 s at 10 frames per second: frame 7 of 8.
      expect(instance(system, 0)[9], 7);

      system.flipbook = const ParticleFlipbook3D(
        mode: ParticleFrameMode.random,
      );
      frame(system);
      expect(
        instance(system, 0)[9],
        (system.particles.seed[0] * 8).floorToDouble(),
      );
    });

    test('alpha particles are drawn back to front', () {
      final system = billboards();
      for (final z in [-5.0, -9.0, -2.0, -7.0]) {
        system.spawn(position: Vector3(0, 0, z));
      }
      expect(system.sortsParticles, isTrue);
      frame(system);
      final zs = [for (var k = 0; k < 4; k++) instance(system, k)[2]];
      expect(zs, [-9, -7, -5, -2]);
    });

    test('additive particles are not sorted', () {
      final system = billboards(
        material: ParticleMaterial(renderState: RenderState.additive),
      );
      expect(system.sortsParticles, isFalse);
    });

    test('mesh particles get a model matrix each', () {
      final mesh = CuboidMesh(
        size: Vector3.all(1),
        material: UnlitMaterial()..renderState = RenderState.opaque,
      );
      final system = ParticleSystem3D(mesh: mesh, spinAxis: Vector3(0, 0, 1))
        ..spawn(
          position: Vector3(1, 2, 3),
          size: 2,
          rotation: math.pi / 2,
          color: const Color(0xFF00FF00),
        );
      frame(system);
      final data = instance(system, 0);
      final matrix = Matrix4.fromList(data.sublist(0, 16));
      // A quarter turn about z, scaled by 2, then moved to (1, 2, 3).
      final x = matrix.transformed3(Vector3(1, 0, 0));
      expect(x.x, closeTo(1, 1e-5));
      expect(x.y, closeTo(4, 1e-5));
      expect(x.z, closeTo(3, 1e-5));
      expect(data.sublist(16, 20), [0, 1, 0, 1]);
      expect(backend.commands, contains('drawIndexed 36 x1'));
    });
  });
}
