import 'dart:math' as math;

import 'package:equatable/equatable.dart';

/// {@template component_angle}
/// The angle property shared by every position based component.
///
/// Mirrors Flame's `angle`: the rotation of the component around its
/// anchor, in radians, clockwise. The editor shows it in [degrees].
/// {@endtemplate}
class const ComponentAngle({
  /// The angle, in radians.
  final double radians = 0,
}) extends Equatable {
  /// {@macro component_angle}
  this;

  /// Creates a [ComponentAngle] of [degrees].
  factory fromDegrees(double degrees) {
    return ComponentAngle(radians: degrees * math.pi / 180);
  }

  /// Creates a [ComponentAngle] from its JSON representation.
  ///
  /// A missing or invalid value falls back to `0`, so components saved
  /// without an angle are not rotated.
  factory fromJson(Object? json) {
    final map = json is Map ? json : const <String, dynamic>{};
    final radians = map['radians'];
    return ComponentAngle(radians: radians is num ? radians.toDouble() : 0);
  }

  /// No rotation, Flame's default angle.
  static const zero = ComponentAngle();

  /// The angle, in degrees.
  double get degrees => radians * 180 / math.pi;

  /// Returns a copy of this angle with the given fields replaced.
  ComponentAngle copyWith({double? radians}) {
    return ComponentAngle(radians: radians ?? this.radians);
  }

  /// Converts this angle to its JSON representation.
  Map<String, dynamic> toJson() => {'radians': radians};

  @override
  List<Object> get props => [radians];
}
