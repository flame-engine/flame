import 'dart:math';
import 'dart:ui';

import 'package:doc_flame_examples/ember.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/post_process.dart';

class PostProcessGame() extends FlameGame {
  @override
  Future<void> onLoad() async {
    await super.onLoad();

    world.add(
      PostProcessComponent(
        postProcess: PixelationPostProcess(),
        position: Vector2(0, 0),
        anchor: Anchor.center,
        children: [
          EmberPlayer(size: Vector2(100, 100)),
        ],
      ),
    );
  }
}

class PixelationPostProcess() extends ShaderPostProcess {
  this
    : super(
        'packages/flutter_shaders/shaders/pixelation.frag',
        sampleSubtree: true,
      );

  late final UniformVec2Slot _pixels;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _pixels = shader.getUniformVec2('uPixels');
  }

  @override
  void updateUniforms(Vector2 size) {
    _pixels.setVector(size / (20 * sin(time)));
  }
}
