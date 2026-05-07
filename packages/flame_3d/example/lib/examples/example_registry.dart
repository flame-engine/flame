import 'package:flame/game.dart';
import 'package:flame_3d_example/examples/basic_example.dart';
import 'package:flame_3d_example/examples/boxes_example.dart';
import 'package:flame_3d_example/examples/colors_example.dart';
import 'package:flame_3d_example/examples/culling_example.dart';
import 'package:flame_3d_example/examples/models_example.dart';
import 'package:flame_3d_example/examples/split_screen_example.dart';

typedef GameFactory = Game Function();

final Map<String, GameFactory> examples = {
  'Basic': BasicExample.new,
  'Boxes': BoxesExample.new,
  'Colors': ColorsExample.new,
  'Culling': CullingExample.new,
  'Models': ModelsExample.new,
  'Split Screen': SplitScreenExample.new,
};
