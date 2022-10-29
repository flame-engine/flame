import 'package:test/test.dart';
import 'package:throstle/src/errors.dart';

Matcher hasSyntaxError(String message) {
  return throwsA(
    isA<SyntaxError>().having((e) => e.toString(), 'toString', message),
  );
}
