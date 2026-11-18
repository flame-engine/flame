import 'dart:typed_data';
import 'dart:ui';

import 'package:flame_3d/game.dart';
import 'package:flame_3d/graphics.dart';
import 'package:meta/meta.dart';

/// {@template uniform_block}
/// The CPU copy of one uniform block of a shader, laid out with the offsets
/// the shader reflects for [slot].
///
/// Members are written by name. A block remembers whether it changed since it
/// was last uploaded, so the [GraphicsDevice] uploads it at most once per frame
/// while it does not change, however many draws bind it.
/// {@endtemplate}
class UniformBlock(
  /// The uniform block slot this data is bound to.
  final GpuUniformSlot slot,
) {
  /// The block's contents, as floats.
  late final Float32List data = Float32List(
    _sizeInBytes(slot) ~/ Float32List.bytesPerElement,
  );

  /// The block's contents, as bytes.
  late final ByteData bytes = data.buffer.asByteData();

  /// The block's contents, as a list of bytes.
  late final Uint8List byteList = data.buffer.asUint8List();

  final Map<String, int?> _offsets = {};

  /// Whether the contents changed since the block was last uploaded.
  bool get isDirty => _dirty;
  bool _dirty = true;

  /// Marks the block as changed, so that it is uploaded again before its next
  /// use.
  void markDirty() => _dirty = true;

  // Where the block was last uploaded, managed by `GraphicsDevice`.
  @internal
  int uploadFrame = -1;
  @internal
  GpuBuffer? uploadBuffer;
  @internal
  int uploadOffset = 0;

  /// Records that the current contents were uploaded to [buffer] at [offset]
  /// during [frame].
  @internal
  void markUploaded(int frame, GpuBuffer buffer, int offset) {
    _dirty = false;
    uploadFrame = frame;
    uploadBuffer = buffer;
    uploadOffset = offset;
  }

  /// Whether the block has a member named [member].
  bool hasMember(String member) => memberOffset(member) != null;

  /// The offset of [member] within the block, in floats, or `null` when the
  /// block has no such member.
  int? memberOffset(String member) {
    return _offsets.putIfAbsent(member, () {
      final bytes = slot.getMemberOffsetInBytes(member);
      return bytes == null ? null : bytes ~/ Float32List.bytesPerElement;
    });
  }

  /// Writes [values] at [offset] floats into the block.
  void writeAt(int offset, Float32List values) {
    data.setRange(offset, offset + values.length, values);
    _dirty = true;
  }

  /// Writes [values] into [member], or into its element [index] when the
  /// member is an array (with the std140 stride of a 16-byte multiple).
  ///
  /// Members the block does not have, and array elements past the end of the
  /// block, are ignored, so writers can fill blocks that only declare some of
  /// the members they know.
  void write(String member, Float32List values, {int? index}) {
    final offset = memberOffset(member);
    if (offset == null) {
      return;
    }
    final at = index == null
        ? offset
        : offset + index * ((values.length + 3) & ~3);
    if (at + values.length <= data.length) {
      writeAt(at, values);
    }
  }

  /// Writes a float into [member].
  void setFloat(String member, double value, {int? index}) {
    _scalar[0] = value;
    write(member, _scalar, index: index);
  }

  /// Writes a [Vector3] into [member].
  void setVector3(String member, Vector3 value, {int? index}) {
    write(member, value.storage, index: index);
  }

  /// Writes a [Vector4] into [member].
  void setVector4(String member, Vector4 value, {int? index}) {
    write(member, value.storage, index: index);
  }

  /// Writes a [Matrix4] into [member].
  void setMatrix4(String member, Matrix4 value, {int? index}) {
    write(member, value.storage, index: index);
  }

  /// Writes a [Color] (as RGBA floats) into [member].
  void setColor(String member, Color value, {int? index}) {
    _color
      ..[0] = value.r
      ..[1] = value.g
      ..[2] = value.b
      ..[3] = value.a;
    write(member, _color, index: index);
  }

  static int _sizeInBytes(GpuUniformSlot slot) {
    final size = slot.sizeInBytes;
    if (size == null) {
      throw StateError('Slot "${slot.name}" is a sampler, not a uniform block');
    }
    return size;
  }

  static final _scalar = Float32List(1);
  static final _color = Float32List(4);
}
