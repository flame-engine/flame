import 'package:flame_yarn/src/structure/commands/command.dart';
import 'package:flame_yarn/src/structure/dialogue_choice.dart';
import 'package:flame_yarn/src/structure/dialogue_line.dart';

/// Base class for all entries in a dialogue, where "entry" is a unit of
/// processing in a dialogue. There are 3 [kind]s of [Statement]s:
/// - [DialogueLine]
/// - [DialogueChoice]
/// - [Command]
abstract class Statement {
  const Statement();

  /// The type of this dialogue entry, corresponds to the derived class:
  /// - [DialogueLine] -> [StatementKind.line]
  /// - [DialogueChoice] -> [StatementKind.choice]
  /// - [Command] -> [StatementKind.command]
  StatementKind get kind;
}

enum StatementKind {
  line,
  choice,
  command,
}
