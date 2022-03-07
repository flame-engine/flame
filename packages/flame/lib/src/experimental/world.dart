import 'dart:ui';

import 'package:meta/meta.dart';

import '../components/component.dart';
import 'camera_component.dart';

/// The root component for all game world elements.
///
/// The primary feature of this component is that it disables regular rendering,
/// and allows itself to be rendered through a [CameraComponent] only. The
/// updates proceed through the world tree normally.
class World extends Component {
  @override
  void renderTree(Canvas canvas) {}

  /// Internal rendering method invoked by the [CameraComponent].
  @internal
  void renderFromCamera(Canvas canvas) {
    assert(CameraComponent.currentCamera != null);
    super.renderTree(canvas);
  }
}
