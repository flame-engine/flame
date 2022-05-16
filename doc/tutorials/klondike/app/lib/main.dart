import 'dart:html'; // ignore: avoid_web_libraries_in_flutter
import 'package:flutter/widgets.dart';
import 'package:klondike/step2/main.dart' as step2;
import 'package:klondike/step3/main.dart' as step3;

void main() {
  var page = window.location.search ?? '';
  if (page.startsWith('?')) {
    page = page.substring(1);
  }
  switch (page) {
    case 'step2':
      step2.main();
      break;

    case 'step3':
      step3.main();
      break;

    default:
      runApp(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text('Error: unknown page name "$page"'),
        ),
      );
  }
}
