import 'dart:convert';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';

/// The [PositionComponentAttributesConnector] is responsible for reporting and
/// changing the attributes of a [PositionComponent] from the devtools
/// extension.
///
/// The `priority` attribute can be set on any component, the other attributes
/// only on a [PositionComponent].
class PositionComponentAttributesConnector extends DevToolsConnector {
  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.getPositionComponentAttributes',
      (method, parameters) async {
        final id = int.tryParse(parameters['id'] ?? '');

        final positionComponent = findComponent<PositionComponent>(id);

        if (positionComponent != null) {
          return ServiceExtensionResponse.result(
            json.encode({
              'id': id,
              'x': positionComponent.x,
              'y': positionComponent.y,
              'width': positionComponent.width,
              'height': positionComponent.height,
              'angle': positionComponent.angle,
              'scaleX': positionComponent.scale.x,
              'scaleY': positionComponent.scale.y,
              'anchor': positionComponent.anchor.toString(),
              'priority': positionComponent.priority,
            }),
          );
        } else {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.extensionError,
            'No PositionComponent found with id: $id',
          );
        }
      },
    );

    registerExtension(
      'ext.flame_devtools.setPositionComponentAttributes',
      (method, parameters) async {
        final id = int.tryParse(parameters['id'] ?? '');
        final attribute = parameters['attribute'];
        final value = parameters['value'] ?? '';

        final component = findComponent<Component>(id);
        if (component == null) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.extensionError,
            'No component found with id: $id',
          );
        }

        try {
          if (attribute == 'priority') {
            component.priority = int.parse(value);
          } else if (component is! PositionComponent) {
            return ServiceExtensionResponse.error(
              ServiceExtensionResponse.extensionError,
              'No PositionComponent found with id: $id',
            );
          } else if (attribute == 'x') {
            component.x = double.parse(value);
          } else if (attribute == 'y') {
            component.y = double.parse(value);
          } else if (attribute == 'width') {
            component.width = double.parse(value);
          } else if (attribute == 'height') {
            component.height = double.parse(value);
          } else if (attribute == 'angle') {
            component.angle = double.parse(value);
          } else if (attribute == 'scaleX') {
            component.scale.x = double.parse(value);
          } else if (attribute == 'scaleY') {
            component.scale.y = double.parse(value);
          } else if (attribute == 'anchor') {
            component.anchor = Anchor.valueOf(value);
          } else {
            return ServiceExtensionResponse.error(
              ServiceExtensionResponse.extensionError,
              'Invalid attribute: $attribute',
            );
          }
        } on FormatException catch (error) {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.invalidParams,
            'Invalid value for $attribute: ${error.message}',
          );
        }
        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'attribute': attribute,
            'value': value,
          }),
        );
      },
    );
  }
}
