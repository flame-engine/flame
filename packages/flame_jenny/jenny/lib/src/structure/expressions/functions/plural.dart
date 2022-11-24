import 'package:jenny/src/parse/parse.dart';
import 'package:jenny/src/structure/expressions/expression.dart';
import 'package:jenny/src/structure/expressions/functions/functions.dart';

class PluralFn extends StringExpression {
  PluralFn(this._num, this._words);

  final NumExpression _num;
  final List<StringExpression> _words;

  static Expression make(List<FunctionArgument> arguments, ErrorFn errorFn) {
    const min = 1 + 1;
    const max = 1 + 2;
    if (arguments.length < min) {
      errorFn('function plural() requires at least $min arguments');
    }
    if (arguments.length > max) {
      errorFn('function plural() requires at most $max arguments');
    }
    if (!arguments[0].expression.isNumeric) {
      errorFn(
        'first argument in plural() must be numeric',
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
    return PluralFn(arguments[0].expression as NumExpression, convertedArgs);
  }

  @override
  String get value {
    final value = _num.value.round();
    final n = value.abs();
    final words = _words.map((w) => w.value).toList(growable: false);
    final result = _pluralEn(n, words);
    if (result.contains('%')) {
      return result.replaceAll('%', value.toString());
    } else {
      return result;
    }
  }
}

String _pluralEn(int n, List<String> words) {
  assert(words.isNotEmpty);
  final singular = words[0];
  if (n % 10 == 1 && n % 100 != 11) {
    return singular;
  }
  if (words.length == 2) {
    return words[1];
  }
  final ch1 = singular.isNotEmpty ? singular[singular.length - 1] : '';
  final ch2 = singular.length >= 2 ? singular[singular.length - 2] : '';
  if ((ch2 == 's' && ch1 == 's') ||
      (ch2 == 'c' && ch1 == 'h') ||
      (ch2 == 's' && ch1 == 'h') ||
      ch1 == 'x') {
    return '${singular}es';
  }
  return '${singular}s';
}
