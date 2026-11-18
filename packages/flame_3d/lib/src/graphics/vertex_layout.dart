import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

/// {@template vertex_attribute}
/// One interleaved 32-bit float attribute of a [VertexLayout].
///
/// An attribute feeds the vertex shader input (`in` variable) with the same
/// [name]; its location is the one the shader compiler assigned to that input.
/// Flutter GPU binds attributes by input name, which keeps a layout valid when
/// inputs are added to or reordered in the shader.
/// {@endtemplate}
@immutable
class const VertexAttribute(
  /// The name of the vertex shader input this attribute feeds.
  final String name,

  /// The number of floats of the attribute, from 1 to 4.
  final int components,
) {
  /// {@macro vertex_attribute}
  this
    : assert(
        components >= 1 && components <= 4,
        'components must be 1 to 4',
      );

  @override
  bool operator ==(Object other) =>
      other is VertexAttribute &&
      other.name == name &&
      other.components == components;

  @override
  int get hashCode => Object.hash(name, components);

  @override
  String toString() => 'VertexAttribute($name, $components)';
}

/// {@template vertex_layout}
/// The layout of a surface's interleaved vertex data: a sequence of float
/// [attributes], packed without padding, one vertex after the other.
///
/// The [standard] layout is the one `Vertex` objects are packed into. A surface
/// may declare its own layout (see `Surface.fromBuffers`); materials draw it as
/// long as their vertex shader only declares inputs the layout provides, plus
/// the per-instance inputs flame_3d feeds itself (see [instanceAttributes]).
///
/// Layouts compare by value, so surfaces with equal layouts share pipelines.
/// {@endtemplate}
@immutable
class VertexLayout(List<VertexAttribute> attributes) {
  /// The attributes of one vertex, in storage order.
  final List<VertexAttribute> attributes = List.unmodifiable(attributes);

  final List<int> _offsets = _computeOffsets(attributes);

  /// The number of floats per vertex.
  final int strideInFloats = attributes.fold(0, (sum, a) => sum + a.components);

  /// {@macro vertex_layout}
  this {
    final names = <String>{};
    for (final attribute in attributes) {
      if (!names.add(attribute.name)) {
        throw ArgumentError('Duplicate vertex attribute "${attribute.name}"');
      }
      if (instanceAttributes.any((a) => a.name == attribute.name)) {
        throw ArgumentError(
          'Vertex attribute "${attribute.name}" is reserved for instance data',
        );
      }
    }
  }

  /// The standard 20-float layout: position (3), texture coordinates (2),
  /// color (4), normal (3), joints (4) and joint weights (4).
  static final VertexLayout standard = VertexLayout(const [
    VertexAttribute(positionAttribute, 3),
    VertexAttribute('vertexTexCoord', 2),
    VertexAttribute('vertexColor', 4),
    VertexAttribute('vertexNormal', 3),
    VertexAttribute('vertexJoints', 4),
    VertexAttribute('vertexWeights', 4),
  ]);

  /// The name of the position attribute. Surfaces compute their bounds from
  /// the attribute with this name.
  static const String positionAttribute = 'vertexPosition';

  /// The per-instance inputs flame_3d feeds from its instance buffer, in the
  /// order they are stored for each instance: the four columns of the model
  /// matrix, a color and four floats of data that materials interpret as they
  /// like (`instanceData`, zero unless the drawing component sets it).
  ///
  /// A vertex shader that declares the four model columns is drawn instanced
  /// (see `shaders/flame_3d/instancing.glsl`); one that does not gets its
  /// model matrix from uniforms, one draw per object. A shader only receives
  /// the inputs it reads.
  static const List<VertexAttribute> instanceAttributes = [
    VertexAttribute('instanceModel0', 4),
    VertexAttribute('instanceModel1', 4),
    VertexAttribute('instanceModel2', 4),
    VertexAttribute('instanceModel3', 4),
    VertexAttribute('instanceColor', 4),
    VertexAttribute('instanceData', 4),
  ];

  /// The number of floats stored per instance: a 4x4 model matrix (column
  /// major), an RGBA color and the four floats of the instance data.
  static const int instanceStrideInFloats = 24;

  /// The number of bytes per vertex.
  int get strideInBytes => strideInFloats * 4;

  /// The offset, in floats, of the attribute named [name] within a vertex, or
  /// `null` when the layout has no such attribute.
  int? offsetOf(String name) {
    for (var i = 0; i < attributes.length; i++) {
      if (attributes[i].name == name) {
        return _offsets[i];
      }
    }
    return null;
  }

  /// The attribute named [name], or `null` when the layout has none.
  VertexAttribute? attribute(String name) {
    return attributes.firstWhereOrNull((a) => a.name == name);
  }

  static List<int> _computeOffsets(List<VertexAttribute> attributes) {
    final offsets = <int>[];
    var offset = 0;
    for (final attribute in attributes) {
      offsets.add(offset);
      offset += attribute.components;
    }
    return List.unmodifiable(offsets);
  }

  static const _equality = ListEquality<VertexAttribute>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VertexLayout && _equality.equals(other.attributes, attributes);

  @override
  int get hashCode => _equality.hash(attributes);

  @override
  String toString() => 'VertexLayout($attributes)';
}
