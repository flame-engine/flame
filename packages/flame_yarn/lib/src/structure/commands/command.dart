import 'dart:async';

import 'package:flame_yarn/src/runner/dialogue_runner.dart';
import 'package:flame_yarn/src/structure/statement.dart';

abstract class Command extends Statement {
  const Command();

  FutureOr<void> execute(DialogueRunner dialogue);

  @override
  StatementKind get kind => StatementKind.command;
}
