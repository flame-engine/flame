import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/components.dart';
import 'package:flame_3d/core.dart';
import 'package:flame_3d/graphics.dart';
import 'package:flame_3d/resources.dart';
import 'package:flutter_test/flutter_test.dart';

import '../_fakes/fake_gpu_backend.dart';

/// A material whose shaders are faked, with an extra pass uniform slot.
class _TestMaterial() extends Material {
  this
    : super(
        vertexShader: VertexShader.fromAsset(
          'test',
          slots: [
            RenderContext3D.cameraMatricesBlock,
            RenderContext3D.jointMatricesBlock,
          ],
        ),
        fragmentShader: FragmentShader.fromAsset(
          'test',
          slots: ['Material', 'Environment', 'albedoTexture'],
        ),
      );

  int applied = 0;
  final List<Matrix4> appliedModels = [];

  @override
  void apply(RenderContext context) {
    applied++;
    appliedModels.add((context as RenderContext3D).model.clone());
    fragmentShader.setFloat('Material.value', applied.toDouble());
  }
}

void main() {
  late FakeGpuBackend backend;
  late GraphicsDevice device;
  late RenderContext3D context;

  Surface triangle([Material? material]) {
    return Surface(
      vertices: [
        Vertex(position: Vector3.zero(), texCoord: Vector2.zero()),
        Vertex(position: Vector3(1, 0, 0), texCoord: Vector2.zero()),
        Vertex(position: Vector3(0, 1, 0), texCoord: Vector2.zero()),
      ],
      indices: [0, 1, 2],
      material: material ?? _TestMaterial(),
    );
  }

  Matrix4 at(double x, double y, double z) =>
      Matrix4.translationValues(x, y, z);

  /// Records [draw] in a pass looking down -z from the origin.
  void frame(void Function() draw) {
    device.begin();
    context.setCamera(
      Matrix4.identity(),
      Matrix4.identity()..setAsPerspective(60, 1, 0.1, 100),
    );
    device.beginPass(const Size(16, 16), frontFace: context.frontFace);
    draw();
    context.flush();
    device
      ..endPass()
      ..end();
  }

  setUp(() {
    backend = FakeGpuBackend();
    device = GraphicsDevice(backend: backend);
    context = RenderContext3D(device);
  });

  group('batching', () {
    test('draws instances of one surface and material at once', () {
      final surface = triangle();
      frame(() {
        for (var i = 0; i < 300; i++) {
          context.drawSurface(surface, transform: at(i.toDouble(), 0, -10));
        }
      });

      expect(backend.countCommands('drawIndexed'), 1);
      expect(backend.commands, contains('drawIndexed 3 x300'));
      expect(device.lastFrameStats.drawCalls, 1);
      expect(device.lastFrameStats.instances, 300);
      expect(device.lastFrameStats.triangles, 300);
      expect(context.drawCount, 300);
    });

    test('orders the instances of a batch front to back', () {
      final surface = triangle();
      frame(() {
        for (final z in [-5.0, -2.0, -9.0, -3.0]) {
          context.drawSurface(surface, transform: at(0, 0, z));
        }
      });

      final translations = [
        for (final instance in backend.instancesOf(0)) instance[14],
      ];
      expect(translations, [-2, -3, -5, -9]);
    });

    test('stores the per-instance color after the model matrix', () {
      final surface = triangle();
      frame(() {
        context.drawSurface(
          surface,
          transform: at(1, 2, -3),
          color: const Color(0x80FF4000),
        );
      });

      final instance = backend.instancesOf(0).single;
      expect(instance.sublist(0, 16), orderedEquals(at(1, 2, -3).storage));
      expect(
        instance.sublist(16, 20),
        orderedEquals(Float32List.fromList([1, 64 / 255, 0, 128 / 255])),
      );
      // No instance data: zero.
      expect(instance.sublist(20), [0, 0, 0, 0]);
    });

    test('stores the per-instance data after the color', () {
      final surface = triangle();
      final data = Vector4(0.5, -1, 2, 0.25);
      frame(() {
        context
          ..drawSurface(surface, transform: at(0, 0, -3), instanceData: data)
          ..drawMesh(
            Mesh()..addSurface(surface),
            transform: at(0, 0, -4),
            instanceData: Vector4(1, 2, 3, 4),
          )
          ..drawSurface(surface, transform: at(0, 0, -5));
        // The data is copied when the draw is recorded.
        data.setZero();
      });

      // Still one instanced draw.
      expect(backend.countCommands('drawIndexed'), 1);
      expect(
        [for (final instance in backend.instancesOf(0)) instance.sublist(20)],
        [
          [0.5, -1, 2, 0.25],
          [1, 2, 3, 4],
          [0, 0, 0, 0],
        ],
      );
    });

    test('groups interleaved draws of two materials', () {
      final first = triangle();
      final second = triangle();
      frame(() {
        for (var i = 0; i < 10; i++) {
          context.drawSurface(
            i.isEven ? first : second,
            transform: at(0, 0, -5),
          );
        }
      });

      expect(backend.commands.where((c) => c.startsWith('drawIndexed')), [
        'drawIndexed 3 x5',
        'drawIndexed 3 x5',
      ]);
      expect(device.lastFrameStats.materialChanges, 2);
    });

    test('keeps skinned draws out of batches', () {
      final surface = triangle();
      final joints = [Matrix4.identity()];
      frame(() {
        context
          ..drawSurface(surface, transform: at(0, 0, -5))
          ..drawSurface(
            surface,
            transform: at(0, 0, -6),
            jointTransforms: joints,
          )
          ..drawSurface(surface, transform: at(0, 0, -7))
          ..drawSurface(
            surface,
            transform: at(0, 0, -8),
            jointTransforms: joints,
          );
      });

      expect(backend.commands.where((c) => c.startsWith('drawIndexed')), [
        'drawIndexed 3 x2',
        'drawIndexed 3 x1',
        'drawIndexed 3 x1',
      ]);
    });

    test('takes the joint matrices of a MeshComponent', () {
      final surface = triangle();
      final joints = [Matrix4.identity(), Matrix4.translationValues(4, 5, 6)];
      final component = MeshComponent(
        mesh: Mesh()..addSurface(surface),
        position: Vector3(0, 0, -5),
        jointTransforms: {0: joints},
      );
      frame(() => component.draw(context));

      final data = backend.uniforms[RenderContext3D.jointMatricesBlock]!;
      final shader = surface.material.vertexShader;
      final base =
          shader
              .slot(RenderContext3D.jointMatricesBlock)
              .getMemberOffsetInBytes('joints')! ~/
          4;
      expect(data.sublist(base + 16, base + 32), joints[1].storage);
      expect(backend.commands.where((c) => c.startsWith('drawIndexed')), [
        'drawIndexed 3 x1',
      ]);
    });

    test('keeps mirrored objects apart and flips their winding', () {
      final surface = triangle();
      final mirror = Matrix4.diagonal3Values(-1, 1, 1);
      frame(() {
        context
          ..drawSurface(surface, transform: at(0, 0, -5))
          ..drawSurface(surface, transform: at(1, 0, -5)..multiply(mirror))
          ..drawSurface(surface, transform: at(2, 0, -5))
          ..drawSurface(surface, transform: at(3, 0, -5)..multiply(mirror));
      });

      final commands = backend.commands
          .where((c) => c.startsWith('drawIndexed') || c.startsWith('setWind'))
          .toList();
      expect(commands, [
        'drawIndexed 3 x2',
        'setWindingOrder clockwise',
        'drawIndexed 3 x2',
      ]);
    });
  });

  group('translucent draws', () {
    test('are drawn back to front, after the opaque ones', () {
      final glass = _TestMaterial()..renderState = RenderState.alphaBlend;
      final glassSurface = triangle(glass);
      final wall = triangle();
      frame(() {
        context
          ..drawSurface(glassSurface, transform: at(0, 0, -2))
          ..drawSurface(glassSurface, transform: at(0, 0, -8))
          ..drawSurface(wall, transform: at(0, 0, -9))
          ..drawSurface(glassSurface, transform: at(0, 0, -5));
      });

      // The wall, then the three panes, consecutive in back to front order:
      // one instanced draw whose instances are in that order.
      expect(backend.countCommands('drawIndexed'), 2);
      expect(backend.instancesOf(0).single[14], -9);
      expect(
        [for (final instance in backend.instancesOf(1)) instance[14]],
        [-8, -5, -2],
      );
    });

    test('batch only the draws that are consecutive back to front', () {
      final glass = _TestMaterial()..renderState = RenderState.alphaBlend;
      final pane = triangle(glass);
      final other = triangle(glass);
      frame(() {
        context
          ..drawSurface(pane, transform: at(0, 0, -2))
          ..drawSurface(other, transform: at(0, 0, -4))
          ..drawSurface(pane, transform: at(0, 0, -6))
          ..drawSurface(pane, transform: at(0, 0, -8));
      });

      expect(backend.countCommands('drawIndexed'), 3);
      expect(
        [
          for (var i = 0; i < 3; i++)
            [for (final instance in backend.instancesOf(i)) instance[14]],
        ],
        [
          [-8, -6],
          [-4],
          [-2],
        ],
      );
    });

    test('keep their recording order at equal depths', () {
      final glass = _TestMaterial()..renderState = RenderState.alphaBlend;
      final surface = triangle(glass);
      frame(() {
        for (var i = 0; i < 20; i++) {
          context.drawSurface(surface, transform: at(i.toDouble(), 0, -5));
        }
      });

      expect(
        [for (final instance in backend.instancesOf(0)) instance[12]],
        [for (var i = 0; i < 20; i++) i.toDouble()],
      );
    });
  });

  test('orders many draws by group, surface and depth, then as recorded', () {
    // Opaque draws: by material (mirrored ones apart), surface, front to
    // back, then recording order; translucent draws after them, back to
    // front, then recording order.
    final random = math.Random(3);
    final opaque = [for (var i = 0; i < 4; i++) _TestMaterial()];
    final translucent = [
      for (var i = 0; i < 2; i++)
        _TestMaterial()..renderState = RenderState.alphaBlend,
    ];
    final surfaces = [for (var i = 0; i < 5; i++) triangle()];
    final draws = <(int, Material, Surface, bool, double)>[];
    for (var i = 0; i < 700; i++) {
      final material = random.nextInt(5) == 0
          ? translucent[random.nextInt(2)]
          : opaque[random.nextInt(4)];
      // Few depths, so that many draws tie.
      final z = -1.0 - random.nextInt(12) * 0.5;
      draws.add((
        i,
        material,
        surfaces[random.nextInt(5)],
        random.nextInt(4) == 0,
        z,
      ));
    }
    frame(() {
      for (final (i, material, surface, mirrored, z) in draws) {
        context.drawSurface(
          surface,
          material: material,
          // The id of the draw in x; mirrored draws scale z by -1.
          transform: at(i.toDouble(), 0, z)
            ..scaleByDouble(1, 1, mirrored ? -1 : 1, 1),
        );
      }
    });

    int compare(
      (int, Material, Surface, bool, double) a,
      (int, Material, Surface, bool, double) b,
    ) {
      final (ia, ma, sa, mirroredA, za) = a;
      final (ib, mb, sb, mirroredB, zb) = b;
      final ta = ma.renderState.translucent;
      final tb = mb.renderState.translucent;
      if (ta != tb) {
        return ta ? 1 : -1;
      }
      if (!ta) {
        if (ma.id != mb.id) {
          return ma.id.compareTo(mb.id);
        }
        if (mirroredA != mirroredB) {
          return mirroredA ? 1 : -1;
        }
        if (sa.id != sb.id) {
          return sa.id.compareTo(sb.id);
        }
        // Front to back: the depth is -z.
        if (za != zb) {
          return zb.compareTo(za);
        }
      } else if (za != zb) {
        // Back to front.
        return za.compareTo(zb);
      }
      return ia.compareTo(ib);
    }

    final expected = [
      for (final (i, _, _, _, _) in [...draws]..sort(compare)) i.toDouble(),
    ];
    final drawn = [
      for (var draw = 0; draw < backend.drawnInstances.length; draw++)
        for (final instance in backend.instancesOf(draw)) instance[12],
    ];
    expect(drawn, expected);
  });

  group('state and bindings', () {
    test('applies only the render state that changes', () {
      final opaque = triangle();
      final additive = triangle(
        _TestMaterial()..renderState = RenderState.additive,
      );
      frame(() {
        for (var i = 0; i < 5; i++) {
          context
            ..drawSurface(opaque, transform: at(0, 0, -5))
            ..drawSurface(additive, transform: at(0, 0, -5));
        }
      });

      expect(backend.commands.where((c) => c.startsWith('set')), [
        'setBlendState additive',
        'setDepthState less false',
      ]);
      expect(device.lastFrameStats.stateChanges, 2);
    });

    test('binds a pipeline once for materials sharing shaders', () {
      final surfaces = [for (var i = 0; i < 45; i++) triangle()];
      frame(() {
        for (final surface in surfaces) {
          context.drawSurface(surface, transform: at(0, 0, -5));
        }
      });

      expect(backend.pipelines, hasLength(1));
      expect(backend.countCommands('bindPipeline'), 1);
      expect(backend.countCommands('clearBindings'), 0);
      expect(device.lastFrameStats.drawCalls, 45);
      expect(device.lastFrameStats.materialChanges, 45);
    });

    test('uploads data shared by every draw once per pass', () {
      final surfaces = [for (var i = 0; i < 45; i++) triangle()];
      for (var frames = 0; frames < 2; frames++) {
        frame(() {
          for (final surface in surfaces) {
            context.drawSurface(surface, transform: at(0, 0, -5));
          }
        });

        // The camera and joint blocks once (no draw is skinned), and the two
        // blocks of each material (Material, and Environment as no pass fills
        // it) once.
        expect(device.lastFrameStats.uniformUploads, 2 + 45 * 2);
        expect(backend.countCommands('bindUniform CameraMatrices'), 1);
        backend.commands.clear();
      }
    });

    test('fills the camera block once per pass', () {
      final surface = triangle();
      final view = Matrix4.translationValues(1, 2, 3);
      final projection = Matrix4.identity()
        ..setAsOrthographic(10, 1, -100, 100);
      device.begin();
      context.setCamera(view, projection);
      device.beginPass(const Size(16, 16));
      context
        ..drawSurface(surface)
        ..flush();
      device
        ..endPass()
        ..end();

      final data = backend.uniforms[RenderContext3D.cameraMatricesBlock]!;
      final slot = surface.material.vertexShader.slot(
        RenderContext3D.cameraMatricesBlock,
      ) as FakeUniformSlot;
      Float32List member(String name) {
        final offset = slot.getMemberOffsetInBytes(name)! ~/ 4;
        return data.sublist(offset, offset + 16);
      }

      expect(member('view'), orderedEquals(view.storage));
      expect(member('projection'), orderedEquals(projection.storage));
      expect(
        member('viewProjection'),
        orderedEquals((projection * view as Matrix4).storage),
      );
    });

    test('fills registered pass uniforms once per pass', () {
      var writes = 0;
      context.registerPassUniform('Environment', (context, block) {
        writes++;
        block.setFloat('time', 4.5);
      });
      final surfaces = [triangle(), triangle()];
      frame(() {
        for (final surface in surfaces) {
          context.drawSurface(surface, transform: at(0, 0, -5));
        }
      });

      expect(writes, 1);
      expect(backend.uniforms['Environment']![0], 4.5);
    });

    test('binds the white texture for samplers without a texture', () {
      frame(() => context.drawSurface(triangle(), transform: at(0, 0, -5)));

      expect(backend.commands, contains('bindTexture albedoTexture'));
    });
  });

  group('materials without instance inputs', () {
    setUp(() {
      backend = FakeGpuBackend(
        inputs: const [
          GpuShaderInput(name: 'vertexPosition', location: 0, components: 3),
        ],
      );
      device = GraphicsDevice(backend: backend);
      context = RenderContext3D(device);
    });

    test('are applied for every draw with its model matrix', () {
      final material = _TestMaterial();
      final surface = triangle(material);
      frame(() {
        for (var i = 0; i < 3; i++) {
          context.drawSurface(surface, transform: at(i.toDouble(), 0, -5));
        }
      });

      expect(backend.countCommands('drawIndexed 3 x1'), 3);
      expect(backend.countCommands('bindVertexBuffer 1'), 0);
      expect(material.applied, 3);
      expect(
        [for (final m in material.appliedModels) m.storage[12]],
        [
          0,
          1,
          2,
        ],
      );
    });
  });

  group('cameras', () {
    test('a standard perspective camera does not mirror', () {
      final projection = Matrix4.identity()..setAsPerspective(60, 1.5, 1, 100);
      final view = Matrix4.identity()
        ..setAsViewMatrix(Vector3(3, 4, 5), Vector3.zero(), Vector3(0, 1, 0));

      expect(RenderContext3D.mirrors(projection * view as Matrix4), isFalse);
    });

    test('a standard orthographic camera does not mirror', () {
      final projection = Matrix4.identity()
        ..setAsOrthographic(10, 1.5, 0.1, 100);
      final view = Matrix4.identity()
        ..setAsViewMatrix(Vector3(3, 4, 5), Vector3.zero(), Vector3(0, 1, 0));

      expect(RenderContext3D.mirrors(projection * view as Matrix4), isFalse);
    });

    test('a reversed-depth perspective camera does not mirror', () {
      // Depth 1 at the near plane, 0 at infinity.
      final projection = Matrix4.zero()
        ..setEntry(0, 0, 1)
        ..setEntry(1, 1, 1)
        ..setEntry(2, 3, 0.1)
        ..setEntry(3, 2, -1);

      expect(RenderContext3D.mirrors(projection), isFalse);
    });

    test('a camera flipping one axis mirrors', () {
      final projection = Matrix4.identity()..setAsPerspective(60, 1, 1, 100);
      final flipped = Matrix4.diagonal3Values(-1, 1, 1)..multiply(projection);
      final orthographic = Matrix4.identity()
        ..setAsOrthographic(10, 1, 0.1, 100);
      final swap = Matrix4.columns(
        Vector4(0, 1, 0, 0),
        Vector4(1, 0, 0, 0),
        Vector4(0, 0, 1, 0),
        Vector4(0, 0, 0, 1),
      );

      expect(RenderContext3D.mirrors(flipped), isTrue);
      expect(RenderContext3D.mirrors(projection * swap as Matrix4), isTrue);
      expect(RenderContext3D.mirrors(orthographic * swap as Matrix4), isTrue);
    });

    test('derive the camera data once in setCamera', () {
      final view = Matrix4.identity()
        ..setAsViewMatrix(Vector3(3, 4, 5), Vector3.zero(), Vector3(0, 1, 0));
      final projection = Matrix4.identity()..setAsPerspective(60, 1, 1, 100);
      context.setCamera(view, projection);

      expect(context.cameraPosition.x, closeTo(3, 1e-5));
      expect(context.cameraPosition.y, closeTo(4, 1e-5));
      expect(context.cameraPosition.z, closeTo(5, 1e-5));
      expect(context.isMirrored, isFalse);
      expect(context.frontFace, WindingOrder.counterClockwise);
      expect(context.frustum.containsVector3(Vector3.zero()), isTrue);
      expect(
        context.frustum.containsVector3(Vector3(-3, -4, -5) * 30),
        isFalse,
      );

      context.setCamera(
        view,
        Matrix4.diagonal3Values(-1, 1, 1)..multiply(projection),
      );
      expect(context.isMirrored, isTrue);
      expect(context.frontFace, WindingOrder.clockwise);
    });
  });
}
