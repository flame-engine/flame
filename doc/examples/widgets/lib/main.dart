import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:dashbook/dashbook.dart';

import 'package:flame/widgets/nine_tile_box.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final nineTileBoxImage = await Flame.images.load('nine_tile_box.png');
  final dashbook = Dashbook();

  dashbook.storiesOf('NineTileBox').decorator(CenterDecorator()).add(
      'default',
      (ctx) => Container(
            width: ctx.numberProperty('width', 200),
            height: ctx.numberProperty('height', 200),
            child: NineTileBox(
              image: nineTileBoxImage,
              tileSize: 16,
              destTileSize: 50,
              child: const Center(
                child: const Text(
                  'Cool label',
                  style: const TextStyle(
                    color: const Color(0xFFFFFFFF),
                  ),
                ),
              ),
            ),
          ));

  runApp(dashbook);
}
