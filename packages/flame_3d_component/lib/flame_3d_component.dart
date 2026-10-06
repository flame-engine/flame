/// Renders [flutter_scene](https://pub.dev/packages/flutter_scene) 3D scenes
/// as regular components in the Flame component tree.
///
/// The main entry point is `Component3D`. Build the scene graph with the
/// flutter_scene API, which this library re-exports, and add the component
/// anywhere in your game like any other `PositionComponent`.
///
/// The names `Component` and `Sprite` exist in both Flame and flutter_scene,
/// so this library re-exports flutter_scene without them. Import
/// `package:flutter_scene/scene.dart` directly when you need the flutter_scene
/// versions.
library;

export 'package:flutter_scene/scene.dart' hide Component, Sprite;

export 'src/component_3d.dart';
