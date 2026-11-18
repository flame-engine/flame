import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

/// A material whose shaders are faked and receive shadows.
class _Receiver() extends Material {
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          'test',
          slots: [RenderContext3D.cameraMatricesBlock],
        ),
        fragmentShader: FragmentShader.fromAsset(
          'test',
          slots: [
            'Material',
            RenderContext3D.shadowsBlock,
            RenderContext3D.shadowMapSampler,
          ],
        ),
      );
}

void main() {
  late FakeGpuBackend backend;
  late GraphicsDevice device;
  late RenderContext3D context;
  late DirectionalShadowProjection projection;

  final bounds = Aabb3.minMax(Vector3(-2, -2, -12), Vector3(2, 2, -8));

  Surface triangle(Material material) {
    return Surface(
      vertices: [
        Vertex(position: Vector3.zero(), texCoord: Vector2.zero()),
        Vertex(position: Vector3(1, 0, 0), texCoord: Vector2.zero()),
        Vertex(position: Vector3(0, 1, 0), texCoord: Vector2.zero()),
      ],
      indices: [0, 1, 2],
      material: material,
    );
  }

  Light sun({ShadowSettings? shadows}) {
    return Light(
      position: Vector3.zero(),
      source: DirectionalLight(
        direction: Vector3(0.3, -1, -0.2),
        shadows: shadows,
      ),
    );
  }

  /// Renders a frame looking down -z, with a shadow pass first when one of
  /// [lights] casts shadows; [draw] records the draws of both passes.
  /// Returns whether there was a shadow pass.
  bool frame(List<Light> lights, void Function() draw) {
    device.begin();
    context
      ..lights = lights
      ..setCamera(
        Matrix4.identity(),
        Matrix4.identity()..setAsPerspective(60, 1, 0.1, 100),
      );
    final shadows = context.beginShadowPass(
      projection: projection,
      sceneBounds: bounds,
    );
    if (shadows) {
      expect(context.isShadowPass, isTrue);
      draw();
      context.endShadowPass();
    }
    expect(context.isShadowPass, isFalse);
    device.beginPass(const Size(16, 16), frontFace: context.frontFace);
    draw();
    context.flush();
    device
      ..endPass()
      ..end();
    return shadows;
  }

  /// The floats of [member] of the Shadows block bound last.
  Float32List shadowsMember(Material material, String member, int floats) {
    final slot = material.fragmentShader.slot(RenderContext3D.shadowsBlock);
    final offset = slot.getMemberOffsetInBytes(member)! ~/ 4;
    return Float32List.sublistView(
      backend.uniforms[RenderContext3D.shadowsBlock]!,
      offset,
      offset + floats,
    );
  }

  setUp(() {
    backend = FakeGpuBackend(textureTargets: true);
    device = GraphicsDevice(backend: backend);
    context = RenderContext3D(device);
    projection = DirectionalShadowProjection();
  });

  group('Shadow pass', () {
    test('none without a light that casts shadows', () {
      final material = _Receiver();
      final surface = triangle(material);
      final shadows = frame([sun()], () {
        context.drawSurface(
          surface,
          transform: Matrix4.translationValues(0, 0, -10),
        );
      });

      expect(shadows, isFalse);
      expect(backend.countCommands('beginRenderPass'), 1);
      expect(backend.countCommands('commit'), 0);
      expect(device.lastFrameStats.shadowPasses, 0);
      // The receivers are told there are no shadows, and get a texture.
      expect(shadowsMember(material, 'toLight', 4)[3], -1);
      expect(
        backend.textureBindings,
        contains(RenderContext3D.shadowMapSampler),
      );
    });

    test('none when the backend cannot render into textures', () {
      backend = FakeGpuBackend();
      device = GraphicsDevice(backend: backend);
      context = RenderContext3D(device);
      final surface = triangle(_Receiver());

      final shadows = frame([sun(shadows: ShadowSettings())], () {
        context.drawSurface(
          surface,
          transform: Matrix4.translationValues(0, 0, -10),
        );
      });

      expect(shadows, isFalse);
      expect(device.lastFrameStats.renderPasses, 1);
    });

    test('renders the casters into the shadow map before the main pass', () {
      final material = _Receiver();
      final surface = triangle(material);
      final shadows = frame(
        [sun(shadows: ShadowSettings(resolution: 512))],
        () {
          for (var i = 0; i < 3; i++) {
            context.drawSurface(
              surface,
              transform: Matrix4.translationValues(i * 0.5, 0, -10),
            );
          }
        },
      );

      expect(shadows, isTrue);
      final commands = backend.commands;
      final shadowPass = commands.indexOf('beginRenderPass 512x512');
      final commit = commands.indexOf('commit');
      final mainPass = commands.indexOf('beginRenderPass 16x16');
      expect(shadowPass, 0);
      expect(commit, greaterThan(shadowPass));
      expect(mainPass, greaterThan(commit));
      // One instanced draw of the three casters, then of the three receivers.
      expect(
        commands.where((c) => c.startsWith('drawIndexed')),
        ['drawIndexed 3 x3', 'drawIndexed 3 x3'],
      );
      final stats = device.lastFrameStats;
      expect(stats.renderPasses, 2);
      expect(stats.shadowPasses, 1);
      expect(stats.drawCalls, 2);
      expect(stats.shadowDrawCalls, 1);
      expect(backend.textureTargetsCreated, [
        (512, 512, GpuPixelFormat.r32Float),
      ]);
      // The main pass samples the map.
      final map = backend.textureBindings[RenderContext3D.shadowMapSampler]!;
      expect(identical(map.$1, backend.textures.last), isTrue);
    });

    test('skips what casts no shadows and batches across materials', () {
      final receiver = _Receiver();
      final other = _Receiver();
      final glass = _Receiver()
        ..renderState = RenderState.premultipliedAlphaBlend;
      final glow = _Receiver()..castsShadows = false;
      final surface = triangle(receiver);
      frame([sun(shadows: ShadowSettings())], () {
        for (final material in [receiver, other, glass, glow]) {
          context.drawSurface(
            surface,
            material: material,
            transform: Matrix4.translationValues(0, 0, -10),
          );
        }
      });

      final draws = backend.commands
          .where((c) => c.startsWith('drawIndexed') || c == 'commit')
          .toList();
      // The shadow pass draws the two opaque materials at once.
      expect(draws.first, 'drawIndexed 3 x2');
      expect(draws[1], 'commit');
      // The main pass draws each material.
      expect(draws.length - 2, 4);
      expect(device.lastFrameStats.shadowDrawCalls, 1);
    });

    test('records no draws of what casts no shadows', () {
      final receiver = _Receiver();
      final glass = _Receiver()
        ..renderState = RenderState.premultipliedAlphaBlend;
      final glow = _Receiver()..castsShadows = false;
      final surface = triangle(receiver);
      final instances = Float32List(VertexLayout.instanceStrideInFloats * 2);
      void draw() {
        for (final material in [receiver, glass, glow]) {
          context.drawSurface(
            surface,
            material: material,
            transform: Matrix4.translationValues(0, 0, -10),
          );
        }
        context.drawInstances(
          surface,
          material: glow,
          instances: instances,
          count: 2,
        );
      }

      device.begin();
      context
        ..lights = [sun(shadows: ShadowSettings())]
        ..setCamera(
          Matrix4.identity(),
          Matrix4.identity()..setAsPerspective(60, 1, 0.1, 100),
        );
      expect(
        context.beginShadowPass(projection: projection, sceneBounds: bounds),
        isTrue,
      );
      draw();
      context.endShadowPass();
      // Only the opaque material was recorded.
      expect(context.drawCount, 1);

      device.beginPass(const Size(16, 16), frontFace: context.frontFace);
      draw();
      context.flush();
      device
        ..endPass()
        ..end();
      expect(context.drawCount, 4);
    });

    test('tells the receivers about the light and its map', () {
      backend = FakeGpuBackend(
        textureTargets: true,
        floatTextureTargets: false,
      );
      device = GraphicsDevice(backend: backend);
      context = RenderContext3D(device);
      final material = _Receiver();
      final surface = triangle(material);
      final settings = ShadowSettings(
        resolution: 256,
        color: const Color(0xFF336699),
        strength: 0.75,
        softness: 2,
        depthBias: 1.25,
      );

      frame([sun(), sun(shadows: settings)], () {
        context.drawSurface(
          surface,
          transform: Matrix4.translationValues(0, 0, -10),
        );
      });

      final toLight = shadowsMember(material, 'toLight', 4);
      final direction = Vector3(0.3, -1, -0.2).normalized();
      expect(toLight[0], closeTo(-direction.x, 1e-6));
      expect(toLight[1], closeTo(-direction.y, 1e-6));
      expect(toLight[2], closeTo(-direction.z, 1e-6));
      // The second directional light casts the shadows.
      expect(toLight[3], 1);
      final color = shadowsMember(material, 'color', 4);
      expect(color[0], closeTo(0x33 / 255, 1e-6));
      expect(color[2], closeTo(0x99 / 255, 1e-6));
      expect(color[3], 0.75);
      expect(shadowsMember(material, 'map', 4), [256, 256, 1 / 256, 1 / 256]);
      final bias = shadowsMember(material, 'bias', 4);
      // The larger side of a texel.
      expect(
        bias[0],
        closeTo(math.max(projection.texelWidth, projection.texelHeight), 1e-6),
      );
      expect(bias.sublist(1), [1.25, 0.5, 2]);
      // Without float targets, the depth is packed into RGBA8.
      expect(backend.textureTargetsCreated.single.$3, GpuPixelFormat.rgba8888);
      expect(shadowsMember(material, 'decode', 4), [
        closeTo(65536 * 255 / 16777215, 1e-9),
        closeTo(256 * 255 / 16777215, 1e-9),
        closeTo(255 / 16777215, 1e-9),
        0,
      ]);
      final lightViewProjection = shadowsMember(
        material,
        'lightViewProjection',
        16,
      );
      expect(
        lightViewProjection,
        orderedEquals(projection.viewProjection.storage),
      );
    });

    test('creates the shadow map once', () {
      final surface = triangle(_Receiver());
      final settings = ShadowSettings(resolution: 128);
      for (var i = 0; i < 3; i++) {
        frame([sun(shadows: settings)], () {
          context.drawSurface(
            surface,
            transform: Matrix4.translationValues(0, 0, -10),
          );
        });
      }
      expect(backend.textureTargetsCreated, hasLength(1));

      settings.resolution = 64;
      frame([sun(shadows: settings)], () {
        context.drawSurface(
          surface,
          transform: Matrix4.translationValues(0, 0, -10),
        );
      });
      expect(backend.textureTargetsCreated, hasLength(2));
    });

    test('a pass after one with shadows has none until told', () {
      final material = _Receiver();
      final surface = triangle(material);
      frame([sun(shadows: ShadowSettings())], () {
        context.drawSurface(
          surface,
          transform: Matrix4.translationValues(0, 0, -10),
        );
      });
      expect(shadowsMember(material, 'toLight', 4)[3], 0);

      // A host that sets its camera without a shadow pass.
      device.begin();
      context.setCamera(Matrix4.identity(), Matrix4.identity());
      device.beginPass(const Size(16, 16));
      context
        ..drawSurface(surface, transform: Matrix4.translationValues(0, 0, -0.5))
        ..flush();
      device
        ..endPass()
        ..end();
      expect(shadowsMember(material, 'toLight', 4)[3], -1);
    });
  });

  group('reuseShadowMap', () {
    /// A main pass whose camera is set without a shadow pass, reusing the
    /// map of [version] when given; returns what reuseShadowMap returned.
    bool mainPass(Surface surface, {int? version}) {
      device.begin();
      context.setCamera(Matrix4.identity(), Matrix4.identity());
      final reused = version != null && context.reuseShadowMap(version);
      device.beginPass(const Size(16, 16));
      context
        ..drawSurface(surface, transform: Matrix4.translationValues(0, 0, -0.5))
        ..flush();
      device
        ..endPass()
        ..end();
      return reused;
    }

    test('fails before any shadow map was rendered', () {
      final material = _Receiver();
      expect(
        mainPass(triangle(material), version: context.shadowMapVersion),
        isFalse,
      );
      expect(shadowsMember(material, 'toLight', 4)[3], -1);
    });

    test('binds the last shadow map to a later pass without rendering', () {
      final material = _Receiver();
      final surface = triangle(material);
      final before = context.shadowMapVersion;
      frame([sun(shadows: ShadowSettings(resolution: 128))], () {
        context.drawSurface(
          surface,
          transform: Matrix4.translationValues(0, 0, -10),
        );
      });
      final version = context.shadowMapVersion;
      expect(version, isNot(before));
      final lightViewProjection = shadowsMember(
        material,
        'lightViewProjection',
        16,
      ).toList();
      final commandsBefore = backend.commands.length;

      expect(mainPass(surface, version: version), isTrue);
      // No shadow pass: one main pass, no commit.
      final commands = backend.commands.sublist(commandsBefore);
      expect(commands.where((c) => c.startsWith('beginRenderPass')), [
        'beginRenderPass 16x16',
      ]);
      expect(commands, isNot(contains('commit')));
      expect(device.lastFrameStats.shadowPasses, 0);
      // The same map and the same light as the pass that rendered it.
      expect(shadowsMember(material, 'toLight', 4)[3], 0);
      expect(
        shadowsMember(material, 'lightViewProjection', 16),
        orderedEquals(lightViewProjection),
      );
      final map = backend.textureBindings[RenderContext3D.shadowMapSampler]!;
      expect(identical(map.$1, backend.textures.last), isTrue);
      expect(context.shadowMapVersion, version);
    });

    test('fails once another shadow map was rendered', () {
      final material = _Receiver();
      final surface = triangle(material);
      void shadowFrame() {
        frame([sun(shadows: ShadowSettings(resolution: 128))], () {
          context.drawSurface(
            surface,
            transform: Matrix4.translationValues(0, 0, -10),
          );
        });
      }

      shadowFrame();
      final version = context.shadowMapVersion;
      shadowFrame();
      expect(context.shadowMapVersion, isNot(version));
      expect(mainPass(surface, version: version), isFalse);
      expect(shadowsMember(material, 'toLight', 4)[3], -1);
    });

    test('is refused while a shadow pass is recorded', () {
      device.begin();
      context
        ..lights = [sun(shadows: ShadowSettings())]
        ..setCamera(
          Matrix4.identity(),
          Matrix4.identity()..setAsPerspective(60, 1, 0.1, 100),
        );
      expect(
        context.beginShadowPass(projection: projection, sceneBounds: bounds),
        isTrue,
      );
      expect(
        () => context.reuseShadowMap(context.shadowMapVersion),
        throwsStateError,
      );
      context.endShadowPass();
      device.end();
    });
  });

  group('Material.castsShadows', () {
    test('defaults to whether the material is opaque', () {
      final material = _Receiver();
      expect(material.castsShadows, isTrue);
      material.renderState = RenderState.additive;
      expect(material.castsShadows, isFalse);
      material.castsShadows = true;
      expect(material.castsShadows, isTrue);
      material
        ..renderState = RenderState.opaque
        ..castsShadows = false;
      expect(material.castsShadows, isFalse);
      material.castsShadows = null;
      expect(material.castsShadows, isTrue);
    });
  });

  group('ShadowSettings', () {
    test('checks its resolution and softness', () {
      final settings = ShadowSettings();
      expect(settings.resolution, 1024);
      expect(settings.softness, 1);
      expect(() => settings.resolution = 8, throwsArgumentError);
      expect(() => settings.resolution = 16384, throwsArgumentError);
      expect(() => settings.softness = -1, throwsArgumentError);
      expect(
        () => settings.softness = ShadowSettings.maxSoftness + 1,
        throwsArgumentError,
      );
      expect(() => ShadowSettings(resolution: 4), throwsArgumentError);
    });

    test('are given to directional lights', () {
      final settings = ShadowSettings();
      final light = LightComponent.directional(shadows: settings);
      expect((light.source as DirectionalLight).shadows, same(settings));
      expect(DirectionalLight().shadows, isNull);
    });
  });

  group('RenderStats', () {
    test('count shadow passes and draw calls', () {
      final stats = RenderStats()
        ..shadowPasses = 2
        ..shadowDrawCalls = 5;
      final copy = RenderStats()..setFrom(stats);
      expect(copy.shadowPasses, 2);
      expect(copy.shadowDrawCalls, 5);
      expect(copy.toString(), contains('shadowDrawCalls: 5'));
      stats.reset();
      expect(stats.shadowPasses, 0);
      expect(stats.shadowDrawCalls, 0);
    });
  });
}
