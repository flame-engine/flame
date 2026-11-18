import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flame_3d/core.dart';
import 'package:flame_3d/src/parser/gltf/accessor_type.dart';
import 'package:flame_3d/src/parser/gltf/buffer_view.dart';
import 'package:flame_3d/src/parser/gltf/component_type.dart';
import 'package:flame_3d/src/parser/gltf/gltf_node.dart';
import 'package:flame_3d/src/parser/gltf/gltf_ref.dart';
import 'package:flame_3d/src/parser/gltf/gltf_root.dart';
import 'package:flame_3d/src/parser/gltf/sparse_accessor.dart';

/// A untyped GLTF accessor; it is typically wrapped into a specific accessor
/// type on the data model. This provides the backing implementation.
class RawAccessor({
  required super.root,

  /// The reference to the buffer view.
  /// When undefined, the accessor **MUST** be initialized with zeros; `sparse`
  /// property or extensions **MAY** override zeros with actual values.
  required final GltfRef<BufferView> bufferView,

  /// The offset relative to the start of the buffer view in bytes.
  ///
  /// This **MUST** be a multiple of the size of the component datatype.
  /// This property **MUST NOT** be defined when `bufferView` is undefined.
  required final int byteOffset,

  /// The datatype of the accessor's components.
  /// UNSIGNED_INT type **MUST NOT** be used for any accessor that is not
  /// referenced by `mesh.primitive.indices`.
  required final ComponentType componentType,

  /// Specifies whether integer data values are normalized (`true`) to [0, 1]
  /// (for unsigned types) or to [-1, 1] (for signed types) when they are
  /// accessed.
  ///
  /// This property **MUST NOT** be set to `true` for accessors with `FLOAT` or
  /// `UNSIGNED_INT` component type.
  required final bool normalized,

  /// The number of elements referenced by this accessor, not to be confused
  /// with the number of bytes or number of components.
  required final int count,

  /// Specifies if the accessor's elements are scalars, vectors, or matrices.
  /// This should match the type used for a [TypedAccessor].
  required final AccessorType type,

  /// Maximum value of each component in this accessor.
  required final List<double>? max,

  /// Minimum value of each component in this accessor.
  required final List<double>? min,

  /// Sparse storage of elements that deviate from their initialization value.
  required final SparseAccessor? sparse,
}) extends GltfNode {
  /// Normalizes a raw integer/float component according to glTF 2.0 section
  /// 3.6.2.1 & `KHR_mesh_quantization` when [normalized] is `true`.
  double normalizeComponent(num raw) {
    final value = raw.toDouble();
    if (!normalized) {
      return value;
    }
    return switch (componentType) {
      ComponentType.byte => math.max(value / 127.0, -1.0),
      ComponentType.unsignedByte => value / 255.0,
      ComponentType.short => math.max(value / 32767.0, -1.0),
      ComponentType.unsignedShort => value / 65535.0,
      ComponentType.unsignedInt || ComponentType.float => value,
    };
  }

  Iterable<num> data() sync* {
    final buffer = bufferView.get();
    final bytes = buffer.data();
    final byteData = ByteData.sublistView(bytes);
    final step = componentType.byteSize;
    for (
      var cursor = byteOffset;
      cursor + step <= bytes.lengthInBytes;
      cursor += step
    ) {
      yield componentType.parseData(byteData, cursor: cursor);
    }
  }

  List<T> _typedData<T>(
    int size,
    T Function(List<num>) producer, {
    required bool applyNormalization,
  }) {
    _verifyNotSparse();
    _verifyAccessorType(size);
    if (count == 0) {
      return <T>[];
    }

    final buffer = bufferView.get();
    final bytes = buffer.data();
    final byteData = ByteData.sublistView(bytes);
    final compBytes = componentType.byteSize;
    final elemBytes = size * compBytes;
    final strideBytes = buffer.byteStride ?? elemBytes;
    if (strideBytes <= 0) {
      throw StateError('Byte stride must be > 0');
    }
    final requiredBytes = byteOffset + (count - 1) * strideBytes + elemBytes;
    if (requiredBytes > bytes.lengthInBytes) {
      throw RangeError(
        'Accessor requires $requiredBytes bytes, bufferView has '
        '${bytes.lengthInBytes}',
      );
    }

    final scratch = List<num>.filled(size, 0);
    final result = <T>[];
    for (var elem = 0; elem < count; elem++) {
      final base = byteOffset + elem * strideBytes;
      for (var c = 0; c < size; c++) {
        final raw = componentType.parseData(
          byteData,
          cursor: base + c * compBytes,
        );
        scratch[c] = applyNormalization ? normalizeComponent(raw) : raw;
      }
      result.add(producer(scratch));
    }
    return result;
  }

  void _verifyAccessorType(int size) {
    if (type.size != size) {
      throw StateError('Accessor type mismatch: $type != $size');
    }
  }

  void _verifyNotSparse() {
    if (sparse != null) {
      throw UnsupportedError('Accessor is sparse: not supported yet.');
    }
  }

  IntAccessor asInt() => IntAccessor(root: root, accessor: this);
  FloatAccessor asFloat() => FloatAccessor(root: root, accessor: this);
  Vector2Accessor asVector2() => Vector2Accessor(root: root, accessor: this);
  Vector3Accessor asVector3() => Vector3Accessor(root: root, accessor: this);
  Vector4Accessor asVector4() => Vector4Accessor(root: root, accessor: this);
  QuaternionAccessor asQuaternion() => QuaternionAccessor(
    root: root,
    accessor: this,
  );
  Matrix4Accessor asMatrix4() => Matrix4Accessor(root: root, accessor: this);

  RawAccessor.parse(
    GltfRoot root,
    Map<String, Object?> map,
  ) : this(
        root: root,
        bufferView: Parser.ref(root, map, 'bufferView')!,
        byteOffset: Parser.integer(map, 'byteOffset') ?? 0,
        componentType: ComponentType.parse(map, 'componentType')!,
        normalized: Parser.boolean(map, 'normalized') ?? false,
        count: Parser.integer(map, 'count')!,
        type: AccessorType.parse(map, 'type')!,
        max: Parser.floatList(map, 'max'),
        min: Parser.floatList(map, 'min'),
        sparse: Parser.object(root, map, 'sparse', SparseAccessor.parse),
      );
}

abstract class TypedAccessor<T>({
  required super.root,
  required RawAccessor accessor,
}) extends GltfNode {
  final RawAccessor rawAccessor = accessor;

  List<T> typedData();

  void _checkAccessorType(AccessorType expected) {
    final type = rawAccessor.type;
    if (type != expected) {
      throw StateError('Accessor type mismatch: $type != $expected');
    }
  }
}

class IntAccessor({
  required super.root,
  required super.accessor,
}) extends TypedAccessor<int> {
  @override
  List<int> typedData() {
    _checkAccessorType(AccessorType.scalar);
    return rawAccessor._typedData(
      1,
      (list) => list[0].toInt(),
      applyNormalization: false,
    );
  }
}

class FloatAccessor({
  required super.root,
  required super.accessor,
}) extends TypedAccessor<double> {
  @override
  List<double> typedData() {
    _checkAccessorType(AccessorType.scalar);
    return rawAccessor._typedData(
      1,
      (list) => list[0].toDouble(),
      applyNormalization: true,
    );
  }
}

class Vector2Accessor({
  required super.root,
  required super.accessor,
}) extends TypedAccessor<Vector2> {
  @override
  List<Vector2> typedData() {
    _checkAccessorType(AccessorType.vec2);
    return rawAccessor._typedData(
      2,
      (values) => Vector2(values[0].toDouble(), values[1].toDouble()),
      applyNormalization: true,
    );
  }
}

class Vector3Accessor({
  required super.root,
  required super.accessor,
}) extends TypedAccessor<Vector3> {
  @override
  List<Vector3> typedData() {
    _checkAccessorType(AccessorType.vec3);
    return rawAccessor._typedData(
      3,
      (values) => Vector3(
        values[0].toDouble(),
        values[1].toDouble(),
        values[2].toDouble(),
      ),
      applyNormalization: true,
    );
  }
}

class Vector4Accessor({
  required super.root,
  required super.accessor,
}) extends TypedAccessor<Vector4> {
  @override
  List<Vector4> typedData() {
    _checkAccessorType(AccessorType.vec4);
    return rawAccessor._typedData(
      4,
      (values) => Vector4(
        values[0].toDouble(),
        values[1].toDouble(),
        values[2].toDouble(),
        values[3].toDouble(),
      ),
      applyNormalization: true,
    );
  }
}

class QuaternionAccessor({
  required super.root,
  required super.accessor,
}) extends TypedAccessor<Quaternion> {
  @override
  List<Quaternion> typedData() {
    _checkAccessorType(AccessorType.vec4);
    return rawAccessor._typedData(
      4,
      (values) => Quaternion(
        values[0].toDouble(),
        values[1].toDouble(),
        values[2].toDouble(),
        values[3].toDouble(),
      ),
      applyNormalization: true,
    );
  }
}

class Matrix4Accessor({
  required super.root,
  required super.accessor,
}) extends TypedAccessor<Matrix4> {
  @override
  List<Matrix4> typedData() {
    _checkAccessorType(AccessorType.mat4);
    return rawAccessor._typedData(
      16,
      (values) => Matrix4.fromList(Parser.coerceFloatList(values)),
      applyNormalization: true,
    );
  }
}
