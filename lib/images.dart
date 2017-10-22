import 'package:flutter/services.dart' show rootBundle;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:async';

class Images {

  Future<Image> load(String name) async {
    ByteData data = await rootBundle.load('assets/images/' + name);
    Uint8List bytes = new Uint8List.view(data.buffer);
    Completer<Image> completer = new Completer();
    decodeImageFromList(bytes, (image) {
      completer.complete(image);
    });
    return completer.future;
  }
}