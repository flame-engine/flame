/// Formats the tree returned by the `ext.flame_devtools.getComponentTree`
/// service extension with one component per line, indented by its depth in
/// the tree, and with the attributes of the component after the id.
///
/// Children deeper than [maxDepth] levels below the root are left out.
String formatComponentTree(
  Map<String, dynamic> node, {
  int depth = 0,
  int? maxDepth,
}) {
  final buffer = StringBuffer()
    ..write('${'  ' * depth}${node['name']} (id: ${node['id']})');
  final attributes = formatAttributes(
    (node['attributes'] as Map<String, dynamic>?) ?? const {},
  );
  if (attributes.isNotEmpty) {
    buffer.write(' $attributes');
  }
  buffer.writeln();
  if (maxDepth == null || depth < maxDepth) {
    for (final child in node['children'] as List) {
      buffer.write(
        formatComponentTree(
          child as Map<String, dynamic>,
          depth: depth + 1,
          maxDepth: maxDepth,
        ),
      );
    }
  }
  return buffer.toString();
}

/// Formats the attributes of a component on one line, leaving out the ones
/// that have their default value.
String formatAttributes(Map<String, dynamic> attributes) {
  final parts = <String>[];
  final position = attributes['position'] as List?;
  if (position != null) {
    parts.add('position ${_formatVector(position)}');
  }
  final size = attributes['size'] as List?;
  if (size != null) {
    parts.add('size ${_formatVector(size)}');
  }
  final angle = attributes['angle'] as num?;
  if (angle != null && angle != 0) {
    parts.add('angle ${_formatNumber(angle)}');
  }
  final scale = attributes['scale'] as List?;
  if (scale != null && (scale[0] != 1 || scale[1] != 1)) {
    parts.add('scale ${_formatVector(scale)}');
  }
  final anchor = attributes['anchor'] as String?;
  if (anchor != null && anchor != 'topLeft') {
    parts.add('anchor $anchor');
  }
  final priority = attributes['priority'] as num?;
  if (priority != null && priority != 0) {
    parts.add('priority $priority');
  }
  return parts.join(', ');
}

/// Keeps the nodes of the tree that [matches], together with their ancestors
/// and their descendants, so that the path to every match is preserved and
/// the matches are shown in full.
///
/// Returns null if neither the node nor any of its descendants match.
Map<String, dynamic>? filterComponentTree(
  Map<String, dynamic> node,
  bool Function(Map<String, dynamic> node) matches,
) {
  if (matches(node)) {
    return node;
  }
  final children = (node['children'] as List)
      .map(
        (child) => filterComponentTree(child as Map<String, dynamic>, matches),
      )
      .nonNulls
      .toList();
  if (children.isEmpty) {
    return null;
  }
  return {...node, 'children': children};
}

String _formatVector(List<dynamic> values) {
  return values.map((value) => _formatNumber(value as num)).join(',');
}

String _formatNumber(num value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}
