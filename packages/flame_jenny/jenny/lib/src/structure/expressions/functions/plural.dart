import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/_common.dart';
import 'package:jenny/src/yarn_project.dart';

class PluralFn extends StringExpression {
  PluralFn(this._num, this._words, this._yarn);

  final NumExpression _num;
  final List<StringExpression> _words;
  final YarnProject _yarn;

  /// Static constructor, used by <parse.dart>.
  static Expression make(
    List<FunctionArgument> arguments,
    YarnProject yarnProject,
    ErrorFn errorFn,
  ) {
    final min = 1 + yarnProject.localization.pluralMinWordCount;
    final max = 1 + yarnProject.localization.pluralMaxWordCount;
    if (arguments.length < min) {
      errorFn('function plural() requires at least $min arguments');
    }
    if (arguments.length > max) {
      errorFn(
        'function plural() requires at most $max arguments',
        arguments[max].position,
      );
    }
    if (!arguments[0].expression.isNumeric) {
      errorFn(
        'the first argument in plural() should be numeric',
        arguments[0].position,
      );
    }
    final convertedArgs = <StringExpression>[];
    for (final argument in arguments.skip(1)) {
      if (!argument.expression.isString) {
        errorFn('a string argument is expected', argument.position);
      }
      convertedArgs.add(argument.expression as StringExpression);
    }
    return PluralFn(
      arguments[0].expression as NumExpression,
      convertedArgs,
      yarnProject,
    );
  }

  @override
  String get value {
    final value = _num.value;
    final words = _words.map((w) => w.value).toList(growable: false);
    final result = _yarn.localization.pluralFunction(value, words);
    if (result.contains('%')) {
      return result.replaceAll('%', value.toString());
    } else {
      return result;
    }
  }
}
