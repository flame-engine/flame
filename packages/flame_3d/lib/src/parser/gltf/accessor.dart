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
class RawAccessor extends GltfNode {
  /// The reference to the buffer view.
  /// When undefined, the accessor **MUST** be initialized with zeros; `sparse`
  /// property or extensions **MAY** override zeros with actual values.
  final GltfRef<BufferView> bufferView;

  /// The offset relative to the start of the buffer view in bytes.
  ///
  /// This **MUST** be a multiple of the size of the component datatype.
  /// This property **MUST NOT** be defined when `bufferView` is undefined.
  final int byteOffset;

  /// The datatype of the accessor's components.
  /// UNSIGNED_INT type **MUST NOT** be used for any accessor that is not
  /// referenced by `mesh.primitive.indices`.
  final ComponentType componentType;

  /// Specifies whether integer data values are normalized (`true`) to [0, 1]
  /// (for unsigned types) or to [-1, 1] (for signed types) when they are
  /// accessed.
  ///
  /// This property **MUST NOT** be set to `true` for accessors with `FLOAT` or
  /// `UNSIGNED_INT` component type.
  final bool normalized;

  /// The number of elements referenced by this accessor, not to be confused
  /// with the number of bytes or number of components.
  final int count;

  /// Specifies if the accessor's elements are scalars, vectors, or matrices.
  /// This should match the type used for a [TypedAccessor].
  final AccessorType type;

  /// Maximum value of each component in this accessor.
  /// Array elements **MUST** be treated as having the same data type as
  /// accessor's `componentType`.
  ///
  /// Both `min` and `max` arrays have the same length.
  ///
  /// The length is determined by the value of the `type` property;
  /// it can be 1, 2, 3, 4, 9, or 16.
  ///
  /// `normalized` property has no effect on array values: they always
  /// correspond to the actual values stored in the buffer.
  ///
  /// When the accessor is sparse, this property **MUST** contain maximum
  /// values of accessor data with sparse substitution applied.
  final List<double>? max;

  /// Minimum value of each component in this accessor.
  ///
  /// Array elements **MUST** be treated as having the same data type as
  /// accessor's `componentType`.
  ///
  /// Both `min` and `max` arrays have the same length.
  ///
  /// The length is determined by the value of the `type` property;
  /// it can be 1, 2, 3, 4, 9, or 16.
  ///
  /// `normalized` property has no effect on array values: they always
  /// correspond to the actual values stored in the buffer.
  ///
  /// When the accessor is sparse, this property **MUST** contain minimum
  /// values of accessor data with sparse substitution applied.
  final List<double>? min;

  /// Sparse storage of elements that deviate from their initialization value.
  final SparseAccessor? sparse;

  Iterable<num> data() sync* {
    final buffer = bufferView.get();
    final bytes = buffer.data();

    final byteData = bytes.buffer.asByteData();

    final step = componentType.byteSize;
    if ((bytes.lengthInBytes - byteOffset) % step != 0) {
      throw Exception(
        'Accessor data length ${bytes.lengthInBytes} '
        'is not a multiple of the stride $step.',
      );
    }

    for (
      var cursor = byteOffset;
      cursor < bytes.lengthInBytes;
      cursor += step
    ) {
      yield componentType.parseData(byteData, cursor: cursor);
    }
  }

  List<T> _typedData<T>(int size, T Function(List<num>) producer) {
    _verifyNotSparse();
    _verifyAccessorType(size);

    final buffer = bufferView.get();
    final view = data().toList();

    final int step;
    final byteStride = buffer.byteStride;
    if (byteStride != null) {
      step = byteStride ~/ componentType.byteSize;
    } else {
      step = size;
    }
    if (step == 0) {
      throw Exception('Step cannot be 0');
    }
    if (view.length % step != 0) {
      throw Exception(
        'Accessor data length ${view.length}'
        ' is not a multiple of the step $step',
      );
    }

    final result = <T>[];
    for (var i = 0; i < view.length; i += step) {
      result.add(producer(view.sublist(i, i + size)));
      if (result.length == count) {
        break;
      }
    }
    return result;
  }

  void _verifyAccessorType(int size) {
    if (type.size != size) {
      throw Exception('Accessor type mismatch: $type != $size');
    }
  }

  void _verifyNotSparse() {
    if (sparse != null) {
      throw Exception('Accessor is sparse: not supported yet.');
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

  RawAccessor({
    required super.root,
    required this.bufferView,
    required this.byteOffset,
    required this.componentType,
    required this.normalized,
    required this.count,
    required this.type,
    required this.max,
    required this.min,
    required this.sparse,
  });

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

abstract class TypedAccessor<T> extends GltfNode {
  final RawAccessor rawAccessor;

  TypedAccessor({
    required super.root,
    required RawAccessor accessor,
  }) : rawAccessor = accessor;

  List<T> typedData();

  void _checkAccessorType(AccessorType expected) {
    final type = rawAccessor.type;
    if (type != expected) {
      throw Exception('Accessor type mismatch: $type != $expected');
    }
  }
}

class IntAccessor extends TypedAccessor<int> {
  IntAccessor({
    required super.root,
    required super.accessor,
  });

  @override
  List<int> typedData() {
    _checkAccessorType(AccessorType.scalar);
    return rawAccessor._typedData(1, (list) => list[0].toInt());
  }
}

class FloatAccessor extends TypedAccessor<double> {
  FloatAccessor({
    required super.root,
    required super.accessor,
  });

  @override
  List<double> typedData() {
    _checkAccessorType(AccessorType.scalar);
    return rawAccessor._typedData(1, (list) => list[0].toDouble());
  }
}

class Vector2Accessor extends TypedAccessor<Vector2> {
  Vector2Accessor({
    required super.root,
    required super.accessor,
  });

  @override
  List<Vector2> typedData() {
    _checkAccessorType(AccessorType.vec2);
    return rawAccessor._typedData(2, (values) {
      final doubles = Parser.coerceFloatList(values);
      return Vector2.array(doubles);
    });
  }
}

class Vector3Accessor extends TypedAccessor<Vector3> {
  Vector3Accessor({
    required super.root,
    required super.accessor,
  });

  @override
  List<Vector3> typedData() {
    _checkAccessorType(AccessorType.vec3);
    return rawAccessor._typedData(3, (values) {
      final doubles = Parser.coerceFloatList(values);
      return Vector3.array(doubles);
    });
  }
}

class Vector4Accessor extends TypedAccessor<Vector4> {
  Vector4Accessor({
    required super.root,
    required super.accessor,
  });

  @override
  List<Vector4> typedData() {
    _checkAccessorType(AccessorType.vec4);
    return rawAccessor._typedData(4, (values) {
      final doubles = Parser.coerceFloatList(values);
      return Vector4.array(doubles);
    });
  }
}

class QuaternionAccessor extends TypedAccessor<Quaternion> {
  QuaternionAccessor({
    required super.root,
    required super.accessor,
  });

  @override
  List<Quaternion> typedData() {
    _checkAccessorType(AccessorType.vec4);
    return rawAccessor._typedData(4, (values) {
      final doubles = Parser.coerceFloatList(values);
      return Quaternion(doubles[0], doubles[1], doubles[2], doubles[3]);
    });
  }
}

class Matrix4Accessor extends TypedAccessor<Matrix4> {
  Matrix4Accessor({
    required super.root,
    required super.accessor,
  });

  @override
  List<Matrix4> typedData() {
    _checkAccessorType(AccessorType.mat4);
    return rawAccessor._typedData(16, (values) {
      final doubles = Parser.coerceFloatList(values);
      return Matrix4.fromList(doubles);
    });
  }
}
