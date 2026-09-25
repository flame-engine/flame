import 'dart:convert';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/src/devtools/component_attributes.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [ComponentTreeConnector] is responsible for reporting the component
/// tree of the game, and information about single components, to the devtools
/// extension.
class ComponentTreeConnector extends DevToolsConnector {
  @override
  void init() {
    // Get the component tree of the game.
    registerExtension(
      'ext.flame_devtools.getComponentTree',
      (method, parameters) async {
        final componentTree = ComponentTreeNode.fromComponent(game);

        return ServiceExtensionResponse.result(
          json.encode({
            'component_tree': componentTree.toJson(),
          }),
        );
      },
    );

    // Get information about a single component in the tree.
    registerExtension(
      'ext.flame_devtools.getComponentInfo',
      (method, parameters) async {
        final id = int.tryParse(parameters['id'] ?? '');
        final component = findComponent<Component>(id);
        if (component == null) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            'No component with the id ${parameters['id']} was found.',
          );
        }

        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'name': component.runtimeType.toString(),
            'toString': component.toString(),
            'parent': component.parent?.hashCode,
            'childCount': component.children.length,
            'debugMode': component.debugMode,
            'attributes': componentAttributes(component),
          }),
        );
      },
    );
  }
}

/// This should only be used internally by the devtools extension.
class ComponentTreeNode {
  final int id;
  final String name;
  final String toStringText;
  final bool isPositionComponent;
  final Map<String, dynamic> attributes;
  final List<ComponentTreeNode> children;

  ComponentTreeNode(
    this.id,
    this.name,
    this.toStringText,
    // ignore: avoid_positional_boolean_parameters
    this.isPositionComponent,
    this.children, {
    this.attributes = const {},
  });

  ComponentTreeNode.fromComponent(Component component)
    : this(
        component.hashCode,
        component.runtimeType.toString(),
        component.toString(),
        component is PositionComponent,
        component.children.map(ComponentTreeNode.fromComponent).toList(),
        attributes: componentAttributes(component),
      );

  ComponentTreeNode.fromJson(Map<String, dynamic> json)
    : this(
        json['id'] as int,
        json['name'] as String,
        json['toString'] as String,
        json['isPositionComponent'] as bool,
        (json['children'] as List)
            .map((e) => ComponentTreeNode.fromJson(e as Map<String, dynamic>))
            .toList(),
        attributes: (json['attributes'] as Map<String, dynamic>?) ?? const {},
      );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'toString': toStringText,
      'isPositionComponent': isPositionComponent,
      'attributes': attributes,
      'children': children.map((e) => e.toJson()).toList(),
    };
  }
}
