import 'package:equatable/equatable.dart';

/// {@template component_radius}
/// The radius property shared by every round component.
/// {@endtemplate}
class const ComponentRadius({
  /// The radius.
  final double radius = defaultValue,
}) extends Equatable {
  /// {@macro component_radius}
  this;

  /// Creates a [ComponentRadius] from its JSON representation.
  ///
  /// A missing or invalid value falls back to [defaultValue].
  factory fromJson(Object? json) {
    final map = json is Map ? json : const <String, dynamic>{};
    final radius = map['radius'];
    return ComponentRadius(
      radius: radius is num && radius >= 0 ? radius.toDouble() : defaultValue,
    );
  }

  /// The default [radius], so that a default circle is as big as a default
  /// rectangle.
  static const defaultValue = 25.0;

  /// Returns a copy of this radius with the given fields replaced.
  ComponentRadius copyWith({double? radius}) {
    return ComponentRadius(radius: radius ?? this.radius);
  }

  /// Converts this radius to its JSON representation.
  Map<String, dynamic> toJson() => {'radius': radius};

  @override
  List<Object> get props => [radius];
}
