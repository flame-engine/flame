import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:ui';

import 'package:flame/camera.dart' as c;
import 'package:flame/game.dart';
import 'package:flame/shader_pipeline.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

const (double, double) kCameraSize = (900, 1600);

void main() async {
  runApp(const GamePage());
}

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  late final Future<ui.FragmentProgram> program =
      ui.FragmentProgram.fromAsset('shaders/the_ball.frag');

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: program,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        return GameWidget(
          game: CrystalBallGame(
            ballProgram: snapshot.data!,
          ),
        );
      },
    );
  }
}

class CrystalBallGame extends FlameGame {
  CrystalBallGame({
    required this.ballProgram,
  }) : super(
          camera: c.CameraComponent.withFixedResolution(
            width: kCameraSize.$1,
            height: kCameraSize.$2,
            hudComponents: [
              CrystalBallPipelineStep(
                program: ballProgram,
              ),
            ],
          ),
        );

  final ui.FragmentProgram ballProgram;
}

class CrystalBallPipelineStep extends SPipelineStep {
  CrystalBallPipelineStep({
    required this.program,
    super.samplingPasses = 0,
  }) : super(size: Vector2(900, 1600));

  c.Viewport get camera => c.CameraComponent.currentCamera!.viewport;

  final FragmentProgram program;

  @override
  void postProcess(List<ui.Image> samples, Size size, Canvas canvas) {
    final uvBall = Vector2(0.5, 0.5);
    final shader = program.fragmentShader();
    shader.setFloatUniforms((value) {
      value
        ..setSize(size)
        ..setVector64(uvBall)
        ..setVector64(Vector2(0.0, 0.0))
        ..setFloat(.1)
        ..setFloat(.3);
    });

    canvas
      ..save()
      ..drawRect(
        Offset.zero & size,
        Paint()
          ..shader = shader
          ..blendMode = BlendMode.lighten,
      )
      ..restore();
  }
}

extension on UniformsSetter {
  void setVector64(Vector vector) {
    setFloats(Float32List.fromList(vector.storage));
  }
}
