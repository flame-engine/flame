import 'dart:async';

import 'package:jenny/src/dialogue_runner.dart';
import 'package:jenny/src/structure/statement.dart';

abstract class Command extends Statement {
  const Command();

  FutureOr<void> execute(DialogueRunner dialogue);

  @override
  StatementKind get kind => StatementKind.command;
}
