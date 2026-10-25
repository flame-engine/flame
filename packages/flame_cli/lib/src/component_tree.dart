import 'package:flame_cli/src/game_responses.dart';

/// Formats the tree returned by the `ext.flame_devtools.getComponentTree`
/// service extension with one component per line, indented by its depth in
/// the tree, and with the attributes of the component after the id.
///
/// Children deeper than [maxDepth] levels below the root are left out.
String formatComponentTree(
  ComponentNode node, {
  int depth = 0,
  int? maxDepth,
}) {
  final buffer = StringBuffer()
    ..write('${'  ' * depth}${node.name} (id: ${node.id})');
  final attributes = formatAttributes(node.attributes);
  if (attributes.isNotEmpty) {
    buffer.write(' $attributes');
  }
  buffer.writeln();
  if (maxDepth == null || depth < maxDepth) {
    for (final child in node.children) {
      buffer.write(
        formatComponentTree(child, depth: depth + 1, maxDepth: maxDepth),
      );
    }
  }
  return buffer.toString();
}

/// Formats the attributes of a component on one line, leaving out the ones
/// that have their default value.
String formatAttributes(ComponentAttributes attributes) {
  final parts = <String>[];
  if (attributes.position case final position?) {
    parts.add('position ${_formatVector(position)}');
  }
  if (attributes.size case final size?) {
    parts.add('size ${_formatVector(size)}');
  }
  if (attributes.angle case final angle? when angle != 0) {
    parts.add('angle ${_formatNumber(angle)}');
  }
  if (attributes.scale case final scale? when scale.x != 1 || scale.y != 1) {
    parts.add('scale ${_formatVector(scale)}');
  }
  if (attributes.anchor case final anchor? when anchor != 'topLeft') {
    parts.add('anchor $anchor');
  }
  if (attributes.priority case final priority? when priority != 0) {
    parts.add('priority $priority');
  }
  return parts.join(', ');
}

/// Keeps the nodes of the tree that [matches], together with their ancestors
/// and their descendants, so that the path to every match is preserved and
/// the matches are shown in full.
///
/// Returns null if neither the node nor any of its descendants match.
ComponentNode? filterComponentTree(
  ComponentNode node,
  bool Function(ComponentNode node) matches,
) {
  if (matches(node)) {
    return node;
  }
  final children = node.children
      .map((child) => filterComponentTree(child, matches))
      .nonNulls
      .toList();
  if (children.isEmpty) {
    return null;
  }
  return node.withChildren(children);
}

String _formatVector(Vector2 vector) {
  return '${_formatNumber(vector.x)},${_formatNumber(vector.y)}';
}

String _formatNumber(num value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(2);
}
