/// Formats the tree returned by the `ext.flame_devtools.getComponentTree`
/// service extension with one component per line, indented by its depth in
/// the tree.
String formatComponentTree(Map<String, dynamic> node, [int depth = 0]) {
  final buffer = StringBuffer()
    ..writeln('${'  ' * depth}${node['name']} (id: ${node['id']})');
  for (final child in node['children'] as List) {
    buffer.write(formatComponentTree(child as Map<String, dynamic>, depth + 1));
  }
  return buffer.toString();
}
