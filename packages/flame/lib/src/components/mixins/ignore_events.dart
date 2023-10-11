import 'package:collection/collection.dart';
import 'package:flame/camera.dart';
import 'package:flame/src/components/core/component.dart';
import 'package:meta/meta.dart';

/// This mixin allows a component and all it's descendants to ignore events.
///
/// Do note that this will also ignore the component and its descendants in
/// calls to [Component.componentsAtPoint].
///
/// This mixin is to be used when you have a large subtree of components that
/// shouldn't receive any events and you want to optimize the event handling.
mixin IgnoreEvents on Component {}
