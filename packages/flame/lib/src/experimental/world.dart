import 'dart:ui';

import 'package:meta/meta.dart';

import '../components/component.dart';
import 'camera.dart';

class World extends Component {
  // World may only be rendered through a camera, so regular [renderTree] is
  // disabled.
  @override
  void renderTree(Canvas canvas) {}

  @internal
  void renderFromCamera(Canvas canvas) {
    assert(Camera2.currentCamera != null);
    super.renderTree(canvas);
  }
}
