import 'package:test/test.dart';
import 'package:throstle/src/errors.dart';

Matcher hasSyntaxError(String message) {
  return throwsA(
    isA<SyntaxError>().having((e) => e.toString(), 'toString', message),
  );
}

Matcher hasNameError(String message) {
  return throwsA(
    isA<NameError>().having((e) => e.toString(), 'toString', message),
  );
}

Matcher hasTypeError(String message) {
  return throwsA(
    isA<TypeError>().having((e) => e.toString(), 'toString', message),
  );
}
