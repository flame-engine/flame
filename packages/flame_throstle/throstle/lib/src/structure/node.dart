import 'package:throstle/src/structure/statement.dart';

class Node {
  Node({
    required this.title,
    required this.lines,
    this.tags,
  });

  final String title;
  final Map<String, String>? tags;
  final List<Statement> lines;

  @override
  String toString() => 'Node($title)';
}
