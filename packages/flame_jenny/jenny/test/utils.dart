import 'package:jenny/jenny.dart';
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

Matcher hasDialogueError(String message) {
  return throwsA(
    isA<DialogueError>()
        .having((e) => e.toString(), 'toString', 'DialogueError: $message'),
  );
}

Matcher throwsAssertionError(String message) {
  return throwsA(
    isA<AssertionError>().having((e) => e.message, 'message', message),
  );
}
