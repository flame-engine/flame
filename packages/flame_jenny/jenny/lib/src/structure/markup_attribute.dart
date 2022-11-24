import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:meta/meta.dart';

class MarkupAttribute {
  MarkupAttribute(
    this._name,
    int startTextPosition,
    int endTextPosition, [
    int startSubIndex = 0,
    int endSubIndex = 1,
    Map<String, Expression>? parameters,
  ])  : _startTextPosition = startTextPosition + startSubIndex * _subFactor,
        _endTextPosition = endTextPosition + endSubIndex * _subFactor,
        _start = 0,
        _end = 0,
        _parameterExpressions = parameters,
        _parameterValues = parameters == null ? null : <String, dynamic>{} {
    reset();
  }

  final String _name;
  final double _startTextPosition;
  final double _endTextPosition;
  final Map<String, Expression>? _parameterExpressions;
  final Map<String, dynamic>? _parameterValues;
  int _start;
  int _end;

  /// The name of the attribute, for example the name of markup attribute
  /// `[flame]` is "flame". This name is always a valid ID.
  String get name => _name;

  /// The range [start]..[end] represents the range of text spanned by this
  /// markup attribute.
  ///
  /// The first index is inclusive, and the second is exclusive. Thus, the
  /// marked text can be obtained as `text.substring(start, end)`. Properties
  /// [start] and [end] may change when the underlying text of changes.
  int get start => _start;
  int get end => _end;

  /// The length of the span of text covered by this markup attribute.
  int get length => end - start;

  /// The map of all parameter values of this markup attribute.
  ///
  /// These will be recalculated upon each [reset], which occurs every time the
  /// parent DialogueLine is served in the dialogue runner.
  Map<String, dynamic> get parameters =>
      _parameterValues ?? const <String, dynamic>{};

  @internal
  void reset() {
    _start = _startTextPosition.floor();
    _end = _endTextPosition.floor();
    _parameterExpressions?.forEach((key, expression) {
      _parameterValues![key] = expression.value;
    });
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
