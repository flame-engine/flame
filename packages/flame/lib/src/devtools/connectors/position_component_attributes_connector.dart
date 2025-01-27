import 'dart:convert';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';

class PositionComponentAttributesConnector extends DevToolsConnector {
  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.getPositionComponentAttributes',
      (method, parameters) async {
        final id = int.tryParse(parameters['id'] ?? '');

        final positionComponent = findComponent<PositionedComponent>(id);

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
            }),
          );
        } else {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.extensionError,
            'No PositionedComponent found with id: $id',
          );
        }
      },
    );

    registerExtension(
      'ext.flame_devtools.setPositionComponentAttributes',
      (method, parameters) async {
        final id = int.tryParse(parameters['id'] ?? '');
        final attribute = parameters['attribute'];

        final positionComponent = findComponent<PositionedComponent>(id);

        if (positionComponent != null) {
          if (attribute == 'x') {
            positionComponent.x = double.parse(parameters['value']!);
          } else if (attribute == 'y') {
            positionComponent.y = double.parse(parameters['value']!);
          } else if (attribute == 'width') {
            positionComponent.width = double.parse(parameters['value']!);
          } else if (attribute == 'height') {
            positionComponent.height = double.parse(parameters['value']!);
          } else if (attribute == 'angle') {
            positionComponent.angle = double.parse(parameters['value']!);
          } else if (attribute == 'scaleX') {
            positionComponent.scale.x = double.parse(parameters['value']!);
          } else if (attribute == 'scaleY') {
            positionComponent.scale.y = double.parse(parameters['value']!);
          } else {
            return ServiceExtensionResponse.error(
              ServiceExtensionResponse.extensionError,
              'Invalid attribute: $attribute',
            );
          }
          return ServiceExtensionResponse.result('Success');
        } else {
          return ServiceExtensionResponse.error(
            ServiceExtensionResponse.extensionError,
            'No PositionedComponent found with id: $id',
          );
        }
      },
    );
  }
}
