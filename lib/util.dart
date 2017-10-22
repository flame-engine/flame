import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'dart:async';
import 'dart:ui';

class Util {
  Future<Size> initialDimensions() async {
    // https://github.com/flutter/flutter/issues/5259
    // "In release mode we start off at 0x0 but we don't in debug mode"
    return await new Future<Size>(() {
      if (window.physicalSize.isEmpty) {
        var completer = new Completer<Size>();
        window.onMetricsChanged = () {
          if (!window.physicalSize.isEmpty) {
            completer.complete(window.physicalSize);
          }
        };
        return completer.future;
      }
      return window.physicalSize;
    });
  }

  void enableEvents() {
    new CustomBinder();
  }
}

class CustomBinder extends BindingBase with ServicesBinding {
}
