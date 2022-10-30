import 'package:flutter/material.dart';
import 'package:oxygen/oxygen.dart';

class TextInit {
  final String text;

  TextStyle? style;

  TextInit(
    this.text, {
    this.style,
  });
}

class TextComponent extends Component<TextInit> {
  late String text;

  late TextStyle style;

  @override
  void init([TextInit? initValue]) {
    style = initValue?.style ?? const TextStyle();
    text = initValue?.text ?? '';
  }

  @override
  void reset() {
    style = const TextStyle();
    text = '';
  }
}
