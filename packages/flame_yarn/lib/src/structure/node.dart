
import 'package:flame_yarn/src/structure/statement.dart';

class Node {
  Node({
    required this.title,
    required this.lines,
    this.tags,
  });

  final String title;
  final List<String>? tags;
  final List<Statement> lines;
}
