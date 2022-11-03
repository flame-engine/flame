import 'package:jenny/src/errors.dart';
import 'package:test/test.dart';

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
