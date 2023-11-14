library flame_tiled;

import 'dart:ui';

export 'package:tiled/tiled.dart';

export 'src/flame_tsx_provider.dart';
export 'src/renderable_tile_map.dart';
export 'src/simple_flips.dart';
export 'src/tiled_component.dart';

Paint _defaultPaintFactory(double opacity) =>
    Paint()..color = Color.fromRGBO(255, 255, 255, opacity);

class FlameTiled {
  FlameTiled._() : paintFactory = _defaultPaintFactory;

  Paint Function(double opacity) paintFactory;

  static final FlameTiled instance = FlameTiled._();
}
