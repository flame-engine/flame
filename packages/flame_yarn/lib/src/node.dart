
class Node {
  Node({
    required this.title,
    required this.lines,
    this.tags,
  });

  final String title;
  final List<String>? tags;
  final List<Entry> lines;
}

class Entry {}
