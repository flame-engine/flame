import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/src/devtools/dev_tools_connector.dart';

class ComponentSnapshotConnector extends DevToolsConnector {
  @override
  void init() {
    registerExtension(
      'ext.flame_devtools.getComponentSnapshot',
      (method, parameters) async {
        Image? image;
        final id = int.tryParse(parameters['id'] ?? '');
        game.propagateToChildren<Component>(
          (c) {
            if (c.hashCode == id) {
              final pictureRecorder = PictureRecorder();

              final canvas = Canvas(pictureRecorder);

              c.render(canvas);

              final picture = pictureRecorder.endRecording();

              var width = 100;
              var height = 100;

              if (c is PositionComponent) {
                width = c.width.toInt();
                height = c.height.toInt();
              }

              image = picture.toImageSync(width, height);

              return false;
            }
            return true;
          },
        );

        if (image != null) {
          final byteData = await image!.toByteData(format: ImageByteFormat.png);
          final buffer = byteData!.buffer.asUint8List();
          final snapshot = base64Encode(buffer);
          return ServiceExtensionResponse.result(
            json.encode({
              'id': id,
              'snapshot': snapshot,
            }),
          );
        }

        return ServiceExtensionResponse.result(
          json.encode({
            'id': id,
            'snapshot': '',
          }),
        );
      },
    );
  }
}
