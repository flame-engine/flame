import 'dart:html'; // ignore: avoid_web_libraries_in_flutter
import 'package:flutter/widgets.dart';
import 'step2/main.dart' as step2;

void main() {
  var page = window.location.search ?? '';
  if (page.startsWith('?')) {
    page = page.substring(1);
  }
  switch (page) {
    case 'step2':
      step2.main();
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
