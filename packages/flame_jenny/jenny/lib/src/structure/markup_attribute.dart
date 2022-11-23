import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:meta/meta.dart';

class MarkupAttribute {
  MarkupAttribute(
    this._name,
    int startTextPosition,
    int endTextPosition, [
    int startSubIndex = 0,
    int endSubIndex = 1,
    this.parameters,
  ])  : _startTextPosition = startTextPosition + startSubIndex * _subFactor,
        _endTextPosition = endTextPosition + endSubIndex * _subFactor,
        _start = startTextPosition,
        _end = endTextPosition;

  final String _name;
  final double _startTextPosition;
  final double _endTextPosition;
  final Map<String, Expression>? parameters;
  int _start;
  int _end;

  /// The name of the attribute, for example the name of markup attribute
  /// `[flame]` is "flame". This name is always a valid ID.
  String get name => _name;

  int get start => _start;

  int get end => _end;

  /// The length of the span of text covered by this markup attribute.
  int get length => end - start;

  @internal
  void reset() {
    _start = _startTextPosition.floor();
    _end = _endTextPosition.floor();
  }

  @internal
  void maybeShift(int position, int length, int subIndex) {
    final fractionalPosition = position + subIndex * _subFactor;
    if (_startTextPosition > fractionalPosition) {
      _start += length;
    }
    if (_endTextPosition > fractionalPosition) {
      _end += length;
    }
  }

  /// Used for calculating fractional text positions.
  static const double _subFactor = 1.0 / 1024;
}
