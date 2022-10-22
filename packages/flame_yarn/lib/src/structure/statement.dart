abstract class Statement {
  const Statement();

  StatementKind get kind;
}

enum StatementKind {
  line,
  choice,
  command,
}
