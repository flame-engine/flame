import 'dart:typed_data';

import 'package:flame_3d/resources.dart';

/// A view of the members of [parent] whose names start with [prefix], under
/// their names without it: writing `numLights` into a view of prefix
/// `Lights_` writes `Lights_numLights` of [parent].
///
/// It lets a pass uniform writer fill the part of a block that holds the
/// members of another block. Its values are those of [parent], and writing
/// into it marks [parent] as changed.
class PrefixedUniformBlock(
  /// The block whose members the view writes.
  final UniformBlock parent,

  /// The prefix of the members of [parent] the view holds.
  final String prefix,
) extends UniformBlock {
  /// Creates the view of the members of [parent] that start with [prefix].
  this : super(parent.slot);

  final Map<String, int?> _offsets = {};

  @override
  Float32List get data => parent.data;

  @override
  int? memberOffset(String member) {
    if (_offsets.containsKey(member)) {
      return _offsets[member];
    }
    return _offsets[member] = parent.memberOffset('$prefix$member');
  }

  @override
  void writeAt(int offset, Float32List values) {
    parent.writeAt(offset, values);
  }
}
