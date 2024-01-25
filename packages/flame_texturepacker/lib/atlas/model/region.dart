import 'package:flame_texturepacker/atlas/model/page.dart';

/// Represents a region within the texture packer atlas.
class Region {
  late Page page;
  late String name;
  late double left;
  late double top;
  late double width;
  late double height;
  late double offsetX;
  late double offsetY;
  late double originalWidth;
  late double originalHeight;
  late int degrees;
  late bool rotate;
  late int index;
}
