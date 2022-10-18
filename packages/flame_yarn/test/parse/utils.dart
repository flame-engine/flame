import 'package:flame_yarn/src/errors.dart';
import 'package:test/test.dart';

Matcher hasSyntaxError(String message) {
  return throwsA(
    isA<SyntaxError>().having((e) => e.toString(), 'toString', message),
  );
}
