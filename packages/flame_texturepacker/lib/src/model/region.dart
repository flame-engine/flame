import 'package:flame_texturepacker/src/model/page.dart';

/// Represents a region within the texture packer atlas.
class Region {
  late Page page;
  late String name;
  late double left;
  late double top;
  late double width;
  late double height;
  double offsetX = 0;
  double offsetY = 0;
  double originalWidth = 0;
  double originalHeight = 0;
  int degrees = 0;
  bool rotate = false;
  int index = -1;
}
