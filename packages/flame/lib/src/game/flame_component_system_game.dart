import 'package:flame/src/components/core/component.dart';
import 'package:flame/src/components/core/component_tree_root.dart';
import 'package:meta/meta.dart';

/// An interface which should be implemented by any `Game` subclass that uses
/// the Flame Component System (i.e. it contains a single Component tree).
@internal
abstract class FlameComponentSystemGame {
  /// The root [Component] of the component tree.
  ComponentTreeRoot get componentTreeRoot;
}
