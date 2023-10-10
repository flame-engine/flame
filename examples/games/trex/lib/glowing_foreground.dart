import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter_shaders/flutter_shaders.dart';
import 'package:trex_game/trex_game.dart';

class GlowingForeground extends StatelessWidget {
  const GlowingForeground({
    Key? key,
    required this.game,
  }) : super(key: key);

  final TRexGame game;

  Offset getMoonOffset() {
    if (game.hasLayout) {
      final absPos = game.horizon.moon.absolutePosition;
      final gameSize = game.size;
      return Offset(absPos.x / gameSize.x, absPos.y / gameSize.y);
    } else {
      return Offset.zero;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ApplyGlow(
      weight: 0.09,
      density: 5,
      moonOffset: getMoonOffset,
      child: SecondaryGameWidget(game: game, secondaryKey: 'moon'),
    );
  }
}

class ApplyGlow extends StatefulWidget {
  const ApplyGlow({
    super.key,
    required this.child,
    this.density = 0.6,
    this.lightStrength = 1,
    this.weight = 0.2,
    required this.moonOffset,
  });

  final Widget child;

  final double density;
  final double lightStrength;
  final double weight;

  final ValueGetter<Offset> moonOffset;

  @override
  State<ApplyGlow> createState() => _ApplyGlowState();
}

class _ApplyGlowState extends State<ApplyGlow>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    getNoise();
    createTicker((elapsed) {
      print("oi");
      setState(() {});
    });
    activate();
  }

  dispose() {
    super.dispose();
    deactivate();
  }

  ui.Image? noise;

  Future<void> getNoise() async {
    const assetImage = AssetImage('assets/images/noise.png');
    final key = await assetImage.obtainKey(ImageConfiguration.empty);

    assetImage
        .loadBuffer(
      key,
      PaintingBinding.instance.instantiateImageCodecFromBuffer,
    )
        .addListener(
      ImageStreamListener((image, synchronousCall) {
        setState(() {
          noise = image.image;
        });
      }),
    );
  }

  late final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;

  @override
  Widget build(BuildContext context) {
    final noise = this.noise;
    if (noise == null) {
      return const SizedBox.shrink();
    }

    return ShaderBuilder(
      assetKey: 'shaders/dir_glow.glsl',
      child: widget.child,
      (context, shader, child) {
        return AnimatedSampler(
          enabled: true,
          child: child!,
          (ui.Image image, Size size, Offset offset, Canvas canvas) {
            final devicePixelRatio = this.devicePixelRatio;
            final moonOffset = widget.moonOffset();
            shader
              ..setFloat(0, image.width.toDouble() / devicePixelRatio)
              ..setFloat(1, image.height.toDouble() / devicePixelRatio)
              ..setFloat(2, moonOffset.dx)
              ..setFloat(3, moonOffset.dy)
              ..setFloat(4, widget.density)
              ..setFloat(5, widget.lightStrength)
              ..setFloat(6, widget.weight)
              ..setImageSampler(0, image)
              ..setImageSampler(1, noise);
            canvas
              ..save()
              ..translate(offset.dx, offset.dy)
              ..drawRect(
                Offset.zero & size,
                Paint()..shader = shader,
              )
              ..restore();
          },
        );
      },
    );
  }
}
